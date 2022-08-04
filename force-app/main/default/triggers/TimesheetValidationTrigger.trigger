trigger TimesheetValidationTrigger on Timesheet_Day__c (after insert,after update) {
    for(Timesheet_Day__c t: Trigger.new){
        
        String ids = t.Timesheet__c;
        String createdId = t.CreatedById;
        Decimal Hours = t.Hours__c;
        System.debug(Ids);
        AggregateResult [] days = [SELECT Timesheet_Date__c, sum(Hours__c)amount FROM Timesheet_Day__c WHERE Timesheet__c =: ids AND CreatedById =:createdId group by Timesheet_Date__c];
        // System.debug('result'+days);
        

        for(AggregateResult ag : days){
		  Decimal amount = (decimal) ag.get('amount');
          Date dates = (date) ag.get('Timesheet_Date__c');
          System.debug('sum'+ amount+'date'+ dates);
          
            if(amount < 9 && amount != 0){
                 t.addError('Daily Working hours goal not reached!'); 
            }
        }

    }

}