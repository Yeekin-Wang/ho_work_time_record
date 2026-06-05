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
          Text('显示模式')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');
          Text('选择浅色、深色或跟随系统。')
            .fontSize(13)
            .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center);

      Row({ space: 6 }) {
        this.buildThemeOption(THEME_MODE_LIGHT, '浅色');
        this.buildThemeOption(THEME_MODE_DARK, '深色');
        this.buildThemeOption(THEME_MODE_SYSTEM, '跟随系统');
      }
      .width('100%')
      .padding(4)
      .borderRadius(16)
      .backgroundColor(this.darkModeEnabled ? '#1E2636' : '#F6F8FC');
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

  @Builder
  buildThemeOption(themeMode: string, label: string) {
    Text(label)
      .fontSize(14)
      .fontWeight(this.themeMode === themeMode ? FontWeight.Bold : FontWeight.Regular)
      .fontColor(this.themeMode === themeMode ? (this.darkModeEnabled ? '#E8EDF5' : '#2E67F8') :
        (this.darkModeEnabled ? '#8892A4' : '#60708A'))
      .textAlign(TextAlign.Center)
      .height(36)
      .layoutWeight(1)
      .borderRadius(12)
      .backgroundColor(this.themeMode === themeMode ? (this.darkModeEnabled ? '#38446A' : '#FFFFFF') : '#00000000')
      .shadow(this.themeMode === themeMode ?
        { radius: 8, color: this.darkModeEnabled ? '#00000033' : '#12223C24', offsetX: 0, offsetY: 2 } :
        { radius: 0, color: '#00000000', offsetX: 0, offsetY: 0 })
      .onClick(() => {
        this.onChange(themeMode);
      });
  }
}
