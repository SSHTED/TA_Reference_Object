@isTest
private class UTIL_BatchLog_TEST {
   
    static testMethod void myUnitTest() {
        
        String BatchName = 'HDC_AS_HistoryBatch';

        Test.startTest();

        Organization OrgInfo = UTIL_BatchLog.getOrganizationInfo();
        UTIL_BatchLog.startLog(BatchName, OrgInfo);
        UTIL_BatchLog.finishLog('', 0, 0, 0, 0, 0, 0, '');
        UTIL_BatchLog.getOrganizationInfo();

        Test.stopTest();
    }
}