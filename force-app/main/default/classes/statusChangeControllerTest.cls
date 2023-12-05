@isTest
private class statusChangeControllerTest {
    
    static testMethod void myUnitTest() {
    
    list<lead_custom__c> lcl = [SELECT id, name, status__c FROM lead_custom__c limit 1];
   
    
 	Test.startTest();
 
  	PageReference myVfPage = Page.StatusChange;
    Test.setCurrentPage(myVfPage);
    ApexPages.StandardsetController sc = new ApexPages.StandardsetController(lcl);
   	StatusChangeController sch = new StatusChangeController(sc);	
   	    sch.getMySelectedSize();
		sch.getMyRecordsSize(); 
		
	Test.stopTest();
        
    
    
}
}