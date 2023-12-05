@isTest
private class PMS_Psc_RiskTrigger_TEST {
    static PMS_Project__c pms_project;
	static PMS_Psc_Risk__c pms_psc_risk;
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
            Name = 'project'
            , OwnerId = System.UserInfo.getUserId()
        );
    
        insert pms_project;

		System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
			pms_psc_risk = new PMS_Psc_Risk__c(ProjectId__c = pms_project.Id);
			insert pms_psc_risk;
		}
	}

    static testMethod void myTest1() {
        Test.startTest();

        System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
            //pms_psc_risk.Name = 'Name modified';
        	update pms_psc_risk;
        }

        Test.stopTest();
    }

    static testMethod void myTest2() {
        Test.startTest();

        delete pms_psc_risk;

        Test.stopTest();
    }
}