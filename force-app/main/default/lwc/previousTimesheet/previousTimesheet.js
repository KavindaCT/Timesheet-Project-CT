import { api, LightningElement } from 'lwc';

const APPROVED_CLASS = 'slds-badge slds-theme_success slds-var-m-horizontal_medium';
const REJECTED_CLASS = 'slds-badge slds-theme_error slds-var-m-horizontal_medium';
export default class PreviousTimesheet extends LightningElement {
    @api timesheet;

    get badgeClass() {
        return this.timesheet.Status__c === 'Approved' ? APPROVED_CLASS : REJECTED_CLASS;
    }

    handleClickView() {
        this.dispatchEvent(new CustomEvent('view', { detail: { id: this.timesheet.Id, name: this.timesheet.Name } }));
    }
}