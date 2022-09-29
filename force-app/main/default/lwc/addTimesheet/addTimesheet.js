import { api, LightningElement, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { publish, MessageContext } from "lightning/messageService";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import TimesheetMessageChannel from "@salesforce/messageChannel/TimesheetMessageChannel__c";
import getRecentTimesheet from "@salesforce/apex/TimesheetDataService.getRecentTimesheet";
import { createRecord } from "lightning/uiRecordApi";

import TIMESHEET_OBJECT from "@salesforce/schema/Timesheet__c";
import TIMESHEET_NAME_FIELD from "@salesforce/schema/Timesheet__c.Name";
import TIMESHEET_STATUS_FIELD from "@salesforce/schema/Timesheet__c.Status__c";

const MONTH = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];

export default class AddTimesheet extends NavigationMixin(LightningElement) {
  showSpinner;
  timeSheetId;
  timePeriod;
  timePeriodCheck;
  userId;
  fullName;

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    const currentDate = new Date();
    this.timePeriod =
      MONTH[currentDate.getMonth()] + " " + currentDate.getFullYear(); // June 2022
  }

  value = "inProgress";

  @api
  get currentUserFullName() {
    return this.fullName;
  }
  set currentUserFullName(value) {
    this.showSpinner = true;
    this.setAttribute("fullName", value);
    this.fullName = value;
    this.showSpinner = false;
  }

  @api
  get currentUserId() {
    return this.userId;
  }
  set currentUserId(value) {
    this.showSpinner = true;
    this.setAttribute("userId", value);
    this.userId = value;
    this.showSpinner = false;
  }

  get options() {
    return [{ label: this.timePeriod, value: this.timePeriod }];
  }

  createNewTimesheet(timePeriod) {
    this.showSpinner = true;

    const fields = {};
    fields[TIMESHEET_NAME_FIELD.fieldApiName] = timePeriod;
    fields[TIMESHEET_STATUS_FIELD.fieldApiName] = "draft";
    const recordInput = { apiName: TIMESHEET_OBJECT.objectApiName, fields };
    createRecord(recordInput)
      .then((timesheet) => {
        this.timeSheetId = timesheet.id;
        this.showSpinner = false;
      })
      .catch((error) => {
        this.showSpinner = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error creating record",
            message: error.body.message,
            variant: "error"
          })
        );
      })
      .finally(() => {
        const payload = {
          timesheetId: this.timeSheetId,
          timesheetName: timePeriod
        };
        publish(this.messageContext, TimesheetMessageChannel, payload);
      });
  }

  handlePeriodSelect(event) {
    this.showSpinner = true;
    const currentTimePeriod = event.detail.value + " - " + this.fullName; // 'June 2022 - Employee Name' String
    getRecentTimesheet({
      timePeriod: currentTimePeriod,
      currentUser: this.userId
    })
      .then((result) => {
        if (result.length > 0) {
          const payload = {
            timesheetId: result[0].Id,
            timesheetName: result[0].Name
          };
          publish(this.messageContext, TimesheetMessageChannel, payload);
        } else {
          this.createNewTimesheet(currentTimePeriod);
        }
        this.showSpinner = false;
      })
      .catch((error) => {
        console.log(error);
      });
    this.timePeriodCheck = currentTimePeriod;
  }

  navigateToTimesheet() {
    if (this.timePeriodCheck != null) {
      this.dispatchEvent(new CustomEvent("viewtimesheet"));
      this.sendTimePeriod();
    } else {
      const event = new ShowToastEvent({
        title: "Please select a period",
        variant: "error"
      });
      this.dispatchEvent(event);
    }
  }
}
