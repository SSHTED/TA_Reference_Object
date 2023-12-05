@isTest
private class EmployeeCreate_Test{
    
    static WorkTime__c w;
    static Employee__c e;
    static ProjectResource__c p;
    static Milestone1_Project__c prj; 
    static Project_Assigned_Period__c pa;
    static Account ac; 
    static Employee__c emp;
    
    static{
        ac = new account(Name = 'DKBMC');
        // insert ac;
        
        User u = [SELECT Id FROM User WHERE Name = 'Org Admin' LIMIT 1];
        
        emp = new Employee__c(
            Name = 'TestEmp'
            , Emp_No__c = '13579'
            , Rank__c = '사원'
            , Start__c = System.today()
            , User__c = u.Id
        );
        insert emp;
    }
    
    @isTest
    static void test_method_one(){
        Test.startTest();
        
        e = new Employee__c(
            Emp_No__c = '140001',
            Name = '황병훈',
            Rank__c = '대리',
            Start__c = System.today()
        );
        insert e;
        
        e.Rank__c ='과장';
        //e.Hq__c='기술본부';
        //e.Team__c='CRM솔루션1팀';
        update e;
        
        e.End__c = System.today();
        update e;
        
        update emp;
        
        Test.stopTest();
    }
}