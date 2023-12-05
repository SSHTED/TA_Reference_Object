public class PMS_MonthlyInputStatusBatchController {
    
    @AuraEnabled
    public static Id executeBatchJob(Id recordId){
        Id batchJobId = null;
        
        List <PMS_Project__c> projectList = [select id from PMS_Project__c where Id =: recordId limit 1];
        
        if(projectList.size() > 0){
            for(PMS_Project__c project : projectList){
                 batchJobId = Database.executeBatch(new PMS_MonthlyInputStatusBatch(project.Id), 1);
            }
           
        }
        
        return batchJobId;
    }
    
    @AuraEnabled 
    public static AsyncApexJob getBatchJobStatus(Id jobId){
        
        AsyncApexJob jobInfo = [SELECT Status, NumberOfErrors, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id = :jobId];

        return jobInfo;        
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
                Name in ('PMS_PERM_HQ', 'PMS_PERM_PMO')
            )
            and IsActive = true
            and AssigneeId = :userId
        ];
    }
}