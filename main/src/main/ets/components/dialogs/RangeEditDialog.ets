import { ThemeService } from '../../service/ThemeService';
@Component
export struct RangeEditDialog {
  @Prop darkModeEnabled: boolean = false;
  @Prop editRangeIndex: number = -1;
  @Prop rangeStartInput: string = '12:00';
  @Prop rangeEndInput: string = '13:00';
  onCancel: () => void = () => {};
  onConfirm: () => void = () => {};
  onPickStart: () => void = () => {};
  onPickEnd: () => void = () => {};

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(ThemeService.getColor('scrim', this.darkModeEnabled))
        .animation({ duration: 220, curve: Curve.EaseInOut })
        .gesture(
          PanGesture({ direction: PanDirection.Horizontal })
            .onActionEnd((_event: GestureEvent) => {
              this.onCancel();
            })
        )
        .onClick(() => {
          this.onCancel();
        });

      Column({ space: 16 }) {
        Text(this.editRangeIndex >= 0 ? $r('app.string.dialog_range_edit_title') : $r('app.string.dialog_range_add_title'))
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled));

        Text($r('app.string.dialog_range_desc'))
          .fontSize(13)
          .fontColor(ThemeService.getColor('text_secondary', this.darkModeEnabled));

        Row({ space: 12 }) {
          Button() {
            Row() {
              Text(this.rangeStartInput)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled));
              Blank();
              Text($r('app.string.field_start'))
                .fontSize(12)
                .fontColor(ThemeService.getColor('text_secondary', this.darkModeEnabled));
            }
            .width('100%');
          }
          .layoutWeight(1)
          .height(72)
          .padding({ left: 16, right: 16 })
          .backgroundColor(ThemeService.getColor('surface_bg', this.darkModeEnabled))
          .borderRadius(18)
          .onClick(() => {
            this.onPickStart();
          });

          Button() {
            Row() {
              Text(this.rangeEndInput)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled));
              Blank();
              Text($r('app.string.field_end'))
                .fontSize(12)
                .fontColor(ThemeService.getColor('text_secondary', this.darkModeEnabled));
            }
            .width('100%');
          }
          .layoutWeight(1)
          .height(72)
          .padding({ left: 16, right: 16 })
          .backgroundColor(ThemeService.getColor('surface_bg', this.darkModeEnabled))
          .borderRadius(18)
          .onClick(() => {
            this.onPickEnd();
          });
        }
        .width('100%');

        Row({ space: 12 }) {
          Button($r('app.string.button_cancel'))
            .layoutWeight(1)
            .height(48)
            .fontSize(16)
            .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled))
            .backgroundColor(ThemeService.getColor('surface_bg', this.darkModeEnabled))
            .borderRadius(20)
            .onClick(() => {
              this.onCancel();
            });

          Button(this.editRangeIndex >= 0 ? $r('app.string.button_save') : $r('app.string.button_add'))
            .layoutWeight(1)
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
        .width('100%');
      }
      .width('88%')
      .padding(20)
      .backgroundColor(ThemeService.getColor('card_bg', this.darkModeEnabled))
      .borderRadius(28);
    }
    .width('100%')
    .height('100%');
  }
}
