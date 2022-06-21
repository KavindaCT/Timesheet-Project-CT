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

    @AuraEnabled
    public static List<Timesheet_Day__c> getTimesheetDays(String timesheetId, String weekNumber){
        try {
            return [
                SELECT Id, Name, Hours__c, Week_Number__c, Earning_Type__c
                FROM Timesheet_Day__c
                WHERE Timesheet__c = :timesheetId AND Week_Number__c = :weekNumber
            ];
        } catch (Exception e) {
            System.debug('Exception: ' + e.getMessage());
            return null;
        }
    }
}