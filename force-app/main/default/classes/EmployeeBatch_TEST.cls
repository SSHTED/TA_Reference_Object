@isTest
public with sharing class EmployeeBatch_TEST {
    static Organization__c org;
    static Employee__c emp;
    static Employee__c emp2;
    static User u;
    static User u2;
    static PMS_PjtResource__c res;

    static{
        org = new Organization__c (
            Code__c = 'CX HQ'
            , DisplayOrder__c = 9
            , IsActive__c = true
            , Level__c = '2'
            , Name = 'CX본부'
            , Note__c = 'Tset3'
            , OwnerId = System.UserInfo.getUserId()
            , IsResourceActive__c = true
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
            Name = '홍길동'
            , Emp_No__c = '111'
            , Rank__c = '인턴'
            , Start__c = System.today()
            , User__c = u.Id
            , Email__c = 'hojae.lee@dkbmc.com'
        );
        insert emp;
        
        emp2 = new Employee__c(
            Name = '김동식'
            , Emp_No__c = '113'
            , Rank__c = '인턴'
            , Start__c = System.today()
            , User__c = u2.Id
            , Email__c = 'OrgAdmin@dkbmc.com'
        );
        insert emp2;
        
        res = new PMS_PjtResource__c(
        	EmployeeId__c = emp.Id
            , IsActive__c = true
            , Name = emp.Name
            , ResourceType__c = '직원'
        );
        insert res;
    }

    static testMethod void myUnitTest() {

        Test.startTest();
        
        delete res;
    
        EmployeeBatch batch = new EmployeeBatch();
        Database.executeBatch(batch, 200);
        
        SchedulableContext sc = null;
        EmployeeBatchScheduler scheduler = new EmployeeBatchScheduler();
        scheduler.execute(sc);

        user u2 = new user(
            FirstName = '방민규'
            ,Username = 'TTest@dkdkdk.com'
            , LastName = 'aa'
            , Email = 'Test@dkb333m333c.com'
            , Alias = '테스트유저'
            , TimeZoneSidKey = 'Asia/Seoul'
            , LocaleSidKey = 'ko_KR'
            , EmailEncodingKey = 'UTF-8'
            , ProfileId = '00e28000001scycAAA'
            , LanguageLocaleKey = 'ko'
        );
        Insert u2;

        EmployeeToPermissionSetController.insertITAMPermssionSet(u2.Id);
        EmployeeToPermissionSetController.insertPMSPermssionSet(u2.Id);

        EmployeeToPermissionSetController.insertITAMPermssionSet(u.Id);
        EmployeeToPermissionSetController.insertPMSPermssionSet(u.Id);

        update emp;

        Test.stopTest();
    }
}