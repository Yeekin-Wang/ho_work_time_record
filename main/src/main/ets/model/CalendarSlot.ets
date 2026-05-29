export class CalendarSlot {
  key: string = '';
  day: number = 0;
  dateKey: string = '';
  inCurrentMonth: boolean = false;
  isToday: boolean = false;
  punchCount: number = 0;

  constructor(key: string, day: number, dateKey: string, inCurrentMonth: boolean, isToday: boolean, punchCount: number) {
    this.key = key;
    this.day = day;
    this.dateKey = dateKey;
    this.inCurrentMonth = inCurrentMonth;
    this.isToday = isToday;
    this.punchCount = punchCount;
  }
}