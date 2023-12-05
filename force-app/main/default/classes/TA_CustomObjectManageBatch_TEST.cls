@isTest
public class TA_CustomObjectManageBatch_TEST {
    static TA_CustomObjectManage__c taCom;

    static {
        taCom = new TA_CustomObjectManage__c(
            name = 'Lead'
        );
        insert taCom;
    }
    
    @isTest
    static void myUnitTest() {
        Test.startTest();
        String c1 = '0 0 23 * * ?';
        TA_CustomObjectManageBatchScheduler bat = new TA_CustomObjectManageBatchScheduler(); 
        System.schedule('TEST', c1, bat);
        Test.stopTest();
    }
}