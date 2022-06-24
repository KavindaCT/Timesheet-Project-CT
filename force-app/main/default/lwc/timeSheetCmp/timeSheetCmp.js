import { LightningElement, api, wire } from 'lwc';
import getTimesheetDays from '@salesforce/apex/TimesheetDataService.getTimesheetDays';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TimeSheetCmp extends LightningElement {
    @api timePeriod;
    @api timesheetId;
    activeWeek; // Only contains weekStart and weekEnding
    activeWeekNumber;
    openModal = false;
    timesheetDays;

    @wire(getTimesheetDays, { timesheetId: '$timesheetId', weekNumber: '$activeWeekNumber' })
    wiredTimesheetDays({ error, data }) {
        if (data) {
            this.timesheetDays = data;
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while getting records',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        }
    }

    handleClickSubmit(event) {
        this.template.querySelector('c-heading-cmp').handleStatus(event.target.value);
        this.openModal = true;
        console.log('Day data: ' + JSON.stringify(this.timesheetDays));
    }

    changeWeek(event) {
        this.timesheetDays = null;
        this.activeWeek = event.detail.week;
        this.activeWeekNumber = event.detail.weekNumber + 1;
    }

    cancelApprovers() {
        this.openModal = false;
    }

    handleClickDraft() { }

    handleClickDelete() { }

    handleClickCancel() { }
}