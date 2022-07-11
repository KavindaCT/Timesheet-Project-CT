import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getTimesheetDays from '@salesforce/apex/TimesheetDataService.getTimesheetDays';
import getAllApprovers from '@salesforce/apex/TimesheetDataService.getAllApprovers';
import submitForApproval from '@salesforce/apex/SubmitTimesheetforApproval.submitForApproval';
import getRoleSubordinateUsers from '@salesforce/apex/RoleHierachy.getRoleSubordinateUsers';
import UsrRoleId from '@salesforce/schema/User.UserRoleId';

// import STATUS_FIELD from '@salesforce/schema/Timesheet__c.Status__c';
import uId from '@salesforce/user/Id';

export default class TimeSheetCmp extends LightningElement {
    @api timePeriod;
    @api timesheetId;
    activeWeek; // Only contains weekStart and weekEnding
    activeWeekNumber;
    openModal = false;
    currentRecordId;
    timesheetDays;
    currentUserId = uId;
    approverId;
    availableApprovers =[];
    roleId;
    isLoading = true;

    @wire(getTimesheetDays, { timesheetId: '$timesheetId', weekNumber: '$activeWeekNumber', currentUser: '$currentUserId' })
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

    // @wire(getAllApprovers)
    // wiredApprovers({ error, data }) {
    //     if (data) {
    //         this.availableApprovers = data.map(approver => {
    //             return {
    //                 label: approver.Name,
    //                 value: approver.Id
    //             }
    //         });
    //         this.isLoading = false;
    //         console.log(JSON.stringify(this.availableApprovers));
    //     } else if (error) {
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Error while getting approvers',
    //                 message: error.body.message,
    //                 variant: 'error',
    //             }),
    //         );
    //         this.isLoading = false;
    //     }
    // }

    @wire(getRoleSubordinateUsers)
    wiredApprovers({ error, data }) {
        if (data) {
            for (let key in data) {
                this.availableApprovers.push({value:data[key], key:key});
             }
            // this.roleId = data;
            console.log(JSON.stringify(this.availableApprovers[0].value.Name));
                 
                return {
                    label: this.availableApprovers[0].value.Name,
                    value:this.availableApprovers[0].value.Id
                }
            
            this.isLoading = false;
        } else if (error) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while getting approvers',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
            this.isLoading = false;
        }
    }
    

    handleChangeApprover(event) {
        this.approverId = event.target.value;
    }

    handleClickSubmit(event) {
        this.template.querySelector('c-heading-cmp').handleStatus(event.target.value);
        this.openModal = true;
        console.log(uRoleId);
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

    sendToApprove() {
        this.isLoading = true;
        if (this.approverId) {
            submitForApproval({ timesheetId: this.timesheetId, approverId: this.approverId })
                .then(result => {
                    console.log(result);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Your request has sent to the Approver',
                            variant: 'success'
                        })
                    );
                    this.isLoading = false;
                    this.openModal = false;
                }).catch(error => {
                    console.log(error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Send to approval Failed - Please contact Administrator',
                            message: error.message,
                            variant: 'error'
                        })
                    );
                    this.isLoading = false;
                });
        }
    }

    handleClickDraft() { }

    handleClickDelete() { }

    handleClickCancel() { }
}