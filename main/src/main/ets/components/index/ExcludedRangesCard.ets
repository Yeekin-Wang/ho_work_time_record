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
          Text('不计入工时的时间段')
            .fontSize(12)
            .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
          Text('排除时段')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');
        }

        Button() {
          Stack({ alignContent: Alignment.Center }) {
            Text('+')
              .fontSize(18)
              .fontWeight(FontWeight.Regular)
              .fontColor(this.darkModeEnabled ? '#8B9EF5' : '#2E67F8');
          }
          .width('100%')
          .height('100%');
        }
        .width(44)
        .height(44)
        .backgroundColor(this.darkModeEnabled ? '#242B3D' : '#FFFFFF')
        .borderRadius(22)
        .border({ width: 1, color: this.darkModeEnabled ? '#3A4255' : '#D8E0F0' })
        .onClick(() => {
          this.onAdd();
        });
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center);

      if (this.excludedRanges.length === 0) {
        Column({ space: 8 }) {
          Text('暂未配置排除时段')
            .fontSize(16)
            .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');
          Text('例如午休 12:00 - 13:00，不参与工时计算。')
            .fontSize(13)
            .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
        }
        .width('100%')
        .padding(16)
        .borderRadius(18)
        .backgroundColor(this.darkModeEnabled ? '#2D3548' : '#F6F8FC')
        .transition(TransitionEffect.OPACITY);
      } else {
        Column({ space: 10 }) {
          ForEach(this.excludedRanges, (range: ExcludedRange, index: number) => {
            Row() {
              Column({ space: 2 }) {
                Text('排除时段 ' + (index + 1).toString())
                  .fontSize(13)
                  .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
                Text(range.start + ' - ' + range.end)
                  .fontSize(17)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');
              }

              if (this.confirmDeleteIndex === index) {
                Button('确认删除')
                  .height(34)
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#FFFFFF')
                  .backgroundColor('#D85353')
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
                    .fontColor('#D85353');
                }
                .width(28)
                .height(28)
                .backgroundColor(this.darkModeEnabled ? '#3D2030' : '#FFF5F5')
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
            .backgroundColor(this.darkModeEnabled ? '#2D3548' : '#F6F8FC')
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
    }
    .width('100%')
    .padding(16)
    .borderRadius(24)
    .backgroundColor(this.darkModeEnabled ? '#242B3D' : '#FFFFFF')
    .border({ width: 1, color: this.darkModeEnabled ? '#3A4255' : '#D8E0F0' })
    .shadow({ radius: 14, color: this.darkModeEnabled ? '#0000004D' : '#12223C5C', offsetX: 0, offsetY: 4 })
    .animation({ duration: 220, curve: Curve.EaseInOut })
    .onClick(() => {
      if (this.confirmDeleteIndex >= 0) {
        this.onResetDeleteConfirm();
      }
    });
  }
}
