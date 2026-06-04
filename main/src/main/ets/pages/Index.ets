import { preferences } from '@kit.ArkData';
import { picker, fileIo, fileUri } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { util } from '@kit.ArkTS';
import { zlib } from '@kit.BasicServicesKit';
import { promptAction, LengthMetrics } from '@kit.ArkUI';
import { ExcludedRange } from '../model/ExcludedRange';
import { DailyPunchRecord } from '../model/DailyPunchRecord';
import { CalendarSlot } from '../model/CalendarSlot';
import { SummaryItem } from '../model/SummaryItem';
import { TimeUtils } from '../service/TimeUtils';
import { StorageService, PersistState } from '../service/StorageService';
import { PunchCalculator } from '../service/PunchCalculator';
import { IndexCalendarService } from '../service/IndexCalendarService';
import { DEFAULT_RANGE_END, DEFAULT_RANGE_START, DEFAULT_TARGET_HOURS, DEFAULT_WORKDAY_START, HOLIDAYS_2026, WEEKDAY_NAMES } from '../constants/IndexConstants';
import { SettingsHeader } from '../components/index/SettingsHeader';
import { WorkdayStartCard } from '../components/index/WorkdayStartCard';
import { ExcludedRangesCard } from '../components/index/ExcludedRangesCard';
import { TargetHoursCard } from '../components/index/TargetHoursCard';
import { DarkModeCard } from '../components/index/DarkModeCard';
import { DataManagementCard } from '../components/index/DataManagementCard';
import { MainHeader } from '../components/index/MainHeader';
import { PunchCardSection } from '../components/index/PunchCardSection';
import { SummaryCardsSection } from '../components/index/SummaryCardsSection';
import { CalendarCard } from '../components/index/CalendarCard';
import { ExpandedCalendarPanel } from '../components/index/ExpandedCalendarPanel';
import { RangeEditDialog } from '../components/dialogs/RangeEditDialog';
import { RangeConflictDialog } from '../components/dialogs/RangeConflictDialog';
import { CustomTimePickerDialog } from './CustomTimePickerDialog';

@Entry
@Component
struct Index {
  @State selectedDateKey: string = '';
  @State calendarExpanded: boolean = false;
  @State showSettingsPage: boolean = false;
  @State displayYear: number = 0;
  @State displayMonth: number = 0;
  @State targetAverageHours: number = DEFAULT_TARGET_HOURS;
  @State workdayStartTime: string = DEFAULT_WORKDAY_START;
  @State excludedRanges: ExcludedRange[] = [];
  @State records: DailyPunchRecord[] = [];
  @State showRangeDialog: boolean = false;
  @State showRangeConflictDialog: boolean = false;
  @State rangeStartInput: string = DEFAULT_RANGE_START;
  @State rangeEndInput: string = DEFAULT_RANGE_END;
  @State settingsTouchStartX: number = 0;
  @State punchCardScale: number = 1;
  @State punchButtonGlow: number = 0;
  @State todayButtonScale: number = 1;
  @State darkModeEnabled: boolean = false;
  @State calendarWeekOffset: number = 0;
  @State monthContentKey: number = 0;
  @State weekContentKey: number = 0;
  @State rangeDialogKey: number = 0;
  @State confirmDeleteIndex: number = -1;
  // 当前编辑的排除时段索引（-1 表示新增模式）
  @State editRangeIndex: number = -1;
  // summary 刷新触发器 - 在影响平均工时的操作后自增，强制 ForEach 重建 summary 卡片
  @State summaryRefreshKey: number = 0;

  // 自定义时间选择弹窗控制器（用于打卡时间编辑）
  private timePickerController: CustomDialogController | null = null;
  // 自定义时间选择弹窗控制器（用于排除时段选择）
  private rangeTimePickerController: CustomDialogController | null = null;
  // 自定义时间选择弹窗控制器（用于上班时间设置）
  private workdayStartPickerController: CustomDialogController | null = null;

  private pref: preferences.Preferences | null = null;
  private readonly prefName: string = 'working_time_record';
  private readonly prefSelectedDateKey: string = 'selected_date_key';
  private readonly prefDisplayMonth: string = 'display_month';
  private readonly prefTargetHours: string = 'target_hours';
  private readonly prefWorkdayStartTime: string = 'workday_start_time';
  private readonly prefExcludedRanges: string = 'excluded_ranges';
  private readonly prefRecords: string = 'records';

  aboutToAppear(): void {
    this.initializeData();
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      this.buildMainPage();

      if (this.showSettingsPage) {
        this.buildSettingsPage();
      }

      if (this.calendarExpanded) {
        this.buildExpandedCalendarOverlay();
      }

      this.buildDialogs();
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 180,
      colors: this.darkModeEnabled ? [['#1A1F2E', 0.0], ['#242B3D', 1.0]] : [['#F9FBFF', 0.0], ['#F2F5FB', 1.0]]
    })
    .animation({ duration: 220, curve: Curve.EaseInOut })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .safeAreaPadding({
      top: new LengthMetrics(0),
      bottom: new LengthMetrics(0)
    });
  }

  @Builder
  buildDialogs() {
    if (this.showRangeDialog) {
      RangeEditDialog({
        darkModeEnabled: this.darkModeEnabled,
        editRangeIndex: this.editRangeIndex,
        rangeStartInput: this.rangeStartInput,
        rangeEndInput: this.rangeEndInput,
        onCancel: (): void => {
          this.showRangeDialog = false;
          this.editRangeIndex = -1;
        },
        onConfirm: (): void => {
          this.confirmAddRange();
        },
        onPickStart: (): void => {
          this.openRangeTimePicker(true);
        },
        onPickEnd: (): void => {
          this.openRangeTimePicker(false);
        }
      });
    }

    if (this.showRangeConflictDialog) {
      RangeConflictDialog({
        darkModeEnabled: this.darkModeEnabled,
        onClose: (): void => {
          this.showRangeConflictDialog = false;
        },
        onConfirm: (): void => {
          this.showRangeConflictDialog = false;
        }
      });
    }
  }

  @Builder
  buildMainPage() {
    Column() {
      this.buildMainHeader();

      Scroll() {
        Column({ space: 16 }) {
          this.buildCalendarCard();
          this.buildPunchCard();
          this.buildSummaryCards();
        }
        .padding({ left: 16, right: 16, top: 16, bottom: 28 })
        .width('100%');
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .width('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 48 });
  }

  @Builder
  buildMainHeader() {
    MainHeader({
      darkModeEnabled: this.darkModeEnabled,
      selectedDateKey: this.selectedDateKey,
      onOpenSettings: (): void => {
        this.showSettingsPage = true;
      }
    });
  }

  @Builder
  buildSettingsPage() {
    Column({ space: 16 }) {
      SettingsHeader({
        darkModeEnabled: this.darkModeEnabled,
        onBack: (): void => {
          this.showSettingsPage = false;
          this.summaryRefreshKey++;
          this.confirmDeleteIndex = -1;
        }
      });

      Scroll() {
        Column({ space: 16 }) {
          WorkdayStartCard({
            darkModeEnabled: this.darkModeEnabled,
            workdayStartTime: this.workdayStartTime,
            onOpenPicker: (): void => {
              this.openWorkdayStartTimePicker();
            }
          });
          ExcludedRangesCard({
            darkModeEnabled: this.darkModeEnabled,
            excludedRanges: this.excludedRanges,
            confirmDeleteIndex: this.confirmDeleteIndex,
            onAdd: (): void => {
              this.rangeStartInput = DEFAULT_RANGE_START;
              this.rangeEndInput = DEFAULT_RANGE_END;
              this.editRangeIndex = -1;
              this.rangeDialogKey++;
              this.showRangeDialog = true;
              this.confirmDeleteIndex = -1;
            },
            onConfirmDelete: (index: number): void => {
              this.removeRange(index);
              this.confirmDeleteIndex = -1;
            },
            onRequestDelete: (index: number): void => {
              this.confirmDeleteIndex = index;
            },
            onEdit: (index: number, range: ExcludedRange): void => {
              this.rangeStartInput = range.start;
              this.rangeEndInput = range.end;
              this.editRangeIndex = index;
              this.rangeDialogKey++;
              this.showRangeDialog = true;
            },
            onResetDeleteConfirm: (): void => {
              this.getUIContext().animateTo({ duration: 200, curve: Curve.EaseInOut }, () => {
                this.confirmDeleteIndex = -1;
              });
            }
          });
          TargetHoursCard({
            darkModeEnabled: this.darkModeEnabled,
            targetAverageHours: this.targetAverageHours,
            onChange: (value: number): void => {
              this.targetAverageHours = Math.round(value * 10) / 10;
              this.summaryRefreshKey++;
              this.persistState();
            }
          });
          DarkModeCard({
            darkModeEnabled: this.darkModeEnabled,
            onToggle: (isOn: boolean): void => {
              this.darkModeEnabled = isOn;
              this.persistState();
            }
          });
          DataManagementCard({
            darkModeEnabled: this.darkModeEnabled,
            onExport: (): void => {
              this.exportRecordsToCsv();
            },
            onImport: (): void => {
              this.importRecordsFromCsv();
            },
            onClear: (): void => {
              this.confirmClearAllRecords();
            }
          });
        }
        .padding({ left: 16, right: 16, top: 20, bottom: 28 })
        .width('100%')
        .alignItems(HorizontalAlign.Start);
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .width('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM]);
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 48 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.darkModeEnabled ? '#1A1F2E' : '#F9FBFF')
    .animation({ duration: 220, curve: Curve.EaseInOut })
    .transition(TransitionEffect.translate({ x: 280, y: 0 }).combine(TransitionEffect.OPACITY).animation({ duration: 280, curve: Curve.EaseInOut }))
    .gesture(
      PanGesture({ direction: PanDirection.Horizontal })
        .onActionStart((event: GestureEvent) => {
          this.settingsTouchStartX = event.offsetX;
        })
        .onActionEnd((event: GestureEvent) => {
          let offsetX: number = event.offsetX - this.settingsTouchStartX;
          if (offsetX > 80 || offsetX < -80) {
            this.showSettingsPage = false;
            this.summaryRefreshKey++;
            this.confirmDeleteIndex = -1;
          }
        })
    )
    .onClick(() => {
      if (this.confirmDeleteIndex >= 0) {
        this.getUIContext().animateTo({ duration: 200, curve: Curve.EaseInOut }, () => {
          this.confirmDeleteIndex = -1;
        });
      }
    });
  }

  @Builder
  buildSettingsHeader() {
    SettingsHeader({
      darkModeEnabled: this.darkModeEnabled,
      onBack: (): void => {
        this.showSettingsPage = false;
        this.summaryRefreshKey++;
        this.confirmDeleteIndex = -1;
      }
    });
  }

  @Builder
  buildExcludedRangesCard() {
    ExcludedRangesCard({
      darkModeEnabled: this.darkModeEnabled,
      excludedRanges: this.excludedRanges,
      confirmDeleteIndex: this.confirmDeleteIndex,
      onAdd: (): void => {
        this.rangeStartInput = DEFAULT_RANGE_START;
        this.rangeEndInput = DEFAULT_RANGE_END;
        this.editRangeIndex = -1;
        this.rangeDialogKey++;
        this.showRangeDialog = true;
        this.confirmDeleteIndex = -1;
      },
      onConfirmDelete: (index: number): void => {
        this.removeRange(index);
        this.confirmDeleteIndex = -1;
      },
      onRequestDelete: (index: number): void => {
        this.confirmDeleteIndex = index;
      },
      onEdit: (index: number, range: ExcludedRange): void => {
        this.rangeStartInput = range.start;
        this.rangeEndInput = range.end;
        this.editRangeIndex = index;
        this.rangeDialogKey++;
        this.showRangeDialog = true;
      },
      onResetDeleteConfirm: (): void => {
        this.getUIContext().animateTo({ duration: 200, curve: Curve.EaseInOut }, () => {
          this.confirmDeleteIndex = -1;
        });
      }
    });
  }

  @Builder
  buildTargetHoursCard() {
    TargetHoursCard({
      darkModeEnabled: this.darkModeEnabled,
      targetAverageHours: this.targetAverageHours,
      onChange: (value: number): void => {
        this.targetAverageHours = Math.round(value * 10) / 10;
        this.summaryRefreshKey++;
        this.persistState();
      }
    });
  }

  @Builder
  buildSettingsWorkdayStartCard() {
    WorkdayStartCard({
      darkModeEnabled: this.darkModeEnabled,
      workdayStartTime: this.workdayStartTime,
      onOpenPicker: (): void => {
        this.openWorkdayStartTimePicker();
      }
    });
  }

  @Builder
  buildDarkModeCard() {
    DarkModeCard({
      darkModeEnabled: this.darkModeEnabled,
      onToggle: (isOn: boolean): void => {
        this.darkModeEnabled = isOn;
        this.persistState();
      }
    });
  }

  @Builder
  buildDataManagementCard() {
    DataManagementCard({
      darkModeEnabled: this.darkModeEnabled,
      onExport: (): void => {
        this.exportRecordsToCsv();
      },
      onImport: (): void => {
        this.importRecordsFromCsv();
      },
      onClear: (): void => {
        this.confirmClearAllRecords();
      }
    });
  }

  @Builder
  buildCalendarCard() {
    CalendarCard({
      darkModeEnabled: this.darkModeEnabled,
      displayYear: this.displayYear,
      displayMonth: this.displayMonth,
      selectedDateKey: this.selectedDateKey,
      todayButtonScale: this.todayButtonScale,
      weekContentKey: this.weekContentKey,
      weekSlots: this.getCurrentWeekSlots(),
      onOpen: (): void => {
        this.calendarExpanded = true;
      },
      onTodayTap: (): void => {
        this.playTodayButtonAnimation();
        this.jumpToToday();
      },
      onSwipe: (offsetX: number): void => {
        this.handleCalendarSwipe(offsetX);
      },
      onSelectDate: (dateKey: string, collapseAfterSelect: boolean): void => {
        this.selectCalendarDate(dateKey, collapseAfterSelect);
      }
    });
  }

  @Builder
  buildExpandedCalendarOverlay() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.darkModeEnabled ? '#80000000' : '#660C1729')
        .animation({ duration: 220, curve: Curve.EaseInOut })
        .onClick(() => {
          this.calendarExpanded = false;
        });

      ExpandedCalendarPanel({
        darkModeEnabled: this.darkModeEnabled,
        displayYear: this.displayYear,
        displayMonth: this.displayMonth,
        selectedDateKey: this.selectedDateKey,
        monthContentKey: this.monthContentKey,
        rows: this.getExpandedCalendarRows(),
        onClose: (): void => {
          this.calendarExpanded = false;
        },
        onPreviousMonth: (): void => {
          this.goToPreviousMonth();
        },
        onNextMonth: (): void => {
          this.goToNextMonth();
        },
        onSelectDate: (dateKey: string, collapseAfterSelect: boolean): void => {
          this.selectCalendarDate(dateKey, collapseAfterSelect);
        }
      });
    }
    .width('100%')
    .height('100%')
    .transition(TransitionEffect.OPACITY)
    .animation({ duration: 220, curve: Curve.EaseInOut });
  }

  @Builder
  buildPunchCard() {
    PunchCardSection({
      darkModeEnabled: this.darkModeEnabled,
      selectedDateLabel: this.getSelectedDateLabel(),
      selectedDateKey: this.selectedDateKey,
      selectedWorkMinutes: this.getSelectedWorkMinutes(),
      startTimeText: this.getStartTimeText(),
      endTimeText: this.getEndTimeText(),
      excludeSummaryText: this.getExcludeSummaryText(),
      holiday: this.isHoliday(),
      punchCardScale: this.punchCardScale,
      punchButtonGlow: this.punchButtonGlow,
      onPunch: (): void => {
        this.handlePunchNow();
      },
      onEditPunch: (field: string): void => {
        this.openTimePicker(field);
      }
    });
  }

  @Builder
  buildSummaryCards() {
    SummaryCardsSection({
      darkModeEnabled: this.darkModeEnabled,
      summaryItems: this.getSummaryItems(),
      summaryRefreshKey: this.summaryRefreshKey,
      differenceLabel: this.getDifferenceLabel(),
      differenceColor: this.getDifferenceColor()
    });
  }

  // ========== 业务逻辑方法 ==========

  initializeData(): void {
    this.selectedDateKey = TimeUtils.createDateKey(new Date());
    this.syncDisplayMonthToSelectedDate();
    this.workdayStartTime = '09:00';
    this.excludedRanges = [];

    try {
      let hostContext: Context = this.getUIContext().getHostContext() as Context;
      this.pref = preferences.getPreferencesSync(hostContext, { name: this.prefName });
      this.loadPersistedState();
    } catch (_error) {
      this.pref = null;
    }

    // 如果从持久化加载后 records 为空（首次使用），则用 mock 数据填充
    this.weekContentKey++;
    this.summaryRefreshKey++;
    this.persistState();
  }

  loadPersistedState(): void {
    if (this.pref === null) {
      return;
    }

    let selectedDateKey: string = this.pref.getSync(this.prefSelectedDateKey, this.selectedDateKey) as string;
    if (selectedDateKey.length > 0) {
      this.selectedDateKey = selectedDateKey;
    }

    let displayMonthText: string = this.pref.getSync(this.prefDisplayMonth, '') as string;
    if (displayMonthText.length > 0) {
      this.restoreDisplayMonth(displayMonthText);
    } else {
      this.syncDisplayMonthToSelectedDate();
    }

    let targetHoursText: string = this.pref.getSync(this.prefTargetHours, this.targetAverageHours.toString()) as string;
    let targetHoursValue: number = Number(targetHoursText);
    if (!Number.isNaN(targetHoursValue)) {
      if (targetHoursValue < 6) {
        this.targetAverageHours = 6;
      } else if (targetHoursValue > 12) {
        this.targetAverageHours = 12;
      } else {
        this.targetAverageHours = Math.round(targetHoursValue * 10) / 10;
      }
    }

    let workdayStartTimeText: string = this.pref.getSync(this.prefWorkdayStartTime, this.workdayStartTime) as string;
    if (TimeUtils.parseTimeToMinutes(workdayStartTimeText) >= 0) {
      this.workdayStartTime = workdayStartTimeText;
    }

    let rangeText: string = this.pref.getSync(this.prefExcludedRanges, '') as string;
    if (rangeText.length > 0) {
      this.excludedRanges = this.deserializeRanges(rangeText);
    }

    let recordsText: string = this.pref.getSync(this.prefRecords, '') as string;
    if (recordsText.length > 0) {
      this.records = this.deserializeRecords(recordsText);
    }

    let darkModeText: string = this.pref.getSync('dark_mode', 'false') as string;
    this.darkModeEnabled = darkModeText === 'true';
  }

  persistState(): void {
    if (this.pref === null) {
      return;
    }

    try {
      this.pref.putSync(this.prefSelectedDateKey, this.selectedDateKey);
      this.pref.putSync(this.prefDisplayMonth, this.getDisplayMonthKey());
      this.pref.putSync(this.prefTargetHours, this.targetAverageHours.toString());
      this.pref.putSync(this.prefWorkdayStartTime, this.workdayStartTime);
      this.pref.putSync(this.prefExcludedRanges, this.serializeRanges());
      this.pref.putSync(this.prefRecords, this.serializeRecords());
      this.pref.putSync('dark_mode', this.darkModeEnabled.toString());
      this.pref.flush();
    } catch (_error) {
    }
  }

  serializeRanges(): string {
    let result: string = '';
    let index: number = 0;
    while (index < this.excludedRanges.length) {
      let item: ExcludedRange = this.excludedRanges[index];
      if (result.length > 0) {
        result += '|';
      }
      result += item.start + ',' + item.end;
      index += 1;
    }
    return result;
  }

  deserializeRanges(content: string): ExcludedRange[] {
    let result: ExcludedRange[] = [];
    let items: string[] = content.split('|');
    let index: number = 0;
    while (index < items.length) {
      let pair: string = items[index];
      if (pair.length > 0) {
        let commaIndex: number = pair.indexOf(',');
        if (commaIndex > 0 && commaIndex < pair.length - 1) {
          let start: string = pair.substring(0, commaIndex);
          let end: string = pair.substring(commaIndex + 1, pair.length);
          if (TimeUtils.parseTimeToMinutes(start) >= 0 && TimeUtils.parseTimeToMinutes(end) >= 0) {
            result.push(new ExcludedRange(start, end));
          }
        }
      }
      index += 1;
    }
    result.sort((a: ExcludedRange, b: ExcludedRange): number => {
      return TimeUtils.parseTimeToMinutes(a.start) - TimeUtils.parseTimeToMinutes(b.start);
    });
    return result;
  }

  serializeRecords(): string {
    let result: string = '';
    let index: number = 0;
    while (index < this.records.length) {
      let item: DailyPunchRecord = this.records[index];
      if (result.length > 0) {
        result += '|';
      }
      result += item.dateKey + '=' + item.punches.join(',');
      index += 1;
    }
    return result;
  }

  deserializeRecords(content: string): DailyPunchRecord[] {
    let result: DailyPunchRecord[] = [];
    let items: string[] = content.split('|');
    let index: number = 0;
    while (index < items.length) {
      let item: string = items[index];
      let separatorIndex: number = item.indexOf('=');
      if (separatorIndex > 0) {
        let dateKey: string = item.substring(0, separatorIndex);
        let punchesText: string = item.substring(separatorIndex + 1, item.length);
        let punches: number[] = [];
        if (punchesText.length > 0) {
          let minuteTexts: string[] = punchesText.split(',');
          let innerIndex: number = 0;
          while (innerIndex < minuteTexts.length) {
            let minuteValue: number = Number(minuteTexts[innerIndex]);
            if (!Number.isNaN(minuteValue) && minuteValue >= 0 && minuteValue < 24 * 60) {
              punches.push(minuteValue);
            }
            innerIndex += 1;
          }
        }
        punches.sort((left: number, right: number) => left - right);
        result.push(new DailyPunchRecord(dateKey, punches));
      }
      index += 1;
    }
    return result;
  }

  restoreDisplayMonth(content: string): void {
    if (content.length !== 7) {
      this.syncDisplayMonthToSelectedDate();
      return;
    }
    let year: number = Number(content.substring(0, 4));
    let month: number = Number(content.substring(5, 7));
    if (Number.isNaN(year) || Number.isNaN(month) || month < 1 || month > 12) {
      this.syncDisplayMonthToSelectedDate();
      return;
    }
    this.displayYear = year;
    this.displayMonth = month - 1;
  }

  getDisplayMonthKey(): string {
    return this.displayYear.toString() + '-' + TimeUtils.toTwoDigits(this.displayMonth + 1);
  }

  syncDisplayMonthToSelectedDate(): void {
    let selectedDate: Date | null = TimeUtils.parseDateKey(this.selectedDateKey);
    if (selectedDate === null) {
      let today: Date = new Date();
      this.displayYear = today.getFullYear();
      this.displayMonth = today.getMonth();
      return;
    }
    this.displayYear = selectedDate.getFullYear();
    this.displayMonth = selectedDate.getMonth();
  }

  getCurrentMonthTitle(): string {
    return this.displayYear.toString() + '年 ' + (this.displayMonth + 1).toString() + '月';
  }

  getSelectedDateDescription(): string {
    let todayKey: string = TimeUtils.createDateKey(new Date());
    if (this.selectedDateKey === todayKey) {
      return '今天';
    }
    return TimeUtils.getDateLabelWithWeekday(this.selectedDateKey, WEEKDAY_NAMES);
  }

  jumpToToday(): void {
    this.selectedDateKey = TimeUtils.createDateKey(new Date());
    this.syncDisplayMonthToSelectedDate();
    this.calendarExpanded = false;
    this.calendarWeekOffset = 0;
    this.summaryRefreshKey++;
    this.persistState();
  }

  playTodayButtonAnimation(): void {
    this.todayButtonScale = 0.88;
    this.getUIContext().animateTo({ duration: 120, curve: Curve.EaseOut }, () => {
      this.todayButtonScale = 1.05;
    });
    this.getUIContext().animateTo({ duration: 180, delay: 120, curve: Curve.FastOutSlowIn }, () => {
      this.todayButtonScale = 1;
    });
  }

  selectCalendarDate(dateKey: string, collapseAfterSelect: boolean): void {
    this.selectedDateKey = dateKey;
    this.calendarWeekOffset = 0;
    this.syncDisplayMonthToSelectedDate();
    if (collapseAfterSelect) {
      this.calendarExpanded = false;
    }
    this.summaryRefreshKey++;
    this.persistState();
  }

  handleCalendarSwipe(offsetX: number): void {
    if (offsetX <= -60) {
      if (this.calendarExpanded) {
        this.goToNextMonth();
      } else {
        this.goToNextWeek();
      }
      return;
    }
    if (offsetX >= 60) {
      if (this.calendarExpanded) {
        this.goToPreviousMonth();
      } else {
        this.goToPreviousWeek();
      }
    }
  }

  goToPreviousMonth(): void {
    let nextMonth: number = this.displayMonth - 1;
    let nextYear: number = this.displayYear;
    if (nextMonth < 0) {
      nextMonth = 11;
      nextYear -= 1;
    }
    this.displayYear = nextYear;
    this.displayMonth = nextMonth;
    this.calendarWeekOffset = 0;
    this.monthContentKey++;
    this.summaryRefreshKey++;
    this.persistState();
  }

  goToPreviousWeek(): void {
    this.calendarWeekOffset -= 1;
    // 同步更新 displayMonth 以支持跨月显示
    this.syncDisplayMonthToWeekOffset();
  }

  goToNextWeek(): void {
    this.calendarWeekOffset += 1;
    // 同步更新 displayMonth 以支持跨月显示
    this.syncDisplayMonthToWeekOffset();
  }

  /**
   * 根据 calendarWeekOffset 计算偏移后的周一，若跨月则更新 displayYear/displayMonth
   */
  syncDisplayMonthToWeekOffset(): void {
    let selectedDate: Date | null = TimeUtils.parseDateKey(this.selectedDateKey);
    if (selectedDate === null) {
      return;
    }
    let dayOfWeek: number = selectedDate.getDay();
    let weekStartOffset: number = dayOfWeek === 0 ? -6 : 1 - dayOfWeek;
    let monday: Date = new Date(selectedDate.getFullYear(), selectedDate.getMonth(), selectedDate.getDate() + weekStartOffset);
    let targetMonday: Date = new Date(monday.getFullYear(), monday.getMonth(), monday.getDate() + this.calendarWeekOffset * 7);

    if (targetMonday.getFullYear() !== this.displayYear || targetMonday.getMonth() !== this.displayMonth) {
      this.displayYear = targetMonday.getFullYear();
      this.displayMonth = targetMonday.getMonth();
    }
  }

  goToNextMonth(): void {
    let today: Date = new Date();
    let maxYear: number = today.getFullYear();
    let maxMonth: number = today.getMonth();
    if (this.displayYear > maxYear || (this.displayYear === maxYear && this.displayMonth >= maxMonth)) {
      return;
    }

    let nextMonth: number = this.displayMonth + 1;
    let nextYear: number = this.displayYear;
    if (nextMonth > 11) {
      nextMonth = 0;
      nextYear += 1;
    }

    if (nextYear > maxYear || (nextYear === maxYear && nextMonth > maxMonth)) {
      return;
    }

    this.displayYear = nextYear;
    this.displayMonth = nextMonth;
    this.calendarWeekOffset = 0;
    this.monthContentKey++;
    this.summaryRefreshKey++;
    this.persistState();
  }

  getExpandedCalendarRows(): CalendarSlot[][] {
    return IndexCalendarService.getExpandedCalendarRows(this.buildMonthSlots());
  }

  buildMonthSlots(): CalendarSlot[] {
    return IndexCalendarService.buildMonthSlots(this.displayYear, this.displayMonth, this.records);
  }

  getCurrentWeekSlots(): CalendarSlot[] {
    return IndexCalendarService.getCurrentWeekSlots(
      this.selectedDateKey,
      this.displayYear,
      this.displayMonth,
      this.calendarWeekOffset,
      this.records
    );
  }

  getSelectedDateLabel(): string {
    return TimeUtils.getDateLabelWithWeekday(this.selectedDateKey, WEEKDAY_NAMES);
  }

  getSelectedWorkMinutes(): number {
    let record: DailyPunchRecord | null = this.getRecordByDateKey(this.selectedDateKey);
    if (record === null) {
      return 0;
    }
    return PunchCalculator.calculateWorkMinutes(record.punches, this.workdayStartTime, this.excludedRanges);
  }

  getStartTimeText(): string {
    let record: DailyPunchRecord | null = this.getRecordByDateKey(this.selectedDateKey);
    if (record === null || record.punches.length === 0) {
      return '--:--';
    }
    return TimeUtils.formatMinuteAsTime(record.punches[0]);
  }

  getEndTimeText(): string {
    let record: DailyPunchRecord | null = this.getRecordByDateKey(this.selectedDateKey);
    if (record === null || record.punches.length < 2) {
      return '--:--';
    }
    return TimeUtils.formatMinuteAsTime(record.punches[record.punches.length - 1]);
  }

  getExcludeSummaryText(): string {
    if (this.excludedRanges.length === 0) {
      return '未设置排除时段';
    }
    return '已排除 ' + this.excludedRanges.length.toString() + ' 个时段';
  }

  getSummaryItems(): SummaryItem[] {
    let averageMinutes: number = this.getDisplayedMonthAverageMinutes();
    let targetMinutes: number = Math.round(this.targetAverageHours * 60);
    let items: SummaryItem[] = [];
    items.push(new SummaryItem('目标平均工时', TimeUtils.formatMinutes(targetMinutes)));
    items.push(new SummaryItem('当前平均工时', TimeUtils.formatMinutes(averageMinutes)));
    return items;
  }

  getDifferenceLabel(): string {
    let averageMinutes: number = this.getDisplayedMonthAverageMinutes();
    let targetMinutes: number = Math.round(this.targetAverageHours * 60);
    let delta: number = averageMinutes - targetMinutes;
    if (delta === 0) {
      return '与目标持平';
    }
    if (delta > 0) {
      return '比目标多 ' + TimeUtils.formatMinutes(delta);
    }
    return '比目标少 ' + TimeUtils.formatMinutes(0 - delta);
  }

  getDifferenceColor(): string {
    let averageMinutes: number = this.getDisplayedMonthAverageMinutes();
    let targetMinutes: number = Math.round(this.targetAverageHours * 60);
    let delta: number = averageMinutes - targetMinutes;
    if (delta === 0) {
      return '#132033';
    }
    if (delta > 0) {
      return '#1EA97C';
    }
    return '#D85353';
  }

  getDisplayedMonthAverageMinutes(): number {
    return PunchCalculator.getDisplayedMonthAverageMinutes(
      this.records, this.displayYear, this.displayMonth,
      this.workdayStartTime, this.excludedRanges
    );
  }

  calculateWorkMinutes(punches: number[]): number {
    return PunchCalculator.calculateWorkMinutes(punches, this.workdayStartTime, this.excludedRanges);
  }

  getOverlapMinutes(startOne: number, endOne: number, startTwo: number, endTwo: number): number {
    return PunchCalculator.getOverlapMinutes(startOne, endOne, startTwo, endTwo);
  }

  openTimePicker(field: string): void {
    let currentValue: string = field === 'start' ? this.getStartTimeText() : this.getEndTimeText();
    let defaultValue: string = currentValue === '--:--' ? (field === 'start' ? '09:00' : '18:00') : currentValue;
    let minutes: number = TimeUtils.parseTimeToMinutes(defaultValue);
    if (minutes < 0) {
      minutes = 0;
    }
    let hour: number = Math.floor(minutes / 60);
    let minute: number = minutes % 60;

    let pickedField: string = field;
    this.timePickerController = new CustomDialogController({
      builder: CustomTimePickerDialog({
        title: field === 'start' ? '编辑上班时间' : '编辑下班时间',
        selectedHour: hour,
        selectedMinute: minute,
        useMilitaryTime: true,
        onConfirm: (h: number, m: number) => {
          this.applyPickedTime(pickedField, h, m);
        }
      }),
      autoCancel: true,
      customStyle: true,
      alignment: DialogAlignment.Center,
      backgroundColor: Color.Transparent,
      backgroundBlurStyle: BlurStyle.NONE
    });
    this.timePickerController.open();
  }

  openRangeTimePicker(isStart: boolean): void {
    let value: string = isStart ? this.rangeStartInput : this.rangeEndInput;
    let minutes: number = TimeUtils.parseTimeToMinutes(value);
    if (minutes < 0) {
      minutes = 0;
    }
    let hour: number = Math.floor(minutes / 60);
    let minute: number = minutes % 60;

    let isStartPicked: boolean = isStart;
    this.rangeTimePickerController = new CustomDialogController({
      builder: CustomTimePickerDialog({
        title: isStart ? '选择开始时间' : '选择结束时间',
        selectedHour: hour,
        selectedMinute: minute,
        useMilitaryTime: true,
        onConfirm: (h: number, m: number) => {
          let picked: string = TimeUtils.toTwoDigits(h) + ':' + TimeUtils.toTwoDigits(m);
          if (isStartPicked) {
            this.rangeStartInput = picked;
            // 修改开始时间后，自动将结束时间设为开始时间 + 30 分钟
            let startMinutes: number = h * 60 + m;
            let endMinutes: number = startMinutes + 30;
            if (endMinutes >= 1440) {
              endMinutes = 1439;
            }
            let endHour: number = Math.floor(endMinutes / 60);
            let endMin: number = endMinutes % 60;
            this.rangeEndInput = TimeUtils.toTwoDigits(endHour) + ':' + TimeUtils.toTwoDigits(endMin);
          } else {
            this.rangeEndInput = picked;
          }
          this.rangeDialogKey++;
        }
      }),
      autoCancel: true,
      customStyle: true,
      alignment: DialogAlignment.Center,
      backgroundColor: Color.Transparent,
      backgroundBlurStyle: BlurStyle.NONE
    });
    this.rangeTimePickerController.open();
  }

  openWorkdayStartTimePicker(): void {
    let minutes: number = TimeUtils.parseTimeToMinutes(this.workdayStartTime);
    if (minutes < 0) {
      minutes = 0;
    }
    let hour: number = Math.floor(minutes / 60);
    let minute: number = minutes % 60;

    this.workdayStartPickerController = new CustomDialogController({
      builder: CustomTimePickerDialog({
        title: '设置上班时间',
        selectedHour: hour,
        selectedMinute: minute,
        useMilitaryTime: true,
        onConfirm: (h: number, m: number) => {
          this.workdayStartTime = TimeUtils.toTwoDigits(h) + ':' + TimeUtils.toTwoDigits(m);
          this.summaryRefreshKey++;
          this.persistState();
        }
      }),
      autoCancel: true,
      customStyle: true,
      alignment: DialogAlignment.Center,
      backgroundColor: Color.Transparent,
      backgroundBlurStyle: BlurStyle.NONE
    });
    this.workdayStartPickerController.open();
  }

  applyPickedTime(field: string, hour: number, minute: number): void {
    let pickedMinutes: number = hour * 60 + minute;
    let record: DailyPunchRecord | null = this.getRecordByDateKey(this.selectedDateKey);
    let nextPunches: number[] = [];

    if (record === null) {
      nextPunches.push(pickedMinutes);
      if (field === 'end') {
        nextPunches.push(pickedMinutes);
      }
    } else {
      nextPunches = PunchCalculator.copyPunches(record.punches);
      if (field === 'start') {
        if (nextPunches.length === 0) {
          nextPunches.push(pickedMinutes);
        } else {
          nextPunches[0] = pickedMinutes;
        }
      } else {
        if (nextPunches.length === 0) {
          nextPunches.push(pickedMinutes);
          nextPunches.push(pickedMinutes);
        } else if (nextPunches.length === 1) {
          if (pickedMinutes < nextPunches[0]) {
            nextPunches.unshift(pickedMinutes);
          } else {
            nextPunches.push(pickedMinutes);
          }
        } else {
          nextPunches[nextPunches.length - 1] = pickedMinutes;
        }
      }
    }

    nextPunches.sort((left: number, right: number) => left - right);
    this.replaceRecordForDate(this.selectedDateKey, nextPunches);
    this.playPunchCardFeedback();
    this.summaryRefreshKey++;
    this.persistState();
  }

  confirmAddRange(): void {
    let startMinute: number = TimeUtils.parseTimeToMinutes(this.rangeStartInput);
    let endMinute: number = TimeUtils.parseTimeToMinutes(this.rangeEndInput);
    if (startMinute < 0 || endMinute <= startMinute) {
      return;
    }
    // 检查与已有排除时段是否有交集（编辑模式下跳过自身）
    let hasOverlap: boolean = false;
    let idx: number = 0;
    while (idx < this.excludedRanges.length) {
      // 编辑模式：跳过当前正在编辑的时段，不与自身比较
      if (this.editRangeIndex >= 0 && idx === this.editRangeIndex) {
        idx++;
        continue;
      }
      let existing: ExcludedRange = this.excludedRanges[idx];
      let existStart: number = TimeUtils.parseTimeToMinutes(existing.start);
      let existEnd: number = TimeUtils.parseTimeToMinutes(existing.end);
      // 两个区间有交集当且仅当 startMinute < existEnd && endMinute > existStart
      if (startMinute < existEnd && endMinute > existStart) {
        hasOverlap = true;
        break;
      }
      idx++;
    }
    if (hasOverlap) {
      this.showRangeConflictDialog = true;
      return;
    }
    let nextRanges: ExcludedRange[] = PunchCalculator.copyRanges(this.excludedRanges);
    if (this.editRangeIndex >= 0 && this.editRangeIndex < nextRanges.length) {
      // 编辑模式：更新已有时段
      nextRanges[this.editRangeIndex] = new ExcludedRange(this.rangeStartInput, this.rangeEndInput);
    } else {
      // 新增模式：追加新时段
      nextRanges.push(new ExcludedRange(this.rangeStartInput, this.rangeEndInput));
    }
    // 按开始时间排序
    nextRanges.sort((a: ExcludedRange, b: ExcludedRange): number => {
      return TimeUtils.parseTimeToMinutes(a.start) - TimeUtils.parseTimeToMinutes(b.start);
    });
    this.excludedRanges = nextRanges;
    this.showRangeDialog = false;
    this.editRangeIndex = -1;
    this.summaryRefreshKey++;
    this.persistState();
  }

  removeRange(index: number): void {
    let nextRanges: ExcludedRange[] = [];
    let current: number = 0;
    while (current < this.excludedRanges.length) {
      if (current !== index) {
        let range: ExcludedRange = this.excludedRanges[current];
        nextRanges.push(new ExcludedRange(range.start, range.end));
      }
      current += 1;
    }
    this.confirmDeleteIndex = -1;
    this.getUIContext().animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
      this.excludedRanges = nextRanges;
    });
    this.summaryRefreshKey++;
    this.persistState();
  }

  getCurrentMinuteOfDay(): number {
    let now: Date = new Date();
    return now.getHours() * 60 + now.getMinutes();
  }

  handlePunchNow(): void {
    let minute: number = this.getCurrentMinuteOfDay();
    let record: DailyPunchRecord | null = this.getRecordByDateKey(this.selectedDateKey);
    let nextPunches: number[] = [];

    if (record === null) {
      nextPunches.push(minute);
    } else {
      nextPunches = PunchCalculator.copyPunches(record.punches);
      nextPunches.push(minute);
    }

    nextPunches.sort((left: number, right: number) => left - right);
    this.replaceRecordForDate(this.selectedDateKey, nextPunches);
    this.playPunchCardFeedback();
    this.persistState();
  }

  replaceRecordForDate(dateKey: string, punches: number[]): void {
    let nextRecords: DailyPunchRecord[] = [];
    let index: number = 0;
    let replaced: boolean = false;
    while (index < this.records.length) {
      let item: DailyPunchRecord = this.records[index];
      if (item.dateKey === dateKey) {
        nextRecords.push(new DailyPunchRecord(dateKey, PunchCalculator.copyPunches(punches)));
        replaced = true;
      } else {
        nextRecords.push(new DailyPunchRecord(item.dateKey, PunchCalculator.copyPunches(item.punches)));
      }
      index += 1;
    }
    if (!replaced) {
      nextRecords.push(new DailyPunchRecord(dateKey, PunchCalculator.copyPunches(punches)));
    }
    this.records = nextRecords;
    this.weekContentKey++;
  }

  playPunchCardFeedback(): void {
    // 缩放动画
    this.punchCardScale = 0.92;
    this.getUIContext().animateTo({
      duration: 140,
      curve: Curve.EaseOut
    }, () => {
      this.punchCardScale = 1.06;
    });
    this.getUIContext().animateTo({
      duration: 220,
      delay: 140,
      curve: Curve.EaseInOut
    }, () => {
      this.punchCardScale = 1;
    });

    // 绿色脉冲动画
    this.punchButtonGlow = 1;
    this.getUIContext().animateTo({
      duration: 600,
      curve: Curve.EaseOut
    }, () => {
      this.punchButtonGlow = 0;
    });
  }

  isHoliday(): boolean {
    return HOLIDAYS_2026.includes(this.selectedDateKey);
  }

  getRecordByDateKey(dateKey: string): DailyPunchRecord | null {
    let index: number = this.findRecordIndex(dateKey);
    if (index < 0) {
      return null;
    }
    return this.records[index];
  }

  findRecordIndex(dateKey: string): number {
    let index: number = 0;
    while (index < this.records.length) {
      if (this.records[index].dateKey === dateKey) {
        return index;
      }
      index += 1;
    }
    return -1;
  }

  onBackPress(): boolean {
    // 弹窗优先：排除时段弹窗打开时，先关弹窗
    if (this.showRangeDialog) {
      this.showRangeDialog = false;
      this.editRangeIndex = -1;
      return true;
    }

    // 设置页打开时，关闭设置页
    if (this.showSettingsPage) {
      this.showSettingsPage = false;
      return true;
    }

    // 日历展开时，折叠日历
    if (this.calendarExpanded) {
      this.calendarExpanded = false;
      return true;
    }

    return false;
  }

  /**
   * 导出打卡记录为包含多个CSV的ZIP包（按月拆分），无数据时导出空模板CSV
   */
  private async exportRecordsToCsv(): Promise<void> {
    try {
      let context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
      let now: Date = new Date();
      let timeStamp: string = now.getFullYear().toString() +
        TimeUtils.toTwoDigits(now.getMonth() + 1) +
        TimeUtils.toTwoDigits(now.getDate()) + '_' +
        TimeUtils.toTwoDigits(now.getHours()) +
        TimeUtils.toTwoDigits(now.getMinutes()) +
        TimeUtils.toTwoDigits(now.getSeconds());

      let baseName: string = '牛马工时簿_打卡记录_' + timeStamp;
      let tempDir: string = context.cacheDir + '/' + baseName;
      let zipPath: string = context.cacheDir + '/' + baseName + '.zip';

      // 创建临时目录
      if (!fileIo.accessSync(tempDir)) {
        fileIo.mkdirSync(tempDir);
      }

      // 按月份分组
      let monthMap: Map<string, DailyPunchRecord[]> = new Map();
      let idx: number = 0;
      while (idx < this.records.length) {
        let record: DailyPunchRecord = this.records[idx];
        let date: Date | null = TimeUtils.parseDateKey(record.dateKey);
        if (date !== null) {
          let monthKey: string = date.getFullYear().toString() + '-' + TimeUtils.toTwoDigits(date.getMonth() + 1);
          let group: DailyPunchRecord[] | undefined = monthMap.get(monthKey);
          if (group === undefined) {
            group = [];
            monthMap.set(monthKey, group);
          }
          group.push(record);
        }
        idx += 1;
      }

      let sortedMonths: string[] = Array.from(monthMap.keys()).sort();

      // 如果没有数据，生成一个空模板 CSV
      if (sortedMonths.length === 0) {
        let templateLines: string[] = [];
        templateLines.push('\uFEFF日期,上班打卡时间,下班打卡时间');
        templateLines.push('# 说明：');
        templateLines.push('# 1. 日期格式为 YYYY-MM-DD，例如 2026-06-01');
        templateLines.push('# 2. 打卡时间格式为 HH:mm，例如 09:00');
        templateLines.push('# 3. 同一日期请填写在同一行，上班时间和下班时间分列填写');
        templateLines.push('# 4. 如果某天只有一次打卡，下班时间留空即可');
        templateLines.push('# 5. 示例：');
        templateLines.push('2026-06-01,09:00,18:30');
        let templateContent: string = templateLines.join('\r\n');
        let templateFile: fileIo.File = fileIo.openSync(tempDir + '/导入模板.csv', fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
        fileIo.writeSync(templateFile.fd, templateContent);
        fileIo.closeSync(templateFile);
      } else {
        // 有数据，按月份生成 CSV 文件
        let monthIdx: number = 0;
        while (monthIdx < sortedMonths.length) {
          let monthKey: string = sortedMonths[monthIdx];
          let monthRecords: DailyPunchRecord[] = monthMap.get(monthKey) as DailyPunchRecord[];
          monthRecords.sort((a: DailyPunchRecord, b: DailyPunchRecord) => {
            return a.dateKey.localeCompare(b.dateKey);
          });

          let csvLines: string[] = [];
          csvLines.push('\uFEFF日期,上班打卡时间,下班打卡时间');
          let recIdx: number = 0;
          while (recIdx < monthRecords.length) {
            let record: DailyPunchRecord = monthRecords[recIdx];
            let firstPunch: string = record.punches.length > 0 ?
              TimeUtils.formatMinuteAsTime(record.punches[0]) : '';
            let lastPunch: string = record.punches.length > 1 ?
              TimeUtils.formatMinuteAsTime(record.punches[record.punches.length - 1]) : '';
            csvLines.push(record.dateKey + ',' + firstPunch + ',' + lastPunch);
            recIdx += 1;
          }

          let csvContent: string = csvLines.join('\r\n');
          let csvPath: string = tempDir + '/' + monthKey + '.csv';
          let csvFile: fileIo.File = fileIo.openSync(csvPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
          fileIo.writeSync(csvFile.fd, csvContent);
          fileIo.closeSync(csvFile);
          monthIdx += 1;
        }
      }

      // 打包为 ZIP 文件
      let options: zlib.Options = {};
      await zlib.compressFile(tempDir, zipPath, options);

      // 使用 DocumentViewPicker 让用户选择保存位置
      let documentSaveOptions: picker.DocumentSaveOptions = new picker.DocumentSaveOptions();
      documentSaveOptions.newFileNames = [baseName + '.zip'];
      documentSaveOptions.fileSuffixChoices = ['ZIP 文件|.zip'];

      let documentViewPicker: picker.DocumentViewPicker = new picker.DocumentViewPicker(context);
      let saveResult: string[] = await documentViewPicker.save(documentSaveOptions);

      if (saveResult.length > 0) {
        let uri: string = saveResult[0];
        // 将打包好的 ZIP 复制到用户选择的路径
        let destFile: fileIo.File = fileIo.openSync(uri, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
        let srcFile: fileIo.File = fileIo.openSync(zipPath, fileIo.OpenMode.READ_ONLY);
        fileIo.copyFileSync(srcFile.fd, destFile.fd);
        fileIo.closeSync(srcFile);
        fileIo.closeSync(destFile);
        this.getUIContext().getPromptAction().showToast({ message: '导出成功' });
      }

      // 清理临时文件
      this.cleanTempFiles(tempDir, zipPath);
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      if (err.code !== 13900015) {
        this.getUIContext().getPromptAction().showToast({ message: '导出失败: ' + err.message });
      }
    }
  }

  /**
   * 清理导出时生成的临时文件
   */
  private cleanTempFiles(tempDir: string, zipPath: string): void {
    try {
      if (fileIo.accessSync(tempDir)) {
        let files: string[] = fileIo.listFileSync(tempDir);
        let idx: number = 0;
        while (idx < files.length) {
          fileIo.unlinkSync(tempDir + '/' + files[idx]);
          idx += 1;
        }
        fileIo.rmdirSync(tempDir);
      }
      if (fileIo.accessSync(zipPath)) {
        fileIo.unlinkSync(zipPath);
      }
    } catch (_error) {
      // 临时文件清理失败不影响主流程
    }
  }

  /**
   * 解析单个 CSV 文件内容为打卡记录列表
   */
  private parseCsvContent(csvContent: string): DailyPunchRecord[] {
    let result: DailyPunchRecord[] = [];
    // 移除 BOM
    if (csvContent.charCodeAt(0) === 0xFEFF) {
      csvContent = csvContent.substring(1);
    }
    let lines: string[] = csvContent.split('\n');
    let lineIdx: number = 0;
    while (lineIdx < lines.length) {
      let line: string = lines[lineIdx].trim();
      // 跳过空行、标题行、注释行
      if (line.length === 0 || line.startsWith('日期') || line.startsWith('#')) {
        lineIdx += 1;
        continue;
      }
      let parts: string[] = line.split(',');
      if (parts.length >= 2) {
        let dateKey: string = parts[0].trim();
        let morningMinutes: number = parts[1].trim().length > 0 ?
          TimeUtils.parseTimeToMinutes(parts[1].trim()) : -1;
        let eveningMinutes: number = (parts.length >= 3 && parts[2].trim().length > 0) ?
          TimeUtils.parseTimeToMinutes(parts[2].trim()) : -1;

        if (dateKey.length === 10) {
          let punches: number[] = [];
          if (morningMinutes >= 0) {
            punches.push(morningMinutes);
          }
          if (eveningMinutes >= 0 && eveningMinutes !== morningMinutes) {
            punches.push(eveningMinutes);
          }
          if (punches.length > 0) {
            punches.sort((a: number, b: number) => a - b);
            result.push(new DailyPunchRecord(dateKey, punches));
          }
        }
      }
      lineIdx += 1;
    }
    return result;
  }

  /**
   * 从 CSV 文件或 ZIP 包导入打卡记录
   */
  private async importRecordsFromCsv(): Promise<void> {
    try {
      let context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
      let documentSelectOptions: picker.DocumentSelectOptions = new picker.DocumentSelectOptions();
      documentSelectOptions.maxSelectNumber = 1;
      documentSelectOptions.fileSuffixFilters = ['.csv', '.zip'];

      let documentViewPicker: picker.DocumentViewPicker = new picker.DocumentViewPicker(context);
      let selectResult: string[] = await documentViewPicker.select(documentSelectOptions);

      if (selectResult.length > 0) {
        let uri: string = selectResult[0];
        let allImportedRecords: DailyPunchRecord[] = [];

        // 判断是 .zip 还是 .csv
        if (uri.toLowerCase().endsWith('.zip')) {
          // ---- 导入 ZIP 包 ----
          let tempZipPath: string = context.cacheDir + '/import_temp.zip';
          let tempExtractDir: string = context.cacheDir + '/import_temp';

          // 复制到沙箱
          let srcFile: fileIo.File = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
          let destFile: fileIo.File = fileIo.openSync(tempZipPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
          fileIo.copyFileSync(srcFile.fd, destFile.fd);
          fileIo.closeSync(srcFile);
          fileIo.closeSync(destFile);

          // 创建解压目录
          if (!fileIo.accessSync(tempExtractDir)) {
            fileIo.mkdirSync(tempExtractDir);
          }

          // 解压 ZIP
          let options: zlib.Options = {};
          await zlib.decompressFile(tempZipPath, tempExtractDir, options);

          // 读取解压目录下所有 CSV 文件
          let csvFiles: string[] = fileIo.listFileSync(tempExtractDir);
          let fIdx: number = 0;
          while (fIdx < csvFiles.length) {
            let fileName: string = csvFiles[fIdx];
            if (fileName.toLowerCase().endsWith('.csv')) {
              let filePath: string = tempExtractDir + '/' + fileName;
              let csvContent: string = fileIo.readTextSync(filePath);
              let parsed: DailyPunchRecord[] = this.parseCsvContent(csvContent);
              let pIdx: number = 0;
              while (pIdx < parsed.length) {
                allImportedRecords.push(parsed[pIdx]);
                pIdx += 1;
              }
            }
            fIdx += 1;
          }

          // 清理临时文件
          this.cleanImportTempFiles(tempZipPath, tempExtractDir);
        } else {
          // ---- 导入 CSV 文件 ----
          let file: fileIo.File = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
          let stat = fileIo.statSync(file.fd);
          let buffer: ArrayBuffer = new ArrayBuffer(stat.size);
          let readLen: number = fileIo.readSync(file.fd, buffer);
          fileIo.closeSync(file);

          let decoder: util.TextDecoder = util.TextDecoder.create('utf-8');
          let uint8Array: Uint8Array = new Uint8Array(buffer.slice(0, readLen));
          let csvContent: string = decoder.decodeToString(uint8Array);

          allImportedRecords = this.parseCsvContent(csvContent);
        }

        if (allImportedRecords.length > 0) {
          let mergedRecords: DailyPunchRecord[] = this.mergeImportRecords(allImportedRecords);
          this.records = mergedRecords;
          this.persistState();
          this.summaryRefreshKey++;
          this.monthContentKey++;
          this.weekContentKey++;
          this.getUIContext().getPromptAction().showToast({ message: '导入成功，共 ' + allImportedRecords.length.toString() + ' 天数据' });
        } else {
          this.getUIContext().getPromptAction().showToast({ message: '未解析到有效打卡数据' });
        }
      }
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      if (err.code !== 13900015) {
        this.getUIContext().getPromptAction().showToast({ message: '导入失败: ' + err.message });
      }
    }
  }

  /**
   * 清理导入时生成的临时文件
   */
  private cleanImportTempFiles(tempZipPath: string, tempDir: string): void {
    try {
      if (fileIo.accessSync(tempDir)) {
        let files: string[] = fileIo.listFileSync(tempDir);
        let idx: number = 0;
        while (idx < files.length) {
          fileIo.unlinkSync(tempDir + '/' + files[idx]);
          idx += 1;
        }
        fileIo.rmdirSync(tempDir);
      }
      if (fileIo.accessSync(tempZipPath)) {
        fileIo.unlinkSync(tempZipPath);
      }
    } catch (_error) {
    }
  }

  /**
   * 合并导入的记录到现有记录（导入数据覆盖当天对应数据）
   */
  private mergeImportRecords(importRecords: DailyPunchRecord[]): DailyPunchRecord[] {
    // 先复制一份现有记录，同时标记是否被覆盖
    let result: DailyPunchRecord[] = [];
    let idx: number = 0;
    while (idx < this.records.length) {
      // 检查导入数据中是否有同一天的记录
      let matched: boolean = false;
      let impIdx: number = 0;
      while (impIdx < importRecords.length) {
        if (importRecords[impIdx].dateKey === this.records[idx].dateKey) {
          matched = true;
          break;
        }
        impIdx += 1;
      }
      // 只有未被覆盖的记录才保留
      if (!matched) {
        result.push(new DailyPunchRecord(this.records[idx].dateKey,
          PunchCalculator.copyPunches(this.records[idx].punches)));
      }
      idx += 1;
    }

    // 直接追加导入数据
    let impIdx: number = 0;
    while (impIdx < importRecords.length) {
      result.push(new DailyPunchRecord(importRecords[impIdx].dateKey,
        PunchCalculator.copyPunches(importRecords[impIdx].punches)));
      impIdx += 1;
    }

    // 按日期排序
    result.sort((a: DailyPunchRecord, b: DailyPunchRecord) => {
      return a.dateKey.localeCompare(b.dateKey);
    });

    return result;
  }

  /**
   * 确认清空所有打卡数据
   */
  private confirmClearAllRecords(): void {
    let context: UIContext = this.getUIContext();
    context.getPromptAction().showDialog({
      title: '确认清空',
      message: '确定要清空所有打卡数据吗？此操作不可恢复，设置项配置不会受影响。',
      buttons: [
        {
          text: '取消',
          color: this.darkModeEnabled ? '#8892A4' : '#60708A'
        },
        {
          text: '确认清空',
          color: '#D85353'
        }
      ]
    }).then((data: promptAction.ShowDialogSuccessResponse) => {
      if (data.index === 1) {
        // 用户确认清空
        let state: PersistState = new PersistState();
        // 保持当前配置
        state.selectedDateKey = this.selectedDateKey;
        state.displayYear = this.displayYear;
        state.displayMonth = this.displayMonth;
        state.targetAverageHours = this.targetAverageHours;
        state.workdayStartTime = this.workdayStartTime;
        state.excludedRanges = PunchCalculator.copyRanges(this.excludedRanges);
        state.darkModeEnabled = this.darkModeEnabled;
        state.records = [];

        // 通过 StorageService 清空
        let storageService: StorageService = new StorageService();
        storageService.init(context.getHostContext() as common.UIAbilityContext);
        storageService.clearAllRecords(state);

        this.records = [];
        this.summaryRefreshKey++;
        this.monthContentKey++;
        this.weekContentKey++;
        context.getPromptAction().showToast({ message: '打卡数据已清空' });
      }
    }).catch(() => {});
  }
}
