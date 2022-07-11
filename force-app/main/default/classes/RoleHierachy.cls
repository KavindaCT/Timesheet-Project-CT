public with sharing class RoleHierachy {


    @AuraEnabled(cacheable=true)  
    public static List<User> getRoleSubordinateUsers() {
      try{
        String roleId = System.userInfo.getUserRoleId();

       // get all of the roles underneath the user
       List<Id> allSubRoleIds = getAllSubRoleIds(new List<ID>{roleId});
          
         // get all of the ids for the users in those roles
         List<User> users = new List<User>([Select Id, Name From User where
         UserRoleId IN :allSubRoleIds]);
         
         System.debug(roleId);
       // return the ids as a set so you can do what you want with them
    //    Ids.add(users.keySet());
       return users;

      }catch(Exception e){
        throw new AuraHandledException(e.getMessage());
      }
        
        }
      
        @AuraEnabled(cacheable=true)  
        public static List<ID> getAllSubRoleIds(List<ID> roleIds) {
      try{
        List<ID> currentRoleIds = new List<ID>();
      
        // get all of the roles underneath the passed roles
        for(UserRole userRole :[select Id,Name,ParentRoleId from UserRole where Id
          IN :roleIds AND ParentRoleId != null] ){
              currentRoleIds.add(userRole.ParentRoleId);
    
              // go fetch some more rolls!
              if(currentRoleIds.size() > 0){
                currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
              }
          }
      
          // System.debug(currentRoleIds);

        return currentRoleIds;
      }catch(Exception e){
        throw new AuraHandledException(e.getMessage());
      }
        
      
        }
      
      }

