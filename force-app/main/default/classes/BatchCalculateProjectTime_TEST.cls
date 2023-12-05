@isTest
public class BatchCalculateProjectTime_TEST {
    static User u;
    static User u2;
    static User systemUser;
    
    static Employee__c emp;
    static ProjectResource__c pr;
    
    static Milestone1_Project__c msp;
    
    static Milestone1_Milestone__c mm;
    
    static Milestone1_Task__c mt1;
    static Milestone1_Task__c mt2;
    
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
        
        Account acc = new Account();
        acc.Name = 'Test Acc';
        insert acc;
        
        msp = new Milestone1_Project__c();
        msp.endcustomer__c = acc.Id;
        msp.Name = 'Test Project';
        msp.Status__c = 'Active';
        insert msp;
        
        mm = new Milestone1_Milestone__c();
        mm.Name = 'Test Miles';
        mm.Project__c = msp.Id;
        insert mm;
        
        mt1 = new Milestone1_Task__c();
        mt1.Name = 'test1';
        mt1.Project_Milestone__c = mm.Id;
        insert mt1;
        
        mt2 = new Milestone1_Task__c();
        mt2.Name = 'test2';
        mt2.Project_Milestone__c = mm.Id;
        insert mt2;
        
        Project_Assigned_Period__c pap = new Project_Assigned_Period__c();
        pap.Project__c = msp.Id;
        pap.ProjectResource__c = pr.Id;
        pap.PlanedStartDate__c = system.today();
        pap.PlanedEndDate__c = system.today();
        pap.StartDate__c = system.today();
            
        insert pap;
		
        Milestone1_Time__c mtime = new Milestone1_Time__c();
        mtime.Project_Task__c = mt1.Id;
        mtime.Date__c = system.today();
        mtime.Hours__c = 8;
        mtime.Employee__c = emp.Id;
        insert mtime;

        Milestone1_Time__c mtime2 = new Milestone1_Time__c();
        mtime2.Project_Task__c = mt2.Id;
        mtime2.Date__c = system.today();
        mtime2.Hours__c = 8;
        mtime2.Employee__c = emp.Id;
        insert mtime2;
    }
    
    testMethod static void etTriggerTest() {
        Test.startTest();
        System.runAs(systemUser) {
           
            ScheduleCalculateProjectTime sche = new ScheduleCalculateProjectTime();
            Datetime dt = Datetime.now().addSeconds(1);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
            system.schedule('TEST', CRON_EXP, sche); 
            
        }
        
        
        Test.stopTest();
    }
}