import { LightningElement, api, wire } from 'lwc';
import getTimesheetDays from '@salesforce/apex/TimesheetDataService.getTimesheetDays';
import STATUS from '@salesforce/schema/Timesheet__c.Status__c';

export default class TimeSheetCmp extends LightningElement {
    @api timePeriod;
    @api timesheetId;
    activeWeek; // Only contains weekStart and weekEnding
    activeWeekNumber;
    openModal = false;
    currentRecordId;

    @wire(getTimesheetDays, { timesheetId: '$timesheetId', weekNumber: '$activeWeekNumber' })
    timesheetDays;
    
    handleClickSubmit(event){
        this.template.querySelector('c-heading-cmp').handleStatus(event.target.value);
        this.openModal = true;
        // this.currentRecordId='a008d000005UjhoAAC';
        // console.log('@@currentRecordId@@@'+this.currentRecordId);
        // updateToggle({cliId: this.currentRecordId})
        //   .then(() => {
        //     console.log('SUCCESS');
        //     return refreshApex(this.caseLineItems);
        // })
        // .catch((error) => {
        //     this.errorMessage=error;
        //     console.log('unable to update the record due to'+JSON.stringify(this.errorMessage));
        // });
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