import { LightningElement, wire } from 'lwc';
import {
    subscribe,
    APPLICATION_SCOPE,
    MessageContext
} from 'lightning/messageService';
import TimesheetMessageChannel from '@salesforce/messageChannel/TimesheetMessageChannel__c';

export default class TimesheetBase extends LightningElement {
    viewDashboard = true;
    timePeriod;
    timesheetId;

    @wire(MessageContext)
    messageContext;

    setView(event) {
        if(event.detail.view === 'dashboard') {
            this.viewDashboard = true;
        } else {
            this.viewDashboard = false;
        }
    }

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                TimesheetMessageChannel,
                (message) => {
                    this.timePeriod = message.timesheetName;
                    this.timesheetId = message.timesheetId;
                },
                { scope: APPLICATION_SCOPE }
            );
        }
    }
}