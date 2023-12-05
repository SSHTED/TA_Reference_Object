@isTest
public class ITAM_propertyTriggerHandler_Test {
    static TriggerSetting__c ts;
    static User user;
    static User user1;
    static Employee__c emp1;
    static Employee__c emp2;
    static property__c addProperty1;
    static property__c addProperty2; 
    static RecordType rt;
    static property_request__c pr1;
    static property_request__c pr2;
    
    
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
            user = new User();
            user.Username ='ITAMtestemail@test.com';
            user.LastName = 'ITAMLastTestName';
            user.Email = 'testemail@test.com';
            user.alias = 'itam';
            user.TimeZoneSidKey = 'America/New_York';
            user.LocaleSidKey = 'en_US';
            user.EmailEncodingKey = 'ISO-8859-1';
            user.ProfileId = [select id from Profile where Name='DK BMC System Admin'].Id;
            user.LanguageLocaleKey = 'en_US';
            insert user;
            
            user1 = new User();
            user1.Username ='ITAMemail@test.com';
            user1.LastName = 'ITAMLastTestName';
            user1.Email = 'testemail@test.com';
            user1.alias = 'itams';
            user1.TimeZoneSidKey = 'America/New_York';
            user1.LocaleSidKey = 'en_US';
            user1.EmailEncodingKey = 'ISO-8859-1';
            user1.ProfileId = [select id from Profile where Name='DK BMC System Admin'].Id;
            user1.LanguageLocaleKey = 'en_US';
            insert user1;
            
            emp1 = new Employee__c();
            emp1.Name = 'TestEmp';
            emp1.Emp_No__c = '1';
            emp1.Rank__c = '사원';
            emp1.Start__c = System.today();
            emp1.User__c = user.Id;
            insert emp1;
            
            emp2 = new Employee__c();
            emp2.Name = 'TestEmp2';
            emp2.Emp_No__c = '2';
            emp2.Rank__c = '사원';
            emp2.Start__c = System.today();
            emp2.User__c = user1.Id;
            insert emp2;
            
            addProperty1 = new property__c();
            addProperty1.Name = 'testProp';
            addProperty1.ProductName__c = 'testPropProductName';
            addProperty1.ModelName__c = 'textPropModle';
            addProperty1.ReceivingDate__c = System.today();
            insert addProperty1;
            
            addProperty2 = new property__c();
            addProperty2.Name = 'userChangeProp';
            addProperty2.ProductName__c = 'userChangePropProdName';
            addProperty2.ModelName__c = 'userChangePropModel';
            addProperty2.RealEmp__c =emp2.Id;
            
            insert addProperty2;
            
            rt = [select id,Name from RecordType where SobjectType='property_request__c' and Name='교체' Limit 1];
            
            pr1 = new property_request__c();
            pr1.realEmp__c = emp2.id;
            pr1.requestEmp__c = emp1.id;
            pr1.status__c= 'createRequest';
            pr1.RecordTypeId = rt.id;
            pr1.requestRemarks__c = 'test remarks';
            pr1.IsResign__c = false;
            pr1.returnAsstNum__c = addProperty1.id;
            pr1.asstNum__c = addProperty1.id;
            pr1.beforeEmp__c = emp1.id;
            pr1.afterEmp__c = emp2.id;
            pr1.Type__c ='하드웨어';
            pr1.requestPropType__c = 'OA';
            pr1.requestPropType_2nd__c = 'MT';
            pr1.Name='testPr';
            insert pr1;
            
            pr2 = new property_request__c();
            pr2.realEmp__c = emp2.id;
            pr2.requestEmp__c = emp2.id;
            pr2.status__c= 'createRequest';
            pr2.RecordTypeId = rt.id;
            pr2.requestRemarks__c = 'test remarks';
            pr2.IsResign__c = false;
            pr2.returnAsstNum__c = addProperty1.id;
            pr2.asstNum__c = addProperty1.id;
            pr2.beforeEmp__c = emp1.id;
            pr2.afterEmp__c = emp2.id;
            pr2.Type__c ='하드웨어';
            pr2.requestPropType__c = 'OA';
            pr2.requestPropType_2nd__c = 'MT';
            pr2.Name='testPr2';
            insert pr2;
            
        }
    }
    static testMethod void myTest1() {
        Test.startTest();
        	addProperty1.RealEmp__c=emp1.id;
        	addProperty1.GiveDate__c = System.today();
        	update addProperty1;
        	addProperty1.RealEmp__c= null;
        	addProperty1.GiveDate__c= null;
        	update addProperty1;
        	delete addProperty1;
        Test.stopTest();
    }
}