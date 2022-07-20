import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import {
  publish,
  MessageContext
} from 'lightning/messageService';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TimesheetMessageChannel from '@salesforce/messageChannel/TimesheetMessageChannel__c';
import getRecentTimesheet from '@salesforce/apex/TimesheetDataService.getRecentTimesheet';
import { createRecord, getRecord } from 'lightning/uiRecordApi';

import uId from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';

import TIMESHEET_OBJECT from '@salesforce/schema/Timesheet__c';
import TIMESHEET_NAME_FIELD from '@salesforce/schema/Timesheet__c.Name';
import TIMESHEET_STATUS_FIELD from '@salesforce/schema/Timesheet__c.Status__c';

const MONTH = [
  "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
];

export default class AddTimesheet extends NavigationMixin(LightningElement) {
  showSpinner = true;
  timeSheetId;
  timePeriod;
  timePeriodCheck;
  currentUserId = uId;
  currentUserName;

  @wire(MessageContext)
  messageContext;

  @wire(getRecord, { recordId: '$currentUserId', fields: [NAME_FIELD] })
  wiredUser({ error, data }) {
    if(data) {
      this.currentUserName = data.fields.Name.value;
      this.showSpinner = false;
    } else if(error) {
      console.log(error);
    }
  }

  connectedCallback() {
    const currentDate = new Date();
    this.timePeriod = MONTH[currentDate.getMonth()] + ' ' + currentDate.getFullYear(); // June 2022
  }

  value = 'inProgress';

  get options() {
    return [{ label: this.timePeriod, value: this.timePeriod }];
  }

  createNewTimesheet(timePeriod) {
    this.showSpinner = true;
  
    const fields = {};
    fields[TIMESHEET_NAME_FIELD.fieldApiName] = timePeriod;
    fields[TIMESHEET_STATUS_FIELD.fieldApiName] = 'draft';
    const recordInput = { apiName: TIMESHEET_OBJECT.objectApiName, fields };
    createRecord(recordInput)
      .then(timesheet => {
        this.timeSheetId = timesheet.id;
        this.showSpinner = false;
      })
      .catch(error => {
        this.showSpinner = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: 'Error creating record',
            message: error.body.message,
            variant: 'error',
          }),
        );
      });
  }

  handlePeriodSelect(event) {
    this.showSpinner = true;
    const currentTimePeriod = event.detail.value + ' - ' + this.currentUserName; // 'June 2022 - Employee Name' String
    getRecentTimesheet({ timePeriod: currentTimePeriod, currentUser: this.currentUserId }).then(result => {
      if(result.length > 0) {
        const payload = { timesheetId: result[0].Id, timesheetName: result[0].Name };
        publish(this.messageContext, TimesheetMessageChannel, payload);
      } else {
        this.createNewTimesheet(currentTimePeriod);
        const payload = { timesheetId: this.timeSheetId, timesheetName: currentTimePeriod };
        publish(this.messageContext, TimesheetMessageChannel, payload);
      }
      this.showSpinner = false;
    }).catch(error => {
      console.log(error);
    });
    this.timePeriodCheck = currentTimePeriod;
  }

  // navigateWithoutAura() {
  //   let cmpDef = {
  //     componentDef: "c:timeSheetCmp"
  //   };

  //   let encodedDef = btoa(JSON.stringify(cmpDef));
  //   this[NavigationMixin.Navigate]({
  //     type: "standard__webPage",
  //     attributes: {
  //       url: "/one/one.app#" + encodedDef
  //     }
  //   });
  // }

  navigateToTimesheet() {
    if(this.timePeriodCheck != null){
      this.dispatchEvent(new CustomEvent("viewtimesheet"));
      this.sendTimePeriod();
    }else{
      const event = new ShowToastEvent({
        title: 'Please select a period',
        variant: 'error',
    });
    this.dispatchEvent(event);
    }
    
  }
}