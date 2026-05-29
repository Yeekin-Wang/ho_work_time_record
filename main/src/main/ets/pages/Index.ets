import { preferences } from '@kit.ArkData';
import { ExcludedRange } from '../model/ExcludedRange';
import { DailyPunchRecord } from '../model/DailyPunchRecord';
import { CalendarSlot } from '../model/CalendarSlot';
import { SummaryItem } from '../model/SummaryItem';
import { TimeUtils } from '../service/TimeUtils';
import { StorageService } from '../service/StorageService';
import { PunchCalculator } from '../service/PunchCalculator';

@Entry
@Component
struct Index {
  @State selectedDateKey: string = '';
  @State calendarExpanded: boolean = false;
  @State showSettingsPage: boolean = false;
  @State displayYear: number = 0;
  @State displayMonth: number = 0;
  @State targetAverageHours: number = 8;
  @State workdayStartTime: string = '09:00';
  @State excludedRanges: ExcludedRange[] = [];
  @State records: DailyPunchRecord[] = [];
  @State showRangeDialog: boolean = false;
  @State showRangeConflictDialog: boolean = false;
  @State rangeStartInput: string = '12:00';
  @State rangeEndInput: string = '13:00';
  @State calendarTouchStartX: number = 0;
  @State settingsTouchStartX: number = 0;
  @State punchCardScale: number = 1;
  @State punchButtonGlow: number = 0;
  @State todayButtonScale: number = 1;
  @State darkModeEnabled: boolean = false;
  @State calendarWeekOffset: number = 0;
  @State monthContentKey: number = 0;
  @State weekContentKey: number = 0;
  @State rangeDialogKey: number = 0;
  @State confirmDeleteIndex: number = -1;

  // 2026年法定节假日
  private holidays2026: string[] = [
    '2026-01-01', '2026-01-28', '2026-01-29', '2026-01-30', '2026-01-31', '2026-02-01', '2026-02-02',
    '2026-04-03', '2026-04-04', '2026-04-05', '2026-04-06',
    '2026-05-01', '2026-05-02', '2026-05-03',
    '2026-06-22', '2026-06-23', '2026-06-24', '2026-06-25',
    '2026-10-01', '2026-10-02', '2026-10-03', '2026-10-04', '2026-10-05', '2026-10-06', '2026-10-07',
    '2026-10-08', '2026-10-09', '2026-10-10'
  ];

  private pref: preferences.Preferences | null = null;
  private readonly prefName: string = 'working_time_record';
  private readonly prefSelectedDateKey: string = 'selected_date_key';
  private readonly prefDisplayMonth: string = 'display_month';
  private readonly prefTargetHours: string = 'target_hours';
  private readonly prefWorkdayStartTime: string = 'workday_start_time';
  private readonly prefExcludedRanges: string = 'excluded_ranges';
  private readonly prefRecords: string = 'records';
  private weekdayNames: string[] = ['一', '二', '三', '四', '五', '六', '日'];

  aboutToAppear(): void {
    this.initializeData();
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      this.buildMainPage();

      if (this.showSettingsPage) {
        this.buildSettingsPage();
      }

      if (this.calendarExpanded) {
        this.buildExpandedCalendarOverlay();
      }

      if (this.showRangeDialog) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(this.darkModeEnabled ? '#80000000' : '#660C1729')
            .animation({ duration: 220, curve: Curve.EaseInOut })
            .onClick(() => {
              this.showRangeDialog = false;
            });

          Column({ space: 16 }) {
            Text('新增排除时段')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');

            Text('使用系统时间滑动选择器，输入体验更正式，避免手动输入格式错误。')
              .fontSize(13)
              .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');

            Row({ space: 12 }) {
              Button() {
                Row() {
                  Text(this.rangeStartInput)
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');
                  Blank();
                  Text('开始')
                    .fontSize(12)
                    .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
                }
                .width('100%');
              }
              .layoutWeight(1)
              .height(72)
              .padding({ left: 16, right: 16 })
              .backgroundColor(this.darkModeEnabled ? '#2D3548' : '#F6F8FC')
              .borderRadius(18)
              .onClick(() => {
                this.openRangeTimePicker(true);
              });

              Button() {
                Row() {
                  Text(this.rangeEndInput)
                    .fontSize(20)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');
                  Blank();
                  Text('结束')
                    .fontSize(12)
                    .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
                }
                .width('100%');
              }
              .layoutWeight(1)
              .height(72)
              .padding({ left: 16, right: 16 })
              .backgroundColor(this.darkModeEnabled ? '#2D3548' : '#F6F8FC')
              .borderRadius(18)
              .onClick(() => {
                this.openRangeTimePicker(false);
              });
            }
            .width('100%');

            Row({ space: 12 }) {
              Button('取消')
                .layoutWeight(1)
                .height(48)
                .fontSize(16)
                .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033')
                .backgroundColor(this.darkModeEnabled ? '#2D3548' : '#F6F8FC')
                .borderRadius(20)
                .onClick(() => {
                  this.showRangeDialog = false;
                });

              Button('添加')
                .layoutWeight(1)
                .height(48)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#FFFFFF')
                .backgroundColor('#2E67F8')
                .borderRadius(20)
                .onClick(() => {
                  this.confirmAddRange();
                });
            }
            .width('100%');
          }
          .width('88%')
          .padding(20)
          .backgroundColor(this.darkModeEnabled ? '#242B3D' : '#FFFFFF')
          .borderRadius(28);
        }
        .width('100%')
        .height('100%');
      }

      if (this.showRangeConflictDialog) {
        Stack({ alignContent: Alignment.Center }) {
          Column()
            .width('100%')
            .height('100%')
            .backgroundColor(this.darkModeEnabled ? '#80000000' : '#660C1729')
            .animation({ duration: 220, curve: Curve.EaseInOut })
            .onClick(() => {
              this.showRangeConflictDialog = false;
            });

          Column({ space: 16 }) {
            Text('时段冲突')
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');

            Text('当前排除时段与已配置的排除时段存在冲突，请调整时间后再试。')
              .fontSize(14)
              .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A')
              .lineHeight(22)
              .textAlign(TextAlign.Center);

            Button('知道了')
              .width('100%')
              .height(48)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#FFFFFF')
              .backgroundColor('#2E67F8')
              .borderRadius(20)
              .onClick(() => {
                this.showRangeConflictDialog = false;
              });
          }
          .width('80%')
          .padding(24)
          .backgroundColor(this.darkModeEnabled ? '#242B3D' : '#FFFFFF')
          .borderRadius(28)
          .shadow({ radius: 18, color: this.darkModeEnabled ? '#0000004D' : '#30223C5C', offsetX: 0, offsetY: 10 })
          .transition(TransitionEffect.scale({ x: 0.85, y: 0.85 }).combine(TransitionEffect.OPACITY).animation({ duration: 250, curve: Curve.EaseInOut }));
        }
        .width('100%')
        .height('100%');
      }
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 180,
      colors: this.darkModeEnabled ? [['#1A1F2E', 0.0], ['#242B3D', 1.0]] : [['#F9FBFF', 0.0], ['#F2F5FB', 1.0]]
    })
    .animation({ duration: 220, curve: Curve.EaseInOut })
    .gesture(
      PanGesture({ direction: PanDirection.Horizontal })
        .onActionEnd((event: GestureEvent) => {
          this.handleHorizontalBackGesture(event.offsetX);
        })
    )
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }

  @Builder
  buildMainPage() {
    Scroll() {
      Column({ space: 16 }) {
        this.buildMainHeader();
        this.buildCalendarCard();
        this.buildPunchCard();
        this.buildSummaryCards();
      }
      .padding({ left: 16, right: 16, top: 20, bottom: 28 })
      .width('100%');
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%');
  }

  @Builder
  buildMainHeader() {
    Column({ space: 16 }) {
      Stack({ alignContent: Alignment.Center }) {
        Text('工时打卡')
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
              this.showSettingsPage = true;
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

  @Builder
  buildSettingsPage() {
    Column({ space: 16 }) {
      this.buildSettingsHeader();

      Scroll() {
        Column({ space: 16 }) {
          this.buildSettingsWorkdayStartCard();
          this.buildExcludedRangesCard();
          this.buildTargetHoursCard();
          this.buildDarkModeCard();
        }
        .padding({ left: 16, right: 16, bottom: 28 })
        .width('100%')
        .alignItems(HorizontalAlign.Start);
      }
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .width('100%');
    }
    .width('100%')
    .height('100%')
    .padding({ left: 16, right: 16, top: 20 })
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Start)
    .backgroundColor(this.darkModeEnabled ? '#1A1F2E' : '#F9FBFF')
    .animation({ duration: 220, curve: Curve.EaseInOut })
    .transition(TransitionEffect.translate({ x: 280, y: 0 }).combine(TransitionEffect.OPACITY).animation({ duration: 280, curve: Curve.EaseInOut }))
    .gesture(
      PanGesture({ direction: PanDirection.Horizontal })
        .onActionStart((event: GestureEvent) => {
          this.settingsTouchStartX = event.offsetX;
        })
        .onActionEnd((event: GestureEvent) => {
          let offsetX: number = event.offsetX - this.settingsTouchStartX;
          if (offsetX > 80 || offsetX < -80) {
            this.showSettingsPage = false;
            this.confirmDeleteIndex = -1;
          }
        })
    )
    .onClick(() => {
      if (this.confirmDeleteIndex >= 0) {
        this.getUIContext().animateTo({ duration: 200, curve: Curve.EaseInOut }, () => {
          this.confirmDeleteIndex = -1;
        });
      }
    });
  }

  @Builder
  buildSettingsHeader() {
    Column({ space: 16 }) {
      Stack({ alignContent: Alignment.Center }) {
        Text('设置')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');

        Row() {
          Button('‹')
            .height(42)
            .width(42)
            .fontSize(22)
            .fontWeight(FontWeight.Normal)
            .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033')
            .backgroundColor(this.darkModeEnabled ? '#242B3D' : '#FFFFFF')
            .borderRadius(21)
            .border({ width: 1, color: this.darkModeEnabled ? '#3A4255' : '#D8E0F0' })
            .onClick(() => {
              this.showSettingsPage = false;
              this.confirmDeleteIndex = -1;
            });
        }
        .width('100%')
        .justifyContent(FlexAlign.Start);
      }
      .width('100%')
      .height(42);

      Row() {
        Blank();
        Text('')
          .fontSize(13)
          .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
        Blank();
      }
      .width('100%');
    }
    .width('100%');
  }

  @Builder
  buildExcludedRangesCard() {
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
          this.rangeStartInput = '12:00';
          this.rangeEndInput = '13:00';
          this.rangeDialogKey++;
          this.showRangeDialog = true;
          this.confirmDeleteIndex = -1;
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
                // 确认删除状态：红底白字按钮
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
                    this.removeRange(index);
                    this.confirmDeleteIndex = -1;
                  });
              } else {
                // 默认状态：圆形×号
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
                  this.confirmDeleteIndex = index;
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
              // 点击任意一行，取消当前确认状态（含其他行）
              if (this.confirmDeleteIndex >= 0) {
                this.getUIContext().animateTo({ duration: 200, curve: Curve.EaseInOut }, () => {
                  this.confirmDeleteIndex = -1;
                });
              }
            });
          }, (range: ExcludedRange) => range.start + '_' + range.end);
        }
        .width('100%')
        .onClick(() => {
          // 点击列表空白区域，取消确认状态
          if (this.confirmDeleteIndex >= 0) {
            this.getUIContext().animateTo({ duration: 200, curve: Curve.EaseInOut }, () => {
              this.confirmDeleteIndex = -1;
            });
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
      // 点击卡片边缘空白区域，取消确认状态
      if (this.confirmDeleteIndex >= 0) {
        this.getUIContext().animateTo({ duration: 200, curve: Curve.EaseInOut }, () => {
          this.confirmDeleteIndex = -1;
        });
      }
    });
  }

  @Builder
  buildTargetHoursCard() {
    Column({ space: 14 }) {
      Text('目标平均工时')
        .fontSize(12)
        .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');

      Text(TimeUtils.formatHoursValue(this.targetAverageHours) + ' / 天')
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
          this.targetAverageHours = Math.round(value * 10) / 10;
          this.persistState();
        });

      Text('调整后会立即持久保存，下次打开应用仍然保留。')
        .fontSize(13)
        .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
    }
    .width('100%')
    .padding(16)
    .borderRadius(24)
    .backgroundColor(this.darkModeEnabled ? '#242B3D' : '#FFFFFF')
    .border({ width: 1, color: this.darkModeEnabled ? '#3A4255' : '#D8E0F0' })
    .shadow({ radius: 14, color: this.darkModeEnabled ? '#0000004D' : '#12223C5C', offsetX: 0, offsetY: 4 })
    .animation({ duration: 220, curve: Curve.EaseInOut });
  }

  @Builder
  buildSettingsWorkdayStartCard() {
    Column({ space: 14 }) {
      Text('工时开始时间')
        .fontSize(12)
        .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');

      Row() {
        Column({ space: 4 }) {
          Text('开始计入工时')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');
          Text('若上班打卡早于该时间，将按该时间开始计算。')
            .fontSize(13)
            .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);

        Button(this.workdayStartTime)
          .height(40)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.darkModeEnabled ? '#8B9EF5' : '#2E67F8')
          .backgroundColor(this.darkModeEnabled ? '#2D3548' : '#EEF3FF')
          .borderRadius(20)
          .padding({ left: 14, right: 14 })
          .onClick(() => {
            this.openWorkdayStartTimePicker();
          });
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center);
    }
    .width('100%')
    .padding(16)
    .borderRadius(24)
    .backgroundColor(this.darkModeEnabled ? '#242B3D' : '#FFFFFF')
    .border({ width: 1, color: this.darkModeEnabled ? '#3A4255' : '#D8E0F0' })
    .shadow({ radius: 14, color: this.darkModeEnabled ? '#0000004D' : '#12223C5C', offsetX: 0, offsetY: 4 })
    .animation({ duration: 220, curve: Curve.EaseInOut });
  }

  @Builder
  buildDarkModeCard() {
    Column({ space: 14 }) {
      Text('显示')
        .fontSize(12)
        .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');

      Row() {
        Column({ space: 4 }) {
          Text('深色模式')
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');
          Text('开启后应用深色主题')
            .fontSize(13)
            .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);

        Toggle({ type: ToggleType.Switch, isOn: this.darkModeEnabled })
          .selectedColor('#2E67F8')
          .onChange((isOn: boolean) => {
            this.darkModeEnabled = isOn;
            this.persistState();
          });
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center);
    }
    .width('100%')
    .padding(16)
    .borderRadius(24)
    .backgroundColor(this.darkModeEnabled ? '#242B3D' : '#FFFFFF')
    .border({ width: 1, color: this.darkModeEnabled ? '#3A4255' : '#D8E0F0' })
    .shadow({ radius: 14, color: this.darkModeEnabled ? '#0000004D' : '#12223C5C', offsetX: 0, offsetY: 4 })
    .animation({ duration: 220, curve: Curve.EaseInOut });
  }

  @Builder
  buildCalendarCard() {
    Column() {
      Column({ space: 14 }) {
        // 点击标题区域打开月历
        Row() {
          Text(TimeUtils.getCurrentMonthTitle(this.displayYear, this.displayMonth))
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033')
            .layoutWeight(1);

          Button('今日')
            .height(30)
            .fontSize(13)
            .fontColor(this.darkModeEnabled ? '#8B9EF5' : '#2E67F8')
            .backgroundColor(this.darkModeEnabled ? '#2D3548' : '#EEF3FF')
            .borderRadius(15)
            .padding({ left: 12, right: 12 })
            .scale({ x: this.todayButtonScale, y: this.todayButtonScale })
            .animation({ duration: 200, curve: Curve.EaseInOut })
            .onClick(() => {
              this.todayButtonScale = 0.88;
              this.getUIContext().animateTo({ duration: 120, curve: Curve.EaseOut }, () => {
                this.todayButtonScale = 1.05;
              });
              this.getUIContext().animateTo({ duration: 180, delay: 120, curve: Curve.FastOutSlowIn }, () => {
                this.todayButtonScale = 1;
              });
              this.jumpToToday();
            });
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignItems(VerticalAlign.Center)
        .onClick(() => {
          this.calendarExpanded = true;
        });

        Row() {
          ForEach(this.weekdayNames, (item: string) => {
            Text(item)
              .layoutWeight(1)
              .textAlign(TextAlign.Center)
              .fontSize(12)
              .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
          }, (item: string) => item);
        }
        .width('100%');

        Row({ space: 8 }) {
          ForEach(this.getCurrentWeekSlots(this.buildMonthSlots()), (slot: CalendarSlot) => {
            this.buildDayCell(slot, false);
          }, (slot: CalendarSlot) => slot.key + '_collapsed_' + this.weekContentKey.toString());
        }
        .width('100%');
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start);
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.darkModeEnabled ? '#242B3D' : '#FFFFFF')
    .borderRadius(24)
    .border({ width: 1, color: this.darkModeEnabled ? '#3A4255' : '#D8E0F0' })
    .shadow({ radius: 14, color: this.darkModeEnabled ? '#0000004D' : '#12223C5C', offsetX: 0, offsetY: 4 })
    .animation({ duration: 220, curve: Curve.EaseInOut })
    .gesture(
      PanGesture({ direction: PanDirection.Horizontal })
        .onActionStart((event: GestureEvent) => {
          this.calendarTouchStartX = event.offsetX;
        })
        .onActionEnd((event: GestureEvent) => {
          let offsetX: number = event.offsetX - this.calendarTouchStartX;
          this.handleCalendarSwipe(offsetX);
        })
    );
  }

  @Builder
  buildExpandedCalendarOverlay() {
    Stack({ alignContent: Alignment.Center }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor(this.darkModeEnabled ? '#80000000' : '#660C1729')
        .animation({ duration: 220, curve: Curve.EaseInOut })
        .onClick(() => {
          this.calendarExpanded = false;
        });

      this.buildExpandedCalendarPanel();
    }
    .width('100%')
    .height('100%')
    .transition(TransitionEffect.OPACITY)
    .animation({ duration: 220, curve: Curve.EaseInOut });
  }

  @Builder
  buildExpandedCalendarPanel() {
    Column({ space: 14 }) {
      // 点击标题区域关闭月历
      Row() {
        Text(TimeUtils.getCurrentMonthTitle(this.displayYear, this.displayMonth))
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033')
          .layoutWeight(1);
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      .onClick(() => {
        this.calendarExpanded = false;
      });

      Row() {
        ForEach(this.weekdayNames, (item: string) => {
          Text(item)
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .fontSize(12)
            .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
        }, (item: string) => item + '_expanded');
      }
      .width('100%');

      Column({ space: 8 }) {
        ForEach(this.getExpandedCalendarRows(), (row: CalendarSlot[], rowIndex: number) => {
          Row({ space: 8 }) {
            ForEach(row, (slot: CalendarSlot) => {
              this.buildDayCell(slot, true);
            }, (slot: CalendarSlot) => slot.key + '_expanded');
          }
          .width('100%')
          .transition(TransitionEffect.translate({ x: 12, y: 0 }).combine(TransitionEffect.OPACITY).animation({ duration: 200, curve: Curve.EaseInOut }));
        }, (_row: CalendarSlot[], rowIndex: number) => 'exp_row_' + this.monthContentKey.toString() + '_' + rowIndex.toString());
      }
      .width('100%');

      // 底部空白区域，点击关闭
      Blank()
        .height(10)
        .onClick(() => {
          this.calendarExpanded = false;
        });
    }
    .width('92%')
    .padding(18)
    .backgroundColor(this.darkModeEnabled ? '#242B3D' : '#FFFFFF')
    .borderRadius(28)
    .shadow({ radius: 20, color: this.darkModeEnabled ? '#0000004D' : '#30223C5C', offsetX: 0, offsetY: 10 })
    .animation({ duration: 220, curve: Curve.EaseInOut })
    .gesture(
      PanGesture({ direction: PanDirection.Horizontal })
        .onActionStart((event: GestureEvent) => {
          this.calendarTouchStartX = event.offsetX;
        })
        .onActionEnd((event: GestureEvent) => {
          let offsetX: number = event.offsetX - this.calendarTouchStartX;
          if (offsetX <= -60) {
            this.goToNextMonth();
          } else if (offsetX >= 60) {
            this.goToPreviousMonth();
          }
        })
    );
  }

  @Builder
  buildDayCell(slot: CalendarSlot, collapseAfterSelect: boolean) {
    if (!slot.inCurrentMonth) {
      Blank()
        .layoutWeight(1)
        .height(48);
    } else {
      Column({ space: 3 }) {
        Text(slot.day.toString())
          .fontSize(15)
          .fontWeight(slot.dateKey === this.selectedDateKey ? FontWeight.Bold : FontWeight.Regular)
          .fontColor(slot.dateKey === this.selectedDateKey ? '#FFFFFF' : (this.darkModeEnabled ? '#E8EDF5' : '#132033'));
        Row({ space: 4 }) {
          if (slot.punchCount >= 1) {
            Row()
              .width(5)
              .height(5)
              .borderRadius(3)
              .backgroundColor(slot.dateKey === this.selectedDateKey ? '#FFFFFF' : '#1EA97C');
          }
          if (slot.punchCount >= 2) {
            Row()
              .width(5)
              .height(5)
              .borderRadius(3)
              .backgroundColor(slot.dateKey === this.selectedDateKey ? '#FFFFFF' : '#1EA97C');
          }
        }
        .width('100%')
        .justifyContent(FlexAlign.Center)
        .height(12);
      }
      .layoutWeight(1)
      .height(48)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(this.getDayCellColor(slot))
      .borderRadius(15)
      .border(slot.isToday && slot.dateKey !== this.selectedDateKey ? { width: 1, color: this.darkModeEnabled ? '#4A5A8A' : '#BFD4FF' } : { width: 0, color: '#00000000' })
      .animation({ duration: 200, curve: Curve.EaseInOut })
      .transition(TransitionEffect.translate({ x: 12, y: 0 }).combine(TransitionEffect.OPACITY).animation({ duration: 200, curve: Curve.EaseInOut }))
      .onClick(() => {
        this.selectedDateKey = slot.dateKey;
        this.calendarWeekOffset = 0;
        this.syncDisplayMonthToSelectedDate();
        if (collapseAfterSelect) {
          this.calendarExpanded = false;
        }
        this.persistState();
      });
    }
  }

  @Builder
  buildPunchCard() {
    Column({ space: 16 }) {
      Row() {
        Column({ space: 4 }) {
          Text('当前日期')
            .fontSize(12)
            .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
          Text(this.getSelectedDateLabel())
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033');
        }

        Text('工时 ' + TimeUtils.formatMinutes(this.getSelectedWorkMinutes()))
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
        Text(this.getExcludeSummaryText())
          .fontSize(13)
          .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
        Blank();
        Text(this.isHoliday() ? '节假日' : '')
          .fontSize(13)
          .fontColor('#D85353')
          .visibility(this.isHoliday() ? Visibility.Visible : Visibility.None);
      }
      .width('100%')
      .justifyContent(FlexAlign.Start);

      // 打卡按钮带绿色脉冲动画
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
            this.handlePunchNow();
          });

        // 绿色脉冲效果
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
        Text(field === 'start' ? this.getStartTimeText() : this.getEndTimeText())
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033')
          .animation({ duration: 200, curve: Curve.EaseInOut });
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
      this.openTimePicker(field);
    });
  }

  @Builder
  buildSummaryCards() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        ForEach(this.getSummaryItems(), (item: SummaryItem) => {
          Column({ space: 8 }) {
            Text(item.title)
              .fontSize(13)
              .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
            Text(item.value)
              .fontSize(22)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.darkModeEnabled ? '#E8EDF5' : '#132033')
              .animation({ duration: 200, curve: Curve.EaseInOut });
          }
          .layoutWeight(1)
          .padding(16)
          .backgroundColor(this.darkModeEnabled ? '#242B3D' : '#FFFFFF')
          .borderRadius(24)
          .border({ width: 1, color: this.darkModeEnabled ? '#3A4255' : '#D8E0F0' })
          .shadow({ radius: 14, color: this.darkModeEnabled ? '#0000004D' : '#12223C5C', offsetX: 0, offsetY: 4 })
          .animation({ duration: 220, curve: Curve.EaseInOut });
        }, (item: SummaryItem) => item.title);
      }
      .width('100%');

      Column({ space: 6 }) {
        Text('与目标平均工时对比')
          .fontSize(13)
          .fontColor(this.darkModeEnabled ? '#8892A4' : '#60708A');
        Text(this.getDifferenceLabel())
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.getDifferenceColor())
          .animation({ duration: 200, curve: Curve.EaseInOut });
      }
      .width('100%')
      .padding(16)
      .backgroundColor(this.darkModeEnabled ? '#242B3D' : '#FFFFFF')
      .borderRadius(24)
      .border({ width: 1, color: this.darkModeEnabled ? '#3A4255' : '#D8E0F0' })
      .shadow({ radius: 14, color: this.darkModeEnabled ? '#0000004D' : '#12223C5C', offsetX: 0, offsetY: 4 })
      .animation({ duration: 420, curve: Curve.EaseOut });
    }
    .width('100%');
  }

  // ========== 业务逻辑方法 ==========

  initializeData(): void {
    this.selectedDateKey = TimeUtils.createDateKey(new Date());
    this.syncDisplayMonthToSelectedDate();
    this.workdayStartTime = '09:00';
    this.excludedRanges = [];

    try {
      let hostContext: Context = this.getUIContext().getHostContext() as Context;
      this.pref = preferences.getPreferencesSync(hostContext, { name: this.prefName });
      this.loadPersistedState();
    } catch (_error) {
      this.pref = null;
    }

    // 始终用最新的 mock 全月数据覆盖，确保日历中所有工作日都有打卡记录
    this.records = PunchCalculator.createMockRecords(this.selectedDateKey);
    this.weekContentKey++;
    this.persistState();
  }

  loadPersistedState(): void {
    if (this.pref === null) {
      return;
    }

    let selectedDateKey: string = this.pref.getSync(this.prefSelectedDateKey, this.selectedDateKey) as string;
    if (selectedDateKey.length > 0) {
      this.selectedDateKey = selectedDateKey;
    }

    let displayMonthText: string = this.pref.getSync(this.prefDisplayMonth, '') as string;
    if (displayMonthText.length > 0) {
      this.restoreDisplayMonth(displayMonthText);
    } else {
      this.syncDisplayMonthToSelectedDate();
    }

    let targetHoursText: string = this.pref.getSync(this.prefTargetHours, this.targetAverageHours.toString()) as string;
    let targetHoursValue: number = Number(targetHoursText);
    if (!Number.isNaN(targetHoursValue)) {
      if (targetHoursValue < 6) {
        this.targetAverageHours = 6;
      } else if (targetHoursValue > 12) {
        this.targetAverageHours = 12;
      } else {
        this.targetAverageHours = Math.round(targetHoursValue * 10) / 10;
      }
    }

    let workdayStartTimeText: string = this.pref.getSync(this.prefWorkdayStartTime, this.workdayStartTime) as string;
    if (TimeUtils.parseTimeToMinutes(workdayStartTimeText) >= 0) {
      this.workdayStartTime = workdayStartTimeText;
    }

    let rangeText: string = this.pref.getSync(this.prefExcludedRanges, '') as string;
    if (rangeText.length > 0) {
      this.excludedRanges = this.deserializeRanges(rangeText);
    }

    let recordsText: string = this.pref.getSync(this.prefRecords, '') as string;
    if (recordsText.length > 0) {
      this.records = this.deserializeRecords(recordsText);
    }

    let darkModeText: string = this.pref.getSync('dark_mode', 'false') as string;
    this.darkModeEnabled = darkModeText === 'true';
  }

  persistState(): void {
    if (this.pref === null) {
      return;
    }

    try {
      this.pref.putSync(this.prefSelectedDateKey, this.selectedDateKey);
      this.pref.putSync(this.prefDisplayMonth, this.getDisplayMonthKey());
      this.pref.putSync(this.prefTargetHours, this.targetAverageHours.toString());
      this.pref.putSync(this.prefWorkdayStartTime, this.workdayStartTime);
      this.pref.putSync(this.prefExcludedRanges, this.serializeRanges());
      this.pref.putSync(this.prefRecords, this.serializeRecords());
      this.pref.putSync('dark_mode', this.darkModeEnabled.toString());
      this.pref.flush();
    } catch (_error) {
    }
  }

  serializeRanges(): string {
    let result: string = '';
    let index: number = 0;
    while (index < this.excludedRanges.length) {
      let item: ExcludedRange = this.excludedRanges[index];
      if (result.length > 0) {
        result += '|';
      }
      result += item.start + ',' + item.end;
      index += 1;
    }
    return result;
  }

  deserializeRanges(content: string): ExcludedRange[] {
    let result: ExcludedRange[] = [];
    let items: string[] = content.split('|');
    let index: number = 0;
    while (index < items.length) {
      let pair: string = items[index];
      if (pair.length > 0) {
        let commaIndex: number = pair.indexOf(',');
        if (commaIndex > 0 && commaIndex < pair.length - 1) {
          let start: string = pair.substring(0, commaIndex);
          let end: string = pair.substring(commaIndex + 1, pair.length);
          if (TimeUtils.parseTimeToMinutes(start) >= 0 && TimeUtils.parseTimeToMinutes(end) >= 0) {
            result.push(new ExcludedRange(start, end));
          }
        }
      }
      index += 1;
    }
    result.sort((a: ExcludedRange, b: ExcludedRange): number => {
      return TimeUtils.parseTimeToMinutes(a.start) - TimeUtils.parseTimeToMinutes(b.start);
    });
    return result;
  }

  serializeRecords(): string {
    let result: string = '';
    let index: number = 0;
    while (index < this.records.length) {
      let item: DailyPunchRecord = this.records[index];
      if (result.length > 0) {
        result += '|';
      }
      result += item.dateKey + '=' + item.punches.join(',');
      index += 1;
    }
    return result;
  }

  deserializeRecords(content: string): DailyPunchRecord[] {
    let result: DailyPunchRecord[] = [];
    let items: string[] = content.split('|');
    let index: number = 0;
    while (index < items.length) {
      let item: string = items[index];
      let separatorIndex: number = item.indexOf('=');
      if (separatorIndex > 0) {
        let dateKey: string = item.substring(0, separatorIndex);
        let punchesText: string = item.substring(separatorIndex + 1, item.length);
        let punches: number[] = [];
        if (punchesText.length > 0) {
          let minuteTexts: string[] = punchesText.split(',');
          let innerIndex: number = 0;
          while (innerIndex < minuteTexts.length) {
            let minuteValue: number = Number(minuteTexts[innerIndex]);
            if (!Number.isNaN(minuteValue) && minuteValue >= 0 && minuteValue < 24 * 60) {
              punches.push(minuteValue);
            }
            innerIndex += 1;
          }
        }
        punches.sort((left: number, right: number) => left - right);
        result.push(new DailyPunchRecord(dateKey, punches));
      }
      index += 1;
    }
    return result;
  }

  restoreDisplayMonth(content: string): void {
    if (content.length !== 7) {
      this.syncDisplayMonthToSelectedDate();
      return;
    }
    let year: number = Number(content.substring(0, 4));
    let month: number = Number(content.substring(5, 7));
    if (Number.isNaN(year) || Number.isNaN(month) || month < 1 || month > 12) {
      this.syncDisplayMonthToSelectedDate();
      return;
    }
    this.displayYear = year;
    this.displayMonth = month - 1;
  }

  getDisplayMonthKey(): string {
    return this.displayYear.toString() + '-' + TimeUtils.toTwoDigits(this.displayMonth + 1);
  }

  syncDisplayMonthToSelectedDate(): void {
    let selectedDate: Date | null = TimeUtils.parseDateKey(this.selectedDateKey);
    if (selectedDate === null) {
      let today: Date = new Date();
      this.displayYear = today.getFullYear();
      this.displayMonth = today.getMonth();
      return;
    }
    this.displayYear = selectedDate.getFullYear();
    this.displayMonth = selectedDate.getMonth();
  }

  getCurrentMonthTitle(): string {
    return this.displayYear.toString() + '年 ' + (this.displayMonth + 1).toString() + '月';
  }

  getSelectedDateDescription(): string {
    let todayKey: string = TimeUtils.createDateKey(new Date());
    if (this.selectedDateKey === todayKey) {
      return '今天';
    }
    return TimeUtils.getDateLabelWithWeekday(this.selectedDateKey, this.weekdayNames);
  }

  jumpToToday(): void {
    this.selectedDateKey = TimeUtils.createDateKey(new Date());
    this.syncDisplayMonthToSelectedDate();
    this.calendarExpanded = false;
    this.calendarWeekOffset = 0;
    this.persistState();
  }

  handleCalendarSwipe(offsetX: number): void {
    if (offsetX <= -60) {
      if (this.calendarExpanded) {
        this.goToNextMonth();
      } else {
        this.goToNextWeek();
      }
      return;
    }
    if (offsetX >= 60) {
      if (this.calendarExpanded) {
        this.goToPreviousMonth();
      } else {
        this.goToPreviousWeek();
      }
    }
  }

  handleHorizontalBackGesture(offsetX: number): void {
    if (!this.showSettingsPage) {
      return;
    }
    if (offsetX > 80 || offsetX < -80) {
      this.showSettingsPage = false;
    }
  }

  goToPreviousMonth(): void {
    let nextMonth: number = this.displayMonth - 1;
    let nextYear: number = this.displayYear;
    if (nextMonth < 0) {
      nextMonth = 11;
      nextYear -= 1;
    }
    this.displayYear = nextYear;
    this.displayMonth = nextMonth;
    this.calendarWeekOffset = 0;
    this.monthContentKey++;
    this.persistState();
  }

  goToPreviousWeek(): void {
    this.calendarWeekOffset -= 1;
  }

  goToNextWeek(): void {
    this.calendarWeekOffset += 1;
  }

  goToNextMonth(): void {
    let today: Date = new Date();
    let maxYear: number = today.getFullYear();
    let maxMonth: number = today.getMonth();
    if (this.displayYear > maxYear || (this.displayYear === maxYear && this.displayMonth >= maxMonth)) {
      return;
    }

    let nextMonth: number = this.displayMonth + 1;
    let nextYear: number = this.displayYear;
    if (nextMonth > 11) {
      nextMonth = 0;
      nextYear += 1;
    }

    if (nextYear > maxYear || (nextYear === maxYear && nextMonth > maxMonth)) {
      return;
    }

    this.displayYear = nextYear;
    this.displayMonth = nextMonth;
    this.calendarWeekOffset = 0;
    this.monthContentKey++;
    this.persistState();
  }

  getExpandedCalendarRows(): CalendarSlot[][] {
    let allSlots: CalendarSlot[] = this.buildMonthSlots();
    let result: CalendarSlot[][] = [];
    let index: number = 0;
    while (index < allSlots.length) {
      let row: CalendarSlot[] = [];
      let rowInnerIndex: number = 0;
      while (rowInnerIndex < 7 && index < allSlots.length) {
        row.push(allSlots[index]);
        rowInnerIndex += 1;
        index += 1;
      }
      result.push(row);
    }
    return result;
  }

  buildMonthSlots(): CalendarSlot[] {
    let result: CalendarSlot[] = [];
    let firstDay: Date = new Date(this.displayYear, this.displayMonth, 1);
    let firstWeekDay: number = firstDay.getDay();
    let firstColumn: number = firstWeekDay === 0 ? 6 : firstWeekDay - 1;
    let blankIndex: number = 0;
    while (blankIndex < firstColumn) {
      result.push(new CalendarSlot('blank_' + blankIndex.toString(), 0, '', false, false, 0));
      blankIndex += 1;
    }

    let lastDayNumber: number = new Date(this.displayYear, this.displayMonth + 1, 0).getDate();
    let day: number = 1;
    while (day <= lastDayNumber) {
      let date: Date = new Date(this.displayYear, this.displayMonth, day);
      let dateKey: string = TimeUtils.createDateKey(date);
      let slot: CalendarSlot = new CalendarSlot(
        dateKey,
        day,
        dateKey,
        true,
        dateKey === TimeUtils.createDateKey(new Date()),
        this.getRecordPunchCount(dateKey)
      );
      result.push(slot);
      day += 1;
    }

    while (result.length % 7 !== 0) {
      result.push(new CalendarSlot('tail_' + result.length.toString(), 0, '', false, false, 0));
    }
    return result;
  }

  getCurrentWeekSlots(allSlots: CalendarSlot[]): CalendarSlot[] {
    let selectedIndex: number = 0;
    let index: number = 0;
    while (index < allSlots.length) {
      if (allSlots[index].dateKey === this.selectedDateKey) {
        selectedIndex = index;
        break;
      }
      index += 1;
    }

    let rowStart: number = Math.floor(selectedIndex / 7) * 7;
    let adjustedStart: number = rowStart + this.calendarWeekOffset * 7;
    if (adjustedStart < 0) {
      adjustedStart = 0;
    }
    let maxStart: number = Math.max(0, Math.floor((allSlots.length - 1) / 7) * 7);
    if (adjustedStart > maxStart) {
      adjustedStart = maxStart;
    }

    let row: CalendarSlot[] = [];
    let innerIndex: number = adjustedStart;
    while (innerIndex < adjustedStart + 7 && innerIndex < allSlots.length) {
      row.push(allSlots[innerIndex]);
      innerIndex += 1;
    }
    return row;
  }

  getDayCellColor(slot: CalendarSlot): string {
    if (!slot.inCurrentMonth) {
      return '#00000000';
    }
    if (slot.dateKey === this.selectedDateKey) {
      return '#2E67F8';
    }
    if (slot.isToday) {
      return this.darkModeEnabled ? '#2D3548' : '#EEF3FF';
    }
    return this.darkModeEnabled ? '#1E2636' : '#F6F8FC';
  }

  getSelectedDateLabel(): string {
    return TimeUtils.getDateLabelWithWeekday(this.selectedDateKey, this.weekdayNames);
  }

  getSelectedWorkMinutes(): number {
    let record: DailyPunchRecord | null = this.getRecordByDateKey(this.selectedDateKey);
    if (record === null) {
      return 0;
    }
    return PunchCalculator.calculateWorkMinutes(record.punches, this.workdayStartTime, this.excludedRanges);
  }

  getStartTimeText(): string {
    let record: DailyPunchRecord | null = this.getRecordByDateKey(this.selectedDateKey);
    if (record === null || record.punches.length === 0) {
      return '--:--';
    }
    return TimeUtils.formatMinuteAsTime(record.punches[0]);
  }

  getEndTimeText(): string {
    let record: DailyPunchRecord | null = this.getRecordByDateKey(this.selectedDateKey);
    if (record === null || record.punches.length < 2) {
      return '--:--';
    }
    return TimeUtils.formatMinuteAsTime(record.punches[record.punches.length - 1]);
  }

  getExcludeSummaryText(): string {
    if (this.excludedRanges.length === 0) {
      return '未设置排除时段';
    }
    return '已排除 ' + this.excludedRanges.length.toString() + ' 个时段';
  }

  getSummaryItems(): SummaryItem[] {
    let averageMinutes: number = this.getDisplayedMonthAverageMinutes();
    let targetMinutes: number = Math.round(this.targetAverageHours * 60);
    let items: SummaryItem[] = [];
    items.push(new SummaryItem('目标平均工时', TimeUtils.formatMinutes(targetMinutes)));
    items.push(new SummaryItem('当前平均工时', TimeUtils.formatMinutes(averageMinutes)));
    return items;
  }

  getDifferenceLabel(): string {
    let averageMinutes: number = this.getDisplayedMonthAverageMinutes();
    let targetMinutes: number = Math.round(this.targetAverageHours * 60);
    let delta: number = averageMinutes - targetMinutes;
    if (delta === 0) {
      return '与目标持平';
    }
    if (delta > 0) {
      return '比目标多 ' + TimeUtils.formatMinutes(delta);
    }
    return '比目标少 ' + TimeUtils.formatMinutes(0 - delta);
  }

  getDifferenceColor(): string {
    let averageMinutes: number = this.getDisplayedMonthAverageMinutes();
    let targetMinutes: number = Math.round(this.targetAverageHours * 60);
    let delta: number = averageMinutes - targetMinutes;
    if (delta === 0) {
      return '#132033';
    }
    if (delta > 0) {
      return '#1EA97C';
    }
    return '#D85353';
  }

  getDisplayedMonthAverageMinutes(): number {
    return PunchCalculator.getDisplayedMonthAverageMinutes(
      this.records, this.displayYear, this.displayMonth,
      this.workdayStartTime, this.excludedRanges
    );
  }

  calculateWorkMinutes(punches: number[]): number {
    return PunchCalculator.calculateWorkMinutes(punches, this.workdayStartTime, this.excludedRanges);
  }

  getOverlapMinutes(startOne: number, endOne: number, startTwo: number, endTwo: number): number {
    return PunchCalculator.getOverlapMinutes(startOne, endOne, startTwo, endTwo);
  }

  openTimePicker(field: string): void {
    let currentValue: string = field === 'start' ? this.getStartTimeText() : this.getEndTimeText();
    let defaultValue: string = currentValue === '--:--' ? (field === 'start' ? '09:00' : '18:00') : currentValue;
    let selectedDate: Date = TimeUtils.createTimePickerDate(defaultValue);

    this.getUIContext().showTimePickerDialog({
      selected: selectedDate,
      useMilitaryTime: true,
      dateTimeOptions: { hour: '2-digit', minute: '2-digit' },
      onAccept: (value: TimePickerResult) => {
        if (value.hour != undefined && value.minute != undefined) {
          this.applyPickedTime(field, value.hour, value.minute);
        }
      }
    });
  }

  openRangeTimePicker(isStart: boolean): void {
    let value: string = isStart ? this.rangeStartInput : this.rangeEndInput;
    let selectedDate: Date = TimeUtils.createTimePickerDate(value);
    this.getUIContext().showTimePickerDialog({
      selected: selectedDate,
      useMilitaryTime: true,
      dateTimeOptions: { hour: '2-digit', minute: '2-digit' },
      onAccept: (result: TimePickerResult) => {
        if (result.hour != undefined && result.minute != undefined) {
          let picked: string = TimeUtils.toTwoDigits(result.hour) + ':' + TimeUtils.toTwoDigits(result.minute);
          if (isStart) {
            this.rangeStartInput = picked;
            // 修改开始时间后，自动将结束时间设为开始时间 + 30 分钟
            let startMinutes: number = result.hour * 60 + result.minute;
            let endMinutes: number = startMinutes + 30;
            if (endMinutes >= 1440) {
              endMinutes = 1439;
            }
            let endHour: number = Math.floor(endMinutes / 60);
            let endMin: number = endMinutes % 60;
            this.rangeEndInput = TimeUtils.toTwoDigits(endHour) + ':' + TimeUtils.toTwoDigits(endMin);
          } else {
            this.rangeEndInput = picked;
          }
          this.rangeDialogKey++;
        }
      }
    });
  }

  openWorkdayStartTimePicker(): void {
    let selectedDate: Date = TimeUtils.createTimePickerDate(this.workdayStartTime);
    this.getUIContext().showTimePickerDialog({
      selected: selectedDate,
      useMilitaryTime: true,
      dateTimeOptions: { hour: '2-digit', minute: '2-digit' },
      onAccept: (result: TimePickerResult) => {
        if (result.hour != undefined && result.minute != undefined) {
          this.workdayStartTime = TimeUtils.toTwoDigits(result.hour) + ':' + TimeUtils.toTwoDigits(result.minute);
          this.persistState();
        }
      }
    });
  }

  applyPickedTime(field: string, hour: number, minute: number): void {
    let pickedMinutes: number = hour * 60 + minute;
    let record: DailyPunchRecord | null = this.getRecordByDateKey(this.selectedDateKey);
    let nextPunches: number[] = [];

    if (record === null) {
      nextPunches.push(pickedMinutes);
      if (field === 'end') {
        nextPunches.push(pickedMinutes);
      }
    } else {
      nextPunches = PunchCalculator.copyPunches(record.punches);
      if (field === 'start') {
        if (nextPunches.length === 0) {
          nextPunches.push(pickedMinutes);
        } else {
          nextPunches[0] = pickedMinutes;
        }
      } else {
        if (nextPunches.length === 0) {
          nextPunches.push(pickedMinutes);
          nextPunches.push(pickedMinutes);
        } else if (nextPunches.length === 1) {
          if (pickedMinutes < nextPunches[0]) {
            nextPunches.unshift(pickedMinutes);
          } else {
            nextPunches.push(pickedMinutes);
          }
        } else {
          nextPunches[nextPunches.length - 1] = pickedMinutes;
        }
      }
    }

    nextPunches.sort((left: number, right: number) => left - right);
    this.replaceRecordForDate(this.selectedDateKey, nextPunches);
    this.playPunchCardFeedback();
    this.persistState();
  }

  confirmAddRange(): void {
    let startMinute: number = TimeUtils.parseTimeToMinutes(this.rangeStartInput);
    let endMinute: number = TimeUtils.parseTimeToMinutes(this.rangeEndInput);
    if (startMinute < 0 || endMinute <= startMinute) {
      return;
    }
    // 检查与已有排除时段是否有交集
    let hasOverlap: boolean = false;
    let idx: number = 0;
    while (idx < this.excludedRanges.length) {
      let existing: ExcludedRange = this.excludedRanges[idx];
      let existStart: number = TimeUtils.parseTimeToMinutes(existing.start);
      let existEnd: number = TimeUtils.parseTimeToMinutes(existing.end);
      // 两个区间有交集当且仅当 startMinute < existEnd && endMinute > existStart
      if (startMinute < existEnd && endMinute > existStart) {
        hasOverlap = true;
        break;
      }
      idx++;
    }
    if (hasOverlap) {
      this.showRangeConflictDialog = true;
      return;
    }
    let nextRanges: ExcludedRange[] = PunchCalculator.copyRanges(this.excludedRanges);
    nextRanges.push(new ExcludedRange(this.rangeStartInput, this.rangeEndInput));
    // 按开始时间排序
    nextRanges.sort((a: ExcludedRange, b: ExcludedRange): number => {
      return TimeUtils.parseTimeToMinutes(a.start) - TimeUtils.parseTimeToMinutes(b.start);
    });
    this.excludedRanges = nextRanges;
    this.showRangeDialog = false;
    this.persistState();
  }

  removeRange(index: number): void {
    let nextRanges: ExcludedRange[] = [];
    let current: number = 0;
    while (current < this.excludedRanges.length) {
      if (current !== index) {
        let range: ExcludedRange = this.excludedRanges[current];
        nextRanges.push(new ExcludedRange(range.start, range.end));
      }
      current += 1;
    }
    this.confirmDeleteIndex = -1;
    this.getUIContext().animateTo({ duration: 300, curve: Curve.EaseInOut }, () => {
      this.excludedRanges = nextRanges;
    });
    this.persistState();
  }

  createTimePickerDate(value: string): Date {
    let minutes: number = TimeUtils.parseTimeToMinutes(value);
    if (minutes < 0) {
      minutes = 0;
    }
    let hour: number = Math.floor(minutes / 60);
    let minute: number = minutes % 60;
    return new Date(2024, 0, 1, hour, minute, 0);
  }

  getCurrentMinuteOfDay(): number {
    let now: Date = new Date();
    return now.getHours() * 60 + now.getMinutes();
  }

  handlePunchNow(): void {
    let minute: number = this.getCurrentMinuteOfDay();
    let record: DailyPunchRecord | null = this.getRecordByDateKey(this.selectedDateKey);
    let nextPunches: number[] = [];

    if (record === null) {
      nextPunches.push(minute);
    } else {
      nextPunches = PunchCalculator.copyPunches(record.punches);
      nextPunches.push(minute);
    }

    nextPunches.sort((left: number, right: number) => left - right);
    this.replaceRecordForDate(this.selectedDateKey, nextPunches);
    this.playPunchCardFeedback();
    this.persistState();
  }

  replaceRecordForDate(dateKey: string, punches: number[]): void {
    let nextRecords: DailyPunchRecord[] = [];
    let index: number = 0;
    let replaced: boolean = false;
    while (index < this.records.length) {
      let item: DailyPunchRecord = this.records[index];
      if (item.dateKey === dateKey) {
        nextRecords.push(new DailyPunchRecord(dateKey, PunchCalculator.copyPunches(punches)));
        replaced = true;
      } else {
        nextRecords.push(new DailyPunchRecord(item.dateKey, PunchCalculator.copyPunches(item.punches)));
      }
      index += 1;
    }
    if (!replaced) {
      nextRecords.push(new DailyPunchRecord(dateKey, PunchCalculator.copyPunches(punches)));
    }
    this.records = nextRecords;
    this.weekContentKey++;
  }

  playPunchCardFeedback(): void {
    // 缩放动画
    this.punchCardScale = 0.92;
    this.getUIContext().animateTo({
      duration: 140,
      curve: Curve.EaseOut
    }, () => {
      this.punchCardScale = 1.06;
    });
    this.getUIContext().animateTo({
      duration: 220,
      delay: 140,
      curve: Curve.EaseInOut
    }, () => {
      this.punchCardScale = 1;
    });

    // 绿色脉冲动画
    this.punchButtonGlow = 1;
    this.getUIContext().animateTo({
      duration: 600,
      curve: Curve.EaseOut
    }, () => {
      this.punchButtonGlow = 0;
    });
  }

  isHoliday(): boolean {
    return this.holidays2026.includes(this.selectedDateKey);
  }

  getRecordPunchCount(dateKey: string): number {
    let record: DailyPunchRecord | null = this.getRecordByDateKey(dateKey);
    if (record === null) {
      return 0;
    }
    return record.punches.length;
  }

  getRecordByDateKey(dateKey: string): DailyPunchRecord | null {
    let index: number = this.findRecordIndex(dateKey);
    if (index < 0) {
      return null;
    }
    return this.records[index];
  }

  findRecordIndex(dateKey: string): number {
    let index: number = 0;
    while (index < this.records.length) {
      if (this.records[index].dateKey === dateKey) {
        return index;
      }
      index += 1;
    }
    return -1;
  }
}