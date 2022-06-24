import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import {
  publish,
  MessageContext
} from 'lightning/messageService';
import TimesheetMessageChannel from '@salesforce/messageChannel/TimesheetMessageChannel__c';
import getRecentTimesheet from '@salesforce/apex/TimesheetDataService.getRecentTimesheet';
import { createRecord } from 'lightning/uiRecordApi';

import TIMESHEET_OBJECT from '@salesforce/schema/Timesheet__c';
import TIMESHEET_NAME_FIELD from '@salesforce/schema/Timesheet__c.Name';
import TIMESHEET_STATUS_FIELD from '@salesforce/schema/Timesheet__c.Status__c';

const MONTH = [
  "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
];

export default class AddTimesheet extends NavigationMixin(LightningElement) {
  showSpinner = false;
  timeSheetId;
  timePeriod;

  @wire(MessageContext)
  messageContext;

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
    const currentTimePeriod = event.detail.value; // June 2022 - String
    getRecentTimesheet({ timePeriod: currentTimePeriod }).then(result => {
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
    this.dispatchEvent(new CustomEvent("viewtimesheet"));
    this.sendTimePeriod();
  }
}