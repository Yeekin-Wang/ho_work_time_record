import { ThemeService } from '../../service/ThemeService';
import { TimeUtils } from '../../service/TimeUtils';

@Component
export struct TargetHoursCard {
  @Prop darkModeEnabled: boolean = false;
  @Prop targetAverageHours: number = 8;
  onChange: (value: number) => void = (_value: number) => {};

  build() {
    Column({ space: 14 }) {
      Column({ space: 4 }) {
        Text($r('app.string.card_target_hours_title'))
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled));
        Text($r('app.string.card_target_hours_desc'))
          .fontSize(13)
          .fontColor(ThemeService.getColor('text_secondary', this.darkModeEnabled));
      }
      .alignItems(HorizontalAlign.Start);

      Row() {
        Text(TimeUtils.formatHoursValue(this.targetAverageHours))
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled));
        Text($r('app.string.card_target_hours_suffix'))
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled));
      }

      Slider({
        value: this.targetAverageHours,
        min: 6,
        max: 12,
        step: 0.1,
        style: SliderStyle.OutSet
      })
        .width('100%')
        .blockColor(ThemeService.getColor('brand_text', this.darkModeEnabled))
        .trackColor(ThemeService.getColor('card_border', this.darkModeEnabled))
        .selectedColor(ThemeService.getColor('brand_text', this.darkModeEnabled))
        .onChange((value: number) => {
          this.onChange(value);
        });

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
