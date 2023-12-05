@isTest
public class Mobile_TimeControllerTest {
    Static User ur;
    static Employee__c e;
    static Account ac;
    static Milestone1_Project__c pr;
    static Project_Assigned_Period__c pap;
    static ProjectResource__c prc;
    static Milestone1_Milestone__c mm;
    static Milestone1_Task__c mtask;
    static Milestone1_Time__c mtime;
    
    static Date to_Date;
    static{
        to_Date = Date.today();
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        ur =  new User(Alias = 'tUser', Email='testUser@dkbmc.com',
                                EmailEncodingKey='UTF-8', LastName='dkbmc', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', ProfileId = adminProfile.id,
                                TimeZoneSidKey='Asia/Seoul', UserName='testUser123@dkbmc.com',EmployeeNumber='111111',title='사원',department='기술본부',division='개발팀'
		);
        insert ur;
        e = new Employee__c(Emp_No__c='111111',Name='테스트',Rank__c='사원',Start__c=to_Date,HQ__c='기술본부',Team__c='개발팀');
        ac = new Account(name = 'testAccount');
 		pr = new Milestone1_Project__c(name='대한항공 B2B 프로젝트', endcustomer__c=ac.Id, Status__c='active',Kickoff__c=to_Date);
        //mtime = new Milestone1_Time__c(Project_Task__c= mtask.Id);
        
    }
    
    @isTest static void insertMobileTime1(){
        //page connect
        PageReference pref = Page.Mobile_Time_Insert;
        Test.setCurrentPageReference(pref);
        System.runAs(ur){
            insert e;
            insert ac;
            insert pr;
            prc = new ProjectResource__c (Type__c='프로젝트 자원', ResourceName__c='테스트',Employee__c=e.id);
            insert prc;
            pap = new Project_Assigned_Period__c(Project__c=pr.Id,ProjectResource__c =prc.Id,PlanedEndDate__c=Date.valueOf('2018-12-31'),Employee__c=e.id);
            insert pap;
            mm = new Milestone1_Milestone__c(name='Fit&Gap 분석',Project__c=pr.Id);
            insert mm;
            mtask = new Milestone1_Task__c(name='프로세스 정리',Project_Milestone__c=mm.Id);
            insert mtask;

            
            Test.startTest(); 
            Mobile_TimeController tc = new Mobile_TimeController();
            Mobile_TimeController.getDataItem(String.valueOf(to_Date));     
            
            Map<String,String> insertMap = new Map<String,String>();
            List<String> stringList = new List<String>();
            //new time
            insertMap.put('timeId', '');
            insertMap.put('taskId', mtask.id);
            insertMap.put('dueDate', String.valueOf(to_Date));
            insertMap.put('hours', '5');
            insertMap.put('description', 'test description');
            
            String jsonMap = JSON.serialize(insertMap);
            stringList.add(jsonMap);
            Mobile_TimeController.insertDailyTask(stringList);   
            Test.stopTest();
        }
    }
    
    @isTest static void insertMobileTime2(){
        //page connect
        PageReference pref = Page.Mobile_Time_Insert;
        Test.setCurrentPageReference(pref);
        System.runAs(ur){
            insert e;
            insert ac;
            insert pr;
            prc = new ProjectResource__c (Type__c='프로젝트 자원', ResourceName__c='테스트',Employee__c=e.id);
            insert prc;
            pap = new Project_Assigned_Period__c(Project__c=pr.Id,ProjectResource__c =prc.Id,PlanedEndDate__c=Date.valueOf('2018-12-31'),Employee__c=e.id);
            insert pap;
            mm = new Milestone1_Milestone__c(name='Fit&Gap 분석',Project__c=pr.Id);
            insert mm;
            mtask = new Milestone1_Task__c(name='프로세스 정리',Project_Milestone__c=mm.Id);
            insert mtask;
            mtime = new Milestone1_Time__c(Project_Task__c=mtask.Id, Description__c='test description', Hours__c= 4, Date__c = to_Date);           
			insert mtime;
            
            Test.startTest(); 
            Mobile_TimeController tc = new Mobile_TimeController();
            Mobile_TimeController.getDataItem(String.valueOf(to_Date));     
            
            Map<String,String> insertMap = new Map<String,String>();
            List<String> stringList = new List<String>();
            
            insertMap.put('timeId', mtime.Id);
            insertMap.put('taskId', mtask.id);
            insertMap.put('dueDate', String.valueOf(to_Date));
            insertMap.put('hours', '5');
            insertMap.put('description', 'test description');
            
            String jsonMap = JSON.serialize(insertMap);
            stringList.add(jsonMap);
            Mobile_TimeController.insertDailyTask(stringList);   
            Test.stopTest();
        }
    }
}