@isTest
private class PMS_ActionItemTrigger_TEST {
    static PMS_Project__c pms_project;
    static PMS_PSC__c pms_psc;
    static PMS_Psc_Issue__c pms_psc_issue;
    static PMS_Psc_Risk__c pms_psc_risk;
    static PMS_Psc_Request__c pms_psc_request;
	static PMS_ActionItem__c pms_actionitem;
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
        
        pms_psc = new PMS_PSC__c (
            MainRemainingWork__c = 'Tset3'
            , MajorWork__c = 'Tset4'
            , OwnerId = System.UserInfo.getUserId()
            , PerformanceProgress__c = 48
            , PerformedStage__c = '착수준비'
            , PlanProgress__c = 47
            , ProgressDate__c = date.today()
            , ProjectId__c = pms_project.Id
            , PscType__c = '정기'
            , Request__c = 'Tset1'
        );
    
        insert pms_psc;
        
        pms_psc_issue = new PMS_Psc_Issue__c (
            PSCId__c = pms_psc.Id
        );
    
        insert pms_psc_issue;
    
        pms_psc_risk = new PMS_Psc_Risk__c (
            PSCId__c = pms_psc.Id
        );
    
        insert pms_psc_risk;
    
        pms_psc_request = new PMS_Psc_Request__c (
            PSCId__c = pms_psc.Id
        );
    
        insert pms_psc_request;

		System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
			pms_actionitem = new PMS_ActionItem__c(PSCId__c = pms_psc.Id);
			insert pms_actionitem;
            
            insert new PMS_ActionItem__c(IssueId__c = pms_psc_issue.Id);
            insert new PMS_ActionItem__c(RiskId__c = pms_psc_risk.Id);
            insert new PMS_ActionItem__c(RequestId__c = pms_psc_request.Id);
		}
	}

    static testMethod void myTest1() {
        Test.startTest();

        System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
            //pms_actionitem.Name = 'Name modified';
        	update pms_actionitem;
        }

        Test.stopTest();
    }

    static testMethod void myTest2() {
        Test.startTest();

        delete pms_actionitem;

        Test.stopTest();
    }
}