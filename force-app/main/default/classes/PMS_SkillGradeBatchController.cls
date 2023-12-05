/*
 * @Class : PMS_SkillGradeBatchController
 *
 * @Method : 

 *  - start(BC)
 *  - execute(BC, scope)
 *  - finish(BC)
 * 
 * @Author : hojae-lee
 * @Date : 2023-01-26
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2023-01-26 | hojae-lee     | 최초작성
 */
global class PMS_SkillGradeBatchController{
	@AuraEnabled
    public static Id executeBatchJob(Id recordId){
        Id batchJobId = null;

        List<PMS_PjtResource__c> prList = [SELECT Id, Name, EmployeeId__c, PjtPartnerEmpId__c FROM PMS_PjtResource__c WHERE Id = :recordId LIMIT 1];
        List<PMS_PjtResource__c> empList = new List<PMS_PjtResource__c>();

        if(prList.size() > 0){
            for(PMS_PjtResource__c pr : prList){
                if(pr.EmployeeId__c != null && pr.PjtPartnerEmpId__c == null){
                    batchJobId = Database.executeBatch(new PMS_EmpSkillGradeBatch(pr.EmployeeId__c), 1);
                }
                if(pr.PjtPartnerEmpId__c != null && pr.EmployeeId__c == null){
                    batchJobId = Database.executeBatch(new PMS_PartnerEmpSkillGradeBatch(pr.Id), 1);
                }
            }
        }
        
        return batchJobId;
    }

    @AuraEnabled
    public static AsyncApexJob getBatchJobStatus(Id jobID){
        AsyncApexJob jobInfo = [SELECT Status, NumberOfErrors, JobItemsProcessed, TotalJobItems FROM AsyncApexJob WHERE Id = :jobID];
        return jobInfo;
    }

    @AuraEnabled // 등급 실행 버튼 권한 부여
    global static Map<String, Object> getPerm() {
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