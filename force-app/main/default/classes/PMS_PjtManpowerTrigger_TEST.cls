@isTest
private class PMS_PjtManpowerTrigger_TEST {
    static Employee__c employee;
    static PMS_PjtResource__c pms_pjtresource;
	static PMS_Project__c pms_project;
	static PMS_PjtManpower__c pms_pjtmanpower;
	static TriggerSetting__c ts;
    static Organization__c org;
    static User u;
    static User u2;
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
        
        employee = new Employee__c (
            Name = '차용진'
            , Emp_No__c = '111'
            , Rank__c = '인턴'
            , Start__c = System.today()
            ,  User__c = u.Id
            , Email__c = 'hojae.lee@dkbmc.com'
            , OrganizationId__c = org.Id
        );
    
        insert employee;
        

        pms_pjtresource = new PMS_PjtResource__c (
            IsActive__c = true
            , OwnerId = System.UserInfo.getUserId()
            , EmployeeId__c = employee.Id            
            , ResourceType__c = '직원'
        );
    
        insert pms_pjtresource;
    
        pms_project = new PMS_Project__c (
            Name = 'project'
            , OwnerId = System.UserInfo.getUserId()
        );
    
        insert pms_project;

		System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
			pms_pjtmanpower = new PMS_PjtManpower__c(
            	PjtResourceId__c = pms_pjtresource.Id
				, ProjectId__c = pms_project.Id,
                JoinHQ__c = org.Id
            );
			insert pms_pjtmanpower;
		}
	}

    static testMethod void myTest1() {
        Test.startTest();

        System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
            //pms_pjtmanpower.Name = 'Name modified';
        	update pms_pjtmanpower;
        }

        Test.stopTest();
    }

    static testMethod void myTest2() {
        Test.startTest();

        delete pms_pjtmanpower;

        Test.stopTest();
    }
}