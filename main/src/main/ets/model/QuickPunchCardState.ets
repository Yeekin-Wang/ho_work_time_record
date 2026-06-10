import { THEME_MODE_SYSTEM } from '../constants/IndexConstants';

export class QuickPunchCardState {
  todayKey: string = '';
  todayLabel: string = '';
  punchCount: number = 0;
  statusText: string = '今天还未打卡';
  actionText: string = '打卡';
  startTimeText: string = '--:--';
  endTimeText: string = '--:--';
  workMinutesText: string = '0h 0m';
  monthAverageText: string = '0h 0m';
  differenceText: string = '与目标持平';
  canPunch: boolean = true;
  lastUpdatedText: string = '';
  themeMode: string = THEME_MODE_SYSTEM;
}
