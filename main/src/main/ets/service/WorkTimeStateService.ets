import { ExcludedRange } from '../model/ExcludedRange';
import { DailyPunchRecord } from '../model/DailyPunchRecord';
import { IndexViewModel } from '../viewmodel/IndexViewModel';
import { IndexPreferencesService, PersistState } from './IndexPreferencesService';
import { PunchCalculator } from './PunchCalculator';

export class WorkTimeStateService {
  private readonly viewModel: IndexViewModel = new IndexViewModel();
  private readonly preferencesService: IndexPreferencesService = new IndexPreferencesService();

  init(context: Context): void {
    this.preferencesService.init(context);
  }

  createTodayState(): PersistState {
    this.viewModel.resetToToday();
    return this.viewModel.createPersistState();
  }

  loadPersistedState(currentState: PersistState): PersistState {
    this.viewModel.applyPersistState(currentState);
    let state: PersistState = this.viewModel.createPersistState();
    this.preferencesService.loadState(state);
    this.viewModel.applyPersistState(state);
    return this.viewModel.createPersistState();
  }

  persistState(state: PersistState): void {
    this.preferencesService.persistState(WorkTimeStateService.copyState(state));
  }

  clearAllRecords(): void {
    this.preferencesService.clearAllRecords();
  }

  syncDisplayMonthToSelectedDate(state: PersistState): PersistState {
    this.viewModel.applyPersistState(state);
    this.viewModel.syncDisplayMonthToSelectedDate();
    return this.viewModel.createPersistState();
  }

  static copyState(source: PersistState): PersistState {
    let state: PersistState = new PersistState();
    state.selectedDateKey = source.selectedDateKey;
    state.displayYear = source.displayYear;
    state.displayMonth = source.displayMonth;
    state.targetAverageHours = source.targetAverageHours;
    state.workdayStartTime = source.workdayStartTime;
    state.excludedRanges = PunchCalculator.copyRanges(source.excludedRanges);
    state.records = WorkTimeStateService.copyRecords(source.records);
    state.darkModeEnabled = source.darkModeEnabled;
    return state;
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

  static copyRanges(ranges: ExcludedRange[]): ExcludedRange[] {
    return PunchCalculator.copyRanges(ranges);
  }
}
