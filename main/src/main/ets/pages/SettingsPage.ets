import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction, LengthMetrics, router } from '@kit.ArkUI';
import { ExcludedRange } from '../model/ExcludedRange';
import { DailyPunchRecord } from '../model/DailyPunchRecord';
import { PunchCalculator } from '../service/PunchCalculator';
import { TimeUtils } from '../service/TimeUtils';
import { IndexImportExportService, ImportRecordsResult } from '../service/IndexImportExportService';
import { IndexPreferencesService, PersistState } from '../service/IndexPreferencesService';
import { DEFAULT_RANGE_END, DEFAULT_RANGE_START, DEFAULT_TARGET_HOURS, DEFAULT_WORKDAY_START } from '../constants/IndexConstants';
import { IndexViewModel } from '../viewmodel/IndexViewModel';
import { SettingsHeader } from '../components/index/SettingsHeader';
import { WorkdayStartCard } from '../components/index/WorkdayStartCard';
import { ExcludedRangesCard } from '../components/index/ExcludedRangesCard';
import { TargetHoursCard } from '../components/index/TargetHoursCard';
import { DarkModeCard } from '../components/index/DarkModeCard';
import { DataManagementCard } from '../components/index/DataManagementCard';
import { RangeEditDialog } from '../components/dialogs/RangeEditDialog';
import { RangeConflictDialog } from '../components/dialogs/RangeConflictDialog';
import { CustomTimePickerDialog } from './CustomTimePickerDialog';

@Entry
@Component
struct SettingsPage {
  @State selectedDateKey: string = '';
  @State displayYear: number = 0;
  @State displayMonth: number = 0;
  @State targetAverageHours: number = DEFAULT_TARGET_HOURS;
  @State workdayStartTime: string = DEFAULT_WORKDAY_START;
  @State excludedRanges: ExcludedRange[] = [];
  @State records: DailyPunchRecord[] = [];
  @State darkModeEnabled: boolean = false;
  @State showRangeDialog: boolean = false;
  @State showRangeConflictDialog: boolean = false;
  @State rangeStartInput: string = DEFAULT_RANGE_START;
  @State rangeEndInput: string = DEFAULT_RANGE_END;
  @State confirmDeleteIndex: number = -1;
  @State editRangeIndex: number = -1;

  private rangeTimePickerController: CustomDialogController | null = null;
  private workdayStartPickerController: CustomDialogController | null = null;
  private readonly viewModel: IndexViewModel = new IndexViewModel();
  private readonly preferencesService: IndexPreferencesService = new IndexPreferencesService();
  private readonly importExportService: IndexImportExportService = new IndexImportExportService();

  aboutToAppear(): void {
    this.initializeData();
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      this.buildSettingsContent();
      this.buildDialogs();
    }
    .width('100%')
    .height('100%')
    .backgroundColor(this.darkModeEnabled ? '#1A1F2E' : '#F9FBFF')
    .animation({ duration: 220, curve: Curve.EaseInOut })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .safeAreaPadding({
      top: new LengthMetrics(0),
      bottom: new LengthMetrics(0)
    });
  }

  @Builder
  buildSettingsContent() {
    Column({ space: 16 }) {
      SettingsHeader({
        darkModeEnabled: this.darkModeEnabled,
        onBack: (): void => {
          this.closeSettingsPage();
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
              this.showRangeDialog = true;
            },
            onResetDeleteConfirm: (): void => {
              this.resetDeleteConfirm();
            }
          });
          TargetHoursCard({
            darkModeEnabled: this.darkModeEnabled,
            targetAverageHours: this.targetAverageHours,
            onChange: (value: number): void => {
              this.targetAverageHours = Math.round(value * 10) / 10;
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
    .onClick(() => {
      if (this.confirmDeleteIndex >= 0) {
        this.resetDeleteConfirm();
      }
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

  initializeData(): void {
    this.viewModel.resetToToday();
    this.applyViewModelState();

    try {
      let hostContext: Context = this.getUIContext().getHostContext() as Context;
      this.preferencesService.init(hostContext);
      let state: PersistState = this.viewModel.createPersistState();
      this.preferencesService.loadState(state);
      this.viewModel.applyPersistState(state);
      this.applyViewModelState();
    } catch (_error) {
    }
  }

  closeSettingsPage(): void {
    this.confirmDeleteIndex = -1;
    router.back();
  }

  persistState(): void {
    this.preferencesService.persistState(this.createPersistState());
  }

  createPersistState(): PersistState {
    this.updateViewModelState();
    return this.viewModel.createPersistState();
  }

  applyPersistState(state: PersistState): void {
    this.viewModel.applyPersistState(state);
    this.applyViewModelState();
  }

  updateViewModelState(): void {
    this.viewModel.selectedDateKey = this.selectedDateKey;
    this.viewModel.displayYear = this.displayYear;
    this.viewModel.displayMonth = this.displayMonth;
    this.viewModel.targetAverageHours = this.targetAverageHours;
    this.viewModel.workdayStartTime = this.workdayStartTime;
    this.viewModel.excludedRanges = PunchCalculator.copyRanges(this.excludedRanges);
    this.viewModel.records = IndexViewModel.copyRecords(this.records);
    this.viewModel.darkModeEnabled = this.darkModeEnabled;
  }

  applyViewModelState(): void {
    this.selectedDateKey = this.viewModel.selectedDateKey;
    this.displayYear = this.viewModel.displayYear;
    this.displayMonth = this.viewModel.displayMonth;
    this.targetAverageHours = this.viewModel.targetAverageHours;
    this.workdayStartTime = this.viewModel.workdayStartTime;
    this.excludedRanges = PunchCalculator.copyRanges(this.viewModel.excludedRanges);
    this.records = IndexViewModel.copyRecords(this.viewModel.records);
    this.darkModeEnabled = this.viewModel.darkModeEnabled;
  }

  resetDeleteConfirm(): void {
    this.getUIContext().animateTo({ duration: 200, curve: Curve.EaseInOut }, () => {
      this.confirmDeleteIndex = -1;
    });
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

  confirmAddRange(): void {
    let startMinute: number = TimeUtils.parseTimeToMinutes(this.rangeStartInput);
    let endMinute: number = TimeUtils.parseTimeToMinutes(this.rangeEndInput);
    if (startMinute < 0 || endMinute <= startMinute) {
      return;
    }

    let hasOverlap: boolean = false;
    let idx: number = 0;
    while (idx < this.excludedRanges.length) {
      if (this.editRangeIndex >= 0 && idx === this.editRangeIndex) {
        idx++;
        continue;
      }
      let existing: ExcludedRange = this.excludedRanges[idx];
      let existStart: number = TimeUtils.parseTimeToMinutes(existing.start);
      let existEnd: number = TimeUtils.parseTimeToMinutes(existing.end);
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
      nextRanges[this.editRangeIndex] = new ExcludedRange(this.rangeStartInput, this.rangeEndInput);
    } else {
      nextRanges.push(new ExcludedRange(this.rangeStartInput, this.rangeEndInput));
    }
    nextRanges.sort((a: ExcludedRange, b: ExcludedRange): number => {
      return TimeUtils.parseTimeToMinutes(a.start) - TimeUtils.parseTimeToMinutes(b.start);
    });
    this.excludedRanges = nextRanges;
    this.showRangeDialog = false;
    this.editRangeIndex = -1;
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
    this.excludedRanges = nextRanges;
    this.persistState();
  }

  private async exportRecordsToCsv(): Promise<void> {
    try {
      let context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
      let exported: boolean = await this.importExportService.exportData(context, this.records);
      if (exported) {
        this.getUIContext().getPromptAction().showToast({ message: '导出成功' });
      }
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      if (err.code !== 13900015) {
        this.getUIContext().getPromptAction().showToast({ message: '导出失败: ' + err.message });
      }
    }
  }

  private async importRecordsFromCsv(): Promise<void> {
    try {
      let context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
      let importResult: ImportRecordsResult = await this.importExportService.importData(context);
      if (importResult.importedCount > 0) {
        this.records = this.importExportService.mergeRecords(this.records, importResult.records);
        this.persistState();
        this.getUIContext().getPromptAction().showToast({ message: '导入成功，共 ' + importResult.importedCount.toString() + ' 天数据' });
      } else if (importResult.selected) {
        this.getUIContext().getPromptAction().showToast({ message: '未解析到有效打卡数据' });
      }
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      if (err.code !== 13900015) {
        this.getUIContext().getPromptAction().showToast({ message: '导入失败: ' + err.message });
      }
    }
  }

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
        this.preferencesService.clearAllRecords();
        this.records = [];
        context.getPromptAction().showToast({ message: '打卡数据已清空' });
      }
    }).catch(() => {});
  }

  onBackPress(): boolean {
    if (this.showRangeDialog) {
      this.showRangeDialog = false;
      this.editRangeIndex = -1;
      return true;
    }

    if (this.showRangeConflictDialog) {
      this.showRangeConflictDialog = false;
      return true;
    }

    router.back();
    return true;
  }
}
