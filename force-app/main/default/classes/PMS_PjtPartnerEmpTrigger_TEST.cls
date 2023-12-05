@isTest
private class PMS_PjtPartnerEmpTrigger_TEST {
    static PMS_PjtPartner__c pms_pjtpartner;
	static PMS_PjtPartnerEmp__c pms_pjtpartneremp;
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
        
        pms_pjtpartner = new PMS_PjtPartner__c (
            Name = 'partner'
        );
    
        insert pms_pjtpartner;

		System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
			pms_pjtpartneremp = new PMS_PjtPartnerEmp__c(Name = 'Name', PjtpartnerId__c = pms_pjtpartner.Id);
			insert pms_pjtpartneremp;
		}
	}

    static testMethod void myTest1() {
        Test.startTest();

        System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
            pms_pjtpartneremp.Name = 'Name modified';
        	update pms_pjtpartneremp;
        }

        Test.stopTest();
    }

    static testMethod void myTest2() {
        Test.startTest();

        delete pms_pjtpartneremp;

        Test.stopTest();
    }
}