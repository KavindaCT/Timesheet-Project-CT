public with sharing class TimesheetDataService {
    @AuraEnabled
    public static List<Timesheet__c> getRecentTimesheet(String timePeriod){
        try {
            List<Timesheet__c> recentTimesheets = [
                SELECT ID, Name FROM Timesheet__c
                WHERE Name = :timePeriod
                WITH SECURITY_ENFORCED
            ];

            return recentTimesheets;
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<TimesheetEarning.earningsWrapper> getTimesheetDays(String timesheetId, String weekNumber){
        try {
            List<Timesheet_Day__c> timesheetDays =  [
                SELECT Id, Name, Hours__c, Week_Number__c, Earning_Type__c, Day__c
                FROM Timesheet_Day__c
                WHERE Timesheet__c = :timesheetId AND Week_Number__c = :weekNumber
            ];
            /* [
                    {Id: '', Name: '20-1', Hours__c: 4, Week_Number__c: 4, Day__c: 'Tue', Earning_Type__c: 'ordinary'},
                    {Id: '', Name: '20-2', Hours__c: 8, Week_Number__c: 4, Day__c: 'Tue', Earning_Type__c: 'overtime'},
                    {Id: '', Name: '21-1', Hours__c: 5, Week_Number__c: 4, Day__c: 'Wed', Earning_Type__c: 'ordinary'},
                    {Id: '', Name: '21-2', Hours__c: 9, Week_Number__c: 4, Day__c: 'Wed', Earning_Type__c: 'overtime'}
               ]
            */
            
            List<TimesheetEarning.earningsWrapper> earnings =  TimesheetEarning.getEarnings(timesheetDays);
            return earnings;
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<User> getAllApprovers(){
        try {
            return [
                SELECT Id, Name FROM User
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}