@isTest
private class PMS_Psc_RequestTrigger_TEST {
    static PMS_PSC__c pms_psc;
	static PMS_Psc_Request__c pms_psc_request;
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
        
        pms_psc = new PMS_PSC__c (
            OwnerId = System.UserInfo.getUserId()
        );
    
        insert pms_psc;

		System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
			pms_psc_request = new PMS_Psc_Request__c(PscId__c = pms_psc.Id);
			insert pms_psc_request;
		}
	}

    static testMethod void myTest1() {
        Test.startTest();

        System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
            //pms_psc_request.Name = 'Name modified';
        	update pms_psc_request;
        }

        Test.stopTest();
    }

    static testMethod void myTest2() {
        Test.startTest();

        delete pms_psc_request;

        Test.stopTest();
    }
}