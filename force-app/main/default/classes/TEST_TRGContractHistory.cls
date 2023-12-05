@isTest
private class TEST_TRGContractHistory  {

    static testmethod void test_trigger(){
        
       Account a = new Account(Name = 'Name');
       insert a;
       CustomContract__c c = new CustomContract__c();
       c.name = 'thest';
       c.account__c = a.Id;
       c.ContractStart__c = date.today();
       c.ContractFinish__c = date.today();
       insert c;
       ContractHistory__c ch = new ContractHistory__c();
       ch.Contract__c = c.Id;
       ch.Amount__c=2000;
       ch.TimeLimitOfPayment__c = '30일';
       ch.SalesPurchase__c = '매입';
       
       ch.PublicationDueDate__c=date.today();
       insert ch;
        
       ch.PublicationCheck__c = true;
       ch.PublicationDate__c = date.today();
       update ch;

       delete ch;
    }
    
    static testmethod void test_trigger2(){
        
       Account a = new Account(Name = 'Name');
       insert a;
       CustomContract__c c = new CustomContract__c();
       c.name = 'thest';
       c.account__c = a.Id;
       c.ContractStart__c = date.today();
       c.ContractFinish__c = date.today();
       insert c;
       ContractHistory__c ch = new ContractHistory__c();
       ch.Contract__c = c.Id;
       ch.Amount__c=2000;
       ch.TimeLimitOfPayment__c = '30일';
       ch.SalesPurchase__c = '매출';
       
       ch.PublicationDueDate__c=date.today();
       insert ch;
        
       ch.PublicationCheck__c = true;
       ch.PublicationDate__c = date.today();
       update ch;

       delete ch;
    }

}