@isTest(SeeAllData = true)
public class TeamStatusMonthClone_TEST {

    static Organization__c org;
    static void testSetUp() {
        List<User> userList =[select id,name,IsActive from User where IsActive  = true];
        System.debug('userList '+userList.size());
       List<Employee__c> empList = [select id ,name from Employee__c];
        System.debug('empList '+empList.size());
        List<Customer_Org__c> customOrgList = [select id ,name from Customer_Org__c];
        System.debug('customOrgList '+ customOrgList.size());
        
        Account acc = new Account(
        	Name='고객사'
        );
        
        insert acc;
        

         org = new Organization__c(
            Name ='CX본부',
            Level__c ='2'
        );
        insert org;
    }
    
    @isTest
    static void testTeamStatusMMBatch(){
        Test.startTest();
        TeamStatusMonthCloneBatch bat = new TeamStatusMonthCloneBatch(); 
		Database.executeBatch(bat, 100);
        Test.stopTest();
    }
}