import { ThemeService } from '../../service/ThemeService';
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
          Text($r('app.string.card_current_date_title'))
            .fontSize(12)
            .fontColor(ThemeService.getColor('text_secondary', this.darkModeEnabled));
          Text(this.selectedDateLabel)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled));
        }

        Row() {
          Text($r('app.string.card_work_hours_prefix'))
            .fontSize(14)
            .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled));
          Text(TimeUtils.formatMinutes(this.selectedWorkMinutes))
            .fontSize(14)
            .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled));
        }
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor(ThemeService.getColor('surface_brand_bg', this.darkModeEnabled))
          .borderRadius(18);
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center);

      Row({ space: 12 }) {
        this.buildTimeCard($r('app.string.card_start_punch_title'), 'start');
        this.buildTimeCard($r('app.string.card_end_punch_title'), 'end');
      }
      .width('100%');

      Row() {
        Text(this.excludeSummaryText)
          .fontSize(13)
          .fontColor(ThemeService.getColor('text_secondary', this.darkModeEnabled));
      }
      .width('100%')
      .justifyContent(FlexAlign.Start);

      Stack({ alignContent: Alignment.Center }) {
        Button($r('app.string.button_punch_now'))
          .width('100%')
          .height(54)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeService.getColor('text_inverse', this.darkModeEnabled))
          .backgroundColor(ThemeService.getColor('brand', this.darkModeEnabled))
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
              color: ThemeService.getColor('success', this.darkModeEnabled)
            })
            .opacity(this.punchButtonGlow * 0.6)
            .scale({ x: 1 + this.punchButtonGlow * 0.1, y: 1 + this.punchButtonGlow * 0.1 })
            .backgroundColor(ThemeService.getColor('success', this.darkModeEnabled))
        }
      }
      .width('100%');
    }
    .width('100%')
    .padding(16)
    .backgroundColor(ThemeService.getColor('card_bg', this.darkModeEnabled))
    .borderRadius(24)
    .border({ width: 1, color: ThemeService.getColor('card_border', this.darkModeEnabled) })
    .shadow({ radius: 14, color: ThemeService.getColor('shadow_card', this.darkModeEnabled), offsetX: 0, offsetY: 4 })
    .animation({ duration: 220, curve: Curve.EaseInOut });
  }

  @Builder
  buildTimeCard(title: ResourceStr, field: string) {
    Button() {
      Column({ space: 8 }) {
        Text(title)
          .fontSize(13)
          .fontColor(ThemeService.getColor('text_secondary', this.darkModeEnabled));
        if (field === 'start') {
          Text(this.startTimeText)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled))
            .animation({ duration: 200, curve: Curve.EaseInOut });
        } else {
          Text(this.endTimeText)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled))
            .animation({ duration: 200, curve: Curve.EaseInOut });
        }
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);
    }
    .layoutWeight(1)
    .height(110)
    .padding(14)
    .backgroundColor(ThemeService.getColor('surface_bg', this.darkModeEnabled))
    .borderRadius(18)
    .animation({ duration: 200, curve: Curve.EaseInOut })
    .onClick(() => {
      this.onEditPunch(field);
    });
  }
}
