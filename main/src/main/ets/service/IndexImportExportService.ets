import { picker, fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { util } from '@kit.ArkTS';
import { zlib } from '@kit.BasicServicesKit';
import { DailyPunchRecord } from '../model/DailyPunchRecord';
import { TimeUtils } from './TimeUtils';
import { CsvTextResources, CsvUtils } from '../utils/CsvUtils';

export class ImportRecordsResult {
  records: DailyPunchRecord[] = [];
  importedCount: number = 0;
  selected: boolean = false;
}

export class IndexImportExportService {
  async exportData(context: common.UIAbilityContext, records: DailyPunchRecord[], csvText: CsvTextResources): Promise<boolean> {
    let now: Date = new Date();
    let timeStamp: string = now.getFullYear().toString() +
      TimeUtils.toTwoDigits(now.getMonth() + 1) +
      TimeUtils.toTwoDigits(now.getDate()) + '_' +
      TimeUtils.toTwoDigits(now.getHours()) +
      TimeUtils.toTwoDigits(now.getMinutes()) +
      TimeUtils.toTwoDigits(now.getSeconds());

    let baseName: string = csvText.fileNamePrefix + timeStamp;
    let tempDir: string = context.cacheDir + '/' + baseName;
    let zipPath: string = context.cacheDir + '/' + baseName + '.zip';

    try {
      this.writeExportFiles(tempDir, records, csvText);

      let options: zlib.Options = {};
      await zlib.compressFile(tempDir, zipPath, options);

      let documentSaveOptions: picker.DocumentSaveOptions = new picker.DocumentSaveOptions();
      documentSaveOptions.newFileNames = [baseName + '.zip'];
      documentSaveOptions.fileSuffixChoices = [csvText.zipSuffixChoice];

      let documentViewPicker: picker.DocumentViewPicker = new picker.DocumentViewPicker(context);
      let saveResult: string[] = await documentViewPicker.save(documentSaveOptions);
      if (saveResult.length === 0) {
        return false;
      }

      let uri: string = saveResult[0];
      let destFile: fileIo.File = fileIo.openSync(uri, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
      let srcFile: fileIo.File = fileIo.openSync(zipPath, fileIo.OpenMode.READ_ONLY);
      fileIo.copyFileSync(srcFile.fd, destFile.fd);
      fileIo.closeSync(srcFile);
      fileIo.closeSync(destFile);
      return true;
    } finally {
      this.cleanTempFiles(tempDir, zipPath);
    }
  }

  async importData(context: common.UIAbilityContext): Promise<ImportRecordsResult> {
    let documentSelectOptions: picker.DocumentSelectOptions = new picker.DocumentSelectOptions();
    documentSelectOptions.maxSelectNumber = 1;
    documentSelectOptions.fileSuffixFilters = ['.csv', '.zip'];

    let documentViewPicker: picker.DocumentViewPicker = new picker.DocumentViewPicker(context);
    let selectResult: string[] = await documentViewPicker.select(documentSelectOptions);
    let result: ImportRecordsResult = new ImportRecordsResult();
    if (selectResult.length === 0) {
      return result;
    }

    result.selected = true;
    let uri: string = selectResult[0];
    if (uri.toLowerCase().endsWith('.zip')) {
      result.records = await this.importZip(context, uri);
    } else {
      let csvContent: string = this.readCsvFile(uri);
      result.records = CsvUtils.parseCsvContent(csvContent);
    }
    result.importedCount = result.records.length;
    return result;
  }

  mergeRecords(existingRecords: DailyPunchRecord[], importRecords: DailyPunchRecord[]): DailyPunchRecord[] {
    return CsvUtils.mergeRecords(existingRecords, importRecords);
  }

  private writeExportFiles(tempDir: string, records: DailyPunchRecord[], csvText: CsvTextResources): void {
    if (!fileIo.accessSync(tempDir)) {
      fileIo.mkdirSync(tempDir);
    }

    let monthMap: Map<string, DailyPunchRecord[]> = CsvUtils.groupRecordsByMonth(records);
    let sortedMonths: string[] = Array.from(monthMap.keys()).sort();
    if (sortedMonths.length === 0) {
      this.writeTextFile(tempDir + '/' + csvText.templateFileName, CsvUtils.buildTemplateCsv(csvText));
      return;
    }

    let monthIdx: number = 0;
    while (monthIdx < sortedMonths.length) {
      let monthKey: string = sortedMonths[monthIdx];
      let monthRecords: DailyPunchRecord[] = monthMap.get(monthKey) as DailyPunchRecord[];
      monthRecords.sort((a: DailyPunchRecord, b: DailyPunchRecord) => {
        return a.dateKey.localeCompare(b.dateKey);
      });
      this.writeTextFile(tempDir + '/' + monthKey + '.csv', CsvUtils.buildMonthCsv(monthRecords, csvText));
      monthIdx += 1;
    }
  }

  private async importZip(context: common.UIAbilityContext, uri: string): Promise<DailyPunchRecord[]> {
    let tempZipPath: string = context.cacheDir + '/import_temp.zip';
    let tempExtractDir: string = context.cacheDir + '/import_temp';
    try {
      let srcFile: fileIo.File = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
      let destFile: fileIo.File = fileIo.openSync(tempZipPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
      fileIo.copyFileSync(srcFile.fd, destFile.fd);
      fileIo.closeSync(srcFile);
      fileIo.closeSync(destFile);

      if (!fileIo.accessSync(tempExtractDir)) {
        fileIo.mkdirSync(tempExtractDir);
      }

      let options: zlib.Options = {};
      await zlib.decompressFile(tempZipPath, tempExtractDir, options);

      let importedRecords: DailyPunchRecord[] = [];
      let csvFiles: string[] = fileIo.listFileSync(tempExtractDir);
      let fIdx: number = 0;
      while (fIdx < csvFiles.length) {
        let fileName: string = csvFiles[fIdx];
        if (fileName.toLowerCase().endsWith('.csv')) {
          let filePath: string = tempExtractDir + '/' + fileName;
          let parsed: DailyPunchRecord[] = CsvUtils.parseCsvContent(fileIo.readTextSync(filePath));
          let pIdx: number = 0;
          while (pIdx < parsed.length) {
            importedRecords.push(parsed[pIdx]);
            pIdx += 1;
          }
        }
        fIdx += 1;
      }
      return importedRecords;
    } finally {
      this.cleanImportTempFiles(tempZipPath, tempExtractDir);
    }
  }

  private readCsvFile(uri: string): string {
    let file: fileIo.File = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
    let stat = fileIo.statSync(file.fd);
    let buffer: ArrayBuffer = new ArrayBuffer(stat.size);
    let readLen: number = fileIo.readSync(file.fd, buffer);
    fileIo.closeSync(file);

    let decoder: util.TextDecoder = util.TextDecoder.create('utf-8');
    let uint8Array: Uint8Array = new Uint8Array(buffer.slice(0, readLen));
    return decoder.decodeToString(uint8Array);
  }

  private writeTextFile(path: string, content: string): void {
    let file: fileIo.File = fileIo.openSync(path, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
    fileIo.writeSync(file.fd, content);
    fileIo.closeSync(file);
  }

  private cleanTempFiles(tempDir: string, zipPath: string): void {
    try {
      if (fileIo.accessSync(tempDir)) {
        let files: string[] = fileIo.listFileSync(tempDir);
        let idx: number = 0;
        while (idx < files.length) {
          fileIo.unlinkSync(tempDir + '/' + files[idx]);
          idx += 1;
        }
        fileIo.rmdirSync(tempDir);
      }
      if (fileIo.accessSync(zipPath)) {
        fileIo.unlinkSync(zipPath);
      }
    } catch (_error) {
    }
  }

  private cleanImportTempFiles(tempZipPath: string, tempDir: string): void {
    try {
      if (fileIo.accessSync(tempDir)) {
        let files: string[] = fileIo.listFileSync(tempDir);
        let idx: number = 0;
        while (idx < files.length) {
          fileIo.unlinkSync(tempDir + '/' + files[idx]);
          idx += 1;
        }
        fileIo.rmdirSync(tempDir);
      }
      if (fileIo.accessSync(tempZipPath)) {
        fileIo.unlinkSync(tempZipPath);
      }
    } catch (_error) {
    }
  }
}
