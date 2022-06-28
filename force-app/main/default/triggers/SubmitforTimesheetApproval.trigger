trigger SubmitforTimesheetApproval on Timesheet__c (after insert,after update) {
 for(Timesheet__c opp:trigger.New){       
        try{
            if(Trigger.isInsert){
                if(opp.Status__c == 'Submitted'){
                    SubmitTimesheetforApproval.submitForApproval(opp);
                }
                else if(opp.Status__c == 'Approved'){
                    SubmitTimesheetforApproval.approveRecord(opp);
                }
                else if(opp.Status__c == 'Rejected'){
                    SubmitTimesheetforApproval.rejectRecord(opp);
                }
            }
            else if(Trigger.isUpdate){
                Timesheet__c oppOld=Trigger.OldMap.get(opp.Id);
                if( opp.Status__c == 'Submitted' && oppOld.Status__c != 'Submitted') {
                    SubmitTimesheetforApproval.submitForApproval(opp);
                }
                else if(opp.Status__c == 'Approved' && oppOld.Status__c != 'Approved'){
                    SubmitTimesheetforApproval.approveRecord(opp);
                }
                else if(opp.Status__c == 'Rejected' && oppOld.Status__c != 'Rejected'){
                    SubmitTimesheetforApproval.rejectRecord(opp);
                }
            }
        }
        catch(Exception e){
            opp.addError(e.getMessage());
        }
    }
 }