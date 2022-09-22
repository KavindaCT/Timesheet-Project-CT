public with sharing class TimesheetDataService {
    @AuraEnabled(cacheable=true)
    public static List<Timesheet__c> getPreviousTimesheets(String currentUserId) {
        List<Timesheet__c> previousTimesheets = new List<Timesheet__c>();
        try {
            previousTimesheets = [
                SELECT ID, Name, Status__c FROM Timesheet__c
                WHERE CreatedById = :currentUserId ORDER BY CreatedDate DESC
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
    public static List<Timesheet_day__c> getTimesheetId(String recordId) {
        
        try {
            System.debug('recordid'+recordId);

            List<ProcessInstanceWorkitem> ProcessInstanceWorkitemIds = [SELECT ProcessInstanceId from ProcessInstanceWorkitem where Id= :recordId];
            Set<Id> ProcessInstanceIdSet = new Set<Id>();
            for(ProcessInstanceWorkitem p : ProcessInstanceWorkitemIds){
                ProcessInstanceIdSet.add(p.ProcessInstanceId);
            }

            List<ProcessInstance> ProcessInstanceIds = [SELECT TargetObjectId, Status, CreatedDate, SubmittedBy.Name FROM ProcessInstance where (Id IN :ProcessInstanceIdSet  AND TargetObject.Type = 'Timesheet__c')];
            Set<Id> TargetObjectIdSet = new Set<Id>();
            for(ProcessInstance p : ProcessInstanceIds){
                TargetObjectIdSet.add(p.TargetObjectId);
            }
            List<Timesheet_day__c> timesheetDayData = [
                SELECT ID, name, Earning_Type__c, Timesheet_Date__c, Timesheet_month__c,Hours__c, Timesheet__r.name FROM Timesheet_day__c WHERE Timesheet__c IN :TargetObjectIdSet
                ];


                //System.debug('ProcessInstanceId '+ProcessInstanceId);
                
                //SELECT ProcessInstanceId from ProcessInstanceWorkitem where Id= '04i8d000000fJdbAAE'
                //SELECT Id, TargetObjectId FROM ProcessInstance where (Id = '04g8d000001xlzNAAQ-ProcessInstanceId'  AND TargetObject.Type = 'Timesheet__c')
                //SELECT Id, Name FROM Timesheet__c WHERE Id = 'TargetObjectId'
                //SELECT Name FROM Timesheet_day__c WHERE Timesheet__r.name= 'August 2022 - Vidura Jayasinghe'
            System.debug('timesheetdata'+timesheetDayData);
            return timesheetDayData;

            } 
            catch (Exception e) {
                    //System.debug('Exception: ' + e.getMessage());
                    return null;
            }
    }


    @AuraEnabled(cacheable=true)
    public static Map<Id,Id> getTimesheetIdFromWorkitemId(String recordId) {
        Map<Id,Id> timesheetWithUser = new Map<Id,Id>();
        try {
            System.debug('recordid'+recordId);

            ProcessInstanceWorkitem ProcessInstanceWorkitemIds = [SELECT ProcessInstanceId, CreatedById from ProcessInstanceWorkitem where Id= :recordId];
            Id ProcessInstanceWorkitemId = ProcessInstanceWorkitemIds.ProcessInstanceId;
            Id userId = ProcessInstanceWorkitemIds.CreatedById;

            ProcessInstance ProcessInstanceIds = [SELECT TargetObjectId FROM ProcessInstance where (Id = :ProcessInstanceWorkitemId  AND TargetObject.Type = 'Timesheet__c')];
            Id ProcessInstanceId = ProcessInstanceIds.TargetObjectId;

            timesheetWithUser.put(ProcessInstanceId, userId);


            System.debug('ProcessInstanceId '+ProcessInstanceId);
                
                //SELECT ProcessInstanceId from ProcessInstanceWorkitem where Id= '04i8d000000fJdbAAE'
                //SELECT Id, TargetObjectId FROM ProcessInstance where (Id = '04g8d000001xlzNAAQ-ProcessInstanceId'  AND TargetObject.Type = 'Timesheet__c')
                //SELECT Id, Name FROM Timesheet__c WHERE Id = 'TargetObjectId'
                //SELECT Name FROM Timesheet_day__c WHERE Timesheet__r.name= 'August 2022 - Vidura Jayasinghe'
            
            return timesheetWithUser;

            } 
            catch (Exception e) {
                    //System.debug('Exception: ' + e.getMessage());
                    return null;
            }
    }
    @AuraEnabled(cacheable=true)
    public static Map<Id,Id> getApprovalRequests(String userId) {
        Map<Id,Id> timesheetWithUser = new Map<Id,Id>();
        try {
            //System.debug('recordid'+userId);

            ProcessInstanceWorkitem ProcessInstanceWorkitemIds = [SELECT ProcessInstanceId from ProcessInstanceWorkitem where ActorId= :userId];
            Id ProcessInstanceWorkitemId = ProcessInstanceWorkitemIds.ProcessInstanceId;
            Id CreatedByUserId = ProcessInstanceWorkitemIds.CreatedById;

            ProcessInstance ProcessInstanceIds = [SELECT TargetObjectId FROM ProcessInstance where (Id = :ProcessInstanceWorkitemId  AND TargetObject.Type = 'Timesheet__c')];
            Id ProcessInstanceId = ProcessInstanceIds.TargetObjectId;

            timesheetWithUser.put(ProcessInstanceId, CreatedByUserId);


            System.debug('ProcessInstanceId '+ProcessInstanceId);
                
                //SELECT ProcessInstanceId from ProcessInstanceWorkitem where Id= '04i8d000000fJdbAAE'
                //SELECT Id, TargetObjectId FROM ProcessInstance where (Id = '04g8d000001xlzNAAQ-ProcessInstanceId'  AND TargetObject.Type = 'Timesheet__c')
                //SELECT Id, Name FROM Timesheet__c WHERE Id = 'TargetObjectId'
                //SELECT Name FROM Timesheet_day__c WHERE Timesheet__r.name= 'August 2022 - Vidura Jayasinghe'
            
            return timesheetWithUser;

            } 
            catch (Exception e) {
                    //System.debug('Exception: ' + e.getMessage());
                    return null;
            }
    }
    // @AuraEnabled
    // public static List<ProcessInstance> ProcessInstanceId(String approvalId) {
    //     try {
    //         // String recordIds = [
    //         //     Select ProcessInstanceId FROM ProcessInstanceWorkitem where Id = : approvalId
    //         // ].ProcessInstanceId;

    //         List<ProcessInstance> recordIdss = [
    //             Select Id, TargetObjectId FROM ProcessInstance where Id =: approvalId
    //         ];
    //         System.debug(recordIds);
    //         return recordIds;

    //     }catch (Exception e) {
    //         System.debug('Exception: ' + e.getMessage());
    //         return null;
    //     }
    // }
        

    @AuraEnabled(cacheable=true)
    public static List<TimesheetEarning.earningsWrapper> getTimesheetDays(String timesheetId, String currentUser){
        List<TimesheetEarning.earningsWrapper> earnings = new List<TimesheetEarning.earningsWrapper>();
        try {
            List<Timesheet_Day__c> timesheetDays =  [
                SELECT Id, Name, Hours__c, Week_Number__c, Earning_Type__c, Day__c, Timesheet_Date__c, Timesheet_month__c
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
            System.debug('results'+timesheetDays);
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
        List<Timesheet_Day__c> timesheetDaysDataUpsert = new List<Timesheet_Day__c>();
        List<Timesheet_Day__c> timesheetDaysDataDelete = new List<Timesheet_Day__c>();
        String tName,tsname; 
        try {
            for(Map<String, Object> earning : timesheetDays) {
                 System.debug('viu'+earning);
                List<Object> hours = (List<Object>) earning.get('hours');
                System.debug('hours'+hours);

                String earningType = (String) earning.get('earningType');
                System.debug('earningType'+earningType);

                String weekNumber = (String) String.valueOf(earning.get('weekNumber'));
                System.debug('weekNumber'+weekNumber);

                boolean deleteFlag = (Boolean) earning.get('deleteFlag');
                System.debug('deleteFlag'+deleteFlag);

                String name = (String) String.valueOf(earning.get('weekNumber'));
                System.debug('name'+name);

                
                // System.debug(name);

                if(hours.size() > 0) {
                    if(!deleteFlag) {
                        for(Object day: hours) {
                            TimesheetEarning.earningHoursWrapper timesheetDay = (TimesheetEarning.earningHoursWrapper) JSON.deserializeStrict(
                                JSON.serialize(day), TimesheetEarning.earningHoursWrapper.class
                            );
                            
                             System.debug(timesheetDays);
                             System.debug((Id) timesheetDay.id);
                             
                             System.debug(timesheetDay.name);
                             System.debug(timesheetDay.hours);
                             String timesheetName = timesheetDay.name;
                             
                                tName = timesheetName.substringBefore('-');
                                System.debug(tName);
                                tsname = tName + '-' + earningType;
                                System.debug(tsname);
                             
                            
                            
                            //  System.debug(hours.name);




                            if (timesheetDay.id != null) {
                                // System.debug(Timesheet_Day__c);
                                // System.debug('update '+updateDay);
                                Timesheet_Day__c updateDay = new Timesheet_Day__c(
                                    Id = (Id) timesheetDay.id,
                                    Name = tsname,
                                    Hours__c = timesheetDay.hours,
                                    Earning_Type__c = earningType,
                                    Timesheet__c = id
                                );
                                timesheetDaysDataUpsert.add(updateDay);
                            } else {
                                // System.debug('new '+newDay);
                                Timesheet_Day__c newDay = new Timesheet_Day__c(
                                    Name = tsname,
                                    Hours__c = timesheetDay.hours,
                                    Day__c = timesheetDay.day,
                                    Timesheet_Date__c = timesheetDay.timesheet_date,
                                    Earning_Type__c = earningType,
                                    Week_Number__c = weekNumber,
                                    Timesheet__c = id
                                );
                                timesheetDaysDataUpsert.add(newDay);
                                // System.debug('new '+newDay);

                            }
                            

                        }
                    } else {
                        for(Object day: hours) {
                            TimesheetEarning.earningHoursWrapper timesheetDay = (TimesheetEarning.earningHoursWrapper) JSON.deserializeStrict(
                                JSON.serialize(day), TimesheetEarning.earningHoursWrapper.class
                            );

                            if (timesheetDay.id != null) {
                                Timesheet_Day__c deleteDay = new Timesheet_Day__c(
                                    Id = (Id) timesheetDay.id,
                                    Hours__c = timesheetDay.hours,
                                    Earning_Type__c = earningType,
                                    Timesheet__c = id
                                );
                                timesheetDaysDataDelete.add(deleteDay);
                            }
                        }
                    }
                }
            }
            // System.debug(timesheetDaysDataUpsert);
            upsert timesheetDaysDataUpsert;
            delete timesheetDaysDataDelete;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}