public class TeamStatusMonthlyBatchController {
    
    @AuraEnabled
    public static Id executeBatchJob(){
        Id batchJob = null;
        
        batchJob = Database.executeBatch(new TeamStatusMonthlyBatch(),1);
        
        return batchJob;
    }
    
    @AuraEnabled
    public static Id executeOutSupportManageBatchJob(){
        Id batchJob = null;
        
        batchJob = Database.executeBatch(new OutSupportManagerBatch(),1);
        
        return batchJob;
    }    
    
    @AuraEnabled
    public static AsyncApexJob getBatchJobStatus(Id jobId){
        AsyncApexJob jobInfo = [SELECT Status, NumberOfErrors, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id = :jobID];
        
        return jobInfo;
    }
    
    @AuraEnabled
    public static Map<String,Object> getPerm(){
        Map<String, Object> resultMap = new Map<String,Object>();
        
        resultMap.put('isPerm', getPermissionSetAssignment().size() > 0 ? true : false);
        return resultMap;
    }
    
    private static List<PermissionSetAssignment> getPermissionSetAssignment(){
        
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
            					Name in ('TeamStatusMM_Permission')
                )
            and IsActive = true
            and AssigneeId = :userId
        ];
    }

}