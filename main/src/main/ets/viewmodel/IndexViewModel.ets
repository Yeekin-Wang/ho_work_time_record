import { ExcludedRange } from '../model/ExcludedRange';
import { DailyPunchRecord } from '../model/DailyPunchRecord';
import { DEFAULT_TARGET_HOURS, DEFAULT_WORKDAY_START, THEME_MODE_SYSTEM } from '../constants/IndexConstants';
import { PersistState } from '../service/IndexPreferencesService';
import { PunchCalculator } from '../service/PunchCalculator';
import { TimeUtils } from '../service/TimeUtils';

export class IndexViewModel {
  selectedDateKey: string = '';
  displayYear: number = 0;
  displayMonth: number = 0;
  targetAverageHours: number = DEFAULT_TARGET_HOURS;
  workdayStartTime: string = DEFAULT_WORKDAY_START;
  excludedRanges: ExcludedRange[] = [];
  records: DailyPunchRecord[] = [];
  darkModeEnabled: boolean = false;
  themeMode: string = THEME_MODE_SYSTEM;

  resetToToday(): void {
    this.selectedDateKey = TimeUtils.createDateKey(new Date());
    this.syncDisplayMonthToSelectedDate();
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

  createPersistState(): PersistState {
    let state: PersistState = new PersistState();
    state.selectedDateKey = this.selectedDateKey;
    state.displayYear = this.displayYear;
    state.displayMonth = this.displayMonth;
    state.targetAverageHours = this.targetAverageHours;
    state.workdayStartTime = this.workdayStartTime;
    state.excludedRanges = PunchCalculator.copyRanges(this.excludedRanges);
    state.records = IndexViewModel.copyRecords(this.records);
    state.darkModeEnabled = this.darkModeEnabled;
    state.themeMode = this.themeMode;
    return state;
  }

  applyPersistState(state: PersistState): void {
    this.selectedDateKey = state.selectedDateKey;
    this.displayYear = state.displayYear;
    this.displayMonth = state.displayMonth;
    this.targetAverageHours = state.targetAverageHours;
    this.workdayStartTime = state.workdayStartTime;
    this.excludedRanges = PunchCalculator.copyRanges(state.excludedRanges);
    this.records = IndexViewModel.copyRecords(state.records);
    this.darkModeEnabled = state.darkModeEnabled;
    this.themeMode = state.themeMode;
  }

  static copyRecords(records: DailyPunchRecord[]): DailyPunchRecord[] {
    let result: DailyPunchRecord[] = [];
    let index: number = 0;
    while (index < records.length) {
      result.push(new DailyPunchRecord(records[index].dateKey, PunchCalculator.copyPunches(records[index].punches)));
      index += 1;
    }
    return result;
  }
}
