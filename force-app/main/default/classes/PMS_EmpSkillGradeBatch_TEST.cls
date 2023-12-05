@isTest
public with sharing class PMS_EmpSkillGradeBatch_TEST{
    static User u;
    static User u2;
    static Employee__c emp;
    static Employee__c emp2;
    static PMS_PjtResource__c res1;
    static PMS_PjtResource__c res2;
    static PMS_PjtCareer__c car;
    static PMS_PjtCareer__c car2;
    static Organization__c org;
    static PMS_Project__c pjt;
    static PMS_PjtManpower__c pm;
    static PMS_LastEduBackground__c eb;
    static PMS_Certificate__c cer;
    static PMS_Certificate__c cer2;
    static MT_Skill_Grade__mdt sgm;
    
    static{
        org = new Organization__c(
            IsActive__c = true
            , IsResourceActive__c = true
            , Level__c = '1'
            , Name = 'testOrg'
        );
        insert org;
        
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
        
        u2 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'DK BMC System Admin'].Id
            , LastName = '이호재'
            , Email = 'hojae.lee@dkbmc.com'
            , Username = 'hojae.lee@dkbmc.com' + System.currentTimeMillis()
            , CompanyName = 'dkbmc'
            , EmployeeNumber='2'
            , Title = 'title2'
            , Alias = 'alias2'
            , TimeZoneSidKey = 'Asia/Seoul'
            , EmailEncodingKey = 'UTF-8'
            , LanguageLocaleKey = 'en_US'
            , LocaleSidKey = 'en_US'
            , IsActive = true
        );
        insert u2;
        
        emp = new Employee__c(
            Emp_No__c = '1'
            , Name = '문주하'
            , Rank__c = '대리'
            , Start__c = Date.newInstance(2020, 12, 26)
            , User__c = u.Id
            , OrganizationId__c = org.Id
        );
        insert emp;
        
        emp2 = new Employee__c(
            Emp_No__c = '2'
            , Name = '이호재'
            , Rank__c = '사원'
            , Start__c = Date.newInstance(2020, 12, 31)
            , User__c = u2.Id
            , OrganizationId__c = org.Id
        );
        insert emp2;
        
        res1 = [SELECT Id FROM PMS_PjtResource__c WHERE EmployeeId__c = :emp.Id];
        res2 = [SELECT Id FROM PMS_PjtResource__c WHERE EmployeeId__c = :emp2.Id];
        
        car = new PMS_PjtCareer__c(
            BusinessType__c = 'IT일반'
            , InputStartDate__c = Date.newInstance(2020, 01, 01)
            , InputEndDate__c = Date.newInstance(2020, 10, 01)
            , PjtResourceId__c = res1.Id
            , EmployeeId__c = emp.Id
        );
        insert car;
        
        car2 = new PMS_PjtCareer__c(
            BusinessType__c = 'Salesforce'
            , InputStartDate__c = Date.newInstance(2018, 01, 01)
            , InputEndDate__c = Date.newInstance(2018, 02, 01)
            , PjtResourceId__c = res1.Id
            , EmployeeId__c = emp.Id
        );
        insert car2;
        
        pjt = new PMS_Project__c(
            IsOnTime__c = true
            , Name = 'testProject'
        );
        insert pjt;
        
        pm = new PMS_PjtManpower__c(
            InputStartDate__c = Date.newInstance(2021, 01, 01)
            , InputEndDate__c = Date.newInstance(2021, 10, 01)
            , ContractPlanStartDate__c = Date.newInstance(2021, 01, 01)
            , ContractPlanEndDate__c = Date.newInstance(2021, 10, 01)
            , PjtResourceId__c = res1.Id
            , JoinHQ__c = org.Id
            , ProjectId__c = pjt.Id
        );
        insert pm;
        
        System.debug('pm.PmPeriods__c ? ' + pm.PmPeriods__c);
        
        eb = new PMS_LastEduBackground__c(
            DegreeType__c = '석사'
            , GraduationType__c = '졸업'
            , PjtResourceId__c = res1.Id
            , EmployeeId__c = emp.Id
        );
        insert eb;
        
        cer = new PMS_Certificate__c(
            CertificateName__c = '정보처리기사'
            , CertificateType__c = '국가기술자격'
            , ExpirationDate__c = null
            , HoldPlanType__c = '보유'
            , PjtResourceId__c = res1.Id
            , EmployeeId__c = emp.Id
        );
        insert cer;
        
        cer2 = new PMS_Certificate__c(
            CertificateName__c = '정보처리산업기사'
            , CertificateType__c = '국가기술자격'
            , ExpirationDate__c = null
            , HoldPlanType__c = '보유'
            , PjtResourceId__c = res2.Id
            , EmployeeId__c = emp2.Id
        );
        insert cer2;
    }
    static testMethod void myUnitTest(){
        Test.startTest();
        
        PMS_EmpSkillGradeBatch batch = new PMS_EmpSkillGradeBatch();
        Database.executeBatch(batch, 200);
        
        SchedulableContext sc = null;
        PMS_EmpSkillGradeScheduler scheduler = new PMS_EmpSkillGradeScheduler();
        scheduler.execute(sc);
        Test.stopTest();
    }
}