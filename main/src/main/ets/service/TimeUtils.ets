/**
 * 时间/日期工具函数 - 从 Index.ets 提取
 */
export class TimeUtils {
  /**
   * 数字补零
   */
  static toTwoDigits(value: number): string {
    if (value < 10) {
      return '0' + value.toString();
    }
    return value.toString();
  }

  /**
   * 解析 HH:MM 字符串为分钟数
   */
  static parseTimeToMinutes(value: string): number {
    if (value.length !== 5) {
      return -1;
    }
    if (value.charAt(2) !== ':') {
      return -1;
    }
    let hours: number = Number(value.substring(0, 2));
    let minutes: number = Number(value.substring(3, 5));
    if (Number.isNaN(hours) || Number.isNaN(minutes)) {
      return -1;
    }
    if (hours < 0 || hours > 23) {
      return -1;
    }
    if (minutes < 0 || minutes > 59) {
      return -1;
    }
    return hours * 60 + minutes;
  }

  /**
   * 将 Date 转为 YYYY-MM-DD 格式
   */
  static createDateKey(date: Date): string {
    return date.getFullYear().toString() + '-' +
      TimeUtils.toTwoDigits(date.getMonth() + 1) + '-' +
      TimeUtils.toTwoDigits(date.getDate());
  }

  /**
   * 将 YYYY-MM-DD 解析为 Date
   */
  static parseDateKey(dateKey: string): Date | null {
    if (dateKey.length !== 10) {
      return null;
    }
    let year: number = Number(dateKey.substring(0, 4));
    let month: number = Number(dateKey.substring(5, 7));
    let day: number = Number(dateKey.substring(8, 10));
    if (Number.isNaN(year) || Number.isNaN(month) || Number.isNaN(day)) {
      return null;
    }
    if (month < 1 || month > 12 || day < 1 || day > 31) {
      return null;
    }
    let parsedDate: Date = new Date(year, month - 1, day);
    if (parsedDate.getFullYear() !== year || parsedDate.getMonth() !== month - 1 ||
      parsedDate.getDate() !== day) {
      return null;
    }
    return parsedDate;
  }

  /**
   * 获取带星期几的日期描述
   */
  static getDateLabelWithWeekday(dateKey: string, weekdayNames: string[]): string {
    let date: Date | null = TimeUtils.parseDateKey(dateKey);
    if (date === null) {
      return dateKey;
    }
    let weekdayIndex: number = date.getDay() === 0 ? 6 : date.getDay() - 1;
    return '星期' + weekdayNames[weekdayIndex] + ' ' + TimeUtils.getDateLabelWithoutWeekday(dateKey);
  }

  /**
   * 获取 MM-DD 格式日期
   */
  static getDateLabelWithoutWeekday(dateKey: string): string {
    let date: Date | null = TimeUtils.parseDateKey(dateKey);
    if (date === null) {
      return dateKey;
    }
    return TimeUtils.toTwoDigits(date.getMonth() + 1) + '-' + TimeUtils.toTwoDigits(date.getDate());
  }

  /**
   * 获取当前分钟数（0~1439）
   */
  static getCurrentMinuteOfDay(): number {
    let now: Date = new Date();
    return now.getHours() * 60 + now.getMinutes();
  }

  /**
   * 将时间字符串转为 TimePicker 可用的 Date
   */
  static createTimePickerDate(value: string): Date {
    let minutes: number = TimeUtils.parseTimeToMinutes(value);
    if (minutes < 0) {
      minutes = 0;
    }
    let hour: number = Math.floor(minutes / 60);
    let minute: number = minutes % 60;
    return new Date(2024, 0, 1, hour, minute, 0);
  }

  /**
   * 格式化分钟数为 "Xh Ym"
   */
  static formatMinutes(totalMinutes: number): string {
    let hours: number = Math.floor(totalMinutes / 60);
    let minutes: number = totalMinutes % 60;
    return hours.toString() + 'h ' + minutes.toString() + 'm';
  }

  /**
   * 格式化小时数为 "X.Xh"
   */
  static formatHoursValue(value: number): string {
    let roundedValue: number = Math.round(value * 10) / 10;
    return roundedValue.toFixed(1) + 'h';
  }

  /**
   * 将分钟数转为 HH:MM 格式
   */
  static formatMinuteAsTime(minuteOfDay: number): string {
    let hours: number = Math.floor(minuteOfDay / 60);
    let minutes: number = minuteOfDay % 60;
    return TimeUtils.toTwoDigits(hours) + ':' + TimeUtils.toTwoDigits(minutes);
  }

  /**
   * 获取月份标题
   */
  static getCurrentMonthTitle(year: number, month: number): string {
    return year.toString() + '年 ' + (month + 1).toString() + '月';
  }

  /**
   * 获取选中日期的描述文字
   */
  static getSelectedDateDescription(selectedDateKey: string): string {
    let todayKey: string = TimeUtils.createDateKey(new Date());
    if (selectedDateKey === todayKey) {
      return '今天';
    }
    let weekdayNames: string[] = ['一', '二', '三', '四', '五', '六', '日'];
    return TimeUtils.getDateLabelWithWeekday(selectedDateKey, weekdayNames);
  }
}
