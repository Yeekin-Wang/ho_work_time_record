import { ExcludedRange } from '../model/ExcludedRange';
import { DailyPunchRecord } from '../model/DailyPunchRecord';
import { TimeUtils } from './TimeUtils';

/**
 * 工时计算服务 - 从 Index.ets 提取
 */
export class PunchCalculator {

  /**
   * 计算某天的工时（扣除排除时段）
   */
  static calculateWorkMinutes(
    punches: number[],
    workdayStartTime: string,
    excludedRanges: ExcludedRange[]
  ): number {
    let parseTimeToMinutes = TimeUtils.parseTimeToMinutes;

    if (punches.length < 2) {
      return 0;
    }

    let startMinute: number = punches[0];
    let configuredStartMinute: number = parseTimeToMinutes(workdayStartTime);
    if (configuredStartMinute >= 0 && startMinute < configuredStartMinute) {
      startMinute = configuredStartMinute;
    }

    let endMinute: number = punches[punches.length - 1];
    if (endMinute <= startMinute) {
      return 0;
    }

    let totalMinutes: number = endMinute - startMinute;
    let index: number = 0;
    while (index < excludedRanges.length) {
      let range: ExcludedRange = excludedRanges[index];
      let rangeStart: number = parseTimeToMinutes(range.start);
      let rangeEnd: number = parseTimeToMinutes(range.end);
      if (rangeStart >= 0 && rangeEnd > rangeStart) {
        totalMinutes -= PunchCalculator.getOverlapMinutes(startMinute, endMinute, rangeStart, rangeEnd);
      }
      index += 1;
    }

    if (totalMinutes < 0) {
      return 0;
    }
    return totalMinutes;
  }

  /**
   * 计算两个时间段的重叠分钟数
   */
  static getOverlapMinutes(
    startOne: number, endOne: number,
    startTwo: number, endTwo: number
  ): number {
    let start: number = startOne > startTwo ? startOne : startTwo;
    let end: number = endOne < endTwo ? endOne : endTwo;
    if (end <= start) {
      return 0;
    }
    return end - start;
  }

  /**
   * 获取显示月份的日平均工时（分钟）
   */
  static getDisplayedMonthAverageMinutes(
    records: DailyPunchRecord[],
    displayYear: number,
    displayMonth: number,
    workdayStartTime: string,
    excludedRanges: ExcludedRange[]
  ): number {
    let totalMinutes: number = 0;
    let validDays: number = 0;
    let index: number = 0;
    while (index < records.length) {
      let record: DailyPunchRecord = records[index];
      let date: Date | null = TimeUtils.parseDateKey(record.dateKey);
      if (date !== null && date.getFullYear() === displayYear && date.getMonth() === displayMonth) {
        let workMinutes: number = PunchCalculator.calculateWorkMinutes(
          record.punches, workdayStartTime, excludedRanges);
        if (workMinutes > 0) {
          totalMinutes += workMinutes;
          validDays += 1;
        }
      }
      index += 1;
    }
    if (validDays === 0) {
      return 0;
    }
    return Math.round(totalMinutes / validDays);
  }

  /**
   * 创建模拟打卡数据
   */
  static createMockRecords(todayKey: string): DailyPunchRecord[] {
    let result: DailyPunchRecord[] = [];
    let today: Date | null = TimeUtils.parseDateKey(todayKey);
    if (today === null) {
      return result;
    }

    let currentYear: number = today.getFullYear();
    let currentMonth: number = today.getMonth();
    let lastDayNumber: number = new Date(currentYear, currentMonth + 1, 0).getDate();
    let day: number = 1;
    while (day <= lastDayNumber) {
      let date: Date = new Date(currentYear, currentMonth, day);
      let weekDay: number = date.getDay();

      if (weekDay >= 1 && weekDay <= 5) {
        let dateKey: string = TimeUtils.createDateKey(date);
        let startMinute: number = 540 + Math.floor(day * 0.5);
        let endMinute: number = 1080 + Math.floor(day * 0.3);
        if (day % 3 === 0) {
          result.push(new DailyPunchRecord(dateKey, [startMinute]));
        } else {
          result.push(new DailyPunchRecord(dateKey, [startMinute, endMinute]));
        }
      }
      day += 1;
    }
    return result;
  }

  /**
   * 深拷贝打卡记录的打点数组
   */
  static copyPunches(source: number[]): number[] {
    let result: number[] = [];
    let index: number = 0;
    while (index < source.length) {
      result.push(source[index]);
      index += 1;
    }
    return result;
  }

  /**
   * 深拷贝排除时段列表
   */
  static copyRanges(ranges: ExcludedRange[]): ExcludedRange[] {
    let result: ExcludedRange[] = [];
    let index: number = 0;
    while (index < ranges.length) {
      let item: ExcludedRange = ranges[index];
      result.push(new ExcludedRange(item.start, item.end));
      index += 1;
    }
    return result;
  }
}