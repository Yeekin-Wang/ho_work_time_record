import { TimeUtils } from '../../service/TimeUtils';

@Component
export struct PunchCardSection {
  @Prop darkModeEnabled: boolean = false;
  @Prop selectedDateLabel: string = '';
  @Prop selectedWorkMinutes: number = 0;
  @Prop startTimeText: string = '--:--';
  @Prop endTimeText: string = '--:--';
  @Prop excludeSummaryText: string = '';
  @Prop punchCardScale: number = 1;
  @Prop punchButtonGlow: number = 0;
  onPunch: () => void = () => {};
  onEditPunch: (field: string) => void = (_field: string): void => {};

  build() {
    Column({ space: 16 }) {
      Row() {
        Column({ space: 4 }) {
          Text('当前日期')
            .fontSize(12)
            .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
          Text(this.selectedDateLabel)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');
        }

        Text('工时 ' + TimeUtils.formatMinutes(this.selectedWorkMinutes))
          .fontSize(14)
          .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033')
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(this.darkModeEnabled ? '#2D3548' : '#EEF3FF')
          .borderRadius(18);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center);

      Row({ space: 12 }) {
        this.buildTimeCard('上班打卡', 'start');
        this.buildTimeCard('下班打卡', 'end');
      }
      .width('100%');

      Row() {
        Text(this.excludeSummaryText)
          .fontSize(13)
          .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
      }
      .width('100%')
      .justifyContent(FlexAlign.Start);

      Stack({ alignContent: Alignment.Center }) {
        Button('立即打卡')
          .width('100%')
          .height(54)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor('#2E67F8')
          .borderRadius(22)
          .scale({ x: this.punchCardScale, y: this.punchCardScale })
          .onClick(() => {
            this.onPunch();
          });

        if (this.punchButtonGlow > 0) {
          Column()
            .width('100%')
            .height(54)
            .borderRadius(22)
            .border({
              width: 2,
              color: this.darkModeEnabled ? '#2ED67C' : '#1EA97C'
            })
            .opacity(this.punchButtonGlow * 0.6)
            .scale({ x: 1 + this.punchButtonGlow * 0.1, y: 1 + this.punchButtonGlow * 0.1 })
            .backgroundColor(this.darkModeEnabled ? '#2ED67C' : '#1EA97C')
        }
      }
      .width('100%');
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.darkModeEnabled ? '#242B3D' : '#FFFFFF')
    .borderRadius(24)
    .border({ width: 1, color: this.darkModeEnabled ? '#3A4255' : '#D8E0F0' })
    .shadow({ radius: 14, color: this.darkModeEnabled ? '#0000004D' : '#12223C5C', offsetX: 0, offsetY: 4 })
    .animation({ duration: 220, curve: Curve.EaseInOut });
  }

  @Builder
  buildTimeCard(title: string, field: string) {
    Button() {
      Column({ space: 8 }) {
        Text(title)
          .fontSize(13)
          .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
        if (field === 'start') {
          Text(this.startTimeText)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033')
            .animation({ duration: 200, curve: Curve.EaseInOut });
        } else {
          Text(this.endTimeText)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033')
            .animation({ duration: 200, curve: Curve.EaseInOut });
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);
    }
    .layoutWeight(1)
    .height(110)
    .padding(14)
    .backgroundColor(this.darkModeEnabled ? '#2D3548' : '#F6F8FC')
    .borderRadius(18)
    .animation({ duration: 200, curve: Curve.EaseInOut })
    .onClick(() => {
      this.onEditPunch(field);
    });
  }
}
