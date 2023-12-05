@isTest
private class OpportunityTrigger_TEST {
	static Opportunity opportunity;
	static TriggerSetting__c ts;

	static {
		ts = new TriggerSetting__c();
		ts.ALL_ACTIVE__c = true;
		ts.AFTER_INSERT__c = true;
		ts.AFTER_UPDATE__c = true;
		ts.BEFORE_DELETE__c = true;
		ts.SetupOwnerId = System.userInfo.getOrganizationId();
		insert ts;

		System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
			opportunity = new Opportunity(Name = 'Name'
            , StageName = '초기접촉'
            , CloseDate = Date.newInstance(2022, 07, 02)
            , Sales_Division__c = 'Tableau'
            );
			insert opportunity;
		}
	}

    static testMethod void myTest1() {
        Test.startTest();

        System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
            opportunity.Name = 'Name modified';
            opportunity.StageName = '가치제안';
            opportunity.CloseDate = Date.newInstance(2022, 07, 07);
            opportunity.Sales_Division__c = 'Salesforce ESR';
        	update opportunity;
        }

        Test.stopTest();
    }

    static testMethod void myTest2() {
        Test.startTest();

        delete opportunity;

        Test.stopTest();
    }
}