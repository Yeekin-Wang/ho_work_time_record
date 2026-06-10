import { ConfigurationConstant } from '@kit.AbilityKit';
import { THEME_MODE_DARK, THEME_MODE_LIGHT, THEME_MODE_SYSTEM } from '../constants/IndexConstants';

export class ThemeService {
  static getColor(token: string, darkModeEnabled: boolean): string {
    switch (token) {
      case 'transparent':
        return '#00000000';
      case 'page_bg':
        return darkModeEnabled ? '#1A1F2E' : '#F9FBFF';
      case 'page_bg_secondary':
        return darkModeEnabled ? '#242B3D' : '#F2F5FB';
      case 'text_primary':
        return darkModeEnabled ? '#E8EDF5' : '#132033';
      case 'text_secondary':
        return darkModeEnabled ? '#8892A4' : '#60708A';
      case 'text_inverse':
        return '#FFFFFF';
      case 'card_bg':
        return darkModeEnabled ? '#242B3D' : '#FFFFFF';
      case 'surface_bg':
        return darkModeEnabled ? '#2D3548' : '#F6F8FC';
      case 'surface_brand_bg':
        return darkModeEnabled ? '#2D3548' : '#EEF3FF';
      case 'calendar_idle_bg':
        return darkModeEnabled ? '#1E2636' : '#F6F8FC';
      case 'segmented_selected_bg':
        return darkModeEnabled ? '#38446A' : '#FFFFFF';
      case 'card_border':
        return darkModeEnabled ? '#3A4255' : '#D8E0F0';
      case 'brand':
        return '#2E67F8';
      case 'brand_text':
        return darkModeEnabled ? '#8B9EF5' : '#2E67F8';
      case 'brand_focus_border':
        return darkModeEnabled ? '#4A5A8A' : '#BFD4FF';
      case 'success':
        return darkModeEnabled ? '#2ED67C' : '#1EA97C';
      case 'danger':
        return '#D85353';
      case 'danger_soft_bg':
        return darkModeEnabled ? '#3D2030' : '#FFF5F5';
      case 'scrim':
        return darkModeEnabled ? '#80000000' : '#660C1729';
      case 'picker_text':
        return darkModeEnabled ? '#8BA0C8' : '#66182431';
      case 'picker_text_faded':
        return darkModeEnabled ? '#5E7394' : '#99182431';
      case 'picker_selected_text':
        return darkModeEnabled ? '#4D8CFF' : '#007DFF';
      case 'shadow_card':
        return darkModeEnabled ? '#0000004D' : '#12223C5C';
      case 'shadow_card_active':
        return darkModeEnabled ? '#00000033' : '#12223C24';
      case 'shadow_modal':
        return darkModeEnabled ? '#0000004D' : '#30223C5C';
      default:
        return darkModeEnabled ? '#E8EDF5' : '#132033';
    }
  }

  static getThemeColorMode(themeMode: string): ThemeColorMode {
    let normalizedThemeMode: string = ThemeService.normalizeThemeMode(themeMode);
    if (normalizedThemeMode === THEME_MODE_DARK) {
      return ThemeColorMode.DARK;
    }
    if (normalizedThemeMode === THEME_MODE_LIGHT) {
      return ThemeColorMode.LIGHT;
    }
    return ThemeColorMode.SYSTEM;
  }

  static getPageBackgroundColor(darkModeEnabled: boolean): string {
    return darkModeEnabled ? '#1A1F2E' : '#F9FBFF';
  }

  static getSystemBarTextColor(darkModeEnabled: boolean): string {
    return darkModeEnabled ? '#E8EDF5' : '#132033';
  }

  static getDifferenceColor(deltaMinutes: number, darkModeEnabled: boolean): string {
    if (deltaMinutes === 0) {
      return ThemeService.getColor('text_primary', darkModeEnabled);
    }
    if (deltaMinutes > 0) {
      return ThemeService.getColor('success', darkModeEnabled);
    }
    return ThemeService.getColor('danger', darkModeEnabled);
  }

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
