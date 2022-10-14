import { api, LightningElement, wire } from 'lwc';
import getTimesheetId from '@salesforce/apex/TimesheetDataService.getTimesheetId';
//import uId from '@salesforce/user/Id';


const columns = [
    { label: 'Name', fieldName: 'Name', type:'Text(80)'},
    { label: 'Timesheet Date', fieldName: 'Timesheet_Date__c', type: 'Date' },
    { label: 'Earning type', fieldName: 'Earning_Type__c', type: 'Picklist' },
    { label: 'Hours', fieldName: 'Hours__c', type: 'Number(16, 2)' },
    { label: 'Timesheet Month', fieldName: 'Timesheet_month__c', type: 'Formula (Text)' },
    
    //{ label: 'Timesheet Name', fieldName: 'Timesheet__r.name', type: 'Text(80)' }
    //{ label: 'Timesheet Day', fieldName: 'Day__c', type: 'Picklist' }
];

export default class ApprovalRequest extends LightningElement {
    @api recordId;
    //userId= uId;

    @wire(getTimesheetId,{recordId:'$recordId'})
    timesheetData
    // wireTimesheetId(results){

    //     if(results){
    //         let timesheetData = JSON.stringify(results);
    //        // console.log('results '+JSON.stringify(results));
    //         console.log('results data'+timesheetData);
    //     }else{
    //         console.log('error');
    //     }
    // }

    //data = [];
    columns = columns;
}