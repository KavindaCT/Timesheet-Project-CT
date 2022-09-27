trigger TimesheetValidationTrigger on Timesheet_Day__c (before insert,before update,after insert,after update) {
    System.debug('TimesheetValidationTrigger');


    for(Timesheet_Day__c t: Trigger.new){
        
        String ids = t.Timesheet__c;
        String createdId = t.CreatedById;
        Decimal Hours = t.Hours__c;
        System.debug('***testhours*** '+Hours);
        AggregateResult [] days = [SELECT Timesheet_Date__c, sum(Hours__c)amount FROM Timesheet_Day__c WHERE Timesheet__c =: ids AND CreatedById =:createdId group by Timesheet_Date__c];
        // System.debug('result'+days);
        

        for(AggregateResult ag : days){
		  Decimal amount = (decimal) ag.get('amount');
          Date dates = (date) ag.get('Timesheet_Date__c');
          System.debug('sum'+ amount+'date'+ dates);
          
            if(amount < 9 || Hours ==0 || amount > 24){
                 t.addError('Your daily working hour limit should be between 9 and 24 hours'); 
            }
        }

    }

}