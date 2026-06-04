import { CalendarSlot } from '../../model/CalendarSlot';
import { IndexCalendarService } from '../../service/IndexCalendarService';

@Component
export struct DayCell {
  @Prop darkModeEnabled: boolean = false;
  @Prop selectedDateKey: string = '';
  @Prop slot: CalendarSlot = new CalendarSlot('', 0, '', false, false, 0);
  @Prop collapseAfterSelect: boolean = false;
  onSelect: (dateKey: string, collapseAfterSelect: boolean) => void =
    (_dateKey: string, _collapseAfterSelect: boolean): void => {};

  build() {
    if (!this.slot.inCurrentMonth) {
      Blank()
        .layoutWeight(1)
        .height(48);
    } else {
      Column({ space: 3 }) {
        Text(this.slot.day.toString())
          .fontSize(15)
          .fontWeight(this.slot.dateKey === this.selectedDateKey ? FontWeight.Bold : FontWeight.Regular)
          .fontColor(this.slot.dateKey === this.selectedDateKey ? '#FFFFFF' : (this.darkModeEnabled ? '#E8EDF5' : '#132033'));
        Row({ space: 4 }) {
          if (this.slot.punchCount >= 1) {
            Row()
              .width(5)
              .height(5)
              .borderRadius(3)
              .backgroundColor(this.slot.dateKey === this.selectedDateKey ? '#FFFFFF' : '#1EA97C');
          }
          if (this.slot.punchCount >= 2) {
            Row()
              .width(5)
              .height(5)
              .borderRadius(3)
              .backgroundColor(this.slot.dateKey === this.selectedDateKey ? '#FFFFFF' : '#1EA97C');
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .height(12);
      }
      .layoutWeight(1)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(IndexCalendarService.getDayCellColor(this.slot, this.selectedDateKey, this.darkModeEnabled))
      .borderRadius(15)
      .border(this.slot.isToday && this.slot.dateKey !== this.selectedDateKey ? { width: 1, color: this.darkModeEnabled ? '#4A5A8A' : '#BFD4FF' } : { width: 0, color: '#00000000' })
      .animation({ duration: 200, curve: Curve.EaseInOut })
      .transition(TransitionEffect.translate({ x: 12, y: 0 }).combine(TransitionEffect.OPACITY).animation({ duration: 200, curve: Curve.EaseInOut }))
      .onClick(() => {
        this.onSelect(this.slot.dateKey, this.collapseAfterSelect);
      });
    }
  }
}
