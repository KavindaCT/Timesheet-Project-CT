public with sharing class TimesheetDataService {
    @AuraEnabled
    public static List<Timesheet__c> getRecentTimesheet(String timePeriod, String currentUser) {
        try {
            List<Timesheet__c> recentTimesheets = [
                SELECT ID, Name FROM Timesheet__c
                WHERE Name = :timePeriod AND CreatedById = :currentUser
            ];

            return recentTimesheets;
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<TimesheetEarning.earningsWrapper> getTimesheetDays(String timesheetId, String currentUser){
        List<TimesheetEarning.earningsWrapper> earnings = new List<TimesheetEarning.earningsWrapper>();
        try {
            List<Timesheet_Day__c> timesheetDays =  [
                SELECT Id, Name, Hours__c, Week_Number__c, Earning_Type__c, Day__c
                FROM Timesheet_Day__c
                WHERE Timesheet__c = :timesheetId AND CreatedById = :currentUser
            ];
            /* [
                    {Id: '', Name: '20-1', Hours__c: 4, Week_Number__c: 4, Day__c: 'Tue', Earning_Type__c: 'ordinary'},
                    {Id: '', Name: '20-2', Hours__c: 8, Week_Number__c: 4, Day__c: 'Tue', Earning_Type__c: 'overtime'},
                    {Id: '', Name: '21-1', Hours__c: 5, Week_Number__c: 4, Day__c: 'Wed', Earning_Type__c: 'ordinary'},
                    {Id: '', Name: '21-2', Hours__c: 9, Week_Number__c: 4, Day__c: 'Wed', Earning_Type__c: 'overtime'}
               ]
            */
            
            earnings =  TimesheetEarning.getEarnings(timesheetDays);
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
        }
        return earnings;
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

    @AuraEnabled
    public static void insertTimesheetDays(List<Map<String, String>> timesheetDays){
        // [ { id: 10, earningType: 'ordinary', hours: [ { id: '', name: '', day: '', hours: 0} ], weekNUmber: 1 }, ]
        try {
            System.debug(timesheetDays);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}