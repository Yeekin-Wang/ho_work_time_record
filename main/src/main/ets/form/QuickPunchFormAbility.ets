import { Want } from '@kit.AbilityKit';
import { formBindingData, FormExtensionAbility, formInfo, formProvider } from '@kit.FormKit';
import { QuickPunchCardState } from '../model/QuickPunchCardState';
import { QuickPunchService } from '../service/QuickPunchService';

const ACTION_PUNCH_NOW: string = 'punch_now';

export default class QuickPunchFormAbility extends FormExtensionAbility {
  private readonly quickPunchService: QuickPunchService = new QuickPunchService();

  onAddForm(want: Want): formBindingData.FormBindingData {
    return this.createBindingData(this.quickPunchService.buildCardState(this.context));
  }

  onUpdateForm(formId: string): void {
    this.updateForm(formId, this.quickPunchService.buildCardState(this.context));
  }

  onFormEvent(formId: string, message: string): void {
    let action: string = this.parseAction(message);
    if (action === ACTION_PUNCH_NOW) {
      this.updateForm(formId, this.quickPunchService.punchToday(this.context));
      return;
    }
    this.updateForm(formId, this.quickPunchService.buildCardState(this.context));
  }

  onCastToNormalForm(formId: string): void {
  }

  onChangeFormVisibility(newStatus: Record<string, number>): void {
  }

  onRemoveForm(formId: string): void {
  }

  onAcquireFormState(want: Want): formInfo.FormState {
    return formInfo.FormState.READY;
  }

  private createBindingData(cardState: QuickPunchCardState): formBindingData.FormBindingData {
    return formBindingData.createFormBindingData(cardState);
  }

  private updateForm(formId: string, cardState: QuickPunchCardState): void {
    try {
      formProvider.updateForm(formId, this.createBindingData(cardState));
    } catch (_error) {
    }
  }

  private parseAction(message: string): string {
    if (message === ACTION_PUNCH_NOW) {
      return ACTION_PUNCH_NOW;
    }
    try {
      let parsed: Record<string, string> = JSON.parse(message) as Record<string, string>;
      if (typeof parsed.action === 'string') {
        return parsed.action;
      }
    } catch (_error) {
    }
    return '';
  }
}
