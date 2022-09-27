@isTest
public with sharing class TimesheetDataServiceTest {
    @TestSetup
     static void testinsertPreviousTimesheets(){
         
        //Added by Inthuja on 26/09/2022 to create user
        
		Profile pf= [Select Id from profile where Name='System Administrator']; 
        String orgId=UserInfo.getOrganizationId(); 
        String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
        Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
        String uniqueName=orgId+dateString+RandomId; 
         
        User nUser = new User(firstname = 'ABC', 
                         	  lastName = 'XYZ', 
                         	  email = uniqueName + '@test' + orgId + '.org', 
                              Username = uniqueName + '@test' + orgId + '.org', 
                              EmailEncodingKey = 'ISO-8859-1', 
                              Alias = uniqueName.substring(18, 23), 
                              TimeZoneSidKey = 'America/Los_Angeles', 
                              LocaleSidKey = 'en_US', 
                              LanguageLocaleKey = 'en_US', 
                              ProfileId = pf.Id);
        insert nUser;
        
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
                Week_Number__c = '1',
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
                User cUser  =  [SELECT Id from User where Name = 'Kavinda Dilanka' ];
            
                List<Timesheet__c> previousTimesheets = 
                [
                SELECT ID, Name, Status__c FROM Timesheet__c
                WHERE CreatedById =: cUser.Id ORDER BY CreatedDate DESC
                LIMIT 3
            ];

            List<Timesheet__c> timesheets =  new List<Timesheet__c>();
            timesheets = TimesheetDataService.getPreviousTimesheets(cUser.Id);

            // System.debug('actual'+timesheets);
            // System.debug('size'+timesheets.size());
            // System.debug(previousTimesheets);
            
            System.assertEquals(2, timesheets.size());

    	}
           
        @isTest static void testgetRecentTimesheets(){

            User cUser  =  [SELECT Id from User where Name = 'Kavinda Dilanka' ];
            
            System.runAs(cUser) {

            List<Timesheet__c> testrecentTimesheets = new List<Timesheet__c>();
            List<Timesheet__c> recentTimesheets = new List<Timesheet__c>();
            
                
              testrecentTimesheets = [SELECT ID, Name, CreatedById, CreatedBy.Name FROM Timesheet__c
              WHERE Name = 'September 2022 - Kavinda Dilanka' AND CreatedById =: cUser.Id
              ];
                
              system.debug('testrecentTimesheets'+ testrecentTimesheets);
              //system.debug('testrecentTimesheets'+ testrecentTimesheets.CreatedById);
              //system.debug('testrecentTimesheets'+ testrecentTimesheets.CreatedBy.Name);
                
              recentTimesheets = TimesheetDataService.getRecentTimesheet('September 2022 - Kavinda Dilanka', cUser.Id);
              System.assertEquals(1, recentTimesheets.size());
			}
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
            User cUser  =  [SELECT Id from User Limit 1];
  
            String jsonString = '[{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[{"day":"4Thu","hours":9,"id":"a018d00000Av3mpAAB","Name":"TD01 September 2-Ordinary Hours","timesheet_month":"September"}],"id":"10","weekNumber":1},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"20","weekNumber":2},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"30","weekNumber":3},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"40","weekNumber":4},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"50","weekNumber":5}]';

            List<Object> items = (List<Object>) JSON.deserializeUntyped(jsonString);
            System.debug('teststring'+items);
            List<Timesheet_Day__c> timesheetDays = [
                SELECT Id, Name, Hours__c, Week_Number__c, Earning_Type__c, Day__c, Timesheet_Date__c, Timesheet_month__c
                FROM Timesheet_Day__c
                WHERE Timesheet__c = 'a008d000007h5VZAAY' AND CreatedById =: cUser.Id
            ];

            List<TimesheetEarning.earningsWrapper> testTimesheetDays = TimesheetDataService.getTimesheetDays('a008d000007giyRAAQ', cUser.Id);
            System.debug(testTimesheetDays.size());
            System.debug(testTimesheetDays);
            System.assertEquals(5, testTimesheetDays.size());

           }


           @isTest static void testupdateTimesheetDays(){
               Timesheet_Day__c previousTimesheetDay = [SELECT Id, Name, Hours__c, Day__c, Timesheet_month__c, Earning_Type__c, Timesheet_Date__c, Timesheet__c FROM Timesheet_Day__c WHERE Week_Number__c = '1' LIMIT 1];
            Decimal newHours = previousTimesheetDay.Hours__c + 1;
               List<Map<String, Object>> timesheetDays = new List<Map<String, Object>> ();
            String jsonString = '[{"deleteFlag":false,"earningType":"' + previousTimesheetDay.Earning_Type__c + '","hours":[{"day":"' + previousTimesheetDay.Day__c + '","hours":' + newHours + ',"id":"' + previousTimesheetDay.Id + '","Name":"' + previousTimesheetDay.Name + '","timesheet_month":"' + previousTimesheetDay.Timesheet_month__c + '"}],"id":"10","weekNumber":1},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"20","weekNumber":2},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"30","weekNumber":3},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"40","weekNumber":4},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"50","weekNumber":5}]';

            List<Object> items = (List<Object>) JSON.deserializeUntyped(jsonString);
            // timesheetDays.put('deleteFlag',false',"earningType":"Ordinary Hours","hours":[{"day":"4Thu","hours":9,"id":"a018d00000Av3mpAAB","Name":"TD01 September 2-Ordinary Hours","timesheet_month":"September"}],"id":"10","weekNumber":1}]');
            // timesheetDays.put('earningType =Ordinary Hours', items);
            for (Object obj : items) {
                timesheetDays.add((Map<String, Object>) obj);
            }
            // String timesheetId = 'a008d000006FnUeAAK';
            
            system.debug('timesheetDays' + timesheetDays);
            TimesheetDataService.insertTimesheetDays(timesheetDays, previousTimesheetDay.Timesheet__c);
               
            Timesheet_Day__c updatedDay = [SELECT Name, Hours__c FROM Timesheet_Day__c WHERE Id =: previousTimesheetDay.Id];
               
            // String earningType =  String.valueOf(ordinaryHours.Timesheet_Day__c.Earning_Type__c);
            // String earningType; 
            // for(Timesheet_Day__c earning : ordinaryHours) {
                // System.debug('viu '+earning);
                 // earningType = (String) earning.get('Earning_Type__c');
                // System.debug('hello '+earningType);
            // }

             System.assertEquals(newHours, updatedDay.Hours__c);

           }


           @isTest static void testinsertTimesheetDays(){
               Timesheet__c timesheetId = [SELECT Id FROM Timesheet__c LIMIT 1];
               
            List<Map<String, Object>> timesheetDays = new List<Map<String, Object>> ();
            
            String jsonString = '[{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[{"day":"4Thu","hours":9,"Name":"TD01 September 2-Ordinary Hours","timesheet_month":"September","timesheet_date":"2022-09-26"},{"day":"5Fri","hours":9,"Name":"TD02 September 2-Ordinary Hours","timesheet_month":"September","timesheet_date":"2022-09-26"}],"id":"10","weekNumber":1},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"20","weekNumber":2},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"30","weekNumber":3},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"40","weekNumber":4},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"50","weekNumber":5}]';

            List<Object> items = (List<Object>) JSON.deserializeUntyped(jsonString);
            // timesheetDays.put('deleteFlag':false',"earningType":"Ordinary Hours","hours":[{"day":"4Thu","hours":9,"id":"a018d00000Av3mpAAB","Name":"TD01 September 2-Ordinary Hours","timesheet_month":"September"}],"id":"10","weekNumber":1}]');
            // timesheetDays.put('earningType =Ordinary Hours', items);
            for (Object obj : items) {
                timesheetDays.add((Map<String, Object>) obj);
            }
            
            // String timesheetId = 'a008d000007h5VZAAY';
            // 
               
            TimesheetDataService.insertTimesheetDays(timesheetDays, timesheetId.Id);
            // List<Timesheet_Day__c> ordinaryHours = [SELECT Earning_Type__c FROM Timesheet_Day__c WHERE Timesheet__c =: timesheetId.Id];
            // String earningType =  String.valueOf(ordinaryHours.Timesheet_Day__c.Earning_Type__c);
            // String earningType; 
            // for(Timesheet_Day__c earning : ordinaryHours) {
                // System.debug('viu '+earning);
                 // earningType = (String) earning.get('Earning_Type__c');
                 // System.debug('hello '+earningType);
            // }
            // 
            
			List<Timesheet_Day__c> newTimesheetDays = [SELECT Id, Name FROM Timesheet_Day__c WHERE Timesheet__c = :timesheetId.Id];
             System.assertEquals(2, newTimesheetDays.size());
           }

           @isTest static void testdeleteTimesheetDays(){
               Timesheet_Day__c previousTimesheetDay = [SELECT Id, Name, Hours__c, Day__c, Timesheet_month__c, Earning_Type__c, Timesheet_Date__c, Timesheet__c FROM Timesheet_Day__c WHERE Week_Number__c = '1' LIMIT 1];
            List<Map<String, Object>> timesheetDays = new List<Map<String, Object>> () ;
            String jsonString = '[{"deleteFlag":true,"earningType":"' + previousTimesheetDay.Earning_Type__c + '","hours":[{"day":"' + previousTimesheetDay.Day__c + '","hours":' + previousTimesheetDay.Hours__c + ',"id":"' + previousTimesheetDay.Id + '","Name":"' + previousTimesheetDay.Name + '","timesheet_month":"' + previousTimesheetDay.Timesheet_month__c + '"}],"id":"10","weekNumber":1},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"20","weekNumber":2},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"30","weekNumber":3},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"40","weekNumber":4},{"deleteFlag":false,"earningType":"Ordinary Hours","hours":[],"id":"50","weekNumber":5}]';

            List<Object> items = (List<Object>) JSON.deserializeUntyped(jsonString);
            // timesheetDays.put('deleteFlag',false',"earningType":"Ordinary Hours","hours":[{"day":"4Thu","hours":9,"id":"a018d00000Av3mpAAB","Name":"TD01 September 2-Ordinary Hours","timesheet_month":"September"}],"id":"10","weekNumber":1}]');
            // timesheetDays.put('earningType =Ordinary Hours', items);
            for (Object obj : items) {
                timesheetDays.add((Map<String, Object>) obj);
            }
            // String timesheetId = 'a008d000007h5VZAAY';
            TimesheetDataService.insertTimesheetDays(timesheetDays, previousTimesheetDay.Timesheet__c);
               
            List<Timesheet_Day__c> newDays = [SELECT Id, Name FROM Timesheet_Day__c WHERE Id =: previousTimesheetDay.Id];
               
            // String earningType =  String.valueOf(ordinaryHours.Timesheet_Day__c.Earning_Type__c);
            // String earningType; 
            // for(Timesheet_Day__c earning : ordinaryHours) {
                // System.debug('viu '+earning);
                 // earningType = (String) earning.get('Earning_Type__c');
                 // System.debug('hello '+earningType);
            // }

             System.assertEquals(0, newDays.size());

           }
}