public class SubmitTimesheetforApproval {
    /**
    * This method will submit the opportunity for approval
    **/
    @AuraEnabled
    public static void submitForApproval(String timesheetId, String approverId){
        Id recordId = Id.valueOf(timesheetId);
        Id approver = Id.valueOf(approverId);
        List<Id> approvers = new List<Id>{approver};

        // Create an approval request for Timesheet        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
        req.setComments('Submitting approval request using Apex class');
        req.setObjectId(recordId);
        req.setNextApproverIds(approvers);

        // Submit the approval request for the Opportunity 
        Approval.ProcessResult result = Approval.process(req);     
    }
 }