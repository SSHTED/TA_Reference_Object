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

    // 필터 적용할 목록 가져오기
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
    public static Map<String, Object> getDataByFilter(String filterGroup) {
    // public void getDataByFilter(String filterGroup) {
        // {"Name":"ahn","EngLabel":"jongmin"}
        Map<String, Object> resultMap = new Map<String, Object>();
        Map<String, Object> filterMap = (Map<String, Object>)JSON.deserializeUntyped(filterGroup);

        String soql = getQueryForm();

        try {
            /* 필터 */
            // Name
            String name = nullToString(filterMap.get('Name'));
            if(String.isNotEmpty(name)) {
                soql += ' and Name like \'%' + name + '%\' ';
            }
            // Eng Label
            String engLabel = nullToString(filterMap.get('EngLabel'));
            if(String.isNotEmpty(engLabel)) {
                soql += ' and Eng_Label__c like \'%' + engLabel + '%\' ';
            }
            // Kor Label
            String korLabel = nullToString(filterMap.get('KorLabel'));
            if(String.isNotEmpty(korLabel)) {
                soql += ' and Kor_Label__c like \'%' + korLabel + '%\' ';
            }
            // Api Version
            String apiVersion = nullToString(filterMap.get('ApiVersion'));
            if(String.isNotEmpty(apiVersion)) {
                soql += ' and (Api_Version__c <= ' + apiVersion + ' or Api_Version__c = null) ';
            }
            // Supported Calls
            String supportedCalls = nullToString(filterMap.get('SupportedCalls'));
            if(String.isNotEmpty(supportedCalls)) {
                soql += ' and Supported_Calls__c includes (\'' + supportedCalls + '\') ';
            }
            // Description
            String description = nullToString(filterMap.get('Description'));
            if(String.isNotEmpty(description)) {
                soql += ' and Description__c like \'%' + description + '%\' ';
            }
            // Remove
            String remove = nullToString(filterMap.get('Remove'));
            if(String.isNotEmpty(remove)) {
                soql += ' and Remove__c = ' + remove + ' ';
            }
            
            /* 잘 안쓰는 필터 */
            // Supported Calls Description
            String scd = nullToString(filterMap.get('SupportedCallsDescription'));
            if(String.isNotEmpty(scd)) {
                soql += ' and Supported_Calls_Description__c like \'%' + scd + '%\' ';
            }
            // Special Access Rules
            String sar = nullToString(filterMap.get('SpecialAccessRules'));
            if(String.isNotEmpty(sar)) {
                soql += ' and Special_Access_Rules__c like \'%' + sar + '%\' ';
            }
            // Usage
            String usage = nullToString(filterMap.get('Usage'));
            if(String.isNotEmpty(usage)) {
                soql += ' and Usage__c like \'%' + usage + '%\' ';
            }
            // Memo
            String memo = nullToString(filterMap.get('Memo'));
            if(String.isNotEmpty(memo)) {
                soql += ' and Memo__c like \'%' + memo + '%\' ';
            }
            // Docs Link
            String docsLink = nullToString(filterMap.get('DocsLink'));
            if(String.isNotEmpty(docsLink)) {
                soql += ' and Docs_Link__c like \'%' + docsLink + '%\' ';
            }
    
            if(apiVersion != ''){
                soql += ' order by Api_Version__c, name ';
            } else {
                soql += ' order by name ';
            }

            List<ObjectReference__c> queryResultList = Database.query(soql);

            System.debug('soql >>>>>>>>>>> ' + soql);
            System.debug('queryResultList >>>>>>>>>>> ' + queryResultList);
            
            resultMap.put('result', queryResultList);
            resultMap.put('success', true);

        } catch (QueryException e) {
            resultMap.put('success', false);
            System.debug('오류를 확인하세요 >>>>>>>>>>>>> ' + e.getMessage());
        }

        return resultMap;
    }

    private static String nullToString(object o) {
        return o == null ? '' : String.valueOf(o);
    }
    private static String getQueryForm() {
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
            + '     Id != null '; // sql의 where 1=1 처럼 동적으로 편하게 하기 위해 추가
    }
}