@isTest
public with sharing class TimesheetDataServiceTest {
    @TestSetup
     static void testinsertPreviousTimesheets(){

        List<Timesheet__c> previousTimesheets = new List<Timesheet__c>();
            Timesheet__c newDayOrdinary1 = new Timesheet__c(
                Name = 'September 2022 - Kavinda Dilanka',
                Status__c = 'Submitted'
            );

            previousTimesheets.add(newDayOrdinary1);
            insert(previousTimesheets);

            Timesheet__c timesheet = new Timesheet__c(
                Name = 'August 2022',
                Status__c = 'Draft'
            );
            insert(timesheet);
            Date newDate1 = date.today();

            List<Timesheet_Day__c> timesheetDays = new List<Timesheet_Day__c>();
                
            Timesheet_Day__c day = new Timesheet_Day__c (
                Name = '20-1', 
                Hours__c = 10, 
                Week_Number__c = '4',
                Day__c = '2Tue',
                Earning_Type__c = 'Ordinary Hours',
                Timesheet__c = timesheet.Id,
                Timesheet_Date__c = newDate1
            );

            timesheetDays.add(day);
            insert(timesheetDays);

        }
            @isTest static void testgetPreviousTimesheets(){
                List<Timesheet__c> previousTimesheets = 
                [
                SELECT ID, Name, Status__c FROM Timesheet__c
                WHERE CreatedById = '0058d000001tsilAAA' ORDER BY CreatedDate DESC
                LIMIT 3
            ];

            List<Timesheet__c> timesheets =  new List<Timesheet__c>();
            timesheets = TimesheetDataService.getPreviousTimesheets('0058d000001tsilAAA');

            System.debug('actual'+timesheets);
            System.debug('size'+timesheets.size());
            System.debug(previousTimesheets);
            
            System.assertEquals(2, timesheets.size());

    }
           
           @isTest static void testgetRecentTimesheets(){
            List<Timesheet__c> testrecentTimesheets = new List<Timesheet__c>();
            List<Timesheet__c> recentTimesheets = new List<Timesheet__c>();

              testrecentTimesheets = [SELECT ID, Name FROM Timesheet__c
              WHERE Name = 'September 2022 - Kavinda Dilanka' AND CreatedById ='0058d000001tsilAAA'
              ];
 
              recentTimesheets = TimesheetDataService.getRecentTimesheet('September 2022 - Kavinda Dilanka','0058d000001tsilAAA');
              System.assertEquals(1, recentTimesheets.size());
           }

            // static void insertTimesheetDays(){
            //     List<Timesheet_Day__c> timesheetDays = new List<Timesheet_Day__c>();
                
            //     Timesheet_Day__c day = new Timesheet_Day__c (
            //         Id ='', 
            //         Name = '20-1', 
            //         Hours__c = 4, 
            //         Week_Number__c = 4,
            //         Day__c = 'Tue',
            //         Earning_Type__c = 'ordinary',
            //         Timesheet_Date__c = '2022-08-01',
            //         Timesheet_month__c = 'August'
            //     );

            //     timesheetDays.add(day);
            //     insert(timesheetDays);
            
            // }


           @isTest static void testgetTimesheetDays(){
            List<Timesheet_Day__c> timesheetDays = [
                SELECT Id, Name, Hours__c, Week_Number__c, Earning_Type__c, Day__c, Timesheet_Date__c, Timesheet_month__c
                FROM Timesheet_Day__c
                WHERE Timesheet__c = 'a008d000007giyRAAQ' AND CreatedById = '0058d000001tsilAAA'
            ];

            List<TimesheetEarning.earningsWrapper> testTimesheetDays = TimesheetDataService.getTimesheetDays('a008d000007giyRAAQ','0058d000001tsilAAA');
            System.debug(testTimesheetDays.size());
            System.debug(testTimesheetDays);
            System.assertEquals(5, testTimesheetDays.size());

           }
}
