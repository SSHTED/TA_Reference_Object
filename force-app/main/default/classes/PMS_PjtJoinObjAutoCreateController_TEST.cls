@isTest
global with sharing class PMS_PjtJoinObjAutoCreateController_TEST {
    @isTest
    static void PMS_PjtJoinObjAutoCreateController_TEST() {
        
        PMS_Project__c prj = new PMS_Project__c(
            Name = 'project'
            , OwnerId = System.UserInfo.getUserId()
        );
        insert prj;
        
        Test.startTest();
        
        String result = PMS_PjtJoinObjAutoCreateButtonController.BatchExecute(prj.Id);
        System.assertEquals(prj.Id, result);
            
        // String result = PMS_PjtManpowerBatch.getId(recordId);
        // System.assertEquals(recordId, result);
        Test.stopTest();
    }
}