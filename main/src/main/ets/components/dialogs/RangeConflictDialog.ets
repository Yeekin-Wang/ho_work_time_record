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
        .backgroundColor(this.darkModeEnabled ? '#80000000' : '#660C1729')
        .animation({ duration: 220, curve: Curve.EaseInOut })
        .onClick(() => {
          this.onClose();
        });

      Column({ space: 16 }) {
        Text('时段冲突')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');

        Text('当前排除时段与已配置的排除时段存在冲突，请调整时间后再试。')
          .fontSize(14)
          .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A')
          .lineHeight(22)
          .textAlign(TextAlign.Center);

        Button('知道了')
          .width('100%')
          .height(48)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor('#2E67F8')
          .borderRadius(20)
          .onClick(() => {
            this.onConfirm();
          });
      }
      .width('80%')
      .padding(24)
      .backgroundColor(this.darkModeEnabled ? '#242B3D' : '#FFFFFF')
      .borderRadius(28)
      .shadow({ radius: 18, color: this.darkModeEnabled ? '#0000004D' : '#30223C5C', offsetX: 0, offsetY: 10 })
      .transition(TransitionEffect.scale({ x: 0.85, y: 0.85 }).combine(TransitionEffect.OPACITY).animation({ duration: 250, curve: Curve.EaseInOut }));
    }
    .width('100%')
    .height('100%');
  }
}
