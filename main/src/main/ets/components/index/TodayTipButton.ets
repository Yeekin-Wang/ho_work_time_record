import { ThemeService } from '../../service/ThemeService';
@Component
export struct TodayTipButton {
  @Prop darkModeEnabled: boolean = false;
  @Prop todayButtonScale: number = 1;
  onTap: () => void = () => {};

  build() {
    Button($r('app.string.button_today'))
      .height(30)
      .fontSize(13)
      .fontColor(ThemeService.getColor('brand_text', this.darkModeEnabled))
      .backgroundColor(ThemeService.getColor('surface_brand_bg', this.darkModeEnabled))
      .borderRadius(15)
      .padding({ left: 12, right: 12 })
      .scale({ x: this.todayButtonScale, y: this.todayButtonScale })
      .animation({ duration: 200, curve: Curve.EaseInOut })
      .onClick(() => {
        this.onTap();
      });
  }
}
