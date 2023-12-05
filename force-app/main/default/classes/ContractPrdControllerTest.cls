@isTest(SeeAllData=false)
private class ContractPrdControllerTest {

  static CustomContract__c c;
  static ContractProduct__c cp, cp2, cp3;
  static Product__c p, p2, p3;
  static list<ContractProduct__c> cplist;
  static list<Product__c> plist;
  static set<Id> prdid;
  static Account a;
  static Date d = Date.newInstance(2015, 12, 12);
  //static User u;
  //static ApexPages.Controller controller;
  static{
    
    a = new Account(Name = 'test');
    insert a;
    
    c = new CustomContract__c(Name='test',  account__c = a.id,  ContractStart__c=d, ContractFinish__c=d);
    insert c; 
  
    p = new Product__c(depth_one__c='License', depth_two__c='SFDC', depth_three__c='force.com', depth_four__c='UE Unlimted Application' , Name='force.com UE Unlimted Application');
    insert p;
    plist = new list<Product__c>();
    plist.add(p);
    prdid = new set<Id>();
    prdid.add(p.id);  
    
    p2 = new Product__c(depth_one__c='용역', depth_two__c='개발');
    insert p2;
    plist.add(p2);
    prdid.add(p2.id);
    
    p3 = new Product__c(depth_one__c='License', depth_two__c='SFDC', depth_three__c='Chatter');
    insert p3;
    plist.add(p3);
    prdid.add(p3.id);
    
    cp = new ContractProduct__c(contract__c=c.id, product__c=p.id, supplyPrice__c=1000, number__c=10);
    insert cp;
    
    cp2 = new ContractProduct__c(contract__c=c.id, product__c=p2.id, supplyPrice__c=2000, number__c=10);
    insert cp2;
    
    cp3 = new ContractProduct__c(contract__c=c.id, product__c=p3.id, supplyPrice__c=3000, number__c=10);
    insert cp3;
      
  }
   
    static testMethod void myUnitTest() {
      
        // TO DO: implement unit test
       Test.startTest(); 
           PageReference pg = Page.PrdList;
           Test.setCurrentPage(pg); 
           Apexpages.currentPage().getParameters().put('cid', c.id); 
           
           
           ContractPrdController cprdc  = new ContractPrdController();
           cprdc.prd.depth_one__c = 'License';
           cprdc.prd.depth_two__c = 'SFDC'; 
           cprdc.prd.depth_three__c='force.com';
           cprdc.prd.depth_four__c='UE Unlimted Application';
           cprdc.prd.Name='force.com UE Unlimted Application';
           //prdc.prd.Id='a0eO0000003NswM';
           cprdc.selectedid = p.id;
           cprdc.plist.add(p); 
           //prdc.plist.add(p2);
           //prdc.plist.add(p3);
           
           cprdc.cprd.product__c = p.id;
           cprdc.cprd.contract__c = c.id;
           cprdc.cprd.supplyPrice__c = 0;
           cprdc.cprd.number__c = 0;
           cprdc.cplist.add(cp);
           //prdc.oplist.add(op2);
           //prdc.oplist.add(op3);
         	cprdc.deletedid = cp.product__c;
             
           cprdc.getProductList();
           cprdc.selectProduct();
           cprdc.deleteProduct();
           cprdc.listSave();
           cprdc.cancel();   
    Test.Stoptest();
    }     
}