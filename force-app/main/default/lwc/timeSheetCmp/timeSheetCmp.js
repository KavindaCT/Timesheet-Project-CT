import { LightningElement, api, wire } from 'lwc';
import getTimesheetDays from '@salesforce/apex/TimesheetDataService.getTimesheetDays';

export default class TimeSheetCmp extends LightningElement {
    @api timePeriod;
    @api timesheetId;
    activeWeek;
    activeWeekNumber;
    timesheetDays;
    openModal = false;

    @wire(getTimesheetDays, { timesheetId: '$timesheetId', weekNumber: '$activeWeekNumber'})
    timesheetDays;
    
    handleClickSubmit(event){
        this.template.querySelector('c-heading-cmp').handleStatus(event.target.value);
        this.openModal = true;
        console.log('Data');
        console.log('Day data: ' + JSON.stringify(this.timesheetDays));
    };

    changeWeek(event) {
        this.activeWeek = event.detail.week;
        this.activeWeekNumber = event.detail.weekNumber;
    }

    cancelApprovers() {
        this.openModal = false;
    }

    handleClickDraft(){};

    handleClickDelete(){};

    handleClickCancel(){};
}