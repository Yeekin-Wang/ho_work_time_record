import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const DOMAIN = 0x0000;

export default class MainAbility extends UIAbility {
  private windowStage: window.WindowStage | null = null;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    this.windowStage = windowStage;

    windowStage.loadContent('pages/Index', async (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');

      // 页面加载完成后设置状态栏颜色
      await this.updateSystemBarColor();
    });
  }

  private async updateSystemBarColor(): Promise<void> {
    if (!this.windowStage) {
      return;
    }

    try {
      const mainWindow = await this.windowStage.getMainWindow();
      if (!mainWindow) {
        return;
      }

      // 获取当前颜色模式
      const config = this.context.config;
      const isDarkMode = config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;

      hilog.info(DOMAIN, 'testTag', 'Setting system bar color, darkMode: %{public}s', isDarkMode.toString());

      // 设置状态栏和导航栏背景色和文字颜色
      const systemBarProperties: window.SystemBarProperties = {
        statusBarColor: isDarkMode ? '#1A1F2E' : '#F9FBFF',
        statusBarContentColor: isDarkMode ? '#E8EDF5' : '#132033',
        navigationBarColor: isDarkMode ? '#1A1F2E' : '#F9FBFF',
        navigationBarContentColor: isDarkMode ? '#E8EDF5' : '#132033'
      };

      mainWindow.setSystemBarProperties(systemBarProperties, (err) => {
        if (err.code) {
          hilog.error(DOMAIN, 'testTag', 'Failed to set system bar properties. Cause: %{public}s', JSON.stringify(err));
        } else {
          hilog.info(DOMAIN, 'testTag', 'System bar properties set successfully');
        }
      });
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to update system bar color. Cause: %{public}s', JSON.stringify(err));
    }
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
    // 应用回到前台时更新状态栏颜色
    this.updateSystemBarColor();
  }

  onBackground(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    hilog.info(DOMAIN, 'testTag', 'onConfigurationUpdate, config: %{public}s', JSON.stringify(newConfig));
    // 监听系统配置变化（深色模式切换），更新状态栏颜色
    this.updateSystemBarColor();
  }
}
