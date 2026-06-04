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
        .backgroundColor(this.darkModeEnabled ? '#80000000' : '#660C1729')
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
        Text(this.editRangeIndex >= 0 ? '编辑排除时段' : '新增排除时段')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');

        Text('使用系统时间滑动选择器，输入体验更正式，避免手动输入格式错误。')
          .fontSize(13)
          .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');

        Row({ space: 12 }) {
          Button() {
            Row() {
              Text(this.rangeStartInput)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');
              Blank();
              Text('开始')
                .fontSize(12)
                .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
            }
            .width('100%');
          }
          .layoutWeight(1)
          .height(72)
          .padding({ left: 16, right: 16 })
          .backgroundColor(this.darkModeEnabled ? '#2D3548' : '#F6F8FC')
          .borderRadius(18)
          .onClick(() => {
            this.onPickStart();
          });

          Button() {
            Row() {
              Text(this.rangeEndInput)
                .fontSize(20)
                .fontWeight(FontWeight.Bold)
                .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');
              Blank();
              Text('结束')
                .fontSize(12)
                .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
            }
            .width('100%');
          }
          .layoutWeight(1)
          .height(72)
          .padding({ left: 16, right: 16 })
          .backgroundColor(this.darkModeEnabled ? '#2D3548' : '#F6F8FC')
          .borderRadius(18)
          .onClick(() => {
            this.onPickEnd();
          });
        }
        .width('100%');

        Row({ space: 12 }) {
          Button('取消')
            .layoutWeight(1)
            .height(48)
            .fontSize(16)
            .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033')
            .backgroundColor(this.darkModeEnabled ? '#2D3548' : '#F6F8FC')
            .borderRadius(20)
            .onClick(() => {
              this.onCancel();
            });

          Button(this.editRangeIndex >= 0 ? '保存' : '添加')
            .layoutWeight(1)
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
        .width('100%');
      }
      .width('88%')
      .padding(20)
      .backgroundColor(this.darkModeEnabled ? '#242B3D' : '#FFFFFF')
      .borderRadius(28);
    }
    .width('100%')
    .height('100%');
  }
}
