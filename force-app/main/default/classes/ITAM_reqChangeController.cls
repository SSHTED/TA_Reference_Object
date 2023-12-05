public class ITAM_reqChangeController {
    @AuraEnabled
    public static sObject getRecord(String recordId) {
        System.debug('getRecord');
        Id myid = recordId;
		System.debug('dd : '+ myid.getSObjectType().getDescribe().getName());
        
        if (myid.getSObjectType().getDescribe().getName() == 'property__c'){
            return [SELECT Id, Name, RealEmp__c FROM property__c WHERE Id =:recordId LIMIT 1];
        }
        if (myid.getSObjectType().getDescribe().getName() == 'Employee__c'){
            //로그인 한 사람
            id loginUser = UserInfo.getUserId();
            return [SELECT Id, Name FROM Employee__c WHERE User__c=:loginUser LIMIT 1];
        }
        
        return null;
    }
    
    @AuraEnabled
    public static Employee__c getEmpId(){
        
        Employee__c empId = [SELECT ID, User__c, Name FROM Employee__c WHERE User__c =:UserInfo.getUserId()];
        
        return empId;
    }
    
    @AuraEnabled
    public static List<User> getApprovalManager(Id setUserId) {
        System.debug('getApprovalManager: '+ setUserId);
        
        //String userId = UserInfo.getUserId();
        String userId = [SELECT ID, User__c FROM Employee__c WHERE id =:setUserId].User__c;
      	/*  
        ID userRole = UserInfo.getUserRoleId();
        List<User> managerResult = new List<User>();
        
        System.debug('user확인 : '+ [SELECT Name FROM User WHERE id =: userId]);
        // top Role 구해서 결재 시스템 예외
        List<UserRole> topRole = new List<UserRole>(topRole(userRole));
        
        User topUser;
        if(topRole.size() >0){
            topUser = [SELECT id, Name FROM User WHERE UserRoleId =:topRole LIMIT 1];
        }
        
        
        System.debug('dd : '+ topUser);
        //System.debug('dd : '+ [SELECT ManagerId FROM USER WHERE id=:userId].ManagerId);
        
        UserRole exceptionUser = [SELECT id, Name FROM UserRole WHERE id =:userRole LIMIT 1];
        User exceptionManager = [SELECT ManagerId FROM USER WHERE id=:userId];
        
        //마케팅 팀 일 경우..예외 로직
        if ('마케팅팀' == exceptionUser.Name || topRole[0].Id == exceptionUser.Id || topUser.Id == exceptionManager.ManagerId){
            System.debug('마케팅팀? : ');
            managerResult.add(topUser);
        }else{
            System.debug('마케팅팀?ㄴㄴ : ');
            SET<ID> GroupMembers = new SET<ID>();
            
            Id directorGroup = [SELECT Id FROM Group WHERE DeveloperName ='ITAM_Approval' LIMIT 1].Id;
            
            for (Group gr :[SELECT Id, RelatedId, DeveloperName, Type FROM Group 
                            WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId =:directorGroup )] ){
                                GroupMembers.add(gr.RelatedId);
                            }
            //예외대상 : GroupUser
            Map<ID, User> GroupUser = New Map<ID,User>([SELECT Id, Name FROM User WHERE UserRoleId=:GroupMembers  and isActive = true]);
            System.debug('approval 리미트 : '+ GroupUser);
            
            User tmpUser = [SELECT Id, Name, ManagerId FROM User WHERE id=:userId];
            if(GroupUser.get(tmpUser.ManagerId) == null ){
                //관리자 그룹에 추가 안되어있다면 매니저를 넣고
                User tmpManager = [SELECT Id, Name FROM User WHERE id=:tmpUser.ManagerId];
                managerResult.add(tmpManager);
            }else{
                //관리자 그룹에 추가 되어있으면 자기 자신하테 하기.
                managerResult.add(tmpUser);
            }
            
            
            //System.debug('getManager: '+getManager(userId, GroupUser, managerResult));
            //managerResult = getManager(userId, GroupUser, managerResult);
            
            
            System.debug('getRelustManager: '+managerResult);
        }
		*/
        List<User> managerResult = new List<User>();
        User tmpUser = [SELECT Id, Name, ManagerId FROM User WHERE id=:userId];
        User tmpManager = [SELECT Id, Name FROM User WHERE id=:tmpUser.ManagerId];
        managerResult.add(tmpManager);
        
        return managerResult;
        
    }
    /*
    private static List<UserRole> topRole(Id ids){
        List<UserRole> ur = new List<UserRole>([SELECT Id, ParentRoleId, Name FROM UserRole WHERE Id=:ids]);
        if (ur[0].ParentRoleId == null) {
            return ur;
        }
        return topRole(ur[0].ParentRoleId);
    }
	*/
}