import { api, LightningElement } from "lwc";

const APPROVED_CLASS =
  "slds-badge slds-theme_success slds-var-p-horizontal_medium slds-text-heading_small";
const REJECTED_CLASS =
  "slds-badge slds-theme_error slds-var-p-horizontal_medium slds-text-heading_small";
const SUBMITTED_CLASS =
  "slds-badge slds-theme_warning slds-var-p-horizontal_medium slds-text-heading_small";
export default class PreviousTimesheet extends LightningElement {
  @api timesheet;

  get badgeClass() {
    return this.timesheet.Status__c === "Approved"
      ? APPROVED_CLASS
      : this.timesheet.Status__c === "Submitted"
      ? SUBMITTED_CLASS
      : REJECTED_CLASS;
  }

  handleClickView() {
    this.dispatchEvent(
      new CustomEvent("view", {
        detail: { id: this.timesheet.Id, name: this.timesheet.Name }
      })
    );
  }
}
