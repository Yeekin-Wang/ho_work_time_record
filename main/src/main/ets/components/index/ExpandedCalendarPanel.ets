import { ThemeService } from '../../service/ThemeService';
import { CalendarSlot } from '../../model/CalendarSlot';
import { WEEKDAY_NAMES } from '../../constants/IndexConstants';
import { TimeUtils } from '../../service/TimeUtils';
import { DayCell } from './DayCell';

@Component
export struct ExpandedCalendarPanel {
  @Prop darkModeEnabled: boolean = false;
  @Prop displayYear: number = 0;
  @Prop displayMonth: number = 0;
  @Prop selectedDateKey: string = '';
  @Prop monthContentKey: number = 0;
  @Prop rows: CalendarSlot[][] = [];
  onClose: () => void = () => {};
  onPreviousMonth: () => void = () => {};
  onNextMonth: () => void = () => {};
  onSelectDate: (dateKey: string, collapseAfterSelect: boolean) => void =
    (_dateKey: string, _collapseAfterSelect: boolean): void => {};
  onLongPressDate: (dateKey: string) => void = (_dateKey: string): void => {};
  @State touchStartX: number = 0;

  build() {
    Column({ space: 14 }) {
      Row() {
        Text(TimeUtils.getCurrentMonthTitle(this.displayYear, this.displayMonth))
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled))
          .layoutWeight(1);
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.onClose();
      });

      Row() {
        ForEach(WEEKDAY_NAMES, (item: string) => {
          Text(item)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .fontSize(12)
            .fontColor(ThemeService.getColor('text_secondary', this.darkModeEnabled));
        }, (item: string) => item + '_expanded');
      }
      .width('100%');

      Column({ space: 8 }) {
        ForEach(this.rows, (row: CalendarSlot[], rowIndex: number) => {
          Row({ space: 8 }) {
            ForEach(row, (slot: CalendarSlot) => {
              DayCell({
                darkModeEnabled: this.darkModeEnabled,
                selectedDateKey: this.selectedDateKey,
                slot: slot,
                collapseAfterSelect: true,
                onSelect: (dateKey: string, collapseAfterSelect: boolean): void => {
                  this.onSelectDate(dateKey, collapseAfterSelect);
                },
                onLongPress: (dateKey: string): void => {
                  this.onLongPressDate(dateKey);
                }
              });
            }, (slot: CalendarSlot) => slot.key + '_expanded');
          }
          .width('100%')
          .transition(TransitionEffect.translate({ x: 12, y: 0 }).combine(TransitionEffect.OPACITY).animation({ duration: 200, curve: Curve.EaseInOut }));
        }, (_row: CalendarSlot[], rowIndex: number) => 'exp_row_' + this.monthContentKey.toString() + '_' + rowIndex.toString());
      }
      .width('100%');

      Blank()
        .height(10)
        .onClick(() => {
          this.onClose();
        });
    }
    .width('92%')
    .padding(18)
    .backgroundColor(ThemeService.getColor('card_bg', this.darkModeEnabled))
    .borderRadius(28)
    .shadow({ radius: 20, color: ThemeService.getColor('shadow_modal', this.darkModeEnabled), offsetX: 0, offsetY: 10 })
    .animation({ duration: 220, curve: Curve.EaseInOut })
    .gesture(
      PanGesture({ direction: PanDirection.Horizontal })
        .onActionStart((event: GestureEvent) => {
          this.touchStartX = event.offsetX;
        })
        .onActionEnd((event: GestureEvent) => {
          let offsetX: number = event.offsetX - this.touchStartX;
          if (offsetX <= -60) {
            this.onNextMonth();
          } else if (offsetX >= 60) {
            this.onPreviousMonth();
          }
        })
    );
  }
}
