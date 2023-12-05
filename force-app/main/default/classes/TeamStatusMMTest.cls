@isTest(SeeAllData = true)
public class TeamStatusMMTest {
    
    static Employee__c emp;
    static Account acc;
    static PMS_Project__c pms_project;
    static PMS_PjtResource__c  pjt_resource;
    static TeamStatusMM__c teamStatus;
    static Organization__c org;
    
    static {
        org = new Organization__c(
            Name ='CX본부',
            Level__c ='2'
        );
        insert org;
		List<Employee__c> empList = [select id ,name from Employee__c where name='차용진'];
        List<Account> accList = [select id ,name from account where name='LG화학'];
        List<PMS_Project__c> PjtManPowerList= [select id ,name from PMS_Project__c where name='엘지화학_엔지니어링Pipeline 관리 시스템 구축' limit 1];
        System.debug('test pjt '+PjtManPowerList[0].Id);
        
        
      
        
        
		teamStatus = new TeamStatusMM__c(
        	TSM_Name__c =empList[0].Id,
            Account__c = accList[0].Id,
            ProjectName__c = PjtManPowerList[0].Id
        ); 
    }

    
    static testMethod void myMethod(){
        Test.startTest();
        insert teamStatus;
        
        Test.stopTest();
    }
}