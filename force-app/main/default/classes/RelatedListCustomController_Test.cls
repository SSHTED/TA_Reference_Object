@isTest
private class RelatedListCustomController_Test {

    @testSetup
    static void setup() {
	Case casea = new Case (
		IsEscalated = true
		, OwnerId = System.UserInfo.getUserId()
	);

	insert casea;
    }

    @isTest
    static void testDeleteRecord() {
        Case testCase = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();

        String recordIdList = JSON.serialize(new List<Id>{testCase.Id});
        Map<String, object> result = RelatedListCustomController.deleteRecord(recordIdList);

        Test.stopTest();
        
    }
}