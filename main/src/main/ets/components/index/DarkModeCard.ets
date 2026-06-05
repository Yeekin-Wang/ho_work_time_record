@Component
export struct DarkModeCard {
  @Prop darkModeEnabled: boolean = false;
  onToggle: (isOn: boolean) => void = (_isOn: boolean) => {};

  build() {
    Column({ space: 14 }) {
      Row() {
        Column({ space: 4 }) {
          Text('深色模式')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');
          Text('切换为深色界面。')
            .fontSize(13)
            .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);

        Toggle({ type: ToggleType.Switch, isOn: this.darkModeEnabled })
          .selectedColor('#2E67F8')
          .onChange((isOn: boolean) => {
            this.onToggle(isOn);
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
