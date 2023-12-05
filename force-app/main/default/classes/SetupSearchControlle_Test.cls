@isTest
public class SetupSearchControlle_Test {
	static Setup_Reference__c setup_reference;

    @testSetup 
    static void setupTestData() {
        // 부모 레코드 생성
        Setup_Reference__c parentReference = new Setup_Reference__c(
            Description__c = 'Tset2'
            , Detail__c = 'Tset1'
            , Docs_Link__c = 'www.aaa9.com'
            , External_ID__c = 'Tset6'
            , Kor_Label__c = 'Tset10'
            , Level__c = 'Tset5'
            , Name = 'Tset7'
            , OwnerId = System.UserInfo.getUserId()
            , Sort_Num__c = '1'
            , Status__c = '초안'
        );
        insert parentReference;
        
        setup_reference = new Setup_Reference__c (
            Description__c = 'Tset4',
            Detail__c = 'Tset5',
            Docs_Link__c = 'www.aaa6.com',
            External_ID__c = 'Tset7',
            Kor_Label__c = 'Tset2',
            Level__c = 'Tset8',
            Name = 'Tset9',
            OwnerId = System.UserInfo.getUserId(),
            Parent_Setup__c = parentReference.Id,
            Sort_Num__c = '3',
            Status__c = '초안'
        );
        insert setup_reference;
    }
    
    @isTest 
    static void testGetInit() {
        Test.startTest();
        Map<String, Object> result = SetupSearchController.getInit();
        Test.stopTest();
    }
    
    @isTest 
    static void testGetDataByFilter() {
        List<Setup_Reference__c> srList = [SELECT Id, Name, Kor_Label__c, Status__c FROM Setup_Reference__c];
        System.assert(srList.size() > 0, 'Setup Reference records X');
        
        Test.startTest();
        
        Map<String, Object> filterMap = new Map<String, Object>{
            'name' => srList[0].Name,
            'korLabel' => srList[0].Kor_Label__c,
            'parentName' => '',
            'status' => srList[0].Status__c,
            'keyWord' => 'Tset'
        };
        
        Map<String, Object> result = SetupSearchController.getDataByFilter(JSON.serialize(filterMap));
        
        Test.stopTest();
    }
}