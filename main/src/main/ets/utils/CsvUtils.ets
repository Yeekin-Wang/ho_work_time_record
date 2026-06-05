import { DailyPunchRecord } from '../model/DailyPunchRecord';
import { PunchCalculator } from '../service/PunchCalculator';
import { TimeUtils } from '../service/TimeUtils';

export class CsvTextResources {
  fileNamePrefix: string = '牛马工时簿_打卡记录_';
  templateFileName: string = '导入模板.csv';
  zipSuffixChoice: string = 'ZIP 文件|.zip';
  header: string = '日期,上班打卡时间,下班打卡时间';
  instructionTitle: string = '# 说明：';
  instructionDate: string = '# 1. 日期格式为 YYYY-MM-DD，例如 2026-06-01';
  instructionTime: string = '# 2. 打卡时间格式为 HH:mm，例如 09:00';
  instructionSameDay: string = '# 3. 同一日期请填写在同一行，上班时间和下班时间分列填写';
  instructionSinglePunch: string = '# 4. 如果某天只有一次打卡，下班时间留空即可';
  instructionExample: string = '# 5. 示例：';
  exampleRow: string = '2026-06-01,09:00,18:30';
}

export class CsvUtils {
  static buildTemplateCsv(text: CsvTextResources): string {
    let templateLines: string[] = [];
    templateLines.push('\uFEFF' + text.header);
    templateLines.push(text.instructionTitle);
    templateLines.push(text.instructionDate);
    templateLines.push(text.instructionTime);
    templateLines.push(text.instructionSameDay);
    templateLines.push(text.instructionSinglePunch);
    templateLines.push(text.instructionExample);
    templateLines.push(text.exampleRow);
    return templateLines.join('\r\n');
  }

  static buildMonthCsv(records: DailyPunchRecord[], text: CsvTextResources): string {
    let csvLines: string[] = [];
    csvLines.push('\uFEFF' + text.header);
    let recIdx: number = 0;
    while (recIdx < records.length) {
      let record: DailyPunchRecord = records[recIdx];
      let firstPunch: string = record.punches.length > 0 ?
        TimeUtils.formatMinuteAsTime(record.punches[0]) : '';
      let lastPunch: string = record.punches.length > 1 ?
        TimeUtils.formatMinuteAsTime(record.punches[record.punches.length - 1]) : '';
      csvLines.push(record.dateKey + ',' + firstPunch + ',' + lastPunch);
      recIdx += 1;
    }
    return csvLines.join('\r\n');
  }

  static groupRecordsByMonth(records: DailyPunchRecord[]): Map<string, DailyPunchRecord[]> {
    let monthMap: Map<string, DailyPunchRecord[]> = new Map();
    let idx: number = 0;
    while (idx < records.length) {
      let record: DailyPunchRecord = records[idx];
      let date: Date | null = TimeUtils.parseDateKey(record.dateKey);
      if (date !== null) {
        let monthKey: string = date.getFullYear().toString() + '-' + TimeUtils.toTwoDigits(date.getMonth() + 1);
        let group: DailyPunchRecord[] | undefined = monthMap.get(monthKey);
        if (group === undefined) {
          group = [];
          monthMap.set(monthKey, group);
        }
        group.push(record);
      }
      idx += 1;
    }
    return monthMap;
  }

  static parseCsvContent(csvContent: string): DailyPunchRecord[] {
    let result: DailyPunchRecord[] = [];
    if (csvContent.length > 0 && csvContent.charCodeAt(0) === 0xFEFF) {
      csvContent = csvContent.substring(1);
    }
    let lines: string[] = csvContent.split('\n');
    let lineIdx: number = 0;
    while (lineIdx < lines.length) {
      let line: string = lines[lineIdx].trim();
      if (line.length === 0 || line.startsWith('日期') || line.startsWith('#')) {
        lineIdx += 1;
        continue;
      }
      let parts: string[] = line.split(',');
      if (parts.length >= 2) {
        let dateKey: string = parts[0].trim();
        let morningMinutes: number = parts[1].trim().length > 0 ?
          TimeUtils.parseTimeToMinutes(parts[1].trim()) : -1;
        let eveningMinutes: number = (parts.length >= 3 && parts[2].trim().length > 0) ?
          TimeUtils.parseTimeToMinutes(parts[2].trim()) : -1;

        if (TimeUtils.parseDateKey(dateKey) !== null) {
          let punches: number[] = [];
          if (morningMinutes >= 0) {
            punches.push(morningMinutes);
          }
          if (eveningMinutes >= 0 && eveningMinutes !== morningMinutes) {
            punches.push(eveningMinutes);
          }
          if (punches.length > 0) {
            punches.sort((a: number, b: number) => a - b);
            result.push(new DailyPunchRecord(dateKey, punches));
          }
        }
      }
      lineIdx += 1;
    }
    return result;
  }

  static mergeRecords(existingRecords: DailyPunchRecord[], importRecords: DailyPunchRecord[]): DailyPunchRecord[] {
    let result: DailyPunchRecord[] = [];
    let idx: number = 0;
    while (idx < existingRecords.length) {
      let matched: boolean = false;
      let impIdx: number = 0;
      while (impIdx < importRecords.length) {
        if (importRecords[impIdx].dateKey === existingRecords[idx].dateKey) {
          matched = true;
          break;
        }
        impIdx += 1;
      }
      if (!matched) {
        result.push(new DailyPunchRecord(existingRecords[idx].dateKey,
          PunchCalculator.copyPunches(existingRecords[idx].punches)));
      }
      idx += 1;
    }

    let impIdx: number = 0;
    while (impIdx < importRecords.length) {
      result.push(new DailyPunchRecord(importRecords[impIdx].dateKey,
        PunchCalculator.copyPunches(importRecords[impIdx].punches)));
      impIdx += 1;
    }

    result.sort((a: DailyPunchRecord, b: DailyPunchRecord) => {
      return a.dateKey.localeCompare(b.dateKey);
    });
    return result;
  }
}
