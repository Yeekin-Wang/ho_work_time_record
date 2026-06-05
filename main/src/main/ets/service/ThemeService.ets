import { ConfigurationConstant } from '@kit.AbilityKit';
import { THEME_MODE_DARK, THEME_MODE_LIGHT, THEME_MODE_SYSTEM } from '../constants/IndexConstants';

export class ThemeService {
  static normalizeThemeMode(themeMode: string): string {
    if (themeMode === THEME_MODE_LIGHT || themeMode === THEME_MODE_DARK || themeMode === THEME_MODE_SYSTEM) {
      return themeMode;
    }
    return THEME_MODE_SYSTEM;
  }

  static isDarkMode(themeMode: string, systemColorMode: number): boolean {
    let normalizedThemeMode: string = ThemeService.normalizeThemeMode(themeMode);
    if (normalizedThemeMode === THEME_MODE_DARK) {
      return true;
    }
    if (normalizedThemeMode === THEME_MODE_LIGHT) {
      return false;
    }
    return systemColorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
  }

  static applyColorMode(context: Context, themeMode: string): void {
    try {
      let normalizedThemeMode: string = ThemeService.normalizeThemeMode(themeMode);
      if (normalizedThemeMode === THEME_MODE_DARK) {
        context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);
        return;
      }
      if (normalizedThemeMode === THEME_MODE_LIGHT) {
        context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);
        return;
      }
      context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (_error) {
    }
  }
}
