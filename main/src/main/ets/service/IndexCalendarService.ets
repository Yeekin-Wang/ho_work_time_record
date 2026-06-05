import { DailyPunchRecord } from '../model/DailyPunchRecord';
import { CalendarSlot } from '../model/CalendarSlot';
import { TimeUtils } from './TimeUtils';
import { ThemeService } from './ThemeService';

export class IndexCalendarService {
  static buildMonthSlots(displayYear: number, displayMonth: number, records: DailyPunchRecord[]): CalendarSlot[] {
    let result: CalendarSlot[] = [];
    let firstDay: Date = new Date(displayYear, displayMonth, 1);
    let firstWeekDay: number = firstDay.getDay();
    let firstColumn: number = firstWeekDay === 0 ? 6 : firstWeekDay - 1;
    let blankIndex: number = 0;
    while (blankIndex < firstColumn) {
      result.push(new CalendarSlot('blank_' + blankIndex.toString(), 0, '', false, false, 0));
      blankIndex += 1;
    }

    let todayKey: string = TimeUtils.createDateKey(new Date());
    let lastDayNumber: number = new Date(displayYear, displayMonth + 1, 0).getDate();
    let day: number = 1;
    while (day <= lastDayNumber) {
      let date: Date = new Date(displayYear, displayMonth, day);
      let dateKey: string = TimeUtils.createDateKey(date);
      result.push(new CalendarSlot(
        dateKey,
        day,
        dateKey,
        true,
        dateKey === todayKey,
        IndexCalendarService.getRecordPunchCount(records, dateKey)
      ));
      day += 1;
    }

    while (result.length % 7 !== 0) {
      result.push(new CalendarSlot('tail_' + result.length.toString(), 0, '', false, false, 0));
    }
    return result;
  }

  static getCurrentWeekSlots(
    selectedDateKey: string,
    displayYear: number,
    displayMonth: number,
    calendarWeekOffset: number,
    records: DailyPunchRecord[]
  ): CalendarSlot[] {
    let selectedDate: Date | null = TimeUtils.parseDateKey(selectedDateKey);
    if (selectedDate === null) {
      return [];
    }

    let dayOfWeek: number = selectedDate.getDay();
    let weekStartOffset: number = dayOfWeek === 0 ? -6 : 1 - dayOfWeek;
    let monday: Date = new Date(selectedDate.getFullYear(), selectedDate.getMonth(), selectedDate.getDate() + weekStartOffset);
    let targetMonday: Date = new Date(monday.getFullYear(), monday.getMonth(), monday.getDate() + calendarWeekOffset * 7);

    let row: CalendarSlot[] = [];
    let todayKey: string = TimeUtils.createDateKey(new Date());
    for (let i: number = 0; i < 7; i++) {
      let date: Date = new Date(targetMonday.getFullYear(), targetMonday.getMonth(), targetMonday.getDate() + i);
      let dateKey: string = TimeUtils.createDateKey(date);
      row.push(new CalendarSlot(
        dateKey,
        date.getDate(),
        dateKey,
        date.getFullYear() === displayYear && date.getMonth() === displayMonth,
        dateKey === todayKey,
        IndexCalendarService.getRecordPunchCount(records, dateKey)
      ));
    }
    return row;
  }

  static getExpandedCalendarRows(monthSlots: CalendarSlot[]): CalendarSlot[][] {
    let result: CalendarSlot[][] = [];
    let index: number = 0;
    while (index < monthSlots.length) {
      let row: CalendarSlot[] = [];
      let rowInnerIndex: number = 0;
      while (rowInnerIndex < 7 && index < monthSlots.length) {
        row.push(monthSlots[index]);
        rowInnerIndex += 1;
        index += 1;
      }
      result.push(row);
    }
    return result;
  }

  static getDayCellColor(slot: CalendarSlot, selectedDateKey: string, _darkModeEnabled: boolean): ResourceColor {
    if (!slot.inCurrentMonth) {
      return ThemeService.getColor('transparent', _darkModeEnabled);
    }
    if (slot.dateKey === selectedDateKey) {
      return ThemeService.getColor('brand', _darkModeEnabled);
    }
    if (slot.isToday) {
      return ThemeService.getColor('surface_brand_bg', _darkModeEnabled);
    }
    return ThemeService.getColor('calendar_idle_bg', _darkModeEnabled);
  }

  private static getRecordPunchCount(records: DailyPunchRecord[], dateKey: string): number {
    let index: number = 0;
    while (index < records.length) {
      let record: DailyPunchRecord = records[index];
      if (record.dateKey === dateKey) {
        return record.punches.length;
      }
      index += 1;
    }
    return 0;
  }
}
