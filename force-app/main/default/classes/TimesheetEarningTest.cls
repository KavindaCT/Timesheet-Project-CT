@isTest
public class TimesheetEarningTest {
  @TestSetup
  static void createTimesheetDays() {
    Timesheet__c timesheet = new Timesheet__c(
      Name = 'June 2022',
      Status__c = 'Draft'
    );
    insert (timesheet);
    Date newDate1 = date.today();
    Date newDate2 = date.today().addDays(1);
    Date newDate3 = date.today().addDays(2);
    Date newDate4 = date.today().addDays(3);
    Date newDate5 = date.today().addDays(4);

    List<Timesheet_Day__c> timesheetDays = new List<Timesheet_Day__c>();
    for (Integer i = 0; i < 2; i++) {
      Timesheet_Day__c newDayOrdinary1 = new Timesheet_Day__c(
        Name = '20-' + i,
        Hours__c = 10,
        Week_Number__c = '1',
        Day__c = '2Tue',
        Earning_Type__c = 'Ordinary Hours',
        Timesheet__c = timesheet.Id,
        Timesheet_Date__c = newDate1
      );

      Timesheet_Day__c newDayOrdinary2 = new Timesheet_Day__c(
        Name = '20-' + i,
        Hours__c = 10,
        Week_Number__c = '2',
        Day__c = '2Tue',
        Earning_Type__c = 'Ordinary Hours',
        Timesheet__c = timesheet.Id,
        Timesheet_Date__c = newDate2
      );
      Timesheet_Day__c newDayOrdinary3 = new Timesheet_Day__c(
        Name = '20-' + i,
        Hours__c = 10,
        Week_Number__c = '3',
        Day__c = '2Tue',
        Earning_Type__c = 'Ordinary Hours',
        Timesheet__c = timesheet.Id,
        Timesheet_Date__c = newDate3
      );
      Timesheet_Day__c newDayOrdinary4 = new Timesheet_Day__c(
        Name = '20-' + i,
        Hours__c = 10,
        Week_Number__c = '4',
        Day__c = '2Tue',
        Earning_Type__c = 'Ordinary Hours',
        Timesheet__c = timesheet.Id,
        Timesheet_Date__c = newDate4
      );
      Timesheet_Day__c newDayOrdinary5 = new Timesheet_Day__c(
        Name = '20-' + i,
        Hours__c = 10,
        Week_Number__c = '5',
        Day__c = '2Tue',
        Earning_Type__c = 'Ordinary Hours',
        Timesheet__c = timesheet.Id,
        Timesheet_Date__c = newDate5
      );

      timesheetDays.add(newDayOrdinary1);
      timesheetDays.add(newDayOrdinary2);
      timesheetDays.add(newDayOrdinary3);
      timesheetDays.add(newDayOrdinary4);
      timesheetDays.add(newDayOrdinary5);
    }
    insert (timesheetDays);
  }
  @isTest
  static void testGetEarnings() {
    List<Timesheet_Day__c> timesheetDays = [
      SELECT
        Id,
        Name,
        Hours__c,
        Week_Number__c,
        Day__c,
        Earning_Type__c,
        Timesheet_month__c
      FROM Timesheet_Day__c
      WHERE
        Timesheet__r.Name = 'June 2022'
        AND (Week_Number__c = '1'
        OR Week_Number__c = '2'
        OR Week_Number__c = '3'
        OR Week_Number__c = '4'
        OR Week_Number__c = '5')
    ];

    List<TimesheetEarning.earningsWrapper> earnings = TimesheetEarning.getEarnings(
      timesheetDays
    );

    System.debug('output ' + timesheetDays);
    System.assertEquals(5, earnings.size());
  }
}
