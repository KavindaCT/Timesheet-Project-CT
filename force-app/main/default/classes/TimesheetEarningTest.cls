@isTest
public class TimesheetEarningTest {
    @TestSetup
    static void createTimesheetDays(){
        Timesheet__c timesheet = new Timesheet__c(
            Name = 'June 2022',
            Status__c = 'Draft'
        );
        insert(timesheet);
        
        List<Timesheet_Day__c> timesheetDays = new List<Timesheet_Day__c>();
        for (Integer i = 0; i < 2; i++) {
            Timesheet_Day__c newDayOrdinary = new Timesheet_Day__c(
                Name = '20-' + i,
                Hours__c = 4,
                Week_Number__c = '4',
                Day__c = 'Tue',
                Earning_Type__c = 'Ordinary Hours',
                Timesheet__c = timesheet.Id
            );

            Timesheet_Day__c newDayOvertime = new Timesheet_Day__c(
                Name = '20-' + i,
                Hours__c = 4,
                Week_Number__c = '4',
                Day__c = 'Tue',
                Earning_Type__c = 'Overtime Hours',
                Timesheet__c = timesheet.Id
            );

            timesheetDays.add(newDayOrdinary);
            timesheetDays.add(newDayOvertime);
        }
        insert(timesheetDays);
    }
    @isTest static void testGetEarnings() {
        List<Timesheet_Day__c> timesheetDays =  [
            SELECT Id, Name, Hours__c, Week_Number__c, Day__c, Earning_Type__c
            FROM Timesheet_Day__c
            WHERE Timesheet__r.Name = 'June 2022' AND Week_Number__c = '4'
        ];

        List<TimesheetEarning.earningsWrapper> earnings = TimesheetEarning.getEarnings(timesheetDays);

        System.debug(earnings);
        System.assertEquals(2, earnings.size());
    }
}
