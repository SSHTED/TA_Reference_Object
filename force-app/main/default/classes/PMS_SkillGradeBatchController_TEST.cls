@isTest
public class PMS_SkillGradeBatchController_TEST{
    static User u;
    static Employee__c emp;
    static PMS_PjtResource__c res1;

    static{
        u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'DK BMC System Admin'].Id
            , LastName = '문주하'
            , Email = 'test31213@dkbmc.com'
            , Username = 'test32113@dkbmc.com' + System.currentTimeMillis()
            , CompanyName = 'dkbmc'
            , EmployeeNumber='1'
            , Title = 'title'
            , Alias = 'alias'
            , TimeZoneSidKey = 'Asia/Seoul'
            , EmailEncodingKey = 'UTF-8'
            , LanguageLocaleKey = 'en_US'
            , LocaleSidKey = 'en_US'
            , IsActive = true
        );
        insert u;
        
        emp = new Employee__c(
            Emp_No__c = '1'
            , Name = '문주하'
            , Rank__c = '대리'
            , Start__c = Date.newInstance(2020, 12, 26)
            , User__c = u.Id
        );
        insert emp;
        
        res1 = [SELECT Id FROM PMS_PjtResource__c WHERE EmployeeId__c = :emp.Id];
    }

    static testMethod void myUnitTest() {

        Test.startTest();
    
        PMS_SkillGradeBatchController.executeBatchJob(res1.Id);
        PMS_SkillGradeBatchController.getBatchJobStatus(PMS_SkillGradeBatchController.executeBatchJob(res1.Id));
        PMS_SkillGradeBatchController.getPerm();
    
        Test.stopTest();
    }
    
}