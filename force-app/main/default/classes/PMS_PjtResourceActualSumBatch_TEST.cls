@isTest
private class PMS_PjtResourceActualSumBatch_TEST {
    
    static Organization__c org;
    static Employee__c employee;
    static PMS_PjtResource__c pms_pjtresource,pms_pjtresource2;
    static PMS_PjtManpower__c pm;
    static PMS_PjtManpower__c pm2;
    static PMS_Project__c pjt;
    static 	PMS_PjtPartnerEmp__c partneremp,partneremp2;
    static PMS_PjtPartner__c partner;
    static PMS_PjtPartner__c partner2;    
    static {
        org = new Organization__c(
            IsActive__c = true
            , IsResourceActive__c = true
            , Level__c = '1'
            , Name = 'testOrg'
        );
        insert org;

        pjt = new PMS_Project__c(
            IsOnTime__c = true
            , Name = 'testProject'
        );
        insert pjt;
        
        partner = new PMS_PjtPartner__c(
        	Name = '협력사'
        );
        insert partner;
        
        partner2 = new PMS_PjtPartner__c(
        	Name = '협력사2'
        );
        insert partner2;        

        employee = new Employee__c (
            Emp_No__c = 'Tset10'
            , OwnerId = System.UserInfo.getUserId()
            , Rank__c = '인턴'
            , Start__c = date.today()
        );
    
        insert employee;
        
        partneremp = new PMS_PjtPartnerEmp__c(
        	PjtPartnerId__c = partner.Id,
            Name = 'test'
           
        );
        insert partneremp;
        
        
        partneremp2 = new PMS_PjtPartnerEmp__c(
        	PjtPartnerId__c = partner2.Id,
            Name = 'test2'
           
        );
        insert partneremp2;
        
        pms_pjtresource = new PMS_PjtResource__c (
            IsActive__c = true
            , OwnerId = System.UserInfo.getUserId()
            , PjtPartnerEmpId__c = partneremp.Id            
            , ResourceType__c = '협력사 인력'
        );
    
        insert pms_pjtresource;

        pms_pjtresource2 = new PMS_PjtResource__c (
            IsActive__c = true
            , OwnerId = System.UserInfo.getUserId()
            , PjtPartnerEmpId__c = partneremp2.Id            
            , ResourceType__c = '협력사 인력'
        );
    
        insert pms_pjtresource2;        
        pm = new PMS_PjtManpower__c(
            InputStartDate__c = Date.newInstance(2021, 01, 01)
            , InputEndDate__c = Date.newInstance(2024, 10, 01)
            , ContractPlanStartDate__c = Date.newInstance(2021, 01, 01)
            , ContractPlanEndDate__c = Date.newInstance(2024, 10, 01)
            , PjtResourceId__c = pms_pjtresource.Id
            , JoinHQ__c = org.Id
            , ProjectId__c = pjt.Id
        );
        insert pm;
        pm2 = new PMS_PjtManpower__c(
              InputEndDate__c = null
            , ContractPlanStartDate__c =null
            , ContractPlanEndDate__c = null
            , PjtResourceId__c = pms_pjtresource2.Id
            , JoinHQ__c = org.Id
            , ProjectId__c = pjt.Id
        );
        insert pm2;
    }

    static testMethod void myUnitTest() {

        Test.startTest();
    
        PMS_PjtResourceActualSumBatch batch = new PMS_PjtResourceActualSumBatch();
        Database.executeBatch(batch, 200);
        
        SchedulableContext sc = null;
        PMS_PjtResourceActualSumScheduler scheduler = new PMS_PjtResourceActualSumScheduler();
        scheduler.execute(sc);
    
        Test.stopTest();
    }
}