public class ReferenceSearchController {
    private class Dataset {
        @AuraEnabled public List<OrDataset> orData { get; set; }
    }
    private class OrDataset {
        @AuraEnabled public String id {get; set;}
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public String engLabel {get; set;}
        @AuraEnabled public String korLabel {get; set;}
        @AuraEnabled public Decimal apiVersion {get; set;}
        @AuraEnabled public String description {get; set;}
        @AuraEnabled public String supportedCalls {get; set;}
        @AuraEnabled public String specialAccessRules {get; set;}
        @AuraEnabled public String usage {get; set;}
        @AuraEnabled public String docsLink {get; set;}
        @AuraEnabled public String memo {get; set;}
        @AuraEnabled public Boolean remove {get; set;}
        @AuraEnabled public String supportedCallsDescription {get; set;}
        @AuraEnabled public List<String> aorName {get; set;}
    }

    /**
     * init
     */
    @RemoteAction
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getInit() {
        Map<String, Object> resultMap = new Map<String, Object>();
        Map<String, Object> valueMap = new Map<String, Object>();
        List<String> fieldList = new List<String>();

        try {
            // 필터 적용할 필드 목록 가져오기
            /* 
                Schema.SObjectField 타입이 문제가 되는지 Map에 담아서 넘길 때 500 에러 발생.
                String으로 다시 담아서 넘겨줘야 js 에서 데이터를 에러없이 받을 수 있다.
                Schema.SObjectField 형태의 타입은 object에 담을 수 없는 것으로 보인다.
                object는 여러 타입을 허용한다. ex) Integer, String, List, Map...
            */
            List<Schema.SObjectField> tempFieldList = getFilterList();
            for(Schema.SObjectField item : tempFieldList){
                fieldList.add(String.valueOf(item));
            }

            // Supported Calls 목록 가져오기
            Set<String> callList = getSupportedCallsList();
            
            // reference 전체데이터 가져오기
            List<OrDataset> refAllData = getRefAllData();

            valueMap.put('fieldList', fieldList);
            valueMap.put('callList', callList);
            valueMap.put('refAllData', refAllData);
            
            resultMap.put('result', valueMap);
            resultMap.put('success', true);
            
        } catch (Exception e) {
            resultMap.put('result', e.getMessage());
            resultMap.put('success', false);
            System.debug('getMessage를 확인하세요 >>>>>>>>>>>>> ' + e.getMessage());
        }
        
        return resultMap;
    }

    // 필터 적용할 필드 목록 가져오기
    private static List<Schema.SObjectField> getFilterList() {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('ObjectReference__c');
        Map<String, Schema.SObjectField> fieldMap = targetType.getDescribe().fields.getMap();

        return fieldMap.values();
    }

    // Supported Calls 목록 가져오기
    private static Set<String> getSupportedCallsList() {
        Set<String> uniqueCalls = new Set<String>();
        
         String soql = ' select '
                     + '   supported_Calls__c '
                     + ' from '
                     + '   objectReference__c ';
        List<ObjectReference__c> queryResult = Database.query(soql);
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
    private static List<OrDataset> getRefAllData() {
        String soql = ' select '
                     + '   id, name, eng_Label__c, kor_Label__c, api_Version__c, description__c, supported_Calls__c, special_Access_Rules__c, usage__c, docs_Link__c, memo__c, remove__c, supported_Calls_Description__c, (select id, name from objectReference__r) '
                     + ' from '
                     + '   objectReference__c '
                     + ' order by '
                     + '   name ';
        List<ObjectReference__c> queryResult = Database.query(soql);
        List<OrDataset> orDatasetList = setAorListInQueryResult(queryResult);

        return orDatasetList;
    }

    // 가져온 쿼리의 결과에 Associated Object Reference 값 세팅
    /* 
        서브쿼리로 데이터를 가져오는 경우 class파일에서는 데이터를 가지고 있지만 js에서는 접근할 수 없다.
        따라서 서브쿼리 데이터는 다른 변수에 넣어 js에 보내거나, 추가 작업을 통해 쿼리 결과에 추가하여 사용해야 한다.
        서브쿼리로 가져온 데이터는 데이터 타입이 다르기 때문에 쿼리 결과에 추가하려면 datawrapper를 사용해야 한다.( 쿼리 결과에 넣지 않고 다른 변수에 넣어 보내려면 사용하지 않아도 된다. )
    */
    private static List<OrDataset> setAorListInQueryResult(List<ObjectReference__c> queryResult){
        Dataset dataset = new Dataset();
        dataset.orData = new List<OrDataset>();

        if(queryResult.size() > 0){
            
            for(ObjectReference__c orItem : queryResult){
                OrDataset orDataset = new OrDataset();
                OrDataset.aorName = new List<String>();
    
                OrDataset.id = orItem.Id;
                OrDataset.name = orItem.Name;
                OrDataset.engLabel = orItem.Eng_Label__c;
                OrDataset.korLabel = orItem.Kor_Label__c;
                OrDataset.apiVersion = orItem.Api_Version__c;
                OrDataset.description = orItem.Description__c;
                OrDataset.supportedCalls = orItem.Supported_Calls__c;
                OrDataset.specialAccessRules = orItem.Special_Access_Rules__c;
                OrDataset.usage = orItem.Usage__c;
                OrDataset.docsLink = orItem.Docs_Link__c;
                OrDataset.memo = orItem.Memo__c;
                OrDataset.remove = orItem.Remove__c;
                OrDataset.supportedCallsDescription = orItem.Supported_Calls_Description__c;
    
                if(orItem.ObjectReference__r.size() > 0){
                    List<Associated_Objects_Reference__c> aorList = orItem.ObjectReference__r;
                    for(Associated_Objects_Reference__c aorItem : aorList){
                        OrDataset.aorName.add(aorItem.Name);
                    }
                }
                dataset.orData.add(OrDataset);
            }
        }
        return dataset.orData;
    }

    // 필터 적용한 데이터 가져오기
    @RemoteAction
    @AuraEnabled
    public static Map<String, Object> getDataByFilter(String filterGroup) {
        Map<String, Object> resultMap = new Map<String, Object>();
        Map<String, Object> filterMap = (Map<String, Object>)JSON.deserializeUntyped(filterGroup);
        List<OrDataset> queryResultList = new List<OrDataset>();
        Map<String, String> soslFilterMap = new Map<String, String>(); // sosl로 가져와야하는 목록

        String query = '';
        Boolean isSosl = false;

        try {
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
            if(String.isNotEmpty(objectToString(filterMap.get('ApiVersion')))){
                query += ' order by Api_Version__c, name ';
            } else {
                query += ' order by name ';
            }

            // [5] sosl 일 때 쿼리 마지막에 close.( getSoslForm 함수 참고 )
            if(isSosl == true){
                query += ' ) ';
            }
            
            // [6] soql, sosl 형식에 따라 쿼리 수행
            System.debug('query >>>>>>>>>>>>> ' + query);
            queryResultList = getQueryResultList(isSosl, query, soslFilterMap);
            
            resultMap.put('result', queryResultList);
            resultMap.put('success', true);
            System.debug('resultMap >>>>>>>>>>>>> ' + resultMap);

        } catch (Exception e) {
            resultMap.put('success', false);
            System.debug('getDataByFilter 오류를 확인하세요 >>>>>>>>>>>>> ' + e.getMessage());
        }
        
        return resultMap;
    }

    // [1] sosl 적용시켜야하는 필드가 있는 경우를 먼저 체크
    /*
        필드 타입이 긴 텍스트 영역(131072)로 선언된 경우 soql쿼리를 사용할 수 없다. sosl쿼리를 적용해야 한다.
    */
    private static String getSoslQueryStr(Map<String, Object> filterMap, Map<String, String> soslFilterMap){
        String query = '';
        Map<String, String> tempMap = new Map<String, String>();

        // Description
        String description = objectToString(filterMap.get('Description'));
        if(String.isNotEmpty(description)) {
            query += description;

            soslFilterMap.put('Description__c', description);
        }
        // Memo
        String memo = objectToString(filterMap.get('Memo'));
        if(String.isNotEmpty(memo)) {
            query += addCommaIfNotNull(query, memo);
            
            soslFilterMap.put('Memo__c', memo);
        }
        // Special Access Rules
        String sar = objectToString(filterMap.get('SpecialAccessRules'));
        if(String.isNotEmpty(sar)) {
            query += addCommaIfNotNull(query, sar);
            
            soslFilterMap.put('Special_Access_Rules__c', sar);
        }
        // Supported Calls Description
        String scd = objectToString(filterMap.get('SupportedCallsDescription'));
        if(String.isNotEmpty(scd)) {
            query += addCommaIfNotNull(query, scd);

            soslFilterMap.put('Supported_Calls_Description__c', scd);
        }
        // Usage
        String usage = objectToString(filterMap.get('Usage'));
        if(String.isNotEmpty(usage)) {
            query += addCommaIfNotNull(query, usage);

            soslFilterMap.put('Usage__c', usage);
        }

        return query;
    }

    // query가 null이 아니면 콤마 추가
    private static String addCommaIfNotNull(String query, String filterName){
        if(query == ''){
            query += filterName;
        } else {
            query += ', ' + filterName;
        }
        return query;
    }
    
    // [3] sosl 체크가 끝나면 soql 적용할 필드 체크
    private static String getSoqlQueryStr(Map<String, Object> filterMap){
        String query = '';

        // Name
        String name = objectToString(filterMap.get('Name'));
        if(String.isNotEmpty(name)) {
            query += ' and name like \'%' + name + '%\' ';
        }
        // Eng Label
        String engLabel = objectToString(filterMap.get('EngLabel'));
        if(String.isNotEmpty(engLabel)) {
            query += ' and eng_Label__c like \'%' + engLabel + '%\' ';
        }
        // Kor Label
        String korLabel = objectToString(filterMap.get('KorLabel'));
        if(String.isNotEmpty(korLabel)) {
            query += ' and kor_Label__c like \'%' + korLabel + '%\' ';
        }
        // Api Version
        String apiVersion = objectToString(filterMap.get('ApiVersion'));
        if(String.isNotEmpty(apiVersion)) {
            query += ' and (api_Version__c <= ' + apiVersion + ' or api_Version__c = null) ';
        }
        // Supported Calls
        String supportedCalls = objectToString(filterMap.get('SupportedCalls'));
        if(String.isNotEmpty(supportedCalls)) {
            query += ' and supported_Calls__c includes (\'' + supportedCalls + '\') ';
        }
        // Remove
        String remove = objectToString(filterMap.get('Remove'));
        if(String.isNotEmpty(remove)) {
            query += ' and remove__c = ' + remove + ' ';
        }
        // Docs Link
        String docsLink = objectToString(filterMap.get('DocsLink'));
        if(String.isNotEmpty(docsLink)) {
            query += ' and docs_Link__c like \'%' + docsLink + '%\' ';
        }
        
        return query;
    }

    // [5] soql, sosl 형식에 따라 쿼리 수행
    private static List<OrDataset> getQueryResultList(Boolean isSosl, String query, Map<String, String> soslFilterMap){
        List<ObjectReference__c> queryResultList = new List<ObjectReference__c>();
        List<OrDataset> orDatasetList = new List<OrDataset>();
        
        try {
            if(isSosl == true){
                List<List<SObject>> querySoslResultList = Search.query(query);
                for(List<ObjectReference__c> recordList : querySoslResultList){
                    queryResultList = getRefinedResultList(recordList, soslFilterMap);
                }
            } else {
                queryResultList = Database.query(query);
            }

            System.debug('queryResultList >>>>>>>>>>>>> \n' + queryResultList);
            orDatasetList = setAorListInQueryResult(queryResultList);
        } catch (QueryException e) {
            System.debug('getQueryResultList 오류를 확인하세요 >>>>>>>>>>>>> ' + e.getMessage());
        }
        
        return orDatasetList;
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
                    String str = objectToString((String)record.get(key));
                    
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

    // soql query form
    private static String getSoqlForm() {
        return ' select '
            + ' 	id,'
            + '     name,'
            + '     eng_Label__c,'
            + '     kor_Label__c,'
            + '     api_Version__c,'
            + '     supported_Calls__c,'
            + '     description__c,'
            + '     remove__c,'
            + '     supported_Calls_Description__c,'
            + '     special_Access_Rules__c,'
            + '     usage__c,'
            + '     memo__c,'
            + '     docs_Link__c,'
            + '     (select id, name from objectReference__r)'
            + ' from  '
            + '     objectReference__c '
            + ' where '
            + '     id != null '; // sql의 where 1=1 처럼 동적으로 편하게 where절을 추가 하기 위해
    }

    // sosl query form
    private static String getSoslForm() {
        return ' in all fields returning '
        + ' objectReference__c '
        + ' ( '
        + '     id, '
        + '     name, '
        + '     eng_Label__c, '
        + '     kor_Label__c, '
        + '     api_Version__c, '
        + '     supported_Calls__c, '
        + '     description__c, '
        + '     remove__c, '
        + '     supported_Calls_Description__c, '
        + '     special_Access_Rules__c, '
        + '     usage__c, '
        + '     memo__c, '
        + '     docs_Link__c, '
        + '     (select id, name from objectReference__r) '
        
        + '     where '
        + '         id != null '; // sql의 where 1=1 처럼 동적으로 편하게 where절을 추가 하기 위해
        // ' ) '로 닫아주는 것을 잊지 말 것
    }

    // return object to String
    private static String objectToString(object o) {
        return o == null ? '' : String.valueOf(o);
    }
}