@isTest
private class ContractDocumentTrigger_TEST {
	static ContractDocument__c contractdocument;
    static ContractDocument__c contractdocument2;
    static User users;
    static Account act;
    static Opportunity op;
    // static ContractDocument__Share cdShare;
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

		System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
            act = new Account(
                Name = 'act01'
            );
            insert act;

            op = new Opportunity(
                Name = 'op01'
                , AccountId = act.Id
                , StageName = '초기접촉'
                , Sales_Division__c = 'Salesforce ISR'
                , CloseDate = Date.newInstance(2022, 09, 09)
            );
            insert op;
            
			contractdocument = new ContractDocument__c(
                Name = 'Name'
                , Account__c = act.id
                , Opportunity__c = op.id
                // , ContractDocumentCode__c = 'C-22-0001'
                , Contracted_company__c = act.id
                , Contract_type__c = '매입 계약서'
            );
			insert contractdocument;

            contractdocument2 = new ContractDocument__c(
                Name = 'Name2'
                , Account__c = act.id
                , Opportunity__c = op.id
                , ContractDocumentCode__c = 'C-22-0002'
                , Contracted_company__c = act.id
                , Contract_type__c = '매입 계약서'
            );
			insert contractdocument2;
		}
	}

    static testMethod void myTest1() {
        Test.startTest();

        System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
            contractdocument.Name = 'Name modified';
            // contractdocument.Account__c = '001p000000zJtICAA0';
            // contractdocument.Opportunity__c = 
        	update contractdocument;
			
            UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
            insert r;
			system.debug('r is : ' + r);
            system.debug('r is : ' + r.Id);
            User u = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'DK BMC System Admin'].Id
                , IsActive = true
                , LastName = 'last'
                , Email = 'puser000@amamama.com'
                , Username = 'puser000@amamama.com' + System.currentTimeMillis()
                , CompanyName = 'TEST'
                , Title = 'title'
                , Alias = 'alias'
                , TimeZoneSidKey = 'America/Los_Angeles'
                , EmailEncodingKey = 'UTF-8'
                , LanguageLocaleKey = 'en_US'
                , LocaleSidKey = 'en_US'
                , UserRoleId = r.Id
            );
            insert u;
            System.debug('UserRoleId' + u.UserRoleId);
            /*List<UserRole> urList = [SELECT Id, Name FROM UserRole WHERE Id = '00E0I00000238RuUAI'];
            List<ContractDocument__Share> cdShareList = new List<ContractDocument__Share>();
            for(UserRole ur : urList){
                List<User> uList = [SELECT Id, UserRoleId FROM User WHERE UserRoleId = '00E0I00000238RuUAI' AND IsActive = true];
                for(User uu : uList){
                    cdShareList.add(
                        new ContractDocument__Share(
                            AccessLevel = 'Edit'
                            , ParentId = contractdocument.id
                            , RowCause = 'Manual'
                            , UserOrGroupId = users.id
                        )
                    );
                }
            }
            insert cdShareList;*/

            ContractDocument__Share cds = new ContractDocument__Share(
                AccessLevel = 'Edit'
                , ParentId = contractdocument.id
                , RowCause = 'Manual'
                , UserOrGroupId = u.id
            );
            insert cds;
        }

        Test.stopTest();
    }

    static testMethod void myTest2() {
        Test.startTest();

        delete contractdocument;

        Test.stopTest();
    }
}