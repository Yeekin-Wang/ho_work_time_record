import { ThemeService } from '../../service/ThemeService';
import { TimeUtils } from '../../service/TimeUtils';

@Component
export struct MainHeader {
  @Prop darkModeEnabled: boolean = false;
  @Prop selectedDateKey: string = '';
  onOpenSettings: () => void = () => {};

  build() {
    Column({ space: 16 }) {
      Stack({ alignContent: Alignment.Center }) {
        Text($r('app.string.page_punch_title'))
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled));

        Row() {
          Button($r('app.string.button_settings'))
            .height(42)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled))
            .backgroundColor(ThemeService.getColor('card_bg', this.darkModeEnabled))
            .borderRadius(21)
            .border({ width: 1, color: ThemeService.getColor('card_border', this.darkModeEnabled) })
            .padding({ left: 18, right: 18 })
            .onClick(() => {
              this.onOpenSettings();
            });
        }
        .width('100%')
        .justifyContent(FlexAlign.Start);
      }
      .width('100%')
      .height(42);

      Row() {
        Blank();
        Text(TimeUtils.getSelectedDateDescription(this.selectedDateKey))
          .fontSize(13)
          .fontColor(ThemeService.getColor('text_secondary', this.darkModeEnabled));
        Blank();
      }
      .width('100%');
    }
    .width('100%');
  }
}
