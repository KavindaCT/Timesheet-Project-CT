public with sharing class TimesheetDataService {
  public class SubmitException extends Exception {
  }

  @AuraEnabled(cacheable=true)
  public static List<Timesheet__c> getPreviousTimesheets(String currentUserId) {
    List<Timesheet__c> previousTimesheets = new List<Timesheet__c>();
    try {
      previousTimesheets = [
        SELECT ID, Name, Status__c
        FROM Timesheet__c
        WHERE CreatedById = :currentUserId
        ORDER BY CreatedDate DESC
        LIMIT 3
      ];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
    System.debug('pre' + previousTimesheets);
    return previousTimesheets;
  }

  @AuraEnabled
  public static List<Timesheet__c> getRecentTimesheet(
    String timePeriod,
    String currentUser
  ) {
    try {
      List<Timesheet__c> recentTimesheets = [
        SELECT ID, Name
        FROM Timesheet__c
        WHERE Name = :timePeriod AND CreatedById = :currentUser
      ];
      System.debug('timeperiod ' + timePeriod);
      return recentTimesheets;
    } catch (Exception e) {
      System.debug('Exception: ' + e.getMessage());
      return null;
    }
  }

  @AuraEnabled(cacheable=true)
  public static Map<Id, Id> getTimesheetIdFromWorkitemId(String recordId) {
    Map<Id, Id> timesheetWithUser = new Map<Id, Id>();
    try {
      System.debug('recordid' + recordId);

      ProcessInstanceWorkitem ProcessInstanceWorkitemIds = [
        SELECT ProcessInstanceId, CreatedById
        FROM ProcessInstanceWorkitem
        WHERE Id = :recordId
      ];
      Id ProcessInstanceWorkitemId = ProcessInstanceWorkitemIds.ProcessInstanceId;
      Id userId = ProcessInstanceWorkitemIds.CreatedById;

      ProcessInstance ProcessInstanceIds = [
        SELECT TargetObjectId
        FROM ProcessInstance
        WHERE
          Id = :ProcessInstanceWorkitemId
          AND TargetObject.Type = 'Timesheet__c'
      ];
      Id ProcessInstanceId = ProcessInstanceIds.TargetObjectId;

      timesheetWithUser.put(ProcessInstanceId, userId);

      System.debug('ProcessInstanceId ' + ProcessInstanceId);

      return timesheetWithUser;
    } catch (Exception e) {
      return null;
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<TimesheetEarning.earningsWrapper> getTimesheetDays(
    String timesheetId,
    String currentUser
  ) {
    List<TimesheetEarning.earningsWrapper> earnings = new List<TimesheetEarning.earningsWrapper>();
    try {
      List<Timesheet_Day__c> timesheetDays = [
        SELECT
          Id,
          Name,
          Hours__c,
          Week_Number__c,
          Earning_Type__c,
          Day__c,
          Timesheet_Date__c,
          Timesheet_month__c
        FROM Timesheet_Day__c
        WHERE Timesheet__c = :timesheetId AND CreatedById = :currentUser
      ];

      System.debug('results' + timesheetDays);
      earnings = TimesheetEarning.getEarnings(timesheetDays);
    } catch (Exception e) {
      System.debug('Exception: ' + e.getMessage());
    }
    System.debug('earnings ' + earnings);
    return earnings;
  }

  @AuraEnabled
  public static void insertTimesheetDays(
    List<Map<String, Object>> timesheetDays,
    String timesheetId,
    String methodType
  ) {
    Id id = Id.valueOf(timesheetId);
    List<Timesheet_Day__c> timesheetDaysDataUpsert = new List<Timesheet_Day__c>();
    List<Timesheet_Day__c> timesheetDaysDataDelete = new List<Timesheet_Day__c>();
    String tName, tsname;
    try {
      for (Map<String, Object> earning : timesheetDays) {
        System.debug('viu' + earning);
        List<Object> hours = (List<Object>) earning.get('hours');
        System.debug('hours' + hours);

        String earningType = (String) earning.get('earningType');
        System.debug('earningType' + earningType);

        String weekNumber = (String) String.valueOf(earning.get('weekNumber'));
        System.debug('weekNumber' + weekNumber);

        boolean deleteFlag = (Boolean) earning.get('deleteFlag');
        System.debug('deleteFlag' + deleteFlag);

        String name = (String) String.valueOf(earning.get('weekNumber'));
        System.debug('name' + name);

        if (hours.size() > 0) {
          if (!deleteFlag) {
            for (Object day : hours) {
              TimesheetEarning.earningHoursWrapper timesheetDay = (TimesheetEarning.earningHoursWrapper) JSON.deserializeStrict(
                JSON.serialize(day),
                TimesheetEarning.earningHoursWrapper.class
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

              if (timesheetDay.id != null) {
                Timesheet_Day__c updateDay = new Timesheet_Day__c(
                  Id = (Id) timesheetDay.id,
                  Name = tsname,
                  Hours__c = timesheetDay.hours,
                  Earning_Type__c = earningType,
                  Timesheet__c = id
                );
                timesheetDaysDataUpsert.add(updateDay);
              } else {
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
              }
            }
          } else {
            for (Object day : hours) {
              TimesheetEarning.earningHoursWrapper timesheetDay = (TimesheetEarning.earningHoursWrapper) JSON.deserializeStrict(
                JSON.serialize(day),
                TimesheetEarning.earningHoursWrapper.class
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
      if (timesheetDaysDataUpsert.size() > 0 || methodType == 'draft') {
        upsert timesheetDaysDataUpsert;
        delete timesheetDaysDataDelete;
      } else {
        throw new SubmitException(
          'Your daily working hour limit should be between 9 and 24 hours'
        );
      }
    } catch (Exception e) {
      System.debug('exception ' + e.getMessage());
      throw new AuraHandledException(e.getMessage());
    }
  }
}
