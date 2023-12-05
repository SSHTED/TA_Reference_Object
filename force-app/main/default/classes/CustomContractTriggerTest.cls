@isTest
private class CustomContractTriggerTest 
{
    static testMethod void Timestamper() {
        
        test.startTest();
        Account a = new Account (name = 'tester22' );
        
        insert a;
        
        CustomContract__c c = new CustomContract__c (name = 'tester',contract_price__c='1234',Category__c='신규',account__c=a.id,ContractStart__c=Date.today() , ContractFinish__c=Date.today()+10);
        insert c; 
        c = [select name, contract_price__c,Clone_ContractPrice__c from CustomContract__c];
        system.debug('insert '+ c );
        c.contract_price__c='6666';
        update c;
        system.debug('update '+ c );
        test.stopTest();
    }
}