export class DailyPunchRecord {
  dateKey: string = '';
  punches: number[] = [];

  constructor(dateKey: string, punches: number[]) {
    this.dateKey = dateKey;
    this.punches = punches;
  }
}