import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getTimesheetDays from '@salesforce/apex/TimesheetDataService.getTimesheetDays';
import submitForApproval from '@salesforce/apex/SubmitTimesheetforApproval.submitForApproval';
import getRoleSubordinateUsers from '@salesforce/apex/RoleHierachy.getRoleSubordinateUsers';
import insertTimesheetDays from '@salesforce/apex/TimesheetDataService.insertTimesheetDays';
import STATUS_FIELD from '@salesforce/schema/Timesheet__c.Status__c';
import MONTHLY_TOT_FIELD from '@salesforce/schema/Timesheet__c.Monthly_Total__c';
import NAME_FIELD from '@salesforce/schema/Timesheet__c.Name';
import uId from '@salesforce/user/Id';
import { getRecord } from 'lightning/uiRecordApi';
import getTimesheetIdFromWorkitemId from '@salesforce/apex/TimesheetDataService.getTimesheetIdFromWorkitemId';
import CallObject from '@salesforce/schema/Task.CallObject';

const fields = [STATUS_FIELD, MONTHLY_TOT_FIELD, NAME_FIELD];
const STATUS = ['Submitted', 'Approved'];
export default class TimeSheetCmp extends LightningElement {
    
    //approvalId;
    @api timePeriod;
    @api timesheetId;
    activeWeek; // Only contains weekStart and weekEnding
    activeWeekNumber;
    openModal = false;
    currentRecordId;
    @track timesheetDays;
    @track timesheetDaysPerWeek;
    availableApprovers = [];
    currentUserId;
    approverId;
    roleId;
    isLoading = true;
    readOnly = false;
    wiredTimesheetData;
    wiredTimesheetDaysData;
    timesheetBasicData;
    timesheetStatus;
    monthlyTotal = 0;
    id = '';


    @api get recordId(){
        return this.id;
    }

    set recordId(value){
        this.id = value;
        if(value){
            getTimesheetIdFromWorkitemId({recordId : this.id}).then(result => {
                console.log('timesheetid  '+JSON.stringify(result));
                console.log('key'+Object.keys(result));
                this.timesheetId = Object.keys(result)[0];

                this.currentUserId = Object.values(result)[0];

                console.log('currentUserId'+this.currentUserId);
            });
        }
        
    }

    @wire(getRecord, { recordId: '$timesheetId', fields })
    getTimesheetData(results) {
        this.wiredTimesheetData = results;

        const { error, data } = results;
        if (data) {
            this.timesheetBasicData = data;
            // if (this.timesheetBasicData.fields.Status__c.value === 'Submitted' || this.timesheetBasicData.fields.Status__c.value === 'Approved') {
            if (STATUS.includes(this.timesheetBasicData.fields.Status__c.value)) {
                this.readOnly = true;
            } else {
                this.readOnly = false;
            }
            this.timePeriod = this.timesheetBasicData.fields.Name.value;
            this.timesheetStatus = this.timesheetBasicData.fields.Status__c.value;
            this.monthlyTotal = this.timesheetBasicData.fields.Monthly_Total__c.value;
        } else if (error) {
            console.log(JSON.stringify(error));
        }
    }

    @wire(getTimesheetDays, { timesheetId: '$timesheetId', currentUser: '$currentUserId' })
    wiredTimesheetDays(results) {
        this.wiredTimesheetDaysData = results;

        const { error, data } = results;
        console.log('inside timesheetdays wire');
        console.log('userid'+ this.currentUserId);
        console.log('timesheetid'+ this.timesheetId);
        if (data) {
            this.timesheetDays = data;
            this.timesheetDaysPerWeek = this.timesheetDays.filter(day => day.weekNumber === this.activeWeekNumber);
            console.log(JSON.stringify(this.timesheetDaysPerWeek));
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

    // @api get approvalId(){
    //     return this.approvalId;
    // }
    // set approvalId(value){
    //     this.approvalId = value;
    // }

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
            let daysPerWeek = this.timesheetDays.filter(day => day.weekNumber === event.detail.weekNumber + 1 && !day.deleteFlag);

            if (daysPerWeek.length > 0) {
                this.timesheetDaysPerWeek = daysPerWeek;
            } else {
                let deletedDaysPerWeek = this.timesheetDays.filter(day => day.weekNumber === event.detail.weekNumber + 1);
                const lastIndex = deletedDaysPerWeek.length - 1;

                let newDummyDay = {
                    id: parseInt(deletedDaysPerWeek[lastIndex].id, 10) + 1,
                    earningType: '',
                    hours: [],
                    weekNumber: this.activeWeekNumber,
                    deleteFlag: false
                }
                this.timesheetDaysPerWeek.push(newDummyDay);
                this.timesheetDays.push(newDummyDay);
            }
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
                    refreshApex(this.wiredTimesheetDaysData);
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

    // handleChangeValue(event) {
    //     var newTimesheetDays = JSON.parse(JSON.stringify(this.timesheetDays));
    //     const dayId = event.detail.dayId;
    //     this.monthlyTotal = '';

    //     let index = this.timesheetDays.findIndex(earning => earning.id === event.detail.earningsId);
    //     console.log(event.detail.value)

    //     if (dayId !== '') {
    //         let hoursindex = this.timesheetDays[index].hours.findIndex(day => day.id === dayId);
    //         newTimesheetDays[index].hours[hoursindex].hours = event.detail.value;

    //     } else {
    //         const date = new Date(`${event.detail.date}${this.timePeriod.substring(0, 11)}`);
    //         const timesheetDate = date.getFullYear() + '-' + (date.getMonth() + 1) + '-' + date.getDate();
    //         let hoursindex = this.timesheetDays[index].hours.findIndex(day => day.timesheet_date === timesheetDate);
    //         if(hoursindex != -1){
    //             newTimesheetDays[index].hours[hoursindex].hours = event.detail.value;
    //         }else{
    //             newTimesheetDays[index].hours.push({
    //                 name: event.detail.name + ' ' + this.timePeriod.substring(0, 11) + '-' + newTimesheetDays[index].earningType,
    //                 hours: event.detail.value,
    //                 day: event.detail.day,
    //                 timesheet_date: timesheetDate
    //             });
    //         }
           
    //     }
    //     this.timesheetDays = newTimesheetDays;
      
    // }

    handleChangeValue(event) {
        var newTimesheetDays = JSON.parse(JSON.stringify(this.timesheetDays));
        const dayId = event.detail.dayId;
        this.monthlyTotal = '';

        let index = this.timesheetDays.findIndex(earning => earning.id === event.detail.earningsId);
        if (dayId !== '') {
            let hoursindex = this.timesheetDays[index].hours.findIndex(day => day.id === dayId);
            newTimesheetDays[index].hours[hoursindex].hours = event.detail.value;
        } else {
            let hoursindex = this.timesheetDays[index].hours.findIndex(day => day.day === event.detail.day);
            if(hoursindex > -1){
                newTimesheetDays[index].hours[hoursindex].hours = event.detail.value;     
            }else{
                let date = new Date(`${event.detail.date}${this.timePeriod.substring(0, 11)}`);
                newTimesheetDays[index].hours.push({
                    name: event.detail.name + ' ' + this.timePeriod.substring(0, 11) + '-' + newTimesheetDays[index].earningType,
                    hours: event.detail.value,
                    day: event.detail.day,
                    timesheet_date: date.getFullYear() + '-' + (date.getMonth() + 1) + '-' + date.getDate()
                });
            }
        }
        this.timesheetDays = newTimesheetDays;
      
    }

    handleEarningTypeChange(event) {
        var newTimesheetDays = JSON.parse(JSON.stringify(this.timesheetDays));
        const earningId = event.detail.id;

        if (earningId !== null) {
            let index = this.timesheetDays.findIndex(earning => earning.id === earningId);
            newTimesheetDays[index].earningType = event.detail.earningType;
        }

        this.timesheetDays = newTimesheetDays;
    }

    handleClickDraft() {

        insertTimesheetDays({ timesheetDays: this.timesheetDays, timesheetId: this.timesheetId }).then(result => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success! Your hours successfully saved',
                    variant: 'success'
                })
            );
            refreshApex(this.wiredTimesheetData);
            refreshApex(this.wiredTimesheetDaysData);
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Something went wrong!',
                    message: 'Check whether you have reached daily working hours goal',
                    variant: 'error'
                })
            );
        });
    }

    handleAddNewEarning(event) {
        var newTimesheetDays = JSON.parse(JSON.stringify(this.timesheetDays));
        if (event) {
            newTimesheetDays.push(event.detail);
            this.timesheetDaysPerWeek.push(event.detail);
        }
        this.timesheetDays = newTimesheetDays;
    }

    handleRemoveEarning(event) {
        var newTimesheetDays = JSON.parse(JSON.stringify(this.timesheetDays));

        if (event) {
            console.log('Delete');
            const id = event.detail.id;
            let index = this.timesheetDays.findIndex(earning => earning.id === id);
            console.log(newTimesheetDays[index]);

            if (newTimesheetDays[index].hours.length > 0) {
                newTimesheetDays[index].deleteFlag = true;
            } else {
                newTimesheetDays.splice(index, 1);
            }
            let perWeekIndex = this.timesheetDaysPerWeek.findIndex(earning => earning.id === id);
            this.timesheetDaysPerWeek.splice(perWeekIndex, 1);
        }
        this.timesheetDays = newTimesheetDays;
        // console.log(JSON.parse(JSON.stringify(this.timesheetDays)));
        // console.log(JSON.parse(JSON.stringify(this.timesheetDaysPerWeek)));
    }

    hideModalBox() {
        this.openModal = false;
    }

    handleClickDelete() { }

    handleClickCancel() {
        this.dispatchEvent(new CustomEvent('resetview'));
    }
}