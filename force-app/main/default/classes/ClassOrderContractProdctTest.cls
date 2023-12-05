@isTest
private class ClassOrderContractProdctTest {
	
	static Account a;
	static Opportunity__c o;
	static OpportunityProduct__c op;
	static CustomContract__c mc;
	static CustomContract__c c;
	static ContractProduct__c cp;
	static Order__c od;
	static Product__c p; 
	static Date d = Date.newInstance(2015, 12, 12);
 	static{
 	    p = new Product__c(Name='라이선스', depth_two__c='SFDC', depth_three__c='force.com', depth_four__c='GE administrator', price__c=1000);
        insert p;
        
        a = new Account(Name='테스트계정');
        insert a;
        
        o = new Opportunity__c(Name='테스트영업기회', Account__c=a.id);
        insert o;
        
        op = new OpportunityProduct__c(Opportunity__c= o.id ,Product__c=p.id, SalePrice__c=2000, number__c=1);
        insert op;	
        
        mc = new CustomContract__c(Opportunity__c=o.id, Account__c=a.id, ContractStart__c=d, ContractFinish__c=d,RecordTypeId='012280000004nW2');
        insert mc;
 		
 	}

    static testMethod void myUnitTest() 
    {
        // TO DO: implement unit test
        Test.startTest(); 
		c = new CustomContract__c(Opportunity__c=o.id, Account__c=a.id, parent__c=mc.id, ContractStart__c=d, ContractFinish__c=d,RecordTypeId='012280000004nVx');
		insert c;
		
		od = new Order__c(Contract__c=c.id);
		insert od;
		cp = new ContractProduct__c(Contract__c=c.id, Order__c=od.id, Product__c=p.id, supplyPrice__c=1000, number__c=1);
		insert cp;
		od.Confirm__c=TRUE;
		update od;
		
         Test.stopTest();	 
	}
}