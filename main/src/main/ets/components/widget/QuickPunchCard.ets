let storage = new LocalStorage();

@Entry(storage)
@Component
struct QuickPunchCard {
  @LocalStorageProp('todayLabel') todayLabel: string = '';
  @LocalStorageProp('statusText') statusText: string = '今天还未打卡';
  @LocalStorageProp('actionText') actionText: string = '打卡';
  @LocalStorageProp('startTimeText') startTimeText: string = '--:--';
  @LocalStorageProp('endTimeText') endTimeText: string = '--:--';
  @LocalStorageProp('workMinutesText') workMinutesText: string = '0h 0m';
  @LocalStorageProp('monthAverageText') monthAverageText: string = '0h 0m';
  @LocalStorageProp('differenceText') differenceText: string = '与目标持平';
  @LocalStorageProp('lastUpdatedText') lastUpdatedText: string = '';

  private readonly ACTION_PUNCH_NOW: string = 'punch_now';
  private readonly ACTION_OPEN_APP: string = 'router';
  private readonly ABILITY_NAME: string = 'MainAbility';

  build() {
    Column() {
      if (this.isMiniCard()) {
        this.buildMiniCard();
      } else if (this.isWideButtonCard()) {
        this.buildWideButtonCard();
      } else if (this.isMediumCard()) {
        this.buildMediumCard();
      } else {
        this.buildSmallCard();
      }
    }
    .width('100%')
    .height('100%')
    .padding(10)
    .backgroundColor($r('app.color.card_bg'))
  }

  @Builder
  private buildMiniCard() {
    FormLink({
      action: 'message',
      params: {
        action: this.ACTION_PUNCH_NOW
      }
    }) {
      Column({ space: 6 }) {
        Text(this.actionText)
          .width(58)
          .height(58)
          .textAlign(TextAlign.Center)
          .fontSize(17)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_inverse'))
          .backgroundColor($r('app.color.brand'))
          .borderRadius(29)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
    }
  }

  @Builder
  private buildWideButtonCard() {
    Row({ space: 10 }) {
      FormLink({
        action: this.ACTION_OPEN_APP,
        abilityName: this.ABILITY_NAME,
        params: {
          target: 'today',
          source: 'quick_punch_card'
        }
      }) {
        Column({ space: 4 }) {
          Text(this.statusText)
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.workMinutesText)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .maxLines(1)
        }
        .layoutWeight(1)
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)
      }

      this.buildPunchButton(76, 44, 18);
    }
    .width('100%')
    .height('100%')
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  private buildSmallCard() {
    Column({ space: 10 }) {
      FormLink({
        action: this.ACTION_OPEN_APP,
        abilityName: this.ABILITY_NAME,
        params: {
          target: 'today',
          source: 'quick_punch_card'
        }
      }) {
        Column({ space: 5 }) {
          Text($r('app.string.widget_title'))
            .fontSize(13)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_secondary'))
          Text(this.statusText)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
          Text(this.startTimeText + ' - ' + this.endTimeText)
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .maxLines(1)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }

      Row() {
        Text(this.workMinutesText)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.brand_text'))
        Blank()
        this.buildPunchButton(76, 40, 17);
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  private buildMediumCard() {
    Column({ space: 8 }) {
      FormLink({
        action: this.ACTION_OPEN_APP,
        abilityName: this.ABILITY_NAME,
        params: {
          target: 'today',
          source: 'quick_punch_card'
        }
      }) {
        Column({ space: 6 }) {
          Row() {
            Text(this.todayLabel)
              .fontSize(13)
              .fontColor($r('app.color.text_secondary'))
              .maxLines(1)
            Blank()
            Text(this.lastUpdatedText)
              .fontSize(11)
              .fontColor($r('app.color.text_secondary'))
          }
          .width('100%')

          Text(this.statusText)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.text_primary'))
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
        .width('100%')
      }

      Row({ space: 8 }) {
        this.buildMetric('上班', this.startTimeText);
        this.buildMetric('下班', this.endTimeText);
      }
      .width('100%')

      Row({ space: 8 }) {
        this.buildMetric('今日', this.workMinutesText);
        this.buildMetric('月均', this.monthAverageText);
      }
      .width('100%')

      Row() {
        Text(this.differenceText)
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Blank()
        this.buildPunchButton(76, 38, 16);
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  private buildMetric(label: string, value: string) {
    Column({ space: 3 }) {
      Text(label)
        .fontSize(11)
        .fontColor($r('app.color.text_secondary'))
      Text(value)
        .fontSize(15)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .layoutWeight(1)
    .padding({ left: 8, right: 8, top: 6, bottom: 6 })
    .borderRadius(8)
    .backgroundColor($r('app.color.surface_bg'))
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private buildPunchButton(widthValue: number, heightValue: number, fontSizeValue: number) {
    FormLink({
      action: 'message',
      params: {
        action: this.ACTION_PUNCH_NOW
      }
    }) {
      Text(this.actionText)
        .width(widthValue)
        .height(heightValue)
        .textAlign(TextAlign.Center)
        .fontSize(fontSizeValue)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_inverse'))
        .backgroundColor($r('app.color.brand'))
        .borderRadius(heightValue / 2)
    }
  }

  private isMiniCard(): boolean {
    return true;
  }

  private isWideButtonCard(): boolean {
    return false;
  }

  private isSmallCard(): boolean {
    return false;
  }

  private isMediumCard(): boolean {
    return false;
  }
}
