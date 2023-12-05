public class ReferenceSearch {
    /**
     * init
     */
    @RemoteAction
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getInit() {
    // public static void getInit() {
        Map<String, Object> resultMap = new Map<String, Object>();
        Map<String, Object> valueMap = new Map<String, Object>();

        try {
            // 필터 적용할 필드 목록 가져오기
            List<Schema.SObjectField> fieldList = getFilterList();
            // Supported Calls 목록 가져오기
            Set<String> callList = getSupportedCallsList();
    
            // reference 전체데이터 가져오기
            List<ObjectReference__c> refAllData = getRefAllData();
    
            valueMap.put('fieldList', fieldList);
            valueMap.put('callList', callList);
            valueMap.put('refAllData', refAllData);

            resultMap.put('result', valueMap);
            resultMap.put('success', true);
        } catch (Exception e) {
            resultMap.put('success', false);
            System.debug('오류를 확인하세요 >>>>>>>>>>>>> ' + e.getMessage());
        }

        return resultMap;
    }

    // 필터 적용할 필드 목록 가져오기
    private static List<Schema.SObjectField> getFilterList() {
    // public void getFilterList() {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('ObjectReference__c');
        Map<String, Schema.SObjectField> fieldMap = targetType.getDescribe().fields.getMap();

        return fieldMap.values();
    }

    // Supported Calls 목록 가져오기
    private static Set<String> getSupportedCallsList() {
    // public void getSupportedCallsList() {
        Set<String> uniqueCalls = new Set<String>();
        
        List<ObjectReference__c> queryResult = [select Supported_Calls__c from ObjectReference__c];
        for(ObjectReference__c supportedCalls: queryResult){
            if(supportedCalls.Supported_Calls__c != null){
                List<String> callList = supportedCalls.Supported_Calls__c.split(';');
                for(String call : callList){
                    uniqueCalls.add(call);
                }
            }
        }
        return uniqueCalls;
    }

    // reference 전체데이터 가져오기
    private static List<ObjectReference__c> getRefAllData() {
    // public void getRefAllData() {
        List<ObjectReference__c> queryResult = [select Id, Name, Eng_Label__c, Kor_Label__c, Api_Version__c, Description__c, Supported_Calls__c, Special_Access_Rules__c, Usage__c, Docs_Link__c, Memo__c, Remove__c, Supported_Calls_Description__c from ObjectReference__c];
        return queryResult;
    }

    // 필터 적용한 데이터 가져오기
    @RemoteAction
    @AuraEnabled
    public static Map<String, Object> getDataByFilter(String filterGroup) {
    // public void getDataByFilter(String filterGroup) {
        // {"Name":"ahn","EngLabel":"jongmin"}
        Map<String, Object> resultMap = new Map<String, Object>();
        Map<String, Object> filterMap = (Map<String, Object>)JSON.deserializeUntyped(filterGroup);
        List<ObjectReference__c> queryResultList = new List<ObjectReference__c>();
        Map<String, String> soslFilterMap = new Map<String, String>(); // sosl로 가져와야하는 목록

        String query = '';
        Boolean isSosl = false;

        try {
            System.debug('filterMap >>>>>>>>>>> ' + filterMap);
            // [1] sosl 적용시켜야하는 필드가 있는 경우를 먼저 체크
            query += getSoslQueryStr(filterMap, soslFilterMap);

            // [2] query 변수가 비어있으면 soql 형식의, 비어있지 않으면 sosl 형식의 query form 가져오기
            if(query == ''){
                query = getSoqlForm();
            } else {
                query = 'FIND \'' + query + '\' ' + getSoslForm();
                isSosl = true;
            }
            
            // [3] sosl 체크가 끝나면 soql 적용할 필드 체크sl 체크가 끝나면 soql 적용할 필드 체크
            query += getSoqlQueryStr(filterMap);
            
            // [4] 버전 존재여부에 따라 order by 값 넣기
            if(String.isNotEmpty(nullToString(filterMap.get('ApiVersion')))){
                query += ' order by Api_Version__c, name ';
            } else {
                query += ' order by name ';
            }

            // [5] sosl 일 때 쿼리 마지막에 close
            if(isSosl == true){
                query += ' ) ';
            }
            
            // [6] soql, sosl 형식에 따라 쿼리 수행
            queryResultList = getQueryResultList(isSosl, query, soslFilterMap);
            System.debug('queryResultList.size >>>>>>>>>>>>> ' + queryResultList.size());
            
            resultMap.put('result', queryResultList);
            resultMap.put('success', true);

        } catch (Exception e) {
            resultMap.put('success', false);
            System.debug('getDataByFilter 오류를 확인하세요 >>>>>>>>>>>>> ' + e.getMessage());
        }
        
        return resultMap;
    }

    // [1] sosl 적용시켜야하는 필드가 있는 경우를 먼저 체크
    private static String getSoslQueryStr(Map<String, Object> filterMap, Map<String, String> soslFilterMap){
        String query = '';
        Map<String, String> tempMap = new Map<String, String>();

        // Description
        String description = nullToString(filterMap.get('Description'));
        if(String.isNotEmpty(description)) {
            query += description;

            soslFilterMap.put('Description__c', description);
        }
        // Memo
        String memo = nullToString(filterMap.get('Memo'));
        if(String.isNotEmpty(memo)) {
            if(query == ''){
                query += memo;
            } else {
                query += ', ' + memo;
            }

            soslFilterMap.put('Memo__c', memo);
        }
        // Special Access Rules
        String sar = nullToString(filterMap.get('SpecialAccessRules'));
        if(String.isNotEmpty(sar)) {
            if(query == ''){
                query += sar;
            } else {
                query += ', ' + sar;
            }

            soslFilterMap.put('Special_Access_Rules__c', sar);
        }
        // Supported Calls Description
        String scd = nullToString(filterMap.get('SupportedCallsDescription'));
        if(String.isNotEmpty(scd)) {
            if(query == ''){
                query += scd;
            } else {
                query += ', ' + scd;
            }

            soslFilterMap.put('Supported_Calls_Description__c', scd);
        }
        // Usage
        String usage = nullToString(filterMap.get('Usage'));
        if(String.isNotEmpty(usage)) {
            if(query == ''){
                query += usage;
            } else {
                query += ', ' + usage;
            }

            soslFilterMap.put('Usage__c', usage);
        }

        return query;
    }
    
    // [3] sosl 체크가 끝나면 soql 적용할 필드 체크
    private static String getSoqlQueryStr(Map<String, Object> filterMap){
        String query = '';

        // Name
        String name = nullToString(filterMap.get('Name'));
        if(String.isNotEmpty(name)) {
            query += ' and Name like \'%' + name + '%\' ';
        }
        // Eng Label
        String engLabel = nullToString(filterMap.get('EngLabel'));
        if(String.isNotEmpty(engLabel)) {
            query += ' and Eng_Label__c like \'%' + engLabel + '%\' ';
        }
        // Kor Label
        String korLabel = nullToString(filterMap.get('KorLabel'));
        if(String.isNotEmpty(korLabel)) {
            query += ' and Kor_Label__c like \'%' + korLabel + '%\' ';
        }
        // Api Version
        String apiVersion = nullToString(filterMap.get('ApiVersion'));
        if(String.isNotEmpty(apiVersion)) {
            query += ' and (Api_Version__c <= ' + apiVersion + ' or Api_Version__c = null) ';
        }
        // Supported Calls
        String supportedCalls = nullToString(filterMap.get('SupportedCalls'));
        if(String.isNotEmpty(supportedCalls)) {
            query += ' and Supported_Calls__c includes (\'' + supportedCalls + '\') ';
        }
        // Remove
        String remove = nullToString(filterMap.get('Remove'));
        if(String.isNotEmpty(remove)) {
            query += ' and Remove__c = ' + remove + ' ';
        }
        // Docs Link
        String docsLink = nullToString(filterMap.get('DocsLink'));
        if(String.isNotEmpty(docsLink)) {
            query += ' and Docs_Link__c like \'%' + docsLink + '%\' ';
        }
        
        return query;
    }

    // [5] soql, sosl 형식에 따라 쿼리 수행
    private static List<ObjectReference__c> getQueryResultList(Boolean isSosl, String query, Map<String, String> soslFilterMap){
        List<ObjectReference__c> queryResultList = new List<ObjectReference__c>();
        
        try {
            if(isSosl == true){
                List<List<SObject>> querySoslResultList = Search.query(query);
                for(List<ObjectReference__c> recordList : querySoslResultList){
                    queryResultList = getRefinedResultList(recordList, soslFilterMap);
                }
            } else {
                queryResultList = Database.query(query);
            }
        } catch (QueryException e) {
            System.debug('getQueryResultList 오류를 확인하세요 >>>>>>>>>>>>> ' + e.getMessage());
        }
        
        return queryResultList;
    }

    // sosl로 가져온 데이터 정제하여 가져오기
    /* 
        sosl로 데이터를 가져올 때 ALL FIELDS 로 가져오는데 그렇게 되면 필터값을 적용하지 않은 필드도 가져온다.
        ALL FIELDS로 가져온 데이터를 한번 더 정제하여 필터를 적용한 필드의 데이터만 가져오기 위한 메서드
    */
    private static List<ObjectReference__c> getRefinedResultList(List<ObjectReference__c> recordList, Map<String, String> soslFilterMap){
        List<ObjectReference__c> queryResultList = new List<ObjectReference__c>();
        
        try {
            for(ObjectReference__c record : recordList){
                List<String> keyList = new List<String>(soslFilterMap.keySet());
                
                for(String key : keyList){
                    String str = nullToString((String)record.get(key));
                    
                    if(String.isNotEmpty(str) && str.contains(soslFilterMap.get(key))){
                        queryResultList.add(record);
                    }
                }
            }
        } catch (Exception e) {
            System.debug('getRefinedResultList 오류를 확인하세요 >>>>>>>>>>>>> ' + e.getMessage());
        }

        return queryResultList;
    }

    private static String getSoqlForm() {
        return ' select '
            + ' 	Id,'
            + '     Name,'
            + '     Eng_Label__c,'
            + '     Kor_Label__c,'
            + '     Api_Version__c,'
            + '     Supported_Calls__c,'
            + '     Description__c,'
            + '     Remove__c,'
            + '     Supported_Calls_Description__c,'
            + '     Special_Access_Rules__c,'
            + '     Usage__c,'
            + '     Memo__c,'
            + '     Docs_Link__c'
            + ' from  '
            + '     ObjectReference__c '
            + ' where '
            + '     Id != null '; // sql의 where 1=1 처럼 동적으로 편하게 where절을 추가 하기 위해
    }
    private static String getSoslForm() {
        return ' IN ALL FIELDS RETURNING '
        + ' ObjectReference__c '
        + ' ( '
        + '     Id, '
        + '     Name, '
        + '     Eng_Label__c, '
        + '     Kor_Label__c, '
        + '     Api_Version__c, '
        + '     Supported_Calls__c, '
        + '     Description__c, '
        + '     Remove__c, '
        + '     Supported_Calls_Description__c, '
        + '     Special_Access_Rules__c, '
        + '     Usage__c, '
        + '     Memo__c, '
        + '     Docs_Link__c '

        + '     where '
        + '         id != null '; // sql의 where 1=1 처럼 동적으로 편하게 where절을 추가 하기 위해
        // ' ) '로 닫아주는 것을 잊지 말 것
    }

    private static String nullToString(object o) {
        return o == null ? '' : String.valueOf(o);
    }
}