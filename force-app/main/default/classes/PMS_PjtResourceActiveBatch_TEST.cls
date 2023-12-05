@isTest
global with sharing class PMS_PjtResourceActiveBatch_TEST {
    static{
        Organization__c org = new Organization__c (
            Code__c = 'TEST_ORG'
            , DisplayOrder__c = 8
            , IsActive__c = true
            , IsResourceActive__c = true
            , Level__c = '2'
            , Name = 'TEST_ORG'
            , Note__c = 'TEST'
        );
        insert org;
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'DK BMC System Admin'].Id,
            LastName = '이호재',
            Email = 'test31213@dkbmc.com',
            Username = 'test32113@dkbmc.com' + System.currentTimeMillis(),
            CompanyName = 'dkbmc',
            EmployeeNumber='111',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'Asia/Seoul',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u;
        
        Employee__c emp = new Employee__c(
            Emp_No__c = '111'     
            , Name = '이호재'
            , Rank__c = '인턴'
            , Start__c = System.today()
            , OrganizationId__c = org.Id
            , User__c = u.Id
        );
        insert emp;
        
        PMS_PjtResource__c pr = new PMS_PjtResource__c(
            IsActive__c = false
            , EmployeeId__c = emp.Id
            // , FM_WorkStatus__c = '재직'
        );
        insert pr;
    }
    
    @isTest
    static void testBatch(){
        Test.startTest();
        PMS_PjtResourceActiveBatch batch = new PMS_PjtResourceActiveBatch();
        
        Database.executeBatch(batch, 200);
        SchedulableContext sc = null;
        PMS_PjtResourceActiveScheduler scheduler = new PMS_PjtResourceActiveScheduler();
		scheduler.execute(sc);
        Test.stopTest();        
    }
}