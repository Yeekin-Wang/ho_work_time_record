import { ThemeService } from '../../service/ThemeService';
import { THEME_MODE_DARK, THEME_MODE_LIGHT, THEME_MODE_SYSTEM } from '../../constants/IndexConstants';

@Component
export struct DarkModeCard {
  @Prop darkModeEnabled: boolean = false;
  @Prop themeMode: string = THEME_MODE_SYSTEM;
  onChange: (themeMode: string) => void = (_themeMode: string) => {};

  build() {
    Column({ space: 14 }) {
      Row() {
        Column({ space: 4 }) {
          Text($r('app.string.card_theme_title'))
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled));
          Text($r('app.string.card_theme_desc'))
            .fontSize(13)
            .fontColor(ThemeService.getColor('text_secondary', this.darkModeEnabled));
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center);

      Row({ space: 6 }) {
        this.buildThemeOption(THEME_MODE_LIGHT, $r('app.string.theme_light'));
        this.buildThemeOption(THEME_MODE_DARK, $r('app.string.theme_dark'));
        this.buildThemeOption(THEME_MODE_SYSTEM, $r('app.string.theme_system'));
      }
      .width('100%')
      .padding(4)
      .borderRadius(16)
      .backgroundColor(ThemeService.getColor('calendar_idle_bg', this.darkModeEnabled));
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .borderRadius(24)
    .backgroundColor(ThemeService.getColor('card_bg', this.darkModeEnabled))
    .border({ width: 1, color: ThemeService.getColor('card_border', this.darkModeEnabled) })
    .shadow({ radius: 14, color: ThemeService.getColor('shadow_card', this.darkModeEnabled), offsetX: 0, offsetY: 4 })
    .animation({ duration: 220, curve: Curve.EaseInOut });
  }

  @Builder
  buildThemeOption(themeMode: string, label: ResourceStr) {
    Text(label)
      .fontSize(14)
      .fontWeight(this.themeMode === themeMode ? FontWeight.Bold : FontWeight.Regular)
      .fontColor(this.themeMode === themeMode ? ThemeService.getColor('brand_text', this.darkModeEnabled) : ThemeService.getColor('text_secondary', this.darkModeEnabled))
      .textAlign(TextAlign.Center)
      .height(36)
      .layoutWeight(1)
      .borderRadius(12)
      .backgroundColor(this.themeMode === themeMode ? ThemeService.getColor('segmented_selected_bg', this.darkModeEnabled) : ThemeService.getColor('transparent', this.darkModeEnabled))
      .shadow(this.themeMode === themeMode ?
        { radius: 8, color: ThemeService.getColor('shadow_card_active', this.darkModeEnabled), offsetX: 0, offsetY: 2 } :
        { radius: 0, color: ThemeService.getColor('transparent', this.darkModeEnabled), offsetX: 0, offsetY: 0 })
      .onClick(() => {
        this.onChange(themeMode);
      });
  }
}
