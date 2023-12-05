@isTest
private class ITAM_reqChangeController_Test {
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
        user.ProfileId = [select id from Profile where Name='System Administrator'].Id;
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
        user1.ProfileId = [select id from Profile where Name='System Administrator'].Id;
        user1.LanguageLocaleKey = 'en_US';
        user1.ManagerId = user.Id;
        user1.UserRoleId = userRole2.Id;
        insert user1;
        
        
        
    }
    @isTest
    static void reqChangeCont(){
        
        User uid = [SELECT id FROM User WHERE UserName='ITAMemail@test.com'];
        
        Employee__c emp = new Employee__c();
        emp.Name = 'TestEmp';
        emp.Emp_No__c = '1';
        emp.Rank__c = '사원';
        emp.Start__c = System.today();
        emp.User__c = uid.Id;
        insert emp;
        
        property__c prop = new property__c();
        prop.Name = 'testProp';
        prop.RealEmp__c = emp.Id;
        insert prop;
        
        //Employee__c emp1 = [SELECT id FROM Employee__c WHERE Name= 'TestEmp'];
        //property__c prop1 = [SELECT id FROM property__c WHERE Name = 'testProp'];
		        
        
        Test.startTest();
        system.runAs(uid){
            ITAM_reqChangeController.getEmpId();
            ITAM_reqChangeController.getRecord(uid.Id);
            ITAM_reqChangeController.getRecord(emp.Id);
            ITAM_reqChangeController.getRecord(prop.Id);
            ITAM_reqChangeController.getApprovalManager(emp.Id);
        }
        
        
        test.stopTest();
    }
}