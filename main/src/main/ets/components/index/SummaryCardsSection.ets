import { ThemeService } from '../../service/ThemeService';
import { SummaryItem } from '../../model/SummaryItem';

@Component
export struct SummaryCardsSection {
  @Prop darkModeEnabled: boolean = false;
  @Prop summaryItems: SummaryItem[] = [];
  @Prop summaryRefreshKey: number = 0;
  @Prop differenceLabel: string = '';
  @Prop differenceColor: string = '#2E67F8';

  build() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        ForEach(this.summaryItems, (item: SummaryItem) => {
          Column({ space: 8 }) {
            Text(item.title)
              .fontSize(13)
              .fontColor(ThemeService.getColor('text_secondary', this.darkModeEnabled));
            Text(item.value)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled))
              .animation({ duration: 200, curve: Curve.EaseInOut });
          }
          .layoutWeight(1)
          .padding(16)
          .backgroundColor(ThemeService.getColor('card_bg', this.darkModeEnabled))
          .borderRadius(24)
          .border({ width: 1, color: ThemeService.getColor('card_border', this.darkModeEnabled) })
          .shadow({ radius: 14, color: ThemeService.getColor('shadow_card', this.darkModeEnabled), offsetX: 0, offsetY: 4 })
          .animation({ duration: 220, curve: Curve.EaseInOut });
        }, (item: SummaryItem) => item.title + '_' + this.summaryRefreshKey.toString());
      }
      .width('100%');

      Column({ space: 6 }) {
        Text($r('app.string.card_summary_compare_title'))
          .fontSize(13)
          .fontColor(ThemeService.getColor('text_secondary', this.darkModeEnabled));
        Text(this.differenceLabel)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.differenceColor)
          .animation({ duration: 200, curve: Curve.EaseInOut });
      }
      .width('100%')
      .padding(16)
      .backgroundColor(ThemeService.getColor('card_bg', this.darkModeEnabled))
      .borderRadius(24)
      .border({ width: 1, color: ThemeService.getColor('card_border', this.darkModeEnabled) })
      .shadow({ radius: 14, color: ThemeService.getColor('shadow_card', this.darkModeEnabled), offsetX: 0, offsetY: 4 })
      .animation({ duration: 420, curve: Curve.EaseOut });
    }
    .width('100%');
  }
}
