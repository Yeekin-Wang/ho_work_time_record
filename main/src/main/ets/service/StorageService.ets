import { preferences } from '@kit.ArkData';
import { ExcludedRange } from '../model/ExcludedRange';
import { DailyPunchRecord } from '../model/DailyPunchRecord';
import { TimeUtils } from './TimeUtils';

/**
 * 持久化状态数据对象
 */
export class PersistState {
  selectedDateKey: string = '';
  displayYear: number = 0;
  displayMonth: number = 0;
  targetAverageHours: number = 8;
  workdayStartTime: string = '09:00';
  excludedRanges: ExcludedRange[] = [];
  records: DailyPunchRecord[] = [];
  darkModeEnabled: boolean = false;
}

/**
 * 数据持久化服务
 */
export class StorageService {
  private pref: preferences.Preferences | null = null;
  private readonly prefName: string = 'working_time_record';
  private readonly prefSelectedDateKey: string = 'selected_date_key';
  private readonly prefDisplayMonth: string = 'display_month';
  private readonly prefTargetHours: string = 'target_hours';
  private readonly prefWorkdayStartTime: string = 'workday_start_time';
  private readonly prefExcludedRanges: string = 'excluded_ranges';
  private readonly prefRecords: string = 'records';

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

    let darkModeText: string = this.pref.getSync('dark_mode', 'false') as string;
    state.darkModeEnabled = darkModeText === 'true';
  }

  persistState(state: PersistState): void {
    if (this.pref === null) {
      return;
    }

    try {
      this.pref.putSync(this.prefSelectedDateKey, state.selectedDateKey);
      this.pref.putSync(this.prefDisplayMonth, this.getDisplayMonthKey(state.displayYear, state.displayMonth));
      this.pref.putSync(this.prefTargetHours, state.targetAverageHours.toString());
      this.pref.putSync(this.prefWorkdayStartTime, state.workdayStartTime);
      this.pref.putSync(this.prefExcludedRanges, this.serializeRanges(state.excludedRanges));
      this.pref.putSync(this.prefRecords, this.serializeRecords(state.records));
      this.pref.putSync('dark_mode', state.darkModeEnabled.toString());
      this.pref.flush();
    } catch (_error) {
    }
  }

  /**
   * 清空所有打卡记录（保留其他配置）
   */
  clearAllRecords(state: PersistState): void {
    state.records = [];
    if (this.pref !== null) {
      try {
        this.pref.putSync(this.prefRecords, '');
        this.pref.flush();
      } catch (_error) {
      }
    }
  }

  private getDisplayMonthKey(year: number, month: number): string {
    return year.toString() + '-' + TimeUtils.toTwoDigits(month + 1);
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

  serializeRanges(ranges: ExcludedRange[]): string {
    let result: string = '';
    let index: number = 0;
    while (index < ranges.length) {
      let item: ExcludedRange = ranges[index];
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

  serializeRecords(records: DailyPunchRecord[]): string {
    let result: string = '';
    let index: number = 0;
    while (index < records.length) {
      let item: DailyPunchRecord = records[index];
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
}