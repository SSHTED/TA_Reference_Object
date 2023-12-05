@isTest
public class PM_EvaluationTrigger_TEST {
    static User u;
    static User u2;
    static ProjectResource__c pr;
    static Employee__c emp;
    static User systemUser;
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
        
    }
    
    testMethod static void etTriggerTest() {
        Test.setMock(HttpCalloutMock.class, new BellNotificationMock());
        Test.startTest();
        System.runAs(systemUser) {
            ProjectMember_Evaluation__c pme = new ProjectMember_Evaluation__c();
            pme.ProjectResource__c = pr.Id;
            
            insert pme; 
        }
        
        system.runAs(u2) {
            ProjectMember_Evaluation__c pme2 = new ProjectMember_Evaluation__c();
            pme2.ProjectResource__c = pr.Id;
            
            insert pme2; 
            
            update pme2;
        }
        Test.stopTest();
    }
}