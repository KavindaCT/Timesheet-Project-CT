@isTest
public with sharing class RoleHierachyTest {
    
    @isTest static void testgetRoleSubordinateUsers() {
        String userId = '0058d000001tsilAAA';

        List<User> testusers = new List<User>([SELECT Name, ManagerId, Manager.Name FROM User where Id =: userId]);
        
        List<User> actualUsers = RoleHierachy.getRoleSubordinateUsers(userId);

        System.assertEquals(testusers.size(), actualUsers.size());

    }
}
