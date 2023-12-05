global with sharing class PMS_PjtJoinObjAutoCreateButtonController {
    @AuraEnabled
    global static String BatchExecute(Id recordId){
        PMS_PjtManpowerBatch batch = new PMS_PjtManpowerBatch(recordId);
        Database.executeBatch(batch, 1);
        return recordId;
    }
}