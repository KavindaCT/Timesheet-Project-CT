public with sharing class RoleHierachy {
  @AuraEnabled(cacheable=true)
  public static List<User> getRoleSubordinateUsers(String currentUser) {
    String x;
    String y;
    String z;

    try {
      List<User> users = new List<User>(
        [SELECT Name, ManagerId, Manager.Name FROM User WHERE Id = :currentUser]
      );
      return users;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
