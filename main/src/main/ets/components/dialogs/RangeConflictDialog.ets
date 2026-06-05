import { ThemeService } from '../../service/ThemeService';
@Component
export struct RangeConflictDialog {
  @Prop darkModeEnabled: boolean = false;
  onClose: () => void = () => {};
  onConfirm: () => void = () => {};

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(ThemeService.getColor('scrim', this.darkModeEnabled))
        .animation({ duration: 220, curve: Curve.EaseInOut })
        .onClick(() => {
          this.onClose();
        });

      Column({ space: 16 }) {
        Text($r('app.string.dialog_range_conflict_title'))
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled));

        Text($r('app.string.dialog_range_conflict_message'))
          .fontSize(14)
          .fontColor(ThemeService.getColor('text_secondary', this.darkModeEnabled))
          .lineHeight(22)
          .textAlign(TextAlign.Center);

        Button($r('app.string.button_got_it'))
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeService.getColor('text_inverse', this.darkModeEnabled))
          .backgroundColor(ThemeService.getColor('brand', this.darkModeEnabled))
          .borderRadius(20)
          .onClick(() => {
            this.onConfirm();
          });
      }
      .width('80%')
      .padding(24)
      .backgroundColor(ThemeService.getColor('card_bg', this.darkModeEnabled))
      .borderRadius(28)
      .shadow({ radius: 18, color: ThemeService.getColor('shadow_modal', this.darkModeEnabled), offsetX: 0, offsetY: 10 })
      .transition(TransitionEffect.scale({ x: 0.85, y: 0.85 }).combine(TransitionEffect.OPACITY).animation({ duration: 250, curve: Curve.EaseInOut }));
    }
    .width('100%')
    .height('100%');
  }
}
