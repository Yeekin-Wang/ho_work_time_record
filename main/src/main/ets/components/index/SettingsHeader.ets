@Component
export struct SettingsHeader {
  @Prop darkModeEnabled: boolean = false;
  onBack: () => void = () => {};

  build() {
    Column({ space: 16 }) {
      Stack({ alignContent: Alignment.Center }) {
        Text('设置')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');

        Row() {
          Button('‹')
            .height(42)
            .width(42)
            .fontSize(22)
            .fontWeight(FontWeight.Normal)
            .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033')
            .backgroundColor(this.darkModeEnabled ? '#242B3D' : '#FFFFFF')
            .borderRadius(21)
            .border({ width: 1, color: this.darkModeEnabled ? '#3A4255' : '#D8E0F0' })
            .onClick(() => {
              this.onBack();
            });
        }
        .width('100%')
        .justifyContent(FlexAlign.Start);
      }
      .width('100%')
      .height(42);

      Row() {
        Blank();
        Text('')
          .fontSize(13)
          .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
        Blank();
      }
      .width('100%');
    }
    .width('100%');
  }
}
