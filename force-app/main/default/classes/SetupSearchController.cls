public with sharing class SetupSearchController {

    // 초기 세팅
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getInit() {
        Map<String, Object> resultMap = new Map<String, Object>();
        Map<String, Object> tempMap = new Map<String, Object>();
        
        try {
            // Setup_Reference__c 오브젝트 필드 목록 가져오기
            List<String> fieldList = new List<String>();
            List<Schema.SObjectField> tempFieldList = getFieldList();
            for(Schema.SObjectField item : tempFieldList){
                fieldList.add(String.valueOf(item));
            }

            // Status__c 필드 picklist 가져오기
            List<String> statusPicklist = new List<String>();
            List<SelectOption> tempStatusPicklist = getStatusPickList();
            for(System.SelectOption item : tempStatusPicklist){
                statusPicklist.add(String.valueOf(item.getLabel()));
            }
            
            // Setup_Reference__c 오브젝트 모든 데이터 가져오기
            Map<String, Object> allDataMap = getAllData();
            
            tempMap.put('FieldList', fieldList);
            tempMap.put('StatusPicklist', statusPicklist);
            tempMap.put('AllData', allDataMap.get('Result'));
            resultMap.put('Result', tempMap);
            resultMap.put('Success', true);
        } catch (Exception e) {
            resultMap.put('Result', e.getMessage());
            resultMap.put('Success', false);
            System.debug('Message를 확인하세요 >>>>>>>>>>>>> ' + e.getMessage());
        }
        
        return resultMap;
    }

    // Setup_Reference__c 오브젝트 필드 목록 가져오기
    private static List<Schema.SObjectField> getFieldList(){
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Setup_Reference__c');
        Map<String, Schema.SObjectField> fieldMap = targetType.getDescribe().fields.getMap();
        return fieldMap.values();
    }

    // Status__c 필드 picklist 가져오기
    private static List<SelectOption> getStatusPickList(){
        List<SelectOption> soList = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = Setup_Reference__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple){
            soList.add(new SelectOption(f.getLabel(), f.getValue()));
        }     
        return soList;
    }
    
    // Setup Reference Object 모든 데이터 가져오기
    private static Map<String, Object> getAllData(){
        Map<String, Object> resultMap = new Map<String, Object>();
        
        try {
            String soqlQuery = ' select '
                             + '      Id, Owner.Name, Name, CreatedDate, CreatedById, format(LastModifiedDate), Kor_Label__c, Parent_Setup__c, Parent_Setup_Name__c, Level__c, Docs_Link__c, Detail__c, Sort_Num__c, Description__c, Status__c '
                             + ' from '
                             + '      Setup_Reference__c '
                             + ' order by '
                             + '      Level__c, Sort_Num__c ';
            List<Setup_Reference__c> queryResult = Database.query(soqlQuery);

            resultMap.put('Result', queryResult);
            resultMap.put('Success', true);
        } catch (QueryException e) {
            resultMap.put('Result', 'getAllData 오류를 확인하세요 >>>>>>> ' + e.getMessage());
            resultMap.put('Success', false);
        }

        return resultMap;
    }

     // 필터 적용한 데이터 가져오기
     @AuraEnabled(cacheable=true)
     public static Map<String, Object> getDataByFilter(String filterGroup) {
        System.debug('getDataByFilter >>>>>>>>>>>>>>>> 진입');
        Map<String, Object> filterMap = (Map<String, Object>)JSON.deserializeUntyped(filterGroup);
        Map<String, Object> resultMap = new Map<String, Object>();
        Map<String, Object> idMap = new Map<String, Object>();
        
        try {
            String whereQuery = getWhereQuery(filterMap);
            String soslQuery = getSoslQuery(filterMap);
            
            if(String.isNotEmpty(soslQuery)){
                idMap = getIdBySoslQuery(soslQuery + whereQuery + ' ) ');
                List<String> idList = (List<String>)idMap.get('Result');
                whereQuery += ' AND Id IN (\'' + String.join(idList, '\', \'') + '\')';
            }
            
            String soqlQuery = getSoqlQuery(whereQuery);
            System.debug('soqlQuery >>>>>>>>>>>>>>>> \n' + soqlQuery);
            List<Setup_Reference__c> soqlQueryResult = Database.query(soqlQuery);
            System.debug('soqlQueryResult >>>>>>>>>>>>>>>> \n' + soqlQueryResult);
                        
            resultMap.put('Result', soqlQueryResult);
            resultMap.put('Success', true);
 
        } catch (Exception e) {
            resultMap.put('Result', 'getDataByFilter 오류를 확인하세요 >>>>>>> ' + e.getMessage());
            resultMap.put('Success', false);
        }
         
        return resultMap;
    }

    private static String getWhereQuery(Map<String, Object> filterMap){
        System.debug('getWhereQuery >>>>>>>>>>>>>>>> 진입');
        String whereQuery = '';

        String name = objectToString(filterMap.get('name'));
        if(String.isNotEmpty(name)) {
            whereQuery += 'AND Name like \'%' + name + '%\' ';
        }
        
        String korLabel = objectToString(filterMap.get('korLabel'));
        if(String.isNotEmpty(korLabel)) {
            whereQuery += 'AND Kor_Label__c like \'%' + korLabel + '%\' ';
        }
        
        String parentName = objectToString(filterMap.get('parentName'));
        if(String.isNotEmpty(parentName)) {
            whereQuery += 'AND Parent_setup_name__c like \'%' + parentName + '%\' ';
        }

        String status = objectToString(filterMap.get('status'));
        if(String.isNotEmpty(status)) {
            whereQuery += 'AND Status__c like \'%' + status + '%\' ';
        }
        
        return whereQuery;
    }

    private static String getSoslQuery(Map<String, Object> filterMap){
        System.debug('getSoslQuery >>>>>>>>>>>>>>>> 진입');
        Map<String, Object> resultMap = new Map<String, Object>();
        String soslQuery = '';
        
        String keyWord = objectToString(filterMap.get('keyWord'));
        if(String.isNotEmpty(keyWord)) {
            soslQuery += 'FIND \'*' + keyWord + '*\' ';
            soslQuery += getSoslForm();
        }

        return soslQuery;
    }

    private static Map<String, Object> getIdBySoslQuery(String query){
        System.debug('getIdBySoslQuery >>>>>>>>>>>>>>>> 진입');
        Map<String, Object> resultMap = new Map<String, Object>();
        List<String> idList = new List<String>();

        try {
            System.debug('query >>>>>>>>>>>>>>>> \n' + query);
            List<List<SObject>> searchList = Search.query(query);

            if(searchList.size() > 0){
                for(List<Setup_Reference__c> recordList : searchList){
                    for(Setup_Reference__c record : recordList){
                        idList.add(String.valueOf(record.get('Id')));
                    }
                }
            }
            resultMap.put('Result', idList);
            resultMap.put('Success', true);
            
        } catch (QueryException e) {
            resultMap.put('Result', 'getIdBySoslQuery 오류를 확인하세요 >>>>> ' + e.getMessage());
            resultMap.put('Success', false);
        }

        return resultMap;
    }

    private static String getSoqlQuery(String whereQuery){
        return getSoqlForm() + whereQuery;
    }

    // sosl query form
    private static String getSoslForm() {
        return ' in all fields returning '
        + ' Setup_Reference__c '
        + ' ( '
        + '     Id '
        + '     where '
        + '         Id != null '; // sql의 where 1=1 처럼 동적으로 편하게 where절을 추가 하기 위해
        // ' ) '로 닫아주는 것을 잊지 말 것
    }

    // soql query form
    private static String getSoqlForm() {
        return ' select '
            + ' 	Id'
            + '     , Name'
            + '     , Owner.Name'
            + '     , CreatedDate'
            + '     , CreatedById'
            + '     , format(LastModifiedDate)'
            + '     , Kor_Label__c'
            + '     , Parent_Setup__c'
            + '     , Parent_Setup_Name__c'
            + '     , Level__c, Docs_Link__c'
            + '     , Detail__c'
            + '     , Sort_Num__c'
            + '     , Description__c'
            + '     , Status__c'
            + ' from  '
            + '     Setup_Reference__c '
            + ' where '
            + '     Id != null '; // sql의 where 1=1 처럼 동적으로 편하게 where절을 추가 하기 위해
    }

    // return object to String
    private static String objectToString(object o) {
        return o == null ? '' : String.valueOf(o);
    }
}