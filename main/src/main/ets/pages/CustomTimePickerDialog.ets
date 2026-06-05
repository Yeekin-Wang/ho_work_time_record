import { ThemeService } from '../service/ThemeService';
/**
 * 自定义时间选择弹窗 - 使用 CustomDialog + TimePicker
 * 替代系统 showTimePickerDialog，避免顶部固定显示 "2024年1月1日"
 */

@CustomDialog
export struct CustomTimePickerDialog {
  controller: CustomDialogController;
  // 当前选中的小时 (0-23)
  @State selectedHour: number = 9;
  // 当前选中的分钟 (0-59)
  @State selectedMinute: number = 0;
  // 是否启用24小时制
  private useMilitaryTime: boolean = true;
  // 弹窗标题
  private darkModeEnabled: boolean = false;
  private title: ResourceStr = $r('app.string.dialog_time_picker_default_title');
  // 确认回调
  onConfirm?: (hour: number, minute: number) => void;

  aboutToAppear(): void {
    // 初始化时不做额外操作，selectedHour/selectedMinute 已在外部设置
  }

  build() {
    Column({ space: 20 }) {
      // 标题
      Text(this.title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled))
        .margin({ top: 8 });

      // 时间选择器（不含顶部日期）
      TimePicker({
        selected: new Date(2000, 0, 1, this.selectedHour, this.selectedMinute, 0)
      })
        .useMilitaryTime(this.useMilitaryTime)
        .width('100%')
        .height(220)
        .disappearTextStyle({
          color: ThemeService.getColor('picker_text_faded', this.darkModeEnabled),
          font: { size: '16fp', weight: FontWeight.Regular }
        })
        .textStyle({
          color: ThemeService.getColor('picker_text', this.darkModeEnabled),
          font: { size: '18fp', weight: FontWeight.Regular }
        })
        .selectedTextStyle({
          color: ThemeService.getColor('picker_selected_text', this.darkModeEnabled),
          font: { size: '24fp', weight: FontWeight.Medium }
        })
        .onChange((value: TimePickerResult) => {
          if (value.hour !== undefined && value.minute !== undefined) {
            this.selectedHour = value.hour;
            this.selectedMinute = value.minute;
          }
        });

      // 按钮组
      Row({ space: 12 }) {
        // 取消按钮
        Button($r('app.string.button_cancel'))
          .layoutWeight(1)
          .height(44)
          .fontSize(16)
          .fontColor(ThemeService.getColor('text_primary', this.darkModeEnabled))
          .backgroundColor(ThemeService.getColor('surface_bg', this.darkModeEnabled))
          .borderRadius(20)
          .onClick(() => {
            this.controller.close();
          });

        // 确定按钮
        Button($r('app.string.button_confirm'))
          .layoutWeight(1)
          .height(44)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor(ThemeService.getColor('text_inverse', this.darkModeEnabled))
          .backgroundColor(ThemeService.getColor('brand', this.darkModeEnabled))
          .borderRadius(20)
          .onClick(() => {
            this.onConfirm?.(this.selectedHour, this.selectedMinute);
            this.controller.close();
          });
      }
      .width('100%')
      .margin({ bottom: 4 });
    }
    .width('100%')
    .padding(24)
    .backgroundColor(ThemeService.getColor('card_bg', this.darkModeEnabled))
    .borderRadius(28);
  }
}
