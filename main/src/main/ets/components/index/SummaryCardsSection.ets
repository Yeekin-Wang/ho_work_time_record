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
              .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
            Text(item.value)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033')
              .animation({ duration: 200, curve: Curve.EaseInOut });
          }
          .layoutWeight(1)
          .padding(16)
          .backgroundColor(this.darkModeEnabled ? '#242B3D' : '#FFFFFF')
          .borderRadius(24)
          .border({ width: 1, color: this.darkModeEnabled ? '#3A4255' : '#D8E0F0' })
          .shadow({ radius: 14, color: this.darkModeEnabled ? '#0000004D' : '#12223C5C', offsetX: 0, offsetY: 4 })
          .animation({ duration: 220, curve: Curve.EaseInOut });
        }, (item: SummaryItem) => item.title + '_' + this.summaryRefreshKey.toString());
      }
      .width('100%');

      Column({ space: 6 }) {
        Text('与目标平均工时对比')
          .fontSize(13)
          .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
        Text(this.differenceLabel)
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.differenceColor)
          .animation({ duration: 200, curve: Curve.EaseInOut });
      }
      .width('100%')
      .padding(16)
      .backgroundColor(this.darkModeEnabled ? '#242B3D' : '#FFFFFF')
      .borderRadius(24)
      .border({ width: 1, color: this.darkModeEnabled ? '#3A4255' : '#D8E0F0' })
      .shadow({ radius: 14, color: this.darkModeEnabled ? '#0000004D' : '#12223C5C', offsetX: 0, offsetY: 4 })
      .animation({ duration: 420, curve: Curve.EaseOut });
    }
    .width('100%');
  }
}
