@isTest
private class PMS_HQ_RequestTrigger_TEST {
	static PMS_HQ_Request__c pms_hq_request;
	static TriggerSetting__c ts;
	static Organization__c org;

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

		org = new Organization__c (
            Code__c = 'CX HQ'
            , DisplayOrder__c = 9
            , IsActive__c = true
            , Level__c = '2'
            , Name = 'CX본부'
            , Note__c = 'Tset3'
            , OwnerId = System.UserInfo.getUserId()
        );
        insert org;

		System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
			pms_hq_request = new PMS_HQ_Request__c(
				HQId__c = org.Id
				, ActionHQ__c = 'EPMO'
			);
			insert pms_hq_request;
		}
	}

    static testMethod void myTest1() {
        Test.startTest();

        System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
            //pms_hq_request.Name = 'Name modified';
        	update pms_hq_request;
        }

        Test.stopTest();
    }

    static testMethod void myTest2() {
        Test.startTest();

        delete pms_hq_request;

        Test.stopTest();
    }
}