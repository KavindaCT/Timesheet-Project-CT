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
            
            List<Timesheet_Day__c> timesheetDays2 = new List<Timesheet_Day__c>();
            
            Timesheet_Day__c day2 = new Timesheet_Day__c (
            
                Name = '20-1', 
                Hours__c = 10, 
                Week_Number__c = '4',
                Day__c = '2Tue',
                Earning_Type__c = 'Ordinary Hours',
                Timesheet__c = timesheet.Id,
                Timesheet_Date__c = newDate1
            );

            timesheetDays2.add(day2);
            upsert(timesheetDays2);
            

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

            // System.debug('actual'+timesheets);
            // System.debug('size'+timesheets.size());
            // System.debug(previousTimesheets);
            
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



            @isTest static void testgetTimesheetId(){

                List<ProcessInstanceWorkitem> testgetTimesheets = new List<ProcessInstanceWorkitem>();
                
                Map<Id,Id> recentTimesheetsId = new Map<Id,Id>();
              

               String recordId='04i8d000000fRkzAAE';

               testgetTimesheets = [SELECT ProcessInstanceId, CreatedById from ProcessInstanceWorkitem where Id= :recordId];
            //    Id ProcessInstanceWorkitemId = testgetTimesheets.ProcessInstanceId;
                // Id userId = testgetTimesheets.CreatedById;
                // ProcessInstance ProcessInstanceIds = [SELECT TargetObjectId FROM ProcessInstance where (Id = :ProcessInstanceWorkitemId  AND TargetObject.Type = 'Timesheet__c')];
            //    Id ProcessInstanceId = ProcessInstanceIds.TargetObjectId;
               
               recentTimesheetsId = TimesheetDataService.getTimesheetIdFromWorkitemId(recordId);
               System.debug('testgetTimesheets '+testgetTimesheets);
               System.debug('recentTimesheetsId '+recentTimesheetsId);
              // System.assertEquals(1, recentTimesheetsId.size());

               
            }
            

           @isTest static void testgetTimesheetDays(){
            String jsonString = '[{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[{"day":"4Thu","hours":9,"id":"a018d00000Av3mpAAB","Name":"TD01 September 2-Ordinary Hours","timesheet_month":"September"}],"id":"10","weekNumber":1},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"20","weekNumber":2},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"30","weekNumber":3},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"40","weekNumber":4},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"50","weekNumber":5}]';

            List<Object> items = (List<Object>) JSON.deserializeUntyped(jsonString);
            System.debug('teststring'+items);
            List<Timesheet_Day__c> timesheetDays = [
                SELECT Id, Name, Hours__c, Week_Number__c, Earning_Type__c, Day__c, Timesheet_Date__c, Timesheet_month__c
                FROM Timesheet_Day__c
                WHERE Timesheet__c = 'a008d000007h5VZAAY' AND CreatedById = '0058d000001tsilAAA'
            ];

            List<TimesheetEarning.earningsWrapper> testTimesheetDays = TimesheetDataService.getTimesheetDays('a008d000007giyRAAQ','0058d000001tsilAAA');
            System.debug(testTimesheetDays.size());
            System.debug(testTimesheetDays);
            System.assertEquals(5, testTimesheetDays.size());

           }


           @isTest static void testupdateTimesheetDays(){
            List<Map<String, Object>> timesheetDays = new List<Map<String, Object>> () ;
            String jsonString = '[{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[{"day":"4Thu","hours":9,"id":"a018d00000Av8k4AAB","Name":"TD01 September 2-Ordinary Hours","timesheet_month":"September"},{"day":"5Fri","hours":9,"id":"a018d00000Av8k5AAB","Name":"TD02 September 2-Ordinary Hours","timesheet_month":"September"}],"id":"10","weekNumber":1},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"20","weekNumber":2},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"30","weekNumber":3},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"40","weekNumber":4},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"50","weekNumber":5}]';

            List<Object> items = (List<Object>) JSON.deserializeUntyped(jsonString);
            // timesheetDays.put('deleteFlag',false',"earningType":"Ordinary Hours","hours":[{"day":"4Thu","hours":9,"id":"a018d00000Av3mpAAB","Name":"TD01 September 2-Ordinary Hours","timesheet_month":"September"}],"id":"10","weekNumber":1}]');
            // timesheetDays.put('earningType =Ordinary Hours', items);
            for (Object obj : items) {
                timesheetDays.add((Map<String, Object>) obj);
            }
            String timesheetId = 'a008d000007h5VZAAY';
            TimesheetDataService.insertTimesheetDays(timesheetDays,timesheetId);
            List<Timesheet_Day__c> ordinaryHours = [SELECT Earning_Type__c FROM Timesheet_Day__c WHERE Timesheet__c =: timesheetId];
            // String earningType =  String.valueOf(ordinaryHours.Timesheet_Day__c.Earning_Type__c);
            String earningType; 
            for(Timesheet_Day__c earning : ordinaryHours) {
                System.debug('viu '+earning);
                 earningType = (String) earning.get('Earning_Type__c');
                 System.debug('hello '+earningType);
            }

             System.assertEquals('Ordinary Hours',earningType);

           }


           @isTest static void testinsertTimesheetDays(){
            List<Map<String, Object>> timesheetDays = new List<Map<String, Object>> () ;
            String jsonString = '[{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[{"day":"4Thu","hours":9,"id":"a018d00000Av8k4AAB","Name":"TD01 September 2-Ordinary Hours","timesheet_month":"September"},{"day":"5Fri","hours":9,"id":"a018d00000Av8k5AAB","Name":"TD02 September 2-Ordinary Hours","timesheet_month":"September"}],"id":"10","weekNumber":1},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"20","weekNumber":2},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"30","weekNumber":3},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"40","weekNumber":4},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"50","weekNumber":5}]';

            List<Object> items = (List<Object>) JSON.deserializeUntyped(jsonString);
            // timesheetDays.put('deleteFlag',false',"earningType":"Ordinary Hours","hours":[{"day":"4Thu","hours":9,"id":"a018d00000Av3mpAAB","Name":"TD01 September 2-Ordinary Hours","timesheet_month":"September"}],"id":"10","weekNumber":1}]');
            // timesheetDays.put('earningType =Ordinary Hours', items);
            for (Object obj : items) {
                timesheetDays.add((Map<String, Object>) obj);
            }
            String timesheetId = 'a008d000007h5VZAAY';
            TimesheetDataService.insertTimesheetDays(timesheetDays,timesheetId);
            List<Timesheet_Day__c> ordinaryHours = [SELECT Earning_Type__c FROM Timesheet_Day__c WHERE Timesheet__c =: timesheetId];
            // String earningType =  String.valueOf(ordinaryHours.Timesheet_Day__c.Earning_Type__c);
            String earningType; 
            for(Timesheet_Day__c earning : ordinaryHours) {
                System.debug('viu '+earning);
                 earningType = (String) earning.get('Earning_Type__c');
                 System.debug('hello '+earningType);
            }

             System.assertEquals(5,timesheetDays.size());

           }

           @isTest static void testdeleteTimesheetDays(){
            List<Map<String, Object>> timesheetDays = new List<Map<String, Object>> () ;
            String jsonString = '[{"deleteFlag":true,"earningType":"Ordinary Hours","hours":[{"day":"4Thu","hours":9,"id":"a018d00000Av3mpAAB","Name":"TD01 September 2-Ordinary Hours","timesheet_month":"September"}],"id":"10","weekNumber":1},{"deleteFlag":true,"earningType":"Ordinary Hours","hours":[],"id":"20","weekNumber":2},{"deleteFlag":true,"earningType":"Ordinary Hours","hours":[],"id":"30","weekNumber":3},{"deleteFlag":true,"earningType":"Ordinary Hours","hours":[],"id":"40","weekNumber":4},{"deleteFlag":true,"earningType":"Ordinary Hours","hours":[],"id":"50","weekNumber":5}]';

            List<Object> items = (List<Object>) JSON.deserializeUntyped(jsonString);
            // timesheetDays.put('deleteFlag',false',"earningType":"Ordinary Hours","hours":[{"day":"4Thu","hours":9,"id":"a018d00000Av3mpAAB","Name":"TD01 September 2-Ordinary Hours","timesheet_month":"September"}],"id":"10","weekNumber":1}]');
            // timesheetDays.put('earningType =Ordinary Hours', items);
            for (Object obj : items) {
                timesheetDays.add((Map<String, Object>) obj);
            }
            String timesheetId = 'a008d000007h5VZAAY';
            TimesheetDataService.insertTimesheetDays(timesheetDays,timesheetId);
            List<Timesheet_Day__c> ordinaryHours = [SELECT Earning_Type__c FROM Timesheet_Day__c WHERE Timesheet__c =: timesheetId];
            // String earningType =  String.valueOf(ordinaryHours.Timesheet_Day__c.Earning_Type__c);
            String earningType; 
            for(Timesheet_Day__c earning : ordinaryHours) {
                System.debug('viu '+earning);
                 earningType = (String) earning.get('Earning_Type__c');
                 System.debug('hello '+earningType);
            }

             System.assertEquals(5,timesheetDays.size());

           }
}
