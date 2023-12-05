@isTest
private class PMS_PjtEvalSettleTrigger_TEST {
    static PMS_Project__c pms_project;
    static Employee__c employee;
    static PMS_PjtResource__c pms_pjtresource;
    static PMS_PjtManpower__c pms_pjtmanpower;
	static PMS_PjtEvalSettle__c pms_pjtevalsettle;
	static TriggerSetting__c ts;

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
        
        pms_project = new PMS_Project__c (
            Name = 'Tset10'
        );
    
        insert pms_project;
        
        employee = new Employee__c (
            Emp_No__c = 'Tset10'
            , OwnerId = System.UserInfo.getUserId()
            , Rank__c = '인턴'
            , Start__c = date.today()
        );
    
        insert employee;
    
        pms_pjtresource = new PMS_PjtResource__c (
            EmployeeId__c = employee.Id
            , IsActive__c = true
            , Name = 'Tset7'
            , ResourceType__c = '직원'
        );
    
        insert pms_pjtresource;
    
        pms_pjtmanpower = new PMS_PjtManpower__c (
            PjtResourceId__c = pms_pjtresource.Id
            , ProjectId__c = pms_project.Id
        );
    
        insert pms_pjtmanpower;

		System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
			pms_pjtevalsettle = new PMS_PjtEvalSettle__c(ProjectId__c = pms_pjtmanpower.ProjectId__c, PjtResourceId__c = pms_pjtmanpower.PjtResourceId__c);
			insert pms_pjtevalsettle;
		}
	}

    static testMethod void myTest1() {
        Test.startTest();

        System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
            //pms_pjtevalsettle.Name = 'Name modified';
        	update pms_pjtevalsettle;
        }

        Test.stopTest();
    }

    static testMethod void myTest2() {
        Test.startTest();

        delete pms_pjtevalsettle;

        Test.stopTest();
    }
}