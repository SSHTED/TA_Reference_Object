public class PMS_ProjectController {
    
	@AuraEnabled
    public static void updateProjectField(String recordId) {
        PMS_Project__c projectList = [select id,PMS_ProjectCompleteCheck__c from PMS_Project__c where Id =: recordId limit 1];
        
        projectList.PMS_ProjectCompleteCheck__c = true;
        
        update projectList;
    }
    
    @AuraEnabled // 등급 실행 버튼 권한 부여
    public static Map<String, Object> getPerm() {
        Map<String, Object> resultMap = new Map<String, Object>();
        
        resultMap.put('isPerm', getPermissionSetAssignment().size() > 0 ? true : false);
        
        return resultMap;
    }
    
    
    private static List<PermissionSetAssignment> getPermissionSetAssignment() {
        
        String userId = System.UserInfo.getUserId();
        
        return [
            select 
            AssigneeId
            , ExpirationDate
            , Id
            , IsActive
            , PermissionSetGroupId
            , PermissionSetId
            , SystemModstamp
            from
            PermissionSetAssignment
            where 
            PermissionSetId in (
                select 
                Id
                from
                PermissionSet
                where 
                Name in ('PMS_PERM_HQ')
            )
            and IsActive = true
            and AssigneeId = :userId
        ];
    }    
}