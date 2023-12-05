@isTest
public class TA_SupportTrigger_Test {
	
    static TA_TechnicalSupport__c ta;
    
    static {
		ta = new TA_TechnicalSupport__c(
        	TA_Title__c ='test'
        );
    }
    
    static testMethod void mymethod(){
        Test.startTest();
        insert ta;
        ta.TA_Status__c ='처리 완료';
        update ta;
        Test.stopTest();
    }
}