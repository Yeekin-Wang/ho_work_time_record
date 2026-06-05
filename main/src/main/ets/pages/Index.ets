import { common } from '@kit.AbilityKit';
import { LengthMetrics, router } from '@kit.ArkUI';
import { ExcludedRange } from '../model/ExcludedRange';
import { DailyPunchRecord } from '../model/DailyPunchRecord';
import { CalendarSlot } from '../model/CalendarSlot';
import { SummaryItem } from '../model/SummaryItem';
import { TimeUtils } from '../service/TimeUtils';
import { PunchCalculator } from '../service/PunchCalculator';
import { IndexCalendarService } from '../service/IndexCalendarService';
import { PersistState } from '../service/IndexPreferencesService';
import { WorkTimeStateService } from '../service/WorkTimeStateService';
import { ThemeService } from '../service/ThemeService';
import { ResourceTextService } from '../service/ResourceTextService';
import { DEFAULT_TARGET_HOURS, DEFAULT_WORKDAY_START, THEME_MODE_SYSTEM, WEEKDAY_NAMES } from '../constants/IndexConstants';
import { MainHeader } from '../components/index/MainHeader';
import { PunchCardSection } from '../components/index/PunchCardSection';
import { SummaryCardsSection } from '../components/index/SummaryCardsSection';
import { CalendarCard } from '../components/index/CalendarCard';
import { ExpandedCalendarPanel } from '../components/index/ExpandedCalendarPanel';
import { CustomTimePickerDialog } from './CustomTimePickerDialog';

@Entry
@Component
struct Index {
  @State selectedDateKey: string = '';
  @State calendarExpanded: boolean = false;
  @State displayYear: number = 0;
  @State displayMonth: number = 0;
  @State targetAverageHours: number = DEFAULT_TARGET_HOURS;
  @State workdayStartTime: string = DEFAULT_WORKDAY_START;
  @State excludedRanges: ExcludedRange[] = [];
  @State records: DailyPunchRecord[] = [];
  @State punchCardScale: number = 1;
  @State punchButtonGlow: number = 0;
  @State todayButtonScale: number = 1;
  @State darkModeEnabled: boolean = false;
  @State themeMode: string = THEME_MODE_SYSTEM;
  @StorageProp('currentColorMode') currentColorMode: number = 0;
  @State calendarWeekOffset: number = 0;
  @State monthContentKey: number = 0;
  @State weekContentKey: number = 0;
  // summary 刷新触发器 - 在影响平均工时的操作后自增，强制 ForEach 重建 summary 卡片
  @State summaryRefreshKey: number = 0;

  // 自定义时间选择弹窗控制器（用于打卡时间编辑）
  private timePickerController: CustomDialogController | null = null;
  private hasInitialized: boolean = false;

  private readonly stateService: WorkTimeStateService = new WorkTimeStateService();

  aboutToAppear(): void {
    this.initializeData();
  }

  onPageShow(): void {
    if (this.hasInitialized) {
      this.loadPersistedState();
    }
  }

  build() {
    WithTheme({ colorMode: ThemeService.getThemeColorMode(this.themeMode) }) {
      this.buildThemedContent();
    }
  }

  @Builder
  buildThemedContent() {
    Stack({ alignContent: Alignment.TopStart }) {
      this.buildMainPage();

      if (this.calendarExpanded) {
        this.buildExpandedCalendarOverlay();
      }
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 180,
      colors: [[ThemeService.getColor('page_bg', this.isEffectiveDarkMode()), 0.0], [ThemeService.getColor('page_bg_secondary', this.isEffectiveDarkMode()), 1.0]]
    })
    .animation({ duration: 220, curve: Curve.EaseInOut })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .safeAreaPadding({
      top: new LengthMetrics(0),
      bottom: new LengthMetrics(0)
    });
  }

  @Builder
  buildMainPage() {
    Column() {
      MainHeader({
        darkModeEnabled: this.isEffectiveDarkMode(),
        selectedDateKey: this.selectedDateKey,
        onOpenSettings: (): void => {
          router.pushUrl({ url: 'pages/SettingsPage' }).catch((error: Error) => {
            this.getUIContext().getPromptAction().showToast({ message: this.getText('toast_open_settings_failed_prefix', '打开设置失败: ') + error.message });
          });
        }
      });

      Scroll() {
        Column({ space: 16 }) {
          CalendarCard({
            darkModeEnabled: this.isEffectiveDarkMode(),
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

          PunchCardSection({
            darkModeEnabled: this.isEffectiveDarkMode(),
            selectedDateLabel: this.getSelectedDateLabel(),
            selectedWorkMinutes: this.getSelectedWorkMinutes(),
            startTimeText: this.getStartTimeText(),
            endTimeText: this.getEndTimeText(),
            excludeSummaryText: this.getExcludeSummaryText(),
            punchCardScale: this.punchCardScale,
            punchButtonGlow: this.punchButtonGlow,
            onPunch: (): void => {
              this.handlePunchNow();
            },
            onEditPunch: (field: string): void => {
              this.openTimePicker(field);
            }
          });

          SummaryCardsSection({
            darkModeEnabled: this.isEffectiveDarkMode(),
            summaryItems: this.getSummaryItems(),
            summaryRefreshKey: this.summaryRefreshKey,
            differenceLabel: this.getDifferenceLabel(),
            differenceColor: this.getDifferenceColor()
          });
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
  buildExpandedCalendarOverlay() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(ThemeService.getColor('scrim', this.isEffectiveDarkMode()))
        .animation({ duration: 220, curve: Curve.EaseInOut })
        .onClick(() => {
          this.calendarExpanded = false;
        });

      ExpandedCalendarPanel({
        darkModeEnabled: this.isEffectiveDarkMode(),
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

  // ========== 业务逻辑方法 ==========

  initializeData(): void {
    this.applyPersistState(this.stateService.createTodayState());

    try {
      let hostContext: Context = this.getUIContext().getHostContext() as Context;
      this.stateService.init(hostContext);
      this.loadPersistedState();
    } catch (_error) {
    }

    // 如果从持久化加载后 records 为空（首次使用），则用 mock 数据填充
    this.weekContentKey++;
    this.summaryRefreshKey++;
    this.persistState();
    this.hasInitialized = true;
  }

  loadPersistedState(): void {
    this.applyPersistState(this.stateService.loadPersistedState(this.createPersistState()));
    this.applyCurrentThemeMode();
    if (this.displayYear === 0 || this.displayMonth < 0) {
      this.syncDisplayMonthToSelectedDate();
    }
    this.weekContentKey++;
    this.monthContentKey++;
    this.summaryRefreshKey++;
  }

  persistState(): void {
    this.stateService.persistState(this.createPersistState());
  }

  createPersistState(): PersistState {
    let state: PersistState = new PersistState();
    state.selectedDateKey = this.selectedDateKey;
    state.displayYear = this.displayYear;
    state.displayMonth = this.displayMonth;
    state.targetAverageHours = this.targetAverageHours;
    state.workdayStartTime = this.workdayStartTime;
    state.excludedRanges = PunchCalculator.copyRanges(this.excludedRanges);
    state.records = WorkTimeStateService.copyRecords(this.records);
    state.darkModeEnabled = this.isEffectiveDarkMode();
    state.themeMode = ThemeService.normalizeThemeMode(this.themeMode);
    return state;
  }

  applyPersistState(state: PersistState): void {
    this.selectedDateKey = state.selectedDateKey;
    this.displayYear = state.displayYear;
    this.displayMonth = state.displayMonth;
    this.targetAverageHours = state.targetAverageHours;
    this.workdayStartTime = state.workdayStartTime;
    this.excludedRanges = PunchCalculator.copyRanges(state.excludedRanges);
    this.records = WorkTimeStateService.copyRecords(state.records);
    this.themeMode = ThemeService.normalizeThemeMode(state.themeMode);
    this.darkModeEnabled = this.isEffectiveDarkMode();
  }

  isEffectiveDarkMode(): boolean {
    return ThemeService.isDarkMode(this.themeMode, this.currentColorMode);
  }

  applyCurrentThemeMode(): void {
    try {
      let hostContext: Context = this.getUIContext().getHostContext() as Context;
      ThemeService.applyColorMode(hostContext, this.themeMode);
    } catch (_error) {
    }
  }

  syncDisplayMonthToSelectedDate(): void {
    let state: PersistState = this.stateService.syncDisplayMonthToSelectedDate(this.createPersistState());
    this.displayYear = state.displayYear;
    this.displayMonth = state.displayMonth;
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
      return this.getText('summary_no_excluded_ranges', '未设置排除时段');
    }
    return this.getText('summary_excluded_ranges_prefix', '已排除 ') + this.excludedRanges.length.toString() +
      this.getText('summary_excluded_ranges_suffix', ' 个时段');
  }

  getSummaryItems(): SummaryItem[] {
    let averageMinutes: number = this.getDisplayedMonthAverageMinutes();
    let targetMinutes: number = Math.round(this.targetAverageHours * 60);
    let items: SummaryItem[] = [];
    items.push(new SummaryItem(this.getText('summary_target_average', '目标平均工时'), TimeUtils.formatMinutes(targetMinutes)));
    items.push(new SummaryItem(this.getText('summary_current_average', '当前平均工时'), TimeUtils.formatMinutes(averageMinutes)));
    return items;
  }

  getDifferenceLabel(): string {
    let averageMinutes: number = this.getDisplayedMonthAverageMinutes();
    let targetMinutes: number = Math.round(this.targetAverageHours * 60);
    let delta: number = averageMinutes - targetMinutes;
    if (delta === 0) {
      return this.getText('summary_difference_equal', '与目标持平');
    }
    if (delta > 0) {
      return this.getText('summary_difference_more_prefix', '比目标多 ') + TimeUtils.formatMinutes(delta);
    }
    return this.getText('summary_difference_less_prefix', '比目标少 ') + TimeUtils.formatMinutes(0 - delta);
  }

  getDifferenceColor(): string {
    let averageMinutes: number = this.getDisplayedMonthAverageMinutes();
    let targetMinutes: number = Math.round(this.targetAverageHours * 60);
    return ThemeService.getDifferenceColor(averageMinutes - targetMinutes, this.isEffectiveDarkMode());
  }

  getDisplayedMonthAverageMinutes(): number {
    return PunchCalculator.getDisplayedMonthAverageMinutes(
      this.records, this.displayYear, this.displayMonth,
      this.workdayStartTime, this.excludedRanges
    );
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
        title: field === 'start' ? $r('app.string.dialog_edit_start_punch_title') : $r('app.string.dialog_edit_end_punch_title'),
        darkModeEnabled: this.isEffectiveDarkMode(),
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

  private getText(resourceName: string, fallback: string): string {
    let context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
    return ResourceTextService.getString(context, resourceName, fallback);
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
    // 日历展开时，折叠日历
    if (this.calendarExpanded) {
      this.calendarExpanded = false;
      return true;
    }

    return false;
  }
}
