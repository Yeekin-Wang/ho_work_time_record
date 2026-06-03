@Component
export struct DataManagementCard {
  @Prop darkModeEnabled: boolean = false;
  onExport: () => void = () => {};
  onImport: () => void = () => {};
  onClear: () => void = () => {};

  build() {
    Column({ space: 14 }) {
      Text('数据管理')
        .fontSize(12)
        .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');

      Row() {
        Column({ space: 4 }) {
          Text('导出/导入数据')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');
          Text('导出打卡数据为CSV文件，或从CSV文件导入')
            .fontSize(13)
            .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center);

      Row({ space: 12 }) {
        Button('导出数据')
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .backgroundColor('#2E67F8')
          .borderRadius(20)
          .onClick(() => {
            this.onExport();
          });

        Button('导入数据')
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033')
          .backgroundColor(this.darkModeEnabled ? '#2D3548' : '#F6F8FC')
          .borderRadius(20)
          .onClick(() => {
            this.onImport();
          });
      }
      .width('100%');

      Row() {
        Column({ space: 4 }) {
          Text('清空打卡数据')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');
          Text('清除所有打卡记录，设置项配置不受影响')
            .fontSize(13)
            .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);

        Button('清空')
          .height(36)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .backgroundColor('#D85353')
          .borderRadius(18)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            this.onClear();
          });
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center);
    }
    .width('100%')
    .padding(16)
    .borderRadius(24)
    .backgroundColor(this.darkModeEnabled ? '#242B3D' : '#FFFFFF')
    .border({ width: 1, color: this.darkModeEnabled ? '#3A4255' : '#D8E0F0' })
    .shadow({ radius: 14, color: this.darkModeEnabled ? '#0000004D' : '#12223C5C', offsetX: 0, offsetY: 4 })
    .animation({ duration: 220, curve: Curve.EaseInOut });
  }
}
