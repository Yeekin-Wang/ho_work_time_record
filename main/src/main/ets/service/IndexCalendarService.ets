import { DailyPunchRecord } from '../model/DailyPunchRecord';
import { CalendarSlot } from '../model/CalendarSlot';
import { TimeUtils } from './TimeUtils';

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

  static getDayCellColor(slot: CalendarSlot, selectedDateKey: string, darkModeEnabled: boolean): string {
    if (!slot.inCurrentMonth) {
      return '#00000000';
    }
    if (slot.dateKey === selectedDateKey) {
      return '#2E67F8';
    }
    if (slot.isToday) {
      return darkModeEnabled ? '#2D3548' : '#EEF3FF';
    }
    return darkModeEnabled ? '#1E2636' : '#F6F8FC';
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
