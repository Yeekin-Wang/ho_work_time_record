import { ThemeService } from '../../service/ThemeService';
import { ExcludedRange } from '../../model/ExcludedRange';

@Component
export struct ExcludedRangesCard {
  @Prop darkModeEnabled: boolean = false;
  @Prop excludedRanges: ExcludedRange[] = [];
  @Prop confirmDeleteIndex: number = -1;
  onAdd: () => void = () => {};
  onConfirmDelete: (index: number) => void = (_index: number) => {};
  onRequestDelete: (index: number) => void = (_index: number) => {};
  onEdit: (index: number, range: ExcludedRange) => void = (_index: number, _range: ExcludedRange) => {};
  onResetDeleteConfirm: () => void = () => {};

  build() {
    Column({ space: 14 }) {
      Row() {
        Column({ space: 4 }) {
          Text($r('app.string.card_excluded_ranges_title'))
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled));
          Text($r('app.string.card_excluded_ranges_desc'))
            .fontSize(13)
            .fontColor(ThemeService.getColor('text_secondary', this.darkModeEnabled));
        }
        .alignItems(HorizontalAlign.Start);

      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(VerticalAlign.Center);

      if (this.excludedRanges.length > 0) {
        Column({ space: 10 }) {
          ForEach(this.excludedRanges, (range: ExcludedRange, index: number) => {
            Row() {
              Column({ space: 2 }) {
                Row() {
                  Text($r('app.string.excluded_range_item_prefix'))
                    .fontSize(13)
                    .fontColor(ThemeService.getColor('text_secondary', this.darkModeEnabled));
                  Text((index + 1).toString())
                    .fontSize(13)
                    .fontColor(ThemeService.getColor('text_secondary', this.darkModeEnabled));
                }
                Text(range.start + ' - ' + range.end)
                  .fontSize(17)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled));
              }

              if (this.confirmDeleteIndex === index) {
                Button($r('app.string.button_confirm_delete'))
                  .height(34)
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(ThemeService.getColor('text_inverse', this.darkModeEnabled))
                  .backgroundColor(ThemeService.getColor('danger', this.darkModeEnabled))
                  .borderRadius(17)
                  .padding({ left: 14, right: 14 })
                  .transition(TransitionEffect.scale({ x: 0.5, y: 0.5 }).combine(TransitionEffect.OPACITY))
                  .onClick(() => {
                    this.onConfirmDelete(index);
                  });
              } else {
                Button() {
                  Text('✕')
                    .fontSize(14)
                    .fontColor(ThemeService.getColor('danger', this.darkModeEnabled));
                }
                .width(28)
                .height(28)
                .backgroundColor(ThemeService.getColor('danger_soft_bg', this.darkModeEnabled))
                .borderRadius(14)
                .padding(0)
                .transition(TransitionEffect.scale({ x: 0.5, y: 0.5 }).combine(TransitionEffect.OPACITY))
                .onClick(() => {
                  this.onRequestDelete(index);
                });
              }
            }
            .width('100%')
            .padding({ left: 14, right: 14, top: 14, bottom: 14 })
            .borderRadius(18)
            .backgroundColor(ThemeService.getColor('surface_bg', this.darkModeEnabled))
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            .transition(TransitionEffect.translate({ x: -20, y: 0 }).combine(TransitionEffect.OPACITY))
            .onClick(() => {
              if (this.confirmDeleteIndex >= 0) {
                this.onResetDeleteConfirm();
              } else {
                this.onEdit(index, range);
              }
            });
          }, (range: ExcludedRange) => range.start + '_' + range.end);
        }
        .width('100%')
        .onClick(() => {
          if (this.confirmDeleteIndex >= 0) {
            this.onResetDeleteConfirm();
          }
        });
      }

      Button() {
        Stack({ alignContent: Alignment.Center }) {
          Row() {
            Text('+')
              .fontSize(26)
              .fontWeight(FontWeight.Medium)
              .fontColor(ThemeService.getColor('brand_text', this.darkModeEnabled));
          }
          .width(34)
          .height(34)
          .borderRadius(17)
          .border({
            width: 1,
            color: ThemeService.getColor('brand_text', this.darkModeEnabled),
            style: BorderStyle.Dashed
          })
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center);
        }
        .width('100%');
      }
      .width('100%')
      .padding({ left: 14, right: 14, top: 14, bottom: 14 })
      .borderRadius(18)
      .backgroundColor(ThemeService.getColor('surface_bg', this.darkModeEnabled))
      .onClick(() => {
        this.onAdd();
      });
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .borderRadius(24)
    .backgroundColor(ThemeService.getColor('card_bg', this.darkModeEnabled))
    .border({ width: 1, color: ThemeService.getColor('card_border', this.darkModeEnabled) })
    .shadow({ radius: 14, color: ThemeService.getColor('shadow_card', this.darkModeEnabled), offsetX: 0, offsetY: 4 })
    .animation({ duration: 220, curve: Curve.EaseInOut })
    .onClick(() => {
      if (this.confirmDeleteIndex >= 0) {
        this.onResetDeleteConfirm();
      }
    });
  }
}
