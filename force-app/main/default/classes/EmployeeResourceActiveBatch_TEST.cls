@isTest
public with sharing class EmployeeResourceActiveBatch_TEST {
    static Organization__c org;
    static Employee__c emp;
    static Employee__c emp2;
    static Employee__c emp3;    
    static User u;
    static User u2;
    static User u3;    
    static PMS_PjtResource__c res;
    static PMS_PjtResource__c res2;

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
            , EmployeeNumber = '1'
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
            , EmployeeNumber = '2'
            , Title = 'title2'
            , Alias = 'alias2'
            , TimeZoneSidKey = 'Asia/Seoul'
            , EmailEncodingKey = 'UTF-8'
            , LanguageLocaleKey = 'en_US'
            , LocaleSidKey = 'en_US'
            , IsActive = true
        );
        insert u2;
        
        u3 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'DK BMC System Admin'].Id
            , LastName = '기성훈'
            , Email = 'sunghoon.ki@dkbmc.com'
            , Username = 'sunghoon.ki@dkbmc.com' + System.currentTimeMillis()
            , CompanyName = 'dkbmc'
            , EmployeeNumber = '2'
            , Title = 'title2'
            , Alias = 'alias2'
          
            , TimeZoneSidKey = 'Asia/Seoul'
            , EmailEncodingKey = 'UTF-8'
            , LanguageLocaleKey = 'en_US'
            , LocaleSidKey = 'en_US'
            , IsActive = true
        );
        insert u3;        
        
        emp = new Employee__c(
            Name = '홍길동'
            , Emp_No__c = '111'
            , Rank__c = '인턴'
            , Start__c = System.today()
            , User__c = u.Id
            , Email__c = 'hojae.lee@dkbmc.com'
            , Affiliation_company__c = 'DK BMC'
            , OrganizationId__c = org.Id
            
        );
        insert emp;
        
        emp2 = new Employee__c(
            Name = '김동식'
            , Emp_No__c = '113'
            , Rank__c = '인턴'
            , Start__c = System.today()
            , User__c = u2.Id
            , Email__c = 'OrgAdmin@dkbmc.com'
            , Affiliation_company__c = 'DK BMC'
            , OrganizationId__c = org.Id
        );
        insert emp2;
     
        emp3 = new Employee__c(
            Name = '기성훈'
            , Emp_No__c = '115'
            , Rank__c = '인턴'
            , Start__c = System.today()-2
            , User__c = u3.Id
            , End__c = System.today()-1
            , Email__c = 'OrgAdmin@dkbmc.com'
            , Affiliation_company__c = 'DK BMC'
            , OrganizationId__c = org.Id
        );
        insert emp3;        
        
        res = new PMS_PjtResource__c(
        	EmployeeId__c = emp.Id
            , IsActive__c = true
            , Name = emp.Name
            , ResourceType__c = '직원'
            , ResourceBizType__c = 'CBU'
        );
        insert res;
        
        res2 = new PMS_PjtResource__c(
        	EmployeeId__c = emp3.Id
            , IsActive__c = false
            , Name = emp3.Name
            , ResourceType__c = '직원'
            , ResourceBizType__c = 'CBU'
        );
        insert res2;        
        
    }

    static testMethod void myUnitTest() {

        Test.startTest();
        
        delete res;
    
        EmployeeResourceActiveBatch batch = new EmployeeResourceActiveBatch();
        Database.executeBatch(batch, 200);
        
        SchedulableContext sc = null;
        EmployeeResourceActiveScheduler scheduler = new EmployeeResourceActiveScheduler();
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

        update emp;
		update emp3;
        Test.stopTest();
    }
}