@isTest
public with sharing class RoleHierachyTest {
    @TestSetup
    static void makeData(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com' );

        User manager = new User(Alias = 'standtmgt', Email='standardmanager@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='TestingMgt', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standardmanager@testorg.com', ManagerId = u.Id);

        insert u;
        insert manager;
        }
    @isTest static void testgetRoleSubordinateUsers() {

      /*  List<User> testusers = new List<User>([SELECT Name, ManagerId, Manager.Name FROM User]);
        
        List<User> actualUsers = RoleHierachy.getRoleSubordinateUsers(u.Id);

        System.assertEquals(testusers.size(), actualUsers.size());*/

    }
}