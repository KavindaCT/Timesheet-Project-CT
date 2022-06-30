import { LightningElement, api, wire } from 'lwc';
import getTimesheetDays from '@salesforce/apex/TimesheetDataService.getTimesheetDays';
// import STATUS_FIELD from '@salesforce/schema/Timesheet__c.Status__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAllApprovers from '@salesforce/apex/TimesheetDataService.getAllApprovers';
import saveApproverName from '@salesforce/apex/SubmitTimesheetforApproval.saveApproverName';

export default class TimeSheetCmp extends LightningElement {
    @api timePeriod;
    @api timesheetId;
    approverName
    approverRecord
    activeWeek; // Only contains weekStart and weekEnding
    activeWeekNumber;
    openModal = false;
    currentRecordId;
    timesheetDays;
    availableApprovers = [];

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

    @wire(getAllApprovers)
    wiredApprovers({ error, data }) {
        if (data) {
            console.log(JSON.stringify(data));
            this.availableApprovers = data.map(approver => {
                return {
                    label: approver.Name,
                    value: approver.Id
                }
            });
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while getting approvers',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        }
    }

    handleClickSubmit(event) {
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
    }

    changeWeek(event) {
        this.timesheetDays = null;
        this.activeWeek = event.detail.week;
        this.activeWeekNumber = event.detail.weekNumber + 1;
    }

    cancelApprovers() {
        this.openModal = false;
    }

   saveApprovers(event) {
        // console.log(this.availableApprovers);
        let details=event.target.value;
        for(let i = 0;i<this.availableApprovers.length;i++){
            if(this.availableApprovers[i].value == details){
                 this.approverName = this.availableApprovers[i].label
                 console.log(this.approverName);
                 
            }
        }
        // console.log(JSON.stringify(details));
    }

    @wire(saveApproverName,{name:'$approverName'})
    wiredApproverNames({ error, data }) {
        if (data) {
            // console.log(JSON.stringify(data));
            this.approverRecord = data;

            this.error = undefined;
        } else if (error) {
            this.error = error;

            this.approverRecord = undefined;
        }
    }
    handleClickDraft() { }

    handleClickDelete() { }

    handleClickCancel() { }
}