@isTest
private class P_O_Flag_Test {
    static Date d = Date.newInstance(2015, 12, 12);
    
    
    static testMethod void myUnitTest() {
       Opportunity__c opp = new Opportunity__c(name = 'oppt');
       insert opp;
       
       Account a = new Account(Name='test');
       insert a;
       
       Customcontract__c cc = new Customcontract__c(name = 'ccc', account__c=a.id,  ContractStart__c=d, ContractFinish__c=d);
       insert cc;
        
       Product__c prod = new Product__c(
       name = 'prod' ,
       depth_one__c = 'license');
       insert prod;
       
       ContractProduct__c cp = new ContractProduct__c(
       
       contract__c = cc.id,
       product__c = prod.id
       
       );
       
       insert cp;
       
       list <ContractProduct__c> lcp = new list <ContractProduct__c>();
       
        ContractProduct__c cp1 = [SELECT id, name, category__c, P_O_flag__c FROM ContractProduct__c WHERE id =:cp.id];
        cp1.P_O_flag__c = true;
        lcp.add(cp1);
        update lcp;
    }
}