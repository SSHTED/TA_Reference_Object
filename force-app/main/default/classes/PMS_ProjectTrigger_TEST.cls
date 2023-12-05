@isTest
private class PMS_ProjectTrigger_TEST {
    static PMS_Project__c pms_project;
    static PMS_Project__c pms_project02;
    static TriggerSetting__c ts;
    static PMS_PjtResource__c pms_resource;
    static PMS_PjtResource__c pms_resource02;
    static Employee__c emp;
    static Employee__c emp02;
    
    static {
        ts = new TriggerSetting__c();
        ts.ALL_ACTIVE__c = true;
        ts.AFTER_DELETE__c = true;
        ts.AFTER_INSERT__c = true;
        ts.AFTER_UNDELETE__c = true;
        ts.AFTER_UPDATE__c = true;
        ts.BEFORE_DELETE__c = true;
        ts.BEFORE_INSERT__c = true;
        ts.BEFORE_UPDATE__c = true;
        ts.SetupOwnerId = System.userInfo.getOrganizationId();
        insert ts;
        
        System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
            pms_project = new PMS_Project__c(
                Name = 'Name'
            );
            insert pms_project;
        }
        
        User u02 = [SELECT Id FROM User WHERE Name = '이호재' LIMIT 1];
        emp = new Employee__c(
            Name = '홍길동'
            , Emp_No__c = '111'
            , Rank__c = '인턴'
            , Start__c = date.today()
            , User__c = u02.Id
        );
        insert emp;
        
        User u03 = [SELECT Id FROM User WHERE Name = '차용진' LIMIT 1];
        emp02 = new Employee__c(
            Name = '홍길동02'
            , Emp_No__c = '112'
            , Rank__c = '인턴'
            , Start__c = date.today()
            , User__c = u03.Id
        );
        insert emp02;
        
        pms_resource = new PMS_PjtResource__c(
            Name = 'test1'
            , ResourceType__c = '직원'
            , EmployeeId__c = emp.Id
        );
        insert pms_resource;
        
        pms_resource02 = new PMS_PjtResource__c(
            Name = 'test2'
            , ResourceType__c = '직원'
            , EmployeeId__c = emp02.Id
           
        );
        insert pms_resource02;
        
        pms_project02 = new PMS_Project__c(
            Name = 'Name02'
            , ProjectManagerId__c = pms_resource.Id
            ,ActualCostPercentageCheck__c = false
            ,ActualCostPercentage100Check__c = false
            ,ContractAmt__c = 541260000
            ,ActualCost__c = 0
            , ContractStartDate__c  = Date.newInstance(2023, 05, 11)
            , ContractEndDate__c =  Date.newInstance(2023, 05, 11)
            , KickoffDate__c = Date.newInstance(2023, 05, 11)
            , DeadlineDate__c = Date.newInstance(2023, 05, 11)
        );
        insert pms_project02;
    }
    
    static testMethod void myTest1() {
        Test.startTest();
        
        System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
            pms_project.Name = 'Name modified';


            update pms_project;
            
            pms_project02.ProjectManagerId__c = pms_resource02.Id;
 			pms_project02.Status__c = 'Completed';
            pms_project02.PMS_ProjectCompleteCheck__c = true;
            update pms_project02;
            
            
        }
        
        Test.stopTest();
    }
    
    static testMethod void myTest2() {
        Test.startTest();
        
        delete pms_project;
        
        Test.stopTest();
    }
}