@isTest // (SeeAllData = true)
private class EmployeeToPermissionSetController_TEST{

	static Employee__c emp;
    static User u;
    
    static{
		u = [SELECT Id FROM User WHERE Name = 'Org Admin' LIMIT 1];

        emp = new Employee__c(
            Name = 'TestEmp'
            , Emp_No__c = '1123123123'
            , Rank__c = '사원'
            , Start__c = System.today()
            , User__c = u.Id
        );
        insert emp;
    }

	@isTest
	static void myTest01(){
		Test.startTest();

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