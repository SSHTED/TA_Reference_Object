@isTest
private class PMS_ProfileViewController_TEST {

    static Employee__c employee;
    static PMS_PjtResource__c pms_pjtresource;
    static PMS_Project__c pms_project;
    static PMS_PjtManpower__c pms_pjtmanpower;
	static PMS_PjtCareer__c pms_pjtcareer;
    static Organization__c org;
    
    static {
        employee = new Employee__c (
            Emp_No__c = 'Tset10'
            , OwnerId = System.UserInfo.getUserId()
            , Rank__c = '인턴'
            , Start__c = date.today()
        );
    
        insert employee;
        
        org = new Organization__c(
            IsActive__c = true
            , IsResourceActive__c = true
            , Level__c = '1'
            , Name = 'testOrg'
        );
        insert org;        
        
        pms_pjtresource = new PMS_PjtResource__c (
            IsActive__c = true
            , OwnerId = System.UserInfo.getUserId()
            , EmployeeId__c = employee.Id            
            , ResourceType__c = '직원'
        );
    
        insert pms_pjtresource;
        
        pms_project = new PMS_Project__c (
            Name = 'Tset10'
        );
    
        insert pms_project;
        
        pms_pjtmanpower = new PMS_PjtManpower__c (
            ActualGrade__c = '초급'
            , ActualInputMM__c = 5
            , AdditionalMM__c = 1
            , Area__c = 'Tset1'
            , BillableRecognizedMM__c = 9
            , BillingType__c = 'Billable'
            , ContractPlanEndDate__c = date.today()
            , ContractPlanStartDate__c = date.today()
            , Division__c = 'Tset10'
            , DownPayment__c = 2
            , HQ__c = 'Tset5'
            , InputEndDate__c = date.today()
            , InputStartDate__c = date.today()
            , InputType__c = 'Full-time'
            , IsRoomSupport__c = true
            , IsTransportationSupport__c = true
            , MainWork__c = 'Tset8'
            , Note__c = 'Tset10'
            , OnSiteWorkMM__c = 9
            , OrgName__c = 'Tset6'
            , PjtResourceId__c = pms_pjtresource.Id
            , PlannedBillableMM__c = 7
            , PlannedNonBillableMM__c = 2
            , PlannedTotalInputMM__c = 4
            , ProjectId__c = pms_project.Id
            , Rank__c = 'Tset7'
            , Role__c = 'Project Manager'
            , SuggestedGrade__c = '초급'
            , Team__c = 'Tset3'
            , WorkStyle__c = 'On-site'
            , JoinHQ__c = org.Id
        );
    
        insert pms_pjtmanpower;
    
        pms_pjtcareer = new PMS_PjtCareer__c (
            Agency__c = 'Tset8'
            , AppliedProduct_Solution__c = 'Tset1'
            , BusinessType__c = 'Salesforce'
            , Buyer__c = 'Tset5'
            , ChargeTask__c = 'Tset5'
            , EmployeeId__c = employee.Id
            , InputEndDate__c = date.today()
            , InputStartDate__c = date.today()
            , JoinDate__c = date.today()
            , JoinProjectInfo__c = 'Tset2'
            , JoinProjectName__c = 'Tset6'
            , PjtResourceId__c = pms_pjtresource.Id
            , RoleType__c = 'Tset3'
        );
    
        insert pms_pjtcareer;
    }
    
    static testMethod void myUnitTest() {

        String recordId = pms_pjtresource.Id;
    
        Test.startTest();
    
        PMS_ProfileViewController.getList(recordId);
    
        Test.stopTest();
    }
}