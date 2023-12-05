@isTest
public class ResellerContractExpireEmailCtr_TEST {

    static User u;
    static Account AC;
    static Contact CON;
    static Product__c P;
    static Opportunity__c OP;
    static ResellerOpportunityProduct__c ROP;
    
    static {
        u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'DK BMC System Admin'].Id,
            LastName = 'testUser',
            Email = 'test@test.com',
            Username = 'test@test.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            EmployeeNumber='test123',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'Asia/Seoul',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = [Select Id  From UserRole Where DeveloperName = 'CEO'].Id
        );
        
        insert u;
        
        system.runAs(u) {
            AC = new Account(Name='Account Name');
            insert AC;
            
            CON = new Contact(LastName= '홍길동', AccountId = AC.Id, Phone = '010-2222-3333', Email='test@test.com', Title='과장');
            insert CON;
            
            OP = new Opportunity__c(Name='Op', Account__c = AC.Id, Main_Contact__c = CON.Id, Field2__c = 'Salesforce ESR', Sales_Estimated_Date__c = System.today()
                                    , RecordTypeId = [select Id from RecordType where SobjectType = 'Opportunity__c' and DeveloperName = 'Reseller'].get(0).Id);
            insert OP;
            
            P = new Product__c(Name='제품');
            
            insert P;
            
            ROP = new ResellerOpportunityProduct__c(Opportunity__c = OP.Id, StartDate__c = System.today(), EndDate__c = System.today().addYears(1), Qty__c = 10, Product__c = P.Id);
            
            insert ROP;
        }
    }
    
    static testMethod void myUnitTest()
    {
        Test.startTest();
        
        ResellerContractExpireEmailController.getEmailPreview(OP.Id);
        ResellerContractExpireEmailController.sendEmail(OP.Id);
        
        Test.stopTest();
    }
}