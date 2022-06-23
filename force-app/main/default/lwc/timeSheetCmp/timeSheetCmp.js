import { LightningElement, api, wire } from 'lwc';
import getTimesheetDays from '@salesforce/apex/TimesheetDataService.getTimesheetDays';

export default class TimeSheetCmp extends LightningElement {
    @api timePeriod;
    @api timesheetId;
    activeWeek;
    activeWeekNumber;
    openModal = false;

    @wire(getTimesheetDays, { timesheetId: '$timesheetId', weekNumber: '$activeWeekNumber'})
    timesheetDays;
    
    handleClickSubmit(event){
        this.template.querySelector('c-heading-cmp').handleStatus(event.target.value);
        this.openModal = true;
        console.log('Week Number: ' + this.activeWeekNumber);
        console.log('Day data: ' + JSON.stringify(this.timesheetDays));
    }

    changeWeek(event) {
        this.activeWeek = event.detail.week;
        this.activeWeekNumber = event.detail.weekNumber + 1;
    }

    cancelApprovers() {
        this.openModal = false;
    }

    handleClickDraft(){}

    handleClickDelete(){}

    handleClickCancel(){}
}