@isTest
public class TestDeviceRentalTrigger_TEST {
    
    static TestDeviceRental__c ta;
    
    static {
        ta = new TestDeviceRental__c(
            //TA_Title__c ='test'
        );
    }
    
    static testMethod void mymethod(){
        Test.startTest();
        insert ta;
        ta.Status__c ='신청';
        update ta;
        Test.stopTest();
    }
}