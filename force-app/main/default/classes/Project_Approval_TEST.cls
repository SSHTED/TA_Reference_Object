@isTest
public class Project_Approval_TEST {
	static User u;
    static User u2;
    static User u3;
    static User u4;
    static ProjectResource__c pr;
    static Employee__c emp;
    static User systemUser;
    static Account acc;
    static Milestone1_Project__c msp;
    static {
        systemUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = '황병훈',
            Email = 'test31213@dkbmc.com',
            Username = 'test32113@dkbmc.com' + System.currentTimeMillis(),
            CompanyName = 'dkbmc',
            EmployeeNumber='1444111',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'Asia/Seoul',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'

        );
        insert u;
        
        u2 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = '문주하',
            Email = 'test3121@dkbmc.com',
            Username = 'test3211@dkbmc.com' + System.currentTimeMillis(),
            CompanyName = 'dkbmc',
            EmployeeNumber='1214552',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'Asia/Seoul',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ManagerId = u.Id
        );
        insert u2;
        
        u3 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = '관리자1',
            Email = 'test12@dkbmc.com',
            Username = 'test12@dkbmc.com' + System.currentTimeMillis(),
            CompanyName = 'dkbmc',
            EmployeeNumber='120002',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'Asia/Seoul',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'

        );
        insert u3;
        
        u4 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = '관리자2',
            Email = 'test34@dkbmc.com',
            Username = 'test343@dkbmc.com' + System.currentTimeMillis(),
            CompanyName = 'dkbmc',
            EmployeeNumber='100001',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'Asia/Seoul',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u4;
        
        
        emp = new Employee__c(
			Emp_No__c = '1214552',     
            Name = '문주하',
            Rank__c = '대리',
            Start__c = system.today()
        );
        insert emp;
        
        pr = new ProjectResource__c(
        	Type__c = 'DKBMC 직원',
            ResourceName__c = '문주하',
            Employee__c = emp.Id
        );
        insert pr;
        
        acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
        
        msp = new Milestone1_Project__c();
        msp.endcustomer__c = acc.Id;
        msp.Name = 'Test Project';
        msp.Status__c = 'Active';
        insert msp;
        
        ProjectMember_Evaluation__c pme = new ProjectMember_Evaluation__c();
        pme.ProjectResource__c = pr.Id;
        pme.Project__c = msp.Id;
        insert pme; 
        
        
        
    }
    
    testMethod static void etTriggerTest() {
        Test.setMock(HttpCalloutMock.class, new BellNotificationMock());
        Test.startTest();
        System.runAs(systemUser) {
            
            msp.Approval_Status__c = '제출';
            update msp;
            
            msp.Approval_Status__c = '승인';
            update msp;
        }
        
       
        Test.stopTest();
    }
}