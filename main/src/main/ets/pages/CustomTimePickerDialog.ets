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
  private title: string = '选择时间';
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
        .fontColor('#132033')
        .margin({ top: 8 });

      // 时间选择器（不含顶部日期）
      TimePicker({
        selected: new Date(2000, 0, 1, this.selectedHour, this.selectedMinute, 0)
      })
        .useMilitaryTime(this.useMilitaryTime)
        .width('100%')
        .height(220)
        .disappearTextStyle({
          color: '#99182431',
          font: { size: '16fp', weight: FontWeight.Regular }
        })
        .textStyle({
          color: '#66182431',
          font: { size: '18fp', weight: FontWeight.Regular }
        })
        .selectedTextStyle({
          color: '#007DFF',
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
        Button('取消')
          .layoutWeight(1)
          .height(44)
          .fontSize(16)
          .fontColor('#132033')
          .backgroundColor('#F6F8FC')
          .borderRadius(20)
          .onClick(() => {
            this.controller.close();
          });

        // 确定按钮
        Button('确定')
          .layoutWeight(1)
          .height(44)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .backgroundColor('#2E67F8')
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
    .backgroundColor('#FFFFFF')
    .borderRadius(28);
  }
}