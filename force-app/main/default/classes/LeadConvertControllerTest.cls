@isTest
private class LeadConvertControllerTest {

   

    static lead_custom__c lea, lea2;
    static Opportunity opp;
    static Account acc;
    static Contact cont;
    static list<String> lis;

    static {
        
        
        lea = new lead_custom__c(Name='test',Phone__c='99999999',company__c='BH');
        insert lea;
        
        lea2 = new lead_custom__c(Name='test2',Phone__c='6666666');
        insert lea2;
    
        acc = new Account(Name=lea.company__c, Phone='6666666');
        insert acc;
        
        cont = new Contact(accountid=acc.id, lastName='test', Phone='6666666');
        insert cont;
    }
    
    static testMethod void myUnitTest() {
        system.Test.startTest();
        //lea = new lead_custom__c();
        
        PageReference pag = Page.Lead_Convert;
        system.Test.setCurrentPage(pag);
        Apexpages.currentPage().getParameters().put('id',lea.Id);   
        Apexpages.currentPage().getParameters().put('action','acc');
        LeadConvertController leadcon = new LeadConvertController();
        
        system.Test.stopTest();
    }
    

     static testMethod void myUnitTest2() {
        system.Test.startTest();
        //lea = new lead_custom__c();
        
        PageReference pag = Page.Lead_Convert;
        system.Test.setCurrentPage(pag);
        Apexpages.currentPage().getParameters().put('id',lea.Id);
        Apexpages.currentPage().getParameters().put('action','opp');
        LeadConvertController leadcon = new LeadConvertController();
        
        system.Test.stopTest();
    }
    
      static testMethod void myUnitTest3() {
        system.Test.startTest();
        //lea = new lead_custom__c();
        
        PageReference pag = Page.Lead_Convert;
        system.Test.setCurrentPage(pag);
        Apexpages.currentPage().getParameters().put('id',lea2.Id);
        Apexpages.currentPage().getParameters().put('action','acc');
        Apexpages.currentPage().getParameters().put('action','cont');
        LeadConvertController leadcon = new LeadConvertController();
      
        system.Test.stopTest(); 
    }

    
}