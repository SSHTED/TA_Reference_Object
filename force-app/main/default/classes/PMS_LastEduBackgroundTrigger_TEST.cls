@isTest
public class PMS_LastEduBackgroundTrigger_TEST {
    
    static PMS_PjtResource__c pms_pjtresource;
    static Employee__c emp;
    static Employee__c emp2;
    static User u;
    static User u2;
    static Organization__c org;
    static PMS_LastEduBackground__c lastEduBackground;
    static PMS_LastEduBackground__c lastEduBackground2;
    
    static{
        u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'DK BMC System Admin'].Id
            , LastName = '차용진'
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
        
        org = new Organization__c(
            Name='CX본부',
            Level__c ='2'
        );
        insert org;        
        
        emp = new Employee__c (
            Name = '차용진'
            ,  Emp_No__c = '111'
            ,  Rank__c = '인턴'
            ,  Start__c = System.today()
            ,  User__c = u.Id
            ,  Email__c = 'yj.cha@dkbmc.com'
            ,  OrganizationId__c = org.Id
        ); 
        
        insert emp;
        
        emp2 = new Employee__c (
            Name = '이호재'
            ,  Emp_No__c = '222'
            ,  Rank__c = '인턴'
            ,  Start__c = System.today()
            ,  User__c = u2.Id
            ,  Email__c = 'hojae.lee@dkbmc.com'
            ,  OrganizationId__c = org.Id
        );
        
        insert emp2;
        
        pms_pjtresource = new PMS_PjtResource__c (
            IsActive__c = true
            , OwnerId = System.UserInfo.getUserId()
            , EmployeeId__c = emp.Id            
            , ResourceType__c = '직원'
        );
        
        insert pms_pjtresource;
        
        
        
        lastEduBackground = new PMS_LastEduBackground__c(
            EmployeeId__c = emp.Id,
            PjtResourceId__c = pms_pjtresource.Id,
            LastEduCheck__c = true
        );

    }
    
    
    static testMethod void myTest1() {
        Test.startTest();
        insert lastEduBackground;
       
        
        Test.stopTest();
    }
}