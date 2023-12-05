@isTest
public class JobOfferEmailTemplateController_TEST {

    static User u;
    static Job_Offer__c JO;
    
    static {
        u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
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
            JO = new Job_Offer__c(
                AdditionalBenefits__c = ''
                , Department__c = '기술본부'
                , Email__c = 'yj.cha@dkbmc.com'
                , HopeStartDate__c = System.today()
                , IsEmploymentInsurance__c = true
                , IsFinalGraduationCertificate__c = true
                , IsIncentive__c = true
                , IsOfferAccept__c = true
            	, IsInterviewDropout__c = false
                , ReplyDeadline__c = ''
                , Salary__c = 1000
                , SelectiveWelfare__c = 100
                , Title__c = '사원'
                , Name = '홍길동'
            	, OwnerId = u.Id
            );
            
            insert JO;
        }
    }
    
    static testMethod void myUnitTest()
    {
        Test.startTest();
        
        JobOfferEmailTemplateController.getEmailPreview(JO.Id);
        JobOfferEmailTemplateController.sendEmail(JO.Id);
        
        Test.stopTest();
    }
}