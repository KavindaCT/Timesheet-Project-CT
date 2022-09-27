@isTest
public with sharing class SubmitTimesheetforApprovalTest {
    
    @isTest static void submitForApproval() {

        String timesheetId = 'a008d000007h5VZAAY'; 
        String approverId = '0058d000001tsilAAA';
        

        SubmitTimesheetforApproval.submitForApproval(timesheetId,approverId);

        
    }
}