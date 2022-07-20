import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getTimesheetDays from '@salesforce/apex/TimesheetDataService.getTimesheetDays';
import submitForApproval from '@salesforce/apex/SubmitTimesheetforApproval.submitForApproval';
import getRoleSubordinateUsers from '@salesforce/apex/RoleHierachy.getRoleSubordinateUsers';
import insertTimesheetDays from '@salesforce/apex/TimesheetDataService.insertTimesheetDays';
import STATUS_FIELD from '@salesforce/schema/Timesheet__c.Status__c';
import MONTHLY_TOT_FIELD from '@salesforce/schema/Timesheet__c.Monthly_Total__c';
import uId from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';

const fields = [STATUS_FIELD, MONTHLY_TOT_FIELD];
export default class TimeSheetCmp extends LightningElement {
    @api timePeriod;
    @api timesheetId;
    activeWeek; // Only contains weekStart and weekEnding
    activeWeekNumber;
    openModal = false;
    currentRecordId;
    @track timesheetDays;
    timesheetDaysPerWeek;
    availableApprovers = [];
    currentUserId = uId;
    approverId;
    roleId;
    isLoading = true;
    readOnly = false;
    wiredTimesheetData;
    timesheetBasicData;
    timesheetStatus;
    monthlyTotal = 0;

    @wire(getRecord, { recordId: '$timesheetId', fields })
    getTimesheetData(results) {
        this.wiredTimesheetData = results;

        const { error, data } = results;
        if (data) {
            this.timesheetBasicData = data;
            if (this.timesheetBasicData.fields.Status__c.value === 'Submitted' || this.timesheetBasicData.fields.Status__c.value === 'Approved') {
                this.readOnly = true;
            } else {
                this.readOnly = false;
            }
            this.timesheetStatus = this.timesheetBasicData.fields.Status__c.value;
            this.monthlyTotal = this.timesheetBasicData.fields.Monthly_Total__c.value;
        } else if (error) {
            console.log(JSON.stringify(error));
        }
    }

    @wire(getTimesheetDays, { timesheetId: '$timesheetId', currentUser: '$currentUserId' })
    wiredTimesheetDays({ error, data }) {
        if (data) {
            this.timesheetDays = data;
            // console.log(JSON.parse(JSON.stringify(this.timesheetDays)));
            this.timesheetDaysPerWeek = this.timesheetDays.filter(day => day.weekNumber === this.activeWeekNumber);
            // console.log(this.timesheetDaysPerWeek);
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

    @wire(getRoleSubordinateUsers)
    wiredApprovers({ error, data }) {
        if (data) {
            // for (let key in data) {
            //     this.availableApprovers.push({label:data[key], value:key});
            //  }
            // this.roleId = data;
            this.availableApprovers = data.map(approver => {
                return {
                    label: approver.Name,
                    value: approver.Id
                }
            });
            this.isLoading = false;
            // console.log(JSON.stringify(this.availableApprovers));

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

    get disableSubmit() {
        return this.approverId == null ? true : false;
    }

    handleChangeApprover(event) {
        this.approverId = event.target.value;
    }

    handleClickSubmit() {
        this.openModal = true;
        this.isLoading = true;

        insertTimesheetDays({ timesheetDays: this.timesheetDays, timesheetId: this.timesheetId }).then(result => {
            console.log(result);
            this.isLoading = false;
        }).catch(error => {
            console.log(error);
            this.openModal = false;
            this.isLoading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Something went wrong!',
                    message: 'Your changes not saved, Please try again later',
                    variant: 'error'
                })
            );
        });

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
        this.activeWeek = event.detail.week; // { Weekstart, Weekending }
        this.activeWeekNumber = event.detail.weekNumber + 1;
        if (this.timesheetDays) {
            this.timesheetDaysPerWeek = [];
            this.timesheetDaysPerWeek = this.timesheetDays.filter(day => day.weekNumber === event.detail.weekNumber + 1);
        }
    }

    // cancelApprovers() {
    //     this.openModal = false;
    // }

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
                    this.openModal = false;
                    refreshApex(this.wiredTimesheetData);
                    this.isLoading = false;
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

    handleChangeValue(event) {
        var newTimesheetDays = JSON.parse(JSON.stringify(this.timesheetDays));
        const dayId = event.detail.dayId;
        this.monthlyTotal = '';

        let index = this.timesheetDays.findIndex(earning => earning.id === event.detail.earningsId);

        if (dayId !== '') {
            let hoursindex = this.timesheetDays[index].hours.findIndex(day => day.id === dayId);
            newTimesheetDays[index].hours[hoursindex].hours = event.detail.value;
        } else {
            newTimesheetDays[index].hours.push({
                name: event.detail.name + '-' + this.timePeriod.substring(0, 9) + '-' + newTimesheetDays[index].earningType,
                hours: event.detail.value,
                day: event.detail.day
            });
        }

        this.timesheetDays = newTimesheetDays;
    }

    handleEarningTypeChange(event) {
        var newTimesheetDays = JSON.parse(JSON.stringify(this.timesheetDays));
        const earningId = event.detail.id;

        if(earningId !== null) {
            let index = this.timesheetDays.findIndex(earning => earning.id === earningId);
            newTimesheetDays[index].earningType = event.detail.earningType;
        }

        this.timesheetDays = newTimesheetDays;
    }

    handleClickDraft() {
        insertTimesheetDays({ timesheetDays: this.timesheetDays, timesheetId: this.timesheetId }).then(result => {
            console.log(result);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success! Your hours successfully saved',
                    variant: 'success'
                })
            );
            refreshApex(this.wiredTimesheetData);
        }).catch(error => {
            console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Something went wrong!',
                    message: 'Your changed not saved, Please try again later',
                    variant: 'error'
                })
            );
        });
    }

    hideModalBox(){
        this.openModal = false;
    }

    handleClickDelete() { }

    handleClickCancel() { }
}