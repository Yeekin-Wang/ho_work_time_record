@Component
export struct TodayTipButton {
  @Prop darkModeEnabled: boolean = false;
  @Prop todayButtonScale: number = 1;
  onTap: () => void = () => {};

  build() {
    Button('今日')
      .height(30)
      .fontSize(13)
      .fontColor(this.darkModeEnabled ? '#8B9EF5' : '#2E67F8')
      .backgroundColor(this.darkModeEnabled ? '#2D3548' : '#EEF3FF')
      .borderRadius(15)
      .padding({ left: 12, right: 12 })
      .scale({ x: this.todayButtonScale, y: this.todayButtonScale })
      .animation({ duration: 200, curve: Curve.EaseInOut })
      .onClick(() => {
        this.onTap();
      });
  }
}
