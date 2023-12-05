@isTest
private class ContentDocumentTrigger02_TEST {
	static ContentDocument contentdocument;
	static TriggerSetting__c ts;
    static opportunity opportunity;
    static ContentVersion contentVersion;
    static ContentDocumentLink cdl;
    static Quote quotes;
    static List<ContentDocument> documents = new List<ContentDocument>();

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
            opportunity = new Opportunity(
                Name = 'Name'
                , StageName = '초기접촉'
                , CloseDate = Date.newInstance(2022, 07, 02)
                , Sales_Division__c = 'Tableau'
            );
			insert opportunity;
		}

        quotes = new Quote(
            OpportunityId = opportunity.Id
            , Name = 'yesQuotes'
        );
        insert quotes;

        contentVersion = new ContentVersion(
            Title = 'a picture'
            , PathOnClient = 'Pic.jpg'
            , VersionData = Blob.valueOf('Test Content')
            , IsMajorVersion = true
        );
        insert contentVersion;

        documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = quotes.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;
	}

    static testMethod void myTest1() {
        Test.startTest();

        System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
        	update cdl;
        }

        Test.stopTest();
    }

    static testMethod void myTest2() {
        Test.startTest();

        delete cdl;
        delete documents;

        Test.stopTest();
    }
}