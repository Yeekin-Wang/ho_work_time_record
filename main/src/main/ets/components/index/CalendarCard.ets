import { ThemeService } from '../../service/ThemeService';
import { CalendarSlot } from '../../model/CalendarSlot';
import { WEEKDAY_NAMES } from '../../constants/IndexConstants';
import { TimeUtils } from '../../service/TimeUtils';
import { TodayTipButton } from './TodayTipButton';
import { DayCell } from './DayCell';

@Component
export struct CalendarCard {
  @Prop darkModeEnabled: boolean = false;
  @Prop displayYear: number = 0;
  @Prop displayMonth: number = 0;
  @Prop selectedDateKey: string = '';
  @Prop todayButtonScale: number = 1;
  @Prop weekContentKey: number = 0;
  @Prop weekSlots: CalendarSlot[] = [];
  onOpen: () => void = () => {};
  onTodayTap: () => void = () => {};
  onSwipe: (offsetX: number) => void = (_offsetX: number): void => {};
  onSelectDate: (dateKey: string, collapseAfterSelect: boolean) => void =
    (_dateKey: string, _collapseAfterSelect: boolean): void => {};
  onLongPressDate: (dateKey: string) => void = (_dateKey: string): void => {};
  @State touchStartX: number = 0;

  build() {
    Column() {
      Column({ space: 14 }) {
        Row() {
          Text(TimeUtils.getCurrentMonthTitle(this.displayYear, this.displayMonth))
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled))
            .layoutWeight(1);

          TodayTipButton({
            darkModeEnabled: this.darkModeEnabled,
            todayButtonScale: this.todayButtonScale,
            onTap: (): void => {
              this.onTodayTap();
            }
          });
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          this.onOpen();
        });

        Row() {
          ForEach(WEEKDAY_NAMES, (item: string) => {
            Text(item)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
              .fontSize(12)
              .fontColor(ThemeService.getColor('text_secondary', this.darkModeEnabled));
          }, (item: string) => item);
        }
        .width('100%');

        Row({ space: 8 }) {
          ForEach(this.weekSlots, (slot: CalendarSlot) => {
            DayCell({
              darkModeEnabled: this.darkModeEnabled,
              selectedDateKey: this.selectedDateKey,
              slot: slot,
              collapseAfterSelect: false,
              onSelect: (dateKey: string, collapseAfterSelect: boolean): void => {
                this.onSelectDate(dateKey, collapseAfterSelect);
              },
              onLongPress: (dateKey: string): void => {
                this.onLongPressDate(dateKey);
              }
            });
          }, (slot: CalendarSlot) => slot.key + '_collapsed_' + this.weekContentKey.toString());
        }
        .width('100%');
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding(16)
    .backgroundColor(ThemeService.getColor('card_bg', this.darkModeEnabled))
    .borderRadius(24)
    .border({ width: 1, color: ThemeService.getColor('card_border', this.darkModeEnabled) })
    .shadow({ radius: 14, color: ThemeService.getColor('shadow_card', this.darkModeEnabled), offsetX: 0, offsetY: 4 })
    .animation({ duration: 220, curve: Curve.EaseInOut })
    .gesture(
      PanGesture({ direction: PanDirection.Horizontal })
        .onActionStart((event: GestureEvent) => {
          this.touchStartX = event.offsetX;
        })
        .onActionEnd((event: GestureEvent) => {
          this.onSwipe(event.offsetX - this.touchStartX);
        })
    );
  }
}
