import { ThemeService } from '../../service/ThemeService';
@Component
export struct WorkdayStartCard {
  @Prop darkModeEnabled: boolean = false;
  @Prop workdayStartTime: string = '09:00';
  onOpenPicker: () => void = () => {};

  build() {
    Column({ space: 14 }) {
      Row() {
        Column({ space: 4 }) {
          Text($r('app.string.card_workday_start_title'))
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled));
          Text($r('app.string.card_workday_start_desc'))
            .fontSize(13)
            .fontColor(ThemeService.getColor('text_secondary', this.darkModeEnabled));
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);

        Button(this.workdayStartTime)
          .height(40)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeService.getColor('brand_text', this.darkModeEnabled))
          .backgroundColor(ThemeService.getColor('surface_brand_bg', this.darkModeEnabled))
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
    .backgroundColor(ThemeService.getColor('card_bg', this.darkModeEnabled))
    .border({ width: 1, color: ThemeService.getColor('card_border', this.darkModeEnabled) })
    .shadow({ radius: 14, color: ThemeService.getColor('shadow_card', this.darkModeEnabled), offsetX: 0, offsetY: 4 })
    .animation({ duration: 220, curve: Curve.EaseInOut });
  }
}
