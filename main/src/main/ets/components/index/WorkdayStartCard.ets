@Component
export struct WorkdayStartCard {
  @Prop darkModeEnabled: boolean = false;
  @Prop workdayStartTime: string = '09:00';
  onOpenPicker: () => void = () => {};

  build() {
    Column({ space: 14 }) {
      Row() {
        Column({ space: 4 }) {
          Text('上班时间')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');
          Text('早于此时间的打卡，将从这里开始计算工时。')
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
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .borderRadius(24)
    .backgroundColor(this.darkModeEnabled ? '#242B3D' : '#FFFFFF')
    .border({ width: 1, color: this.darkModeEnabled ? '#3A4255' : '#D8E0F0' })
    .shadow({ radius: 14, color: this.darkModeEnabled ? '#0000004D' : '#12223C5C', offsetX: 0, offsetY: 4 })
    .animation({ duration: 220, curve: Curve.EaseInOut });
  }
}
