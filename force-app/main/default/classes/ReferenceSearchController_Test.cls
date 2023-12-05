@isTest
public class ReferenceSearchController_Test {
    
    // 테스트 데이터 정의
    static ObjectReference__c objectreference;
    static Associated_Objects_Reference__c associatedObj;

    @testSetup 
    static void setup() {
        // objectreference 객체 생성 및 필드 설정
        objectreference = new ObjectReference__c (
            Api_Version__c = 6,
            Description__c = 'Test5',
            Docs_Link__c = 'www.aaa6.com',
            Eng_Label__c = 'Test6',
            ExternalId__c = 'Test9',
            Kor_Label__c = 'Test4',
            Memo__c = 'Test8',
            Name = 'Test9',
            OwnerId = System.UserInfo.getUserId(),
            Remove__c = true,
            Special_Access_Rules__c = 'Test8',
            Supported_Calls__c = 'create()',
            Supported_Calls_Description__c = 'Test8',
            Usage__c = 'Test10'
        );
        insert objectreference;
        
        // associatedObj 객체 생성 및 필드 설정
        associatedObj = new Associated_Objects_Reference__c (
            //조회관계
            Object_Reference__c = objectreference.Id,
            OwnerId = System.UserInfo.getUserId()
        );
        insert associatedObj;
    }

    @isTest 
    static void testGetInit() {
        
        Test.startTest();
        Map<String, Object> result = ReferenceSearchController.getInit();
        Test.stopTest();

        System.assert(result != null, '결과가 null이 아니어야 합니다.');

    }
    
    @isTest 
    static void testGetDataByFilter() {
    	String filterGroup = '{"ApiVersion": "6", "Description": "Test5", "Memo": "Test8", "key": "TestKey"}';
        
        Test.startTest();
        Map<String, Object> result = ReferenceSearchController.getDataByFilter(filterGroup);
        Test.stopTest();

        System.assert(result != null, '결과가 null이 아니어야 합니다.');

    }
    
    @isTest 
    static void testGetSoslQueryStr() {
        Map<String, Object> filterMap = new Map<String, Object>();
        Map<String, String> soslFilterMap = new Map<String, String>();

        filterMap.put('Description', 'Test5');
        filterMap.put('Memo', 'Test8');
        filterMap.put('SpecialAccessRules', 'Test8');  
        filterMap.put('SupportedCallsDescription', 'Test8');
        filterMap.put('Usage', 'Test10');  
        
        // 메서드 호출하여 SOSL 쿼리 문자열 가져오기
        String soslQuery = ReferenceSearchController.getSoslQueryStr(filterMap, soslFilterMap);

        // 예상되는 SOSL 쿼리 문자열 정의
		String expectedQuery = '*Test5*, *Test8*, *Test8*, *Test8*, *Test10*';

        System.assert(soslQuery != null, 'SOSL 쿼리가 null이 아니어야 합니다.');
        System.assertEquals(expectedQuery, soslQuery, 'SOSL 쿼리가 예상된 값과 일치하지 않습니다.');
    }

    @isTest 
    static void testGetSoqlWhereQuery() {
        // 필터맵을 만듭니다. 이 예제에서는 여러 케이스를 테스트합니다.
        Map<String, Object> filterMap = new Map<String, Object>{
            'Name' => 'Test9',
            'EngLabel' => 'Test6',
            'KorLabel' => 'Test4',
            'ApiVersion' => '6',
            'ApiVersionType' => 'before',
            'SupportedCalls' => 'create()',
            'Remove' => 'true',
            'DocsLink' => 'www.aaa6.com'
        };
        
        Test.startTest();
        String whereQuery = ReferenceSearchController.getSoqlWhereQuery(filterMap);
        Test.stopTest();

        System.assert(whereQuery != null, 'SOQL WHERE 절이 null이 아니어야 합니다.');
    }
    
    @isTest 
    static void testGetWhereQueryForSoslId() {
        
        List<ObjectReference__c> testRecords = [SELECT Id, Name, Eng_Label__c, Kor_Label__c, Description__c, Memo__c FROM ObjectReference__c];
        System.debug('Number of test records: ' + testRecords.size());
        System.debug('testRecords: ' + testRecords);
        

        String query = 'FIND \'Test9\' IN ALL FIELDS RETURNING ObjectReference__c (Id)';
        
        Map<String, String> soslFilterMap = new Map<String, String>{
            'Description__c' => 'Test5'
        };

        Test.startTest();
        String whereQuery = ReferenceSearchController.getWhereQueryForSoslId(query, soslFilterMap);
        Test.stopTest();

        System.debug('Generated whereQuery: ' + whereQuery);
        System.assert(whereQuery != null, 'SOSL WHERE 절이 null이 아니어야 합니다.');
    }
    
    @isTest 
    static void testGetRefinedResultList() {
        // SOQL 쿼리를 사용하여 테스트 레코드 목록 검색
        List<ObjectReference__c> testRecords = [SELECT Id, Name, Eng_Label__c, Kor_Label__c FROM ObjectReference__c];
    
        Map<String, String> soslFilterMap = new Map<String, String>{
            'Name' => 'Test1',
            'Eng_Label__c' => 'EngTest1',
            'Kor_Label__c' => 'KorTest1'
        };
    
        Test.startTest();
        List<ObjectReference__c> refinedList = ReferenceSearchController.getRefinedResultList(testRecords, soslFilterMap);
        Test.stopTest();
        
        System.assert(refinedList != null, '정제된 목록이 null이 아니어야 합니다.');

    }
    
    @isTest 
    static void testGetSoslForm() {
        Test.startTest();
        String soslForm = ReferenceSearchController.getSoslForm();
        Test.stopTest();
        
        System.assert(soslForm != null, 'SOSL 형식이 null이 아니어야 합니다.');

    }
}