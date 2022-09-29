@isTest
public with sharing class SubmitTimesheetforApprovalTest {
  @TestSetup
  static void makeTestData() {
    Timesheet__c timesheet = new Timesheet__c(
      Name = 'September 2022 - Kavinda Dilanka',
      Status__c = 'Submitted'
    );
    insert (timesheet);

    Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];

    User u1 = new User(
      Alias = 'standt',
      Email = 'standarduser2@testorg.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing2',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'standarduserrole2@testorg.com'
    );

    insert u1;

    User u2 = new User(
      ManagerID = u1.id,
      Alias = 'standt',
      Email = 'standarduser1@testorg.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing1',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p.Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'standarduserrole1@testorg.com'
    );

    insert u2;
  }
  @isTest
  static void submitForApproval() {
    User testusers = [
      SELECT Id, Name, ManagerId
      FROM User
      WHERE Email = 'standarduser1@testorg.com'
    ];
    Timesheet__c testTimesheetId = [
      SELECT ID, Name
      FROM Timesheet__c
      WHERE Name = 'September 2022 - Kavinda Dilanka'
    ];
    List<User> testmanagers = new List<User>(
      [
        SELECT Id, Name, ManagerId
        FROM User
        WHERE Email = 'standarduser1@testorg.com'
      ]
    );
    SubmitTimesheetforApproval.submitForApproval(
      testTimesheetId.ID,
      testusers.ManagerId
    );

    System.debug('*tusers ' + testusers.ManagerId);
    System.debug('*tid ' + testTimesheetId.ID);
    System.assertEquals(1, testmanagers.size());
  }
}
