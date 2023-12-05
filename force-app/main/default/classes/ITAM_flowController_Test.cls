@isTest
public class ITAM_flowController_Test {
	@testSetup
    static void setup(){
        UserRole userRole1 = new UserRole();
        userRole1.DeveloperName ='ParentRole1Dev';
        userRole1.Name='ParentRole1Name';
        insert userRole1;
        
        UserRole userRole2 = new UserRole();
        userRole2.DeveloperName ='ParentRole2Dev';
        userRole2.Name='ParentRole2Name';
        userRole2.ParentRoleId = userRole1.Id;
        insert userRole2;
        
        User user = new User();
        user.Username ='ITAMtestemail@test.com';
        user.LastName = 'ITAMLastTestName';
        user.Email = 'testemail@test.com';
        user.alias = 'itam';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.EmailEncodingKey = 'ISO-8859-1';
        user.ProfileId = [select id from Profile where Name='DK BMC System Admin'].Id;
        user.LanguageLocaleKey = 'en_US';
        user.UserRoleId = userRole1.Id;
        insert user;
        
        User user1 = new User();
        user1.Username ='ITAMemail@test.com';
        user1.LastName = 'ITAMLastTestName';
        user1.Email = 'testemail@test.com';
        user1.alias = 'itams';
        user1.TimeZoneSidKey = 'America/New_York';
        user1.LocaleSidKey = 'en_US';
        user1.EmailEncodingKey = 'ISO-8859-1';
        user1.ProfileId = [select id from Profile where Name='DK BMC System Admin'].Id;
        user1.LanguageLocaleKey = 'en_US';
        user1.ManagerId = user.Id;
        user1.UserRoleId = userRole2.Id;
        insert user1;
        
    }
    
    @isTest
    static void flowContTest(){
        User uid = [SELECT id FROM User WHERE UserName='ITAMemail@test.com'];
        User uid2 = [SELECT id FROM User WHERE UserName='ITAMtestemail@test.com'];
        
        Employee__c emp = new Employee__c();
        emp.Name = 'TestEmp';
        emp.Emp_No__c = '1';
        emp.Rank__c = '사원';
        emp.Start__c = System.today();
        emp.User__c = uid.Id;
        insert emp;
        
        Employee__c emp2 = new Employee__c();
        emp2.Name = 'TestEmp2';
        emp2.Emp_No__c = '2';
        emp2.Rank__c = '사원';
        emp2.Start__c = System.today();
        emp2.User__c = uid2.Id;
        insert emp2;
        
        property__c prop = new property__c();
        prop.Name = 'testProp';
        prop.ProductName__c = 'testPropProductName';
        prop.ModelName__c = 'textPropModle';
        prop.largeType__c = 'HardWare';
        prop.ProductType__c = 'OA';
        prop.ProductType_2nd__c ='NB';
        insert prop;
        
        RecordType rt = [select id,Name from RecordType where SobjectType='property_request__c' and Name='교체' Limit 1];
        
        property_request__c pr = new property_request__c();
        pr.realEmp__c = emp2.id;
        pr.requestEmp__c = emp.id;
        pr.status__c= 'createRequest';
        pr.RecordTypeId = rt.id;
        pr.requestRemarks__c = 'test remarks';
        pr.IsResign__c = false;
        pr.returnAsstNum__c = prop.id;
        pr.asstNum__c = prop.id;
        pr.beforeEmp__c = emp.id;
        pr.afterEmp__c = emp2.id;
        pr.Type__c ='하드웨어';
        pr.requestPropType__c = 'OA';
        pr.requestPropType_2nd__c = 'MT';
        insert pr;
        
        //property_request__c
        
        Test.startTest();
        
        system.runAs(uid){
            ITAM_flowController.findReqList('소프트웨어');
            ITAM_flowController.findProcList('NB');
        }
        Test.stopTest();
        
    }
}