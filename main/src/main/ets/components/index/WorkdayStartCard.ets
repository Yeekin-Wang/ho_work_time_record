@Component
export struct WorkdayStartCard {
  @Prop darkModeEnabled: boolean = false;
  @Prop workdayStartTime: string = '09:00';
  onOpenPicker: () => void = () => {};

  build() {
    Column({ space: 14 }) {
      Text('工时开始时间')
        .fontSize(12)
        .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');

      Row() {
        Column({ space: 4 }) {
          Text('开始计入工时')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');
          Text('若上班打卡早于该时间，将按该时间开始计算。')
            .fontSize(13)
            .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);

        Button(this.workdayStartTime)
          .height(40)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.darkModeEnabled ? '#8B9EF5' : '#2E67F8')
          .backgroundColor(this.darkModeEnabled ? '#2D3548' : '#EEF3FF')
          .borderRadius(20)
          .padding({ left: 14, right: 14 })
          .onClick(() => {
            this.onOpenPicker();
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
