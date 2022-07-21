public with sharing class TimesheetDataService {
    @AuraEnabled(cacheable=true)
    public static List<Timesheet__c> getPreviousTimesheets(String currentUserId) {
        List<Timesheet__c> previousTimesheets = new List<Timesheet__c>();
        try {
            previousTimesheets = [
                SELECT ID, Name, Status__c FROM Timesheet__c
                WHERE CreatedById = :currentUserId
                LIMIT 3
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return previousTimesheets;
    }

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
                SELECT Id, Name, Hours__c, Week_Number__c, Earning_Type__c, Day__c, Timesheet_Date__c
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

    @AuraEnabled
    public static void insertTimesheetDays(List<Map<String, Object>> timesheetDays, String timesheetId){
        // [ { id: 10, earningType: 'ordinary', hours: [ { id: '', name: '', day: '', hours: 0} ], weekNUmber: 1 }, ]
        Id id = Id.valueOf(timesheetId);
        List<Timesheet_Day__c> timesheetDaysData = new List<Timesheet_Day__c>();

        try {
            for(Map<String, Object> earning : timesheetDays) {
                List<Object> hours = (List<Object>) earning.get('hours');
                String earningType = (String) earning.get('earningType');
                String weekNumber = (String) String.valueOf(earning.get('weekNumber'));

                if(hours.size() > 0) {
                    for(Object day: hours) {
                        TimesheetEarning.earningHoursWrapper timesheetDay = (TimesheetEarning.earningHoursWrapper) JSON.deserializeStrict(
                            JSON.serialize(day), TimesheetEarning.earningHoursWrapper.class
                        );

                        if (timesheetDay.id != null) {
                            Timesheet_Day__c updateDay = new Timesheet_Day__c(
                                Id = (Id) timesheetDay.id,
                                Hours__c = timesheetDay.hours,
                                Earning_Type__c = earningType,
                                Timesheet__c = id
                            );
                            timesheetDaysData.add(updateDay);
                        } else {
                            Timesheet_Day__c newDay = new Timesheet_Day__c(
                                Name = timesheetDay.name,
                                Hours__c = timesheetDay.hours,
                                Day__c = timesheetDay.day,
                                Timesheet_Date__c = timesheetDay.timesheet_date,
                                Earning_Type__c = earningType,
                                Week_Number__c = weekNumber,
                                Timesheet__c = id
                            );
                            timesheetDaysData.add(newDay);
                        }
                    }
                }
            }

            upsert timesheetDaysData;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}