import { TimeUtils } from '../../service/TimeUtils';

@Component
export struct TargetHoursCard {
  @Prop darkModeEnabled: boolean = false;
  @Prop targetAverageHours: number = 8;
  onChange: (value: number) => void = (_value: number) => {};

  build() {
    Column({ space: 14 }) {
      Column({ space: 4 }) {
        Text('每日目标')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');
        Text('用于计算平均工时和目标差距。')
          .fontSize(13)
          .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
      }
      .alignItems(HorizontalAlign.Start);

      Text(TimeUtils.formatHoursValue(this.targetAverageHours) + ' 小时/天')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');

      Slider({
        value: this.targetAverageHours,
        min: 6,
        max: 12,
        step: 0.1,
        style: SliderStyle.OutSet
      })
        .width('100%')
        .blockColor(this.darkModeEnabled ? '#8B9EF5' : '#2E67F8')
        .trackColor(this.darkModeEnabled ? '#3A4255' : '#D8E0F0')
        .selectedColor(this.darkModeEnabled ? '#8B9EF5' : '#2E67F8')
        .onChange((value: number) => {
          this.onChange(value);
        });

    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding(16)
    .borderRadius(24)
    .backgroundColor(this.darkModeEnabled ? '#242B3D' : '#FFFFFF')
    .border({ width: 1, color: this.darkModeEnabled ? '#3A4255' : '#D8E0F0' })
    .shadow({ radius: 14, color: this.darkModeEnabled ? '#0000004D' : '#12223C5C', offsetX: 0, offsetY: 4 })
    .animation({ duration: 220, curve: Curve.EaseInOut });
  }
}
