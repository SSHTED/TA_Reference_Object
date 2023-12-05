@isTest
private class PMS_PjtResourceTrigger_TEST {
    static Employee__c employee;
	static PMS_PjtResource__c pms_pjtresource;
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
        
        employee = new Employee__c (
            Emp_No__c = 'Tset10'
            , OwnerId = System.UserInfo.getUserId()
            , Rank__c = '인턴'
            , Start__c = date.today()
        );
    
        insert employee;

		System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
			pms_pjtresource = new PMS_PjtResource__c(
                EmployeeId__c = employee.Id
                , IsActive__c = true
                , Name = 'Tset7'
                , OwnerId = System.UserInfo.getUserId()
                , ResourceType__c = '직원'
            );
            
			insert pms_pjtresource;
		}
	}

    static testMethod void myTest1() {
        Test.startTest();

        System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
            pms_pjtresource.Name = 'Name modified';
        	update pms_pjtresource;
        }

        Test.stopTest();
    }

    static testMethod void myTest2() {
        Test.startTest();

        delete pms_pjtresource;

        Test.stopTest();
    }
}