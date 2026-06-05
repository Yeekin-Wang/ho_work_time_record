import { describe, it, expect } from '@ohos/hypium';
import { ExcludedRange } from '../main/ets/model/ExcludedRange';
import { DailyPunchRecord } from '../main/ets/model/DailyPunchRecord';
import { TimeUtils } from '../main/ets/service/TimeUtils';
import { PunchCalculator } from '../main/ets/service/PunchCalculator';
import { CsvUtils } from '../main/ets/utils/CsvUtils';

export default function localUnitTest() {
  describe('TimeUtils', () => {
    it('parseTimeToMinutes accepts valid HH:mm', 0, () => {
      expect(TimeUtils.parseTimeToMinutes('09:30')).assertEqual(570);
      expect(TimeUtils.parseTimeToMinutes('23:59')).assertEqual(1439);
    });

    it('parseTimeToMinutes rejects invalid time text', 0, () => {
      expect(TimeUtils.parseTimeToMinutes('24:00')).assertEqual(-1);
      expect(TimeUtils.parseTimeToMinutes('12:60')).assertEqual(-1);
      expect(TimeUtils.parseTimeToMinutes('9:00')).assertEqual(-1);
      expect(TimeUtils.parseTimeToMinutes('')).assertEqual(-1);
    });

    it('parseDateKey rejects impossible calendar dates', 0, () => {
      expect(TimeUtils.parseDateKey('2026-02-31') === null).assertEqual(true);
      expect(TimeUtils.parseDateKey('2026-13-01') === null).assertEqual(true);
      expect(TimeUtils.parseDateKey('2026-06-05') !== null).assertEqual(true);
    });
  });

  describe('PunchCalculator', () => {
    it('calculates work minutes from configured start and excludes rest ranges', 0, () => {
      let ranges: ExcludedRange[] = [new ExcludedRange('12:00', '13:00')];
      let punches: number[] = [
        TimeUtils.parseTimeToMinutes('08:30'),
        TimeUtils.parseTimeToMinutes('18:30')
      ];
      expect(PunchCalculator.calculateWorkMinutes(punches, '09:00', ranges)).assertEqual(510);
    });

    it('returns zero when fewer than two punches exist', 0, () => {
      expect(PunchCalculator.calculateWorkMinutes([TimeUtils.parseTimeToMinutes('09:00')], '09:00', [])).assertEqual(0);
    });

    it('calculates displayed month average from valid work days only', 0, () => {
      let records: DailyPunchRecord[] = [
        new DailyPunchRecord('2026-06-01', [540, 1080]),
        new DailyPunchRecord('2026-06-02', [540]),
        new DailyPunchRecord('2026-07-01', [540, 1140])
      ];
      expect(PunchCalculator.getDisplayedMonthAverageMinutes(records, 2026, 5, '09:00', [])).assertEqual(540);
    });
  });

  describe('CsvUtils', () => {
    it('parses valid rows and ignores comments and invalid dates', 0, () => {
      let csv: string = '\uFEFF日期,上班打卡时间,下班打卡时间\r\n' +
        '# comment\r\n' +
        '2026-06-01,09:00,18:30\r\n' +
        '2026-02-31,09:00,18:00\r\n';
      let records: DailyPunchRecord[] = CsvUtils.parseCsvContent(csv);
      expect(records.length).assertEqual(1);
      expect(records[0].dateKey).assertEqual('2026-06-01');
      expect(records[0].punches[0]).assertEqual(540);
      expect(records[0].punches[1]).assertEqual(1110);
    });

    it('mergeRecords replaces records with the same date', 0, () => {
      let existingRecords: DailyPunchRecord[] = [
        new DailyPunchRecord('2026-06-01', [540, 1080]),
        new DailyPunchRecord('2026-06-02', [540, 1080])
      ];
      let importRecords: DailyPunchRecord[] = [
        new DailyPunchRecord('2026-06-02', [600, 1140])
      ];
      let merged: DailyPunchRecord[] = CsvUtils.mergeRecords(existingRecords, importRecords);
      expect(merged.length).assertEqual(2);
      expect(merged[1].dateKey).assertEqual('2026-06-02');
      expect(merged[1].punches[0]).assertEqual(600);
    });
  });
}
