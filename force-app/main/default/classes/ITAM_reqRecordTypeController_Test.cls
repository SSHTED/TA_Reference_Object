@isTest
private class ITAM_reqRecordTypeController_Test {

    @testSetup
    static void setup(){
        
    }
    @isTest
    static void getRecordType(){
        ITAM_reqRecordTypeController.getRecordType('property_request__c');
    }
}