import { preferences } from '@kit.ArkData';
import { ExcludedRange } from '../model/ExcludedRange';
import { DailyPunchRecord } from '../model/DailyPunchRecord';
import { DEFAULT_TARGET_HOURS, DEFAULT_WORKDAY_START } from '../constants/IndexConstants';
import { TimeUtils } from './TimeUtils';

export class PersistState {
  schemaVersion: number = 1;
  selectedDateKey: string = '';
  displayYear: number = 0;
  displayMonth: number = 0;
  targetAverageHours: number = DEFAULT_TARGET_HOURS;
  workdayStartTime: string = DEFAULT_WORKDAY_START;
  excludedRanges: ExcludedRange[] = [];
  records: DailyPunchRecord[] = [];
  darkModeEnabled: boolean = false;
}

export class IndexPreferencesService {
  private pref: preferences.Preferences | null = null;
  private readonly schemaVersion: number = 1;
  private readonly prefName: string = 'working_time_record';
  private readonly prefStateJson: string = 'state_json';
  private readonly prefSelectedDateKey: string = 'selected_date_key';
  private readonly prefDisplayMonth: string = 'display_month';
  private readonly prefTargetHours: string = 'target_hours';
  private readonly prefWorkdayStartTime: string = 'workday_start_time';
  private readonly prefExcludedRanges: string = 'excluded_ranges';
  private readonly prefRecords: string = 'records';
  private readonly prefDarkMode: string = 'dark_mode';

  init(context: Context): void {
    try {
      this.pref = preferences.getPreferencesSync(context, { name: this.prefName });
    } catch (_error) {
      this.pref = null;
    }
  }

  loadState(state: PersistState): void {
    if (this.pref === null) {
      return;
    }

    let stateJson: string = this.pref.getSync(this.prefStateJson, '') as string;
    if (stateJson.length > 0 && this.restoreJsonState(stateJson, state)) {
      return;
    }

    this.loadLegacyState(state);
    this.persistState(state);
  }

  private loadLegacyState(state: PersistState): void {
    if (this.pref === null) {
      return;
    }

    let selectedDateKey: string = this.pref.getSync(this.prefSelectedDateKey, state.selectedDateKey) as string;
    if (selectedDateKey.length > 0) {
      state.selectedDateKey = selectedDateKey;
    }

    let displayMonthText: string = this.pref.getSync(this.prefDisplayMonth, '') as string;
    if (displayMonthText.length > 0) {
      this.restoreDisplayMonth(displayMonthText, state);
    }

    let targetHoursText: string = this.pref.getSync(this.prefTargetHours, state.targetAverageHours.toString()) as string;
    let targetHoursValue: number = Number(targetHoursText);
    if (!Number.isNaN(targetHoursValue)) {
      if (targetHoursValue < 6) {
        state.targetAverageHours = 6;
      } else if (targetHoursValue > 12) {
        state.targetAverageHours = 12;
      } else {
        state.targetAverageHours = Math.round(targetHoursValue * 10) / 10;
      }
    }

    let workdayStartTimeText: string = this.pref.getSync(this.prefWorkdayStartTime, state.workdayStartTime) as string;
    if (TimeUtils.parseTimeToMinutes(workdayStartTimeText) >= 0) {
      state.workdayStartTime = workdayStartTimeText;
    }

    let rangeText: string = this.pref.getSync(this.prefExcludedRanges, '') as string;
    if (rangeText.length > 0) {
      state.excludedRanges = this.deserializeRanges(rangeText);
    }

    let recordsText: string = this.pref.getSync(this.prefRecords, '') as string;
    if (recordsText.length > 0) {
      state.records = this.deserializeRecords(recordsText);
    }

    let darkModeText: string = this.pref.getSync(this.prefDarkMode, 'false') as string;
    state.darkModeEnabled = darkModeText === 'true';
  }

  persistState(state: PersistState): void {
    if (this.pref === null) {
      return;
    }

    try {
      state.schemaVersion = this.schemaVersion;
      this.pref.putSync(this.prefStateJson, this.serializeState(state));
      this.pref.flush();
    } catch (_error) {
    }
  }

  clearAllRecords(): void {
    if (this.pref === null) {
      return;
    }

    try {
      let state: PersistState = new PersistState();
      this.loadState(state);
      state.records = [];
      this.pref.putSync(this.prefStateJson, this.serializeState(state));
      this.pref.putSync(this.prefRecords, '');
      this.pref.flush();
    } catch (_error) {
    }
  }

  private serializeState(state: PersistState): string {
    let safeState: PersistState = new PersistState();
    safeState.schemaVersion = this.schemaVersion;
    safeState.selectedDateKey = state.selectedDateKey;
    safeState.displayYear = state.displayYear;
    safeState.displayMonth = state.displayMonth;
    safeState.targetAverageHours = state.targetAverageHours;
    safeState.workdayStartTime = state.workdayStartTime;
    safeState.excludedRanges = this.copyValidRanges(state.excludedRanges);
    safeState.records = this.copyValidRecords(state.records);
    safeState.darkModeEnabled = state.darkModeEnabled;
    return JSON.stringify(safeState);
  }

  private restoreJsonState(content: string, state: PersistState): boolean {
    try {
      let parsed: PersistState = JSON.parse(content) as PersistState;
      state.schemaVersion = this.schemaVersion;

      if (typeof parsed.selectedDateKey === 'string' && TimeUtils.parseDateKey(parsed.selectedDateKey) !== null) {
        state.selectedDateKey = parsed.selectedDateKey;
      }

      if (typeof parsed.displayYear === 'number' && typeof parsed.displayMonth === 'number' &&
        parsed.displayYear > 0 && parsed.displayMonth >= 0 && parsed.displayMonth <= 11) {
        state.displayYear = parsed.displayYear;
        state.displayMonth = parsed.displayMonth;
      }

      if (typeof parsed.targetAverageHours === 'number') {
        state.targetAverageHours = this.normalizeTargetHours(parsed.targetAverageHours);
      }

      if (typeof parsed.workdayStartTime === 'string' && TimeUtils.parseTimeToMinutes(parsed.workdayStartTime) >= 0) {
        state.workdayStartTime = parsed.workdayStartTime;
      }

      if (Array.isArray(parsed.excludedRanges)) {
        state.excludedRanges = this.copyValidRanges(parsed.excludedRanges);
      }

      if (Array.isArray(parsed.records)) {
        state.records = this.copyValidRecords(parsed.records);
      }

      if (typeof parsed.darkModeEnabled === 'boolean') {
        state.darkModeEnabled = parsed.darkModeEnabled;
      }

      return true;
    } catch (_error) {
      return false;
    }
  }

  private normalizeTargetHours(value: number): number {
    if (Number.isNaN(value)) {
      return DEFAULT_TARGET_HOURS;
    }
    if (value < 6) {
      return 6;
    }
    if (value > 12) {
      return 12;
    }
    return Math.round(value * 10) / 10;
  }

  private copyValidRanges(ranges: ExcludedRange[]): ExcludedRange[] {
    let result: ExcludedRange[] = [];
    let index: number = 0;
    while (index < ranges.length) {
      let item: ExcludedRange = ranges[index];
      if (item !== null && TimeUtils.parseTimeToMinutes(item.start) >= 0 &&
        TimeUtils.parseTimeToMinutes(item.end) > TimeUtils.parseTimeToMinutes(item.start)) {
        result.push(new ExcludedRange(item.start, item.end));
      }
      index += 1;
    }
    result.sort((a: ExcludedRange, b: ExcludedRange): number => {
      return TimeUtils.parseTimeToMinutes(a.start) - TimeUtils.parseTimeToMinutes(b.start);
    });
    return result;
  }

  private copyValidRecords(records: DailyPunchRecord[]): DailyPunchRecord[] {
    let result: DailyPunchRecord[] = [];
    let index: number = 0;
    while (index < records.length) {
      let item: DailyPunchRecord = records[index];
      if (item !== null && TimeUtils.parseDateKey(item.dateKey) !== null && Array.isArray(item.punches)) {
        let punches: number[] = [];
        let innerIndex: number = 0;
        while (innerIndex < item.punches.length) {
          let minuteValue: number = Number(item.punches[innerIndex]);
          if (!Number.isNaN(minuteValue) && minuteValue >= 0 && minuteValue < 24 * 60) {
            punches.push(minuteValue);
          }
          innerIndex += 1;
        }
        punches.sort((left: number, right: number) => left - right);
        result.push(new DailyPunchRecord(item.dateKey, punches));
      }
      index += 1;
    }
    result.sort((left: DailyPunchRecord, right: DailyPunchRecord): number => {
      return left.dateKey.localeCompare(right.dateKey);
    });
    return result;
  }

  private restoreDisplayMonth(content: string, state: PersistState): void {
    if (content.length !== 7) {
      return;
    }
    let year: number = Number(content.substring(0, 4));
    let month: number = Number(content.substring(5, 7));
    if (Number.isNaN(year) || Number.isNaN(month) || month < 1 || month > 12) {
      return;
    }
    state.displayYear = year;
    state.displayMonth = month - 1;
  }

  private deserializeRanges(content: string): ExcludedRange[] {
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

  private deserializeRecords(content: string): DailyPunchRecord[] {
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
}
