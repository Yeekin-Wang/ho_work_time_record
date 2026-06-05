import { ThemeService } from '../../service/ThemeService';
@Component
export struct SettingsHeader {
  @Prop darkModeEnabled: boolean = false;
  onBack: () => void = () => {};

  build() {
    Column({ space: 16 }) {
      Stack({ alignContent: Alignment.Center }) {
        Text($r('app.string.page_settings_title'))
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled));

        Row() {
          Button($r('app.string.button_back'))
            .height(42)
            .width(42)
            .fontSize(22)
            .fontWeight(FontWeight.Normal)
            .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled))
            .backgroundColor(ThemeService.getColor('card_bg', this.darkModeEnabled))
            .borderRadius(21)
            .border({ width: 1, color: ThemeService.getColor('card_border', this.darkModeEnabled) })
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
          .fontColor(ThemeService.getColor('text_secondary', this.darkModeEnabled));
        Blank();
      }
      .width('100%');
    }
    .width('100%');
  }
}
