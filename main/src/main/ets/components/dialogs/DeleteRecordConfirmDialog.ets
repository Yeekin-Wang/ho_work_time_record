import { ThemeService } from '../../service/ThemeService';

@Component
export struct DeleteRecordConfirmDialog {
  @Prop darkModeEnabled: boolean = false;
  @Prop dateLabel: string = '';
  onCancel: () => void = () => {};
  onConfirm: () => void = () => {};

  private getDeleteMessage(): string {
    try {
      let rm = getContext(this).resourceManager;
      let prefix: string = rm.getStringSync($r('app.string.dialog_delete_record_message_prefix'));
      let suffix: string = rm.getStringSync($r('app.string.dialog_delete_record_message_suffix'));
      return prefix + this.dateLabel + suffix;
    } catch (_error) {
      return '将删除 ' + this.dateLabel + ' 的所有打卡记录，此操作不可撤销。';
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(ThemeService.getColor('scrim', this.darkModeEnabled))
        .animation({ duration: 220, curve: Curve.EaseInOut })
        .onClick(() => {
          this.onCancel();
        });

      Column({ space: 16 }) {
        Text($r('app.string.dialog_delete_record_title'))
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled));

        Text(this.getDeleteMessage())
          .fontSize(14)
          .fontColor(ThemeService.getColor('text_secondary', this.darkModeEnabled))
          .lineHeight(22)
          .textAlign(TextAlign.Center);

        Row({ space: 12 }) {
          Button($r('app.string.button_cancel'))
            .layoutWeight(1)
            .height(48)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled))
            .backgroundColor(ThemeService.getColor('surface_bg', this.darkModeEnabled))
            .borderRadius(20)
            .onClick(() => {
              this.onCancel();
            });

          Button($r('app.string.button_confirm_delete'))
            .layoutWeight(1)
            .height(48)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeService.getColor('text_inverse', this.darkModeEnabled))
            .backgroundColor(ThemeService.getColor('danger', this.darkModeEnabled))
            .borderRadius(20)
            .onClick(() => {
              this.onConfirm();
            });
        }
        .width('100%');
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
