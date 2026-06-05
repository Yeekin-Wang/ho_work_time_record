import { ThemeService } from '../../service/ThemeService';
@Component
export struct DataManagementCard {
  @Prop darkModeEnabled: boolean = false;
  onExport: () => void = () => {};
  onImport: () => void = () => {};
  onClear: () => void = () => {};

  build() {
    Column({ space: 14 }) {
      Row() {
        Column({ space: 4 }) {
          Text($r('app.string.card_data_title'))
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled));
          Text($r('app.string.card_data_desc'))
            .fontSize(13)
            .fontColor(ThemeService.getColor('text_secondary', this.darkModeEnabled));
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center);

      Row({ space: 12 }) {
        Button($r('app.string.button_export'))
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeService.getColor('text_inverse', this.darkModeEnabled))
          .backgroundColor(ThemeService.getColor('brand', this.darkModeEnabled))
          .borderRadius(20)
          .onClick(() => {
            this.onExport();
          });

        Button($r('app.string.button_import'))
          .layoutWeight(1)
          .height(40)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled))
          .backgroundColor(ThemeService.getColor('surface_bg', this.darkModeEnabled))
          .borderRadius(20)
          .onClick(() => {
            this.onImport();
          });
      }
      .width('100%');

      Row() {
        Column({ space: 4 }) {
          Text($r('app.string.card_clear_records_title'))
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled));
          Text($r('app.string.card_clear_records_desc'))
            .fontSize(13)
            .fontColor(ThemeService.getColor('text_secondary', this.darkModeEnabled));
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);

        Button($r('app.string.button_clear'))
          .height(36)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor(ThemeService.getColor('text_inverse', this.darkModeEnabled))
          .backgroundColor(ThemeService.getColor('danger', this.darkModeEnabled))
          .borderRadius(18)
          .padding({ left: 16, right: 16 })
          .onClick(() => {
            this.onClear();
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
