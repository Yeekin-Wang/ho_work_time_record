import { TimeUtils } from '../../service/TimeUtils';

@Component
export struct MainHeader {
  @Prop darkModeEnabled: boolean = false;
  @Prop selectedDateKey: string = '';
  onOpenSettings: () => void = () => {};

  build() {
    Column({ space: 16 }) {
      Stack({ alignContent: Alignment.Center }) {
        Text('打卡')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');

        Row() {
          Button('设置')
            .height(42)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033')
            .backgroundColor(this.darkModeEnabled ? '#242B3D' : '#FFFFFF')
            .borderRadius(21)
            .border({ width: 1, color: this.darkModeEnabled ? '#3A4255' : '#D8E0F0' })
            .padding({ left: 18, right: 18 })
            .onClick(() => {
              this.onOpenSettings();
            });
        }
        .width('100%')
        .justifyContent(FlexAlign.Start);
      }
      .width('100%')
      .height(42);

      Row() {
        Blank();
        Text(TimeUtils.getSelectedDateDescription(this.selectedDateKey))
          .fontSize(13)
          .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
        Blank();
      }
      .width('100%');
    }
    .width('100%');
  }
}
