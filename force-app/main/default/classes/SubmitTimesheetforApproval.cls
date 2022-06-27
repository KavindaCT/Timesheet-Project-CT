public class SubmitTimesheetforApproval {
 /**
    * This method will submit the opportunity for approval
    **/
    public static void submitForApproval(Timesheet__c opp){        
        // Create an approval request for  Opportunity        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
        req.setComments('Submitting approval request using Trigger');        
        req.setObjectId(opp.id);
        // Submit the approval request for the Opportunity        
        Approval.ProcessResult result = Approval.process(req);        
    }     
    
    /**
    *Get ProcessInstanceWorkItemId using SOQL
    **/
    public static Id getWorkItemId(Id targetObjectId){
        Id workItemId = null;
        for(ProcessInstanceWorkitem workItem  : [Select p.Id from ProcessInstanceWorkitem p where p.ProcessInstance.TargetObjectId =: targetObjectId]){
            workItemId  =  workItem.Id;
        }
        return workItemId;
    }

    /**
    * This method will Approve the opportunity
    **/
    public static void approveRecord(Timesheet__c opp){
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Approving request using Trigger');
        req.setAction('Approve');        
        Id workItemId = getWorkItemId(opp.id); 
        if(workItemId == null){
            opp.addError('Error Occured in Trigger');
        }
        else{
            req.setWorkitemId(workItemId);
            // Submit the request for approval
            Approval.ProcessResult result =  Approval.process(req);
        }
    }

    /**
    * This method will Reject the opportunity
    **/
    public static void rejectRecord(Timesheet__c opp){
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setComments('Rejected request using Trigger');
        req.setAction('Reject');
        Id workItemId = getWorkItemId(opp.id);
        if(workItemId == null){
            opp.addError('Error Occured in Trigger');
        }
        else{
            req.setWorkitemId(workItemId);
            // Submit the request for approval
            Approval.ProcessResult result =  Approval.process(req);
        }
    }
 }