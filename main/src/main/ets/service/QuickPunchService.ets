import { WEEKDAY_NAMES } from '../constants/IndexConstants';
import { DailyPunchRecord } from '../model/DailyPunchRecord';
import { QuickPunchCardState } from '../model/QuickPunchCardState';
import { IndexPreferencesService, PersistState } from './IndexPreferencesService';
import { PunchCalculator } from './PunchCalculator';
import { TimeUtils } from './TimeUtils';
import { WorkTimeStateService } from './WorkTimeStateService';

export class QuickPunchService {
  private readonly preferencesService: IndexPreferencesService = new IndexPreferencesService();

  loadState(context: Context): PersistState {
    let state: PersistState = this.createDefaultState();
    this.preferencesService.init(context);
    this.preferencesService.loadState(state);
    this.ensureTodayContext(state, new Date());
    return state;
  }

  persistState(context: Context, state: PersistState): void {
    this.preferencesService.init(context);
    this.preferencesService.persistState(WorkTimeStateService.copyState(state));
  }

  buildCardState(context: Context): QuickPunchCardState {
    let state: PersistState = this.loadState(context);
    return QuickPunchService.buildCardStateFromPersistState(state, new Date(), '');
  }

  punchToday(context: Context): QuickPunchCardState {
    let now: Date = new Date();
    let state: PersistState = this.loadState(context);
    let feedbackText: string = QuickPunchService.appendPunchToState(state, now);
    this.persistState(context, state);
    return QuickPunchService.buildCardStateFromPersistState(state, now, feedbackText);
  }

  static appendPunchToState(state: PersistState, now: Date): string {
    let todayKey: string = TimeUtils.createDateKey(now);
    QuickPunchService.ensureTodayContextForState(state, todayKey, now);

    let currentMinute: number = now.getHours() * 60 + now.getMinutes();
    let recordIndex: number = QuickPunchService.findRecordIndex(state.records, todayKey);
    if (recordIndex < 0) {
      state.records.push(new DailyPunchRecord(todayKey, [currentMinute]));
      state.records.sort((left: DailyPunchRecord, right: DailyPunchRecord): number => {
        return left.dateKey.localeCompare(right.dateKey);
      });
      return '已记录 ' + TimeUtils.formatMinuteAsTime(currentMinute);
    }

    let record: DailyPunchRecord = state.records[recordIndex];
    if (record.punches.length > 0 && record.punches[record.punches.length - 1] === currentMinute) {
      return '刚刚已打卡';
    }

    record.punches.push(currentMinute);
    record.punches.sort((left: number, right: number): number => left - right);
    return '已记录 ' + TimeUtils.formatMinuteAsTime(currentMinute);
  }

  static buildCardStateFromPersistState(
    state: PersistState,
    now: Date,
    feedbackText: string
  ): QuickPunchCardState {
    let todayKey: string = TimeUtils.createDateKey(now);
    QuickPunchService.ensureTodayContextForState(state, todayKey, now);

    let cardState: QuickPunchCardState = new QuickPunchCardState();
    cardState.todayKey = todayKey;
    cardState.todayLabel = QuickPunchService.buildTodayLabel(todayKey);
    cardState.themeMode = state.themeMode;
    cardState.lastUpdatedText = TimeUtils.formatMinuteAsTime(now.getHours() * 60 + now.getMinutes());

    let record: DailyPunchRecord | null = QuickPunchService.getRecordByDateKey(state.records, todayKey);
    if (record !== null) {
      cardState.punchCount = record.punches.length;
      if (record.punches.length > 0) {
        cardState.startTimeText = TimeUtils.formatMinuteAsTime(record.punches[0]);
      }
      if (record.punches.length > 1) {
        cardState.endTimeText = TimeUtils.formatMinuteAsTime(record.punches[record.punches.length - 1]);
      }
      let workMinutes: number = PunchCalculator.calculateWorkMinutes(
        record.punches, state.workdayStartTime, state.excludedRanges);
      cardState.workMinutesText = TimeUtils.formatMinutes(workMinutes);
    }

    cardState.monthAverageText = TimeUtils.formatMinutes(PunchCalculator.getDisplayedMonthAverageMinutes(
      state.records, now.getFullYear(), now.getMonth(), state.workdayStartTime, state.excludedRanges));
    cardState.differenceText = QuickPunchService.buildDifferenceText(state, now);
    cardState.statusText = feedbackText.length > 0 ? feedbackText : QuickPunchService.buildStatusText(cardState);
    cardState.actionText = cardState.punchCount > 0 ? '再打' : '打卡';
    return cardState;
  }

  private createDefaultState(): PersistState {
    let state: PersistState = new PersistState();
    this.ensureTodayContext(state, new Date());
    return state;
  }

  private ensureTodayContext(state: PersistState, now: Date): void {
    QuickPunchService.ensureTodayContextForState(state, TimeUtils.createDateKey(now), now);
  }

  private static ensureTodayContextForState(state: PersistState, todayKey: string, now: Date): void {
    state.selectedDateKey = todayKey;
    state.displayYear = now.getFullYear();
    state.displayMonth = now.getMonth();
  }

  private static buildTodayLabel(todayKey: string): string {
    return TimeUtils.getDateLabelWithWeekday(todayKey, WEEKDAY_NAMES);
  }

  private static buildStatusText(state: QuickPunchCardState): string {
    if (state.punchCount === 0) {
      return '今天还未打卡';
    }
    if (state.punchCount === 1) {
      return '已打上班卡';
    }
    if (state.punchCount === 2) {
      return '今日已形成工时';
    }
    return '已打 ' + state.punchCount.toString() + ' 次';
  }

  private static buildDifferenceText(state: PersistState, now: Date): string {
    let averageMinutes: number = PunchCalculator.getDisplayedMonthAverageMinutes(
      state.records, now.getFullYear(), now.getMonth(), state.workdayStartTime, state.excludedRanges);
    let targetMinutes: number = Math.round(state.targetAverageHours * 60);
    let delta: number = averageMinutes - targetMinutes;
    if (delta === 0) {
      return '与目标持平';
    }
    if (delta > 0) {
      return '比目标多 ' + TimeUtils.formatMinutes(delta);
    }
    return '比目标少 ' + TimeUtils.formatMinutes(0 - delta);
  }

  private static findRecordIndex(records: DailyPunchRecord[], dateKey: string): number {
    let index: number = 0;
    while (index < records.length) {
      if (records[index].dateKey === dateKey) {
        return index;
      }
      index += 1;
    }
    return -1;
  }

  private static getRecordByDateKey(records: DailyPunchRecord[], dateKey: string): DailyPunchRecord | null {
    let index: number = QuickPunchService.findRecordIndex(records, dateKey);
    if (index < 0) {
      return null;
    }
    return records[index];
  }
}
