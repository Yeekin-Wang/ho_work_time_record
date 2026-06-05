import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { ThemeService } from '../service/ThemeService';

const DOMAIN = 0x0000;

export default class MainAbility extends UIAbility {
  private windowStage: window.WindowStage | null = null;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    // 缓存当前设备的颜色模式，供页面使用
    AppStorage.setOrCreate('currentColorMode', this.context.config.colorMode);
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

      // 缓存窗口对象到 AppStorage，供页面使用
      const mainWindow = await this.windowStage!.getMainWindow();
      if (mainWindow) {
        AppStorage.setOrCreate('windowClass', mainWindow);
      }

      // 设置沉浸式全屏布局
      await this.setImmersiveMode(mainWindow);

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

      // 设置状态栏和导航栏 - 背景色透明，文字颜色跟随主题
      // 沉浸式模式下，状态栏背景由页面背景通过 expandSafeArea 延伸填充
      const systemBarProperties: window.SystemBarProperties = {
        statusBarColor: '#00000000',
        statusBarContentColor: ThemeService.getSystemBarTextColor(isDarkMode),
        navigationBarColor: '#00000000',
        navigationBarContentColor: ThemeService.getSystemBarTextColor(isDarkMode)
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

  /**
   * 设置沉浸式模式：全屏布局 + 窗口背景色与页面一致
   * 开启 setWindowLayoutFullScreen 后，布局扩展到状态栏和导航栏区域
   * 页面中的 expandSafeArea 会将绘制内容延伸到非安全区域
   */
  private async setImmersiveMode(mainWindow: window.Window): Promise<void> {
    try {
      // 1. 设置窗口全屏布局（沉浸式）
      await mainWindow.setWindowLayoutFullScreen(true);

      // 2. 设置窗口背景色与页面背景色一致
      // 当页面 expandSafeArea 延伸时，窗口背景会透过状态栏区域显示
      const config = this.context.config;
      const isDarkMode = config.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
      const windowBgColor = ThemeService.getPageBackgroundColor(isDarkMode);
      mainWindow.setWindowBackgroundColor(windowBgColor);

      hilog.info(DOMAIN, 'testTag', 'Immersive mode set successfully');
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set immersive mode. Cause: %{public}s', JSON.stringify(err));
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
    // 更新缓存中的颜色模式，页面通过 @StorageProp 监听变化
    AppStorage.setOrCreate('currentColorMode', newConfig.colorMode);
    // 监听系统配置变化（深色模式切换），更新状态栏颜色和沉浸模式
    this.updateSystemBarColor();
    this.updateWindowBackgroundOnConfigChange(newConfig);
  }

  /**
   * 配置变化时同步更新窗口背景色，保持沉浸效果与深色/浅色模式一致
   */
  private async updateWindowBackgroundOnConfigChange(newConfig: Configuration): Promise<void> {
    if (!this.windowStage) {
      return;
    }
    try {
      const mainWindow = await this.windowStage.getMainWindow();
      if (!mainWindow) {
        return;
      }
      const isDarkMode = newConfig.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
      const windowBgColor = ThemeService.getPageBackgroundColor(isDarkMode);
      mainWindow.setWindowBackgroundColor(windowBgColor);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to update window bg color. Cause: %{public}s', JSON.stringify(err));
    }
  }
}
