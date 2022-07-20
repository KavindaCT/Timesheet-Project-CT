import { LightningElement, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import {
    publish,
    MessageContext
} from 'lightning/messageService';
import TimesheetMessageChannel from '@salesforce/messageChannel/TimesheetMessageChannel__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getPreviousTimesheets from '@salesforce/apex/TimesheetDataService.getPreviousTimesheets';
import uId from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';

export default class TimesheetManagement extends LightningElement {
    isModalOpen = false;
    previousTimesheets;
    currentUserId = uId;
    showSpinner = true;
    fullName;

    @wire(MessageContext)
    messageContext;

    @wire(getRecord, { recordId: '$currentUserId', fields: [NAME_FIELD] })
    wiredUser({ error, data }) {
        if (data) {
            this.fullName = data.fields.Name.value;
            this.showSpinner = false;
        } else if (error) {
            console.log(error);
            this.showSpinner = false;
        }
    }

    @wire(getPreviousTimesheets, { currentUserId: '$currentUserId' })
    wiredPreviousTimesheets({ error, data }) {
        if (data) {
            this.previousTimesheets = data.filter(timesheet => timesheet.Status__c !== 'Draft');
        } else if (error) {
            console.log(error);
        }
    }

    closeQuickAction() {
        this.isModalOpen = true;
    }

    hideModalBox() {
        this.isModalOpen = false;
    }

    get timesheetsToShow() {
        return this.previousTimesheets !== undefined && this.previousTimesheets !== null && this.previousTimesheets.length > 0;
    }

    viewTimeSheet(event) {
        if (event) {
            this.hideModalBox();
            this.dispatchEvent(new CustomEvent("setview", { detail: { view: "timesheet" } }));
        }
    }

    handleViewTimesheet(event) {
        const id = event.detail.id;
        const name = event.detail.name;

        if (id !== null && id !== undefined && name !== null && name !== undefined) {
            const payload = { timesheetId: id, timesheetName: name };
            publish(this.messageContext, TimesheetMessageChannel, payload);
            this.dispatchEvent(new CustomEvent("setview", { detail: { view: "timesheet" } }));
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Opening Previous Timesheet',
                    variant: 'error',
                })
            );
        }
    }
}