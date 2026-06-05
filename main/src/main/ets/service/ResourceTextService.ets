import { common } from '@kit.AbilityKit';

export class ResourceTextService {
  static getString(context: common.UIAbilityContext, resourceName: string, fallback: string): string {
    try {
      return context.resourceManager.getStringByNameSync(resourceName);
    } catch (_error) {
      return fallback;
    }
  }
}
