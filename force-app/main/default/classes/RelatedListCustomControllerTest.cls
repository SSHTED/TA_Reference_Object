/**
 * @Class : RelatedListCustomController
 *
 * @Method : 
 * 
 * @Author : 안종민
 * @Date : 2023-11-07
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2023-11-07 | 안종민        | 최초작성
 */
global without sharing class RelatedListCustomControllerTest {
    
    private static List<String> checkObjList() {
        List<String> checkList = new List<String>{'NetworkUserHistoryRecent'};
        return checkList;
    }

    @AuraEnabled(cacheable=true)
    global static Map<String, Object> getInit(){
        Map<String, Object> resultMap = new Map<String, Object>();
        return resultMap;
    }

    // 관계 타입에 따라 관련 목록 가져오기
    @AuraEnabled(cacheable=true)
    global static List<String> getRelatedMap(Id recordId, String relationType){
        Map<String, Object> resultMap = new Map<String, Object>();
        Map<String, String> objMap = new Map<String, String>();
        List<String> objList = new List<String>();
        String objMapKey = '';
        String replaceRelationType = relationType.replaceAll('"','');

        if(replaceRelationType == 'Parent'){
            objList = getParentRelatedForEditPage(recordId);
        } else {
            objList = getChildRelatedForEditPage(recordId);
        }
        
        // resultMap.put('Result', objMap);
        // return resultMap;
        return objList;
    }

    // 페이지 편집 화면의 상위( Parent ) 관련 목록 가져오기
    private static List<String> getParentRelatedForEditPage(Id recordId){
        Map<String, String> objMap = new Map<String, String>();
        List<Schema.SobjectField> recordFieldList = recordId.getSObjectType().getDescribe().fields.getMap().Values();
        Set<Schema.sObjectType> setSfList = new Set<Schema.sObjectType>();
        List<String> objList = new List<String>();
        
        for(Schema.SobjectField sf : recordFieldList){
            DescribeFieldResult sfd = sf.getDescribe();
            // REFERENCE 타입은 Lookup 관계의 필드를 의미( MASTER_DETAIL 타입은 Master-Detail 관계) 
            if(sfd.getType() == Schema.DisplayType.REFERENCE){
                setSfList.addAll(sfd.getReferenceTo());
            }
        }
        for(Schema.sObjectType sot : setSfList){
            DescribeSObjectResult sotd = sot.getDescribe();
            if(sotd.isAccessible() == true && sotd.isQueryable() == true){
                objList.add(sotd.getLabel() + '(' + String.valueOf(sot) + ')');
                // objMap.put(String.valueOf(sot), sotd.getLabel());
            }
        }
        return objList;
        // return objMap;
    }

    // 페이지 편집 화면의 하위( MySelf ) 관련 목록 가져오기
    private static List<String> getChildRelatedForEditPage(Id recordId){
        Map<String, String> objMap = new Map<String, String>();
        List<Schema.ChildRelationship> childRelationships = new List<Schema.ChildRelationship>();
        Set<Schema.sObjectType> setCrList = new Set<Schema.sObjectType>();
        List<String> objList = new List<String>();

        childRelationships = recordId.getSObjectType().getDescribe().getChildRelationships();

        // 중복되는 오브젝트가 있기 때문에 set 작업이 필요
        for(Schema.ChildRelationship c : childRelationships){
            if(c.getRelationshipName() != null){
                setCrList.add(c.getChildSObject());
            }
        }

        List<String> tempCheckList = checkObjList();
        for(Schema.sObjectType sot : setCrList){
            DescribeSObjectResult sotd = sot.getDescribe();
            // 해당 오브젝트를 볼 수 있고 쿼리를 할 수 있는 오브젝트만 관련 목록으로 표출 되도록( 서브쿼리를 사용하면 사용할 수는 있음.)
            if(sotd.isAccessible() == true && sotd.isQueryable() == true && sotd.isDeletable() == true){
                if(!tempCheckList.contains(sotd.getName())){
                    objList.add(String.valueOf(sot));
                    // objList.add(sotd.getLabel() + '(' + String.valueOf(sot) + ')');
                    // objMap.put(String.valueOf(sot), sotd.getLabel());
                }
            }
        }
        return objList;
        // return objMap;
    }

    // 컴포넌트 데이터 가져오기
    /*
        페이지 편집에서 컴포넌트가 추가되고 추가된 오브젝트의 데이터를 가져올 때 사용되는 메서드.
    */
    @AuraEnabled(cacheable=true)
    global static Map<String, Object> getData(Id recordId, String relatedObjName){
        Map<String, Object> resultMap = new Map<String, Object>();
        Map<String, Object> tempMap = new Map<String, Object>();
        List<Map<String, Object>> tempList = new List<Map<String, Object>>();
        String soql = '';
        System.debug('recordId : ' + recordId);
        System.debug('relatedObjName : ' + relatedObjName);

        String parentObjName = recordId.getSObjectType().getDescribe().getName();
        
        // 전체 필드 가져오기
        // getAllFields(); // 필요하다면 구현.

        // 컴포넌트 오브젝트의 필드 가져오기

        // 컴포넌트 오브젝트의 관련 목록 가져오기
        // getRelatedListOfComObj(recordId, parentObjName, relatedObjName);

        // 관련 목록의 필드 가져오기
        // getRelatedListFields();

        // restAPI로 관련 목록 및 필드 정보 가져오기
        /* 필드 한글명 가져오는 코드
        
        */
        
        List<String> fnList = getFieldNameList(relatedObjName);
        String fnListToString = String.join(fnList, ', ');
        String referencedField = getReferencedField(parentObjName, relatedObjName, fnList);
        
        if(parentObjName == relatedObjName){
            soql = ' SELECT ' + fnListToString + ' FROM ' + relatedObjName + ' WHERE Id=\'' + recordId + '\' ';
        } else {
            soql = ' SELECT ' + fnListToString + ' FROM ' + relatedObjName + ' WHERE ' + referencedField + '=\'' + recordId + '\' ';
        }

        try {
            System.debug('soql recordId >>> ' + recordId);
            System.debug('soql referencedField >>> ' + referencedField);
            System.debug('soql relatedObjName >>> ' + relatedObjName);
            List<sObject> data = Database.query(soql);
            tempMap.put('ComponentObjectName', relatedObjName);
            tempMap.put('ComponentObjectFieldList', fnList);
            if(data.size() > 0){
                for(sObject so : data){
                    tempList.add(getComponentChildData(Id.valueOf(String.valueOf(so.get('Id'))), relatedObjName));
                }
                tempMap.put('ComponentObjectList', tempList);
                // tempMap.put('ChildData', );
                resultMap.put('Result', tempMap);
            } else {
                resultMap.put('Result', false);
                resultMap.put('Message', '데이터가 없습니다.');
            }
        } catch (QueryException e) {
            System.debug('error >>> ' + e.getMessage());
            resultMap.put('Result', false);
        }
        
        return resultMap;
    }
    
    // 컴포넌트 오브젝트의 관련 목록 가져오기
    private static void getRelatedListOfComObj(Id recordId, String recordObjName, String relatedObjName){
        Map<String, Object> resultMap = new Map<String, Object>();
        List<Object> columnList = new List<Object>();
        
        String Fields = 'Id';
        String title = '';
        String sObjectName = '';

        String recordTypeId = getRecordTypeId(recordId, recordObjName); // 레코드 타입 ID 가져오기
        String externalKey = recordObjName + '_' + recordTypeId + '_' + relatedObjName;

        // 오브젝트에 기존에 저장한 데이터가 있는지 확인하고 해당 데이터가 없을 때만 restAPI 통신 사용
        List<TA_ComponentData__c> taRelList = [SELECT ComponentData__c, LastModifiedDate FROM TA_ComponentData__c WHERE ExternalKey__c = :externalKey];
        Map<String, Object> tempMap = new Map<String, Object>();
        if(taRelList.size() > 0){
            tempMap = (Map<String, Object>)JSON.deserializeUntyped(taRelList[0].ComponentData__c);
        } else {
            Map<String, Object> layout = (Map<String, Object>)JSON.deserializeUntyped(getRelatedLayoutsByRestAPI(recordTypeId, recordObjName));
            List<Object> relatedDataList = (List<Object>)layout.get('relatedLists');

            for(Object r : relatedDataList){
                Map<String, Object> m = (Map<String, Object>)r;
                if(String.valueOf(m.get('name')) == relatedObjName){
                    tempMap = m;
                    // 관련 목록 정보 저장( 관련 목록의 하위 오브젝트들의 정보, 필드 정보 )
                    // saveRelatedData(recordObjName, relatedObjName, recordTypeId, externalKey, JSON.serializePretty(m));
                    break;
                }
            }
        }

        if(tempMap != null){
            // title = String.valueOf(tempMap.get('label'));
            // sObjectName = String.valueOf(tempMap.get('sobject'));
            // columnList = (List<Object>)rMap.get('columns');
        }
        // Map<String, Object> refindRelatedDataMap = getRefindRelatedData(tempMap);
    }

    private static void saveRelatedData(String parentObj, String relatedObj, String recordTypeId, String extKey, String relatedData) {
        TA_ComponentData__c r = new TA_ComponentData__c();

        r.ParentObject__c = parentObj;
        r.RelatedObject__c = relatedObj;
        r.RecordTypeId__c = recordTypeId;
        r.ExternalKey__c = extKey;
        r.ComponentData__c = relatedData;

        try {
            // upsert record ExternalKey__c;
        } catch (DmlException e) {
            System.debug(e.getMessage());
        }
    }

    // restAPI로 관련 목록 가져오기
    /*
        잦은 restAPI 통신은 서버에 성능 저하가 올 수 있다.
    */
    private static String getRelatedLayoutsByRestAPI(String recordTypeId, String objName){
        String sessionId = getSession(); // Session Id 가져오기
        System.debug(sessionId);

        Httprequest httpReq = new Httprequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();
        String resBody = null;
        
        // http 설정
        String endpoint = System.URL.getOrgDomainUrl().toExternalForm(); // 조직 url
        httpReq.setMethod('GET');          
        httpReq.setEndpoint(endpoint + '/services/data/v59.0/sobjects/' + objName + '/describe/layouts/' + recordTypeId);
        httpReq.setTimeout(120000);
        httpReq.setHeader('Authorization', 'Bearer ' + sessionId);
        httpReq.setHeader('charset', 'UTF-8');
        httpReq.setHeader('Content-Type', 'application/json');        
        httpReq.setHeader('Accept', 'application/json');

        // http 데이터 받아오기
        if(!Test.isRunningTest()) {
            httpRes = http.send(httpReq);            
        } else {
            String blStr= '{"relatedLists":[{"accessLevelRequiredForCreate":null,"buttons":[{"behavior":null,"colors":[{"color":"A094ED","context":"primary","theme":"theme4"}],"content":null,"contentSource":null,"custom":false,"encoding":null,"height":null,"icons":[{"contentType":"image/svg+xml","height":0,"theme":"theme4","url":"https://dk-lc-dev-ed.my.salesforce.com/img/icon/t4v35/action/new_contact.svg","width":0},{"contentType":"image/png","height":60,"theme":"theme4","url":"https://dk-lc-dev-ed.my.salesforce.com/img/icon/t4v35/action/new_contact_60.png","width":60},{"contentType":"image/png","height":120,"theme":"theme4","url":"https://dk-lc-dev-ed.my.salesforce.com/img/icon/t4v35/action/new_contact_120.png","width":120}],"label":"New","menubar":false,"name":"NewContact","overridden":false,"resizeable":false,"scrollbars":false,"showsLocation":false,"showsStatus":false,"toolbar":false,"url":null,"width":null,"windowPosition":null},{"behavior":null,"colors":null,"content":null,"contentSource":null,"custom":false,"encoding":null,"height":null,"icons":null,"label":"Get More Contacts","menubar":false,"name":"DataDotComGetContactsMultiAddAction","overridden":false,"resizeable":false,"scrollbars":false,"showsLocation":false,"showsStatus":false,"toolbar":false,"url":null,"width":null,"windowPosition":null},{"behavior":null,"colors":null,"content":null,"contentSource":null,"custom":false,"encoding":null,"height":null,"icons":null,"label":"Merge Contacts","menubar":false,"name":"Merge","overridden":false,"resizeable":false,"scrollbars":false,"showsLocation":false,"showsStatus":false,"toolbar":false,"url":null,"width":null,"windowPosition":null},{"behavior":null,"colors":null,"content":null,"contentSource":null,"custom":false,"encoding":null,"height":null,"icons":null,"label":"Add to Campaign","menubar":false,"name":"MassAddToCampaign","overridden":false,"resizeable":false,"scrollbars":false,"showsLocation":false,"showsStatus":false,"toolbar":false,"url":null,"width":null,"windowPosition":null}],"columns":[{"field":"Contact.Name","fieldApiName":"Name","format":null,"label":"Contact Name","lookupId":"Id","name":"Name","sortable":true},{"field":"Contact.Title","fieldApiName":"Title","format":null,"label":"Title","lookupId":null,"name":"Title","sortable":true},{"field":"Contact.Email","fieldApiName":"Email","format":null,"label":"Email","lookupId":null,"name":"Email","sortable":true},{"field":"Contact.Phone","fieldApiName":"Phone","format":null,"label":"Phone","lookupId":null,"name":"Phone","sortable":true}],"custom":false,"field":"AccountId","label":"Contacts","limitRows":5,"name":"Contacts","sobject":"Contact","sort":[{"ascending":true,"column":"LastName"}]}]}';
            Blob bl = Blob.valueof(blStr);
            httpRes.setBody(blStr);
            httpRes.setStatusCode(200);
        }
        
        resBody = httpRes.getBody();
        System.debug('** getRelatedListLayout resBody : ' + resBody);

        return resBody;
    }

    // Session Id 가져오기
    private static String getSession(){
        if(Test.isRunningTest()) {
            return 'SESSION_ID';
        } else {
            // System.debug(UserInfo.getOrganizationId().substring(0, 15) + ' ' + UserInfo.getSessionId().substring(15));
            return UserInfo.getSessionId().substring(15);
        }
    }

    // private static Map<String, Object> getRefindRelatedData(Map<String, Object> relatedData){
    // }

    private static void getChildRelatedList(Id recordId, String recordObjName, String relatedListName){
        String sessionId = getSession(); // Session Id 가져오기
        System.debug(sessionId);

        Httprequest httpReq = new Httprequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();
        String resBody = null;
        String ENDPOINT = System.URL.getOrgDomainUrl().toExternalForm();
        httpReq.setMethod('GET');          
        httpReq.setEndpoint(ENDPOINT + '/services/data/v58.0/sobjects/Employee__c/describe/');
        //httpReq.setEndpoint(ENDPOINT + '/services/data/v54.0/sobjects/Employee__c/describe/layouts/012000000000000AAA');
        httpReq.setTimeout(120000);
        httpReq.setHeader('Authorization', 'Bearer ' + sessionId);
        httpReq.setHeader('charset', 'UTF-8');
        httpReq.setHeader('Content-Type', 'application/json');        
        httpReq.setHeader('Accept', 'application/json');
        httpRes = http.send(httpReq);
        resBody = httpRes.getBody();
        Map<String, Object> o = (Map<String, Object>)JSON.deserializeUntyped(resBody);
        List<Object> fields = (List<Object>)o.get('fields');
        for(Object s : fields){
            Map<String, Object> m = (Map<String, Object>)s;
            System.debug(m.get('label'));
        }
    }

    // 레코드 타입 ID 가져오기
    /*
        오브젝트에 레코드 타입이 존재하는 경우 해당 레코드 타입을 가져오기 위함.
        레코드 타입이 없다면 기본 값인 레코드 타입의 마스터 ID를 사용.( 012000000000000AAA )
    */
    private static String getRecordTypeId(Id recordId, String objName) {
        String recordTypeId = '';
        System.debug('getRecordTypeId : ' + recordId + ' : ' + objName);
        
        List<RecordType> rtList = [SELECT Id FROM RecordType WHERE SobjectType = :objName];
        if(rtList.size() > 0) {
            Sobject sObj = (Sobject)Database.query('select RecordTypeId from ' + objName + ' where Id = :recordId').get(0);
            recordTypeId = String.valueOf(sObj.get('RecordTypeId'));
        // 레코드 타입이 존재하지 않을 경우
        } else {
            recordTypeId = '012000000000000AAA';
        }
            
        return recordTypeId;
    }

    // 오브젝트의 필드 목록 name 가져오기
    private static List<String> getFieldNameList(String objName){
        List<String> resultList = new List<String>();

        SObjectType sot = ((SObject) Type.forName(objName).newInstance()).getSObjectType();
        List<Schema.SObjectField> sofList = sot.getDescribe().fields.getMap().Values();

        for(SObjectField sof : sofList){
            if(sof.getDescribe().isAccessible() == true){
                resultList.add(sof.getDescribe().getName());
            }
        }

        return resultList;
    }

    // 컴포넌트 오브젝트의 자식 데이터 가져오기
    private static Map<String, Object> getComponentChildData(Id recordId, String objName){
        Map<String, Object> resultMap = new Map<String, Object>();
        String soql = '';

        try {
            // Map<String, String> crMap = getChildRelatedForEditPage(Id.valueOf(recordId));
            // for(String cro: crMap.KeySet()){
            List<String> crMap = getChildRelatedForEditPage(recordId);
            for(String cro: crMap){
                List<String> fnList = getFieldNameList(cro);
                String fnListToString = String.join(fnList, ', ');
                String referencedField = getReferencedField(objName, cro, fnList);
                soql = ' SELECT ' + fnListToString + ' FROM ' + cro + ' WHERE ' + referencedField + '=\'' + recordId + '\' ';
                List<Object> queryResult = Database.query(soql);

                if(queryResult.size() > 0){
                    Map<String, Object> tempMap = new Map<String, Object>();
                    tempMap.put(cro + ' QueryResult', queryResult);
                    tempMap.put(cro + ' FieldList', fnList);
                    resultMap.put(cro, tempMap);
                }
            }
        } catch (QueryException e) {
            System.debug('e.getMessage() : ' + e.getMessage());
            resultMap.put('ErrorMessage', e.getMessage());
        }

        return resultMap;
    }

    // 참조하는 상위 필드 가져오기
    private static String getReferencedField(String parentObj, String cro, List<String> fnList){
        String resultString = '';
        Map<String, Schema.SObjectField> sofMap = Schema.getGlobalDescribe().get(cro).getDescribe().fields.getMap();
        SObjectType sot = ((SObject) Type.forName(parentObj).newInstance()).getSObjectType();

        try {
            for(String fn : fnList){
                SObjectField sof = sofMap.get(fn);
                List<Schema.sObjectType> sotList = sof.getDescribe().getReferenceTo();

                if(sotList.contains(sot)){
                    resultString = String.valueOf(sof);
                    break;
                }
            }

            if(resultString == ''){
                throw new StringException('참조되는 필드가 없습니다.');
            }
        } catch (Exception e) {
            return e.getMessage();
        }
        return resultString;
    }

    // TODO 레코드 추가( 필요 없을지도.. )
    @AuraEnabled
    global static Map<String, Object> insertRecord(String recordId, String dataMap){
        Map<String, Object> resultMap = new Map<String, Object>();
        try {
            
        } catch (DmlException e) {
            
        }
        resultMap.put('Result', true);
        return resultMap;
    }
    // TODO 레코드 편집( 필요 없을지도.. )
    @AuraEnabled
    global static Map<String, Object> updateRecord(String recordId, String dataMap){
        Map<String, Object> resultMap = new Map<String, Object>();
        try {
            
        } catch (DmlException e) {
            
        }
        resultMap.put('Result', true);
        return resultMap;
    }

    // 레코드 삭제
    @AuraEnabled
    global static Map<String, Object> deleteRecord(String recordIdList){
        Map<String, Object> resultMap = new Map<String, Object>();
        recordIdList = recordIdList.replaceAll('[\\[\\]\'\" ]', ''); // 괄호와 작은 따옴표, 큰 따옴표 제거
        List<String> idList = new List<String>(recordIdList.split(','));

        System.debug('idList >>> ' + idList);
        String objName = Id.valueOf(idList.get(0)).getSObjectType().getDescribe().getName();
        String idListToString = '\'' + String.join(idList, '\', \'') + '\'';
        String soql = ' SELECT Id FROM ' +objName+ ' WHERE Id IN(' +idListToString+ ') ';
        System.debug('soql >>> ' + soql);
        List<sObject> queryResult = Database.query(soql);
        System.debug('queryResult >>> ' + queryResult);

        try {
            System.debug('queryResult.size() >>> ' + queryResult.size());
            if(queryResult.size() > 0){
                delete queryResult;
            }
            resultMap.put('Result', true);
            resultMap.put('Count', queryResult.size());
        } catch (DmlException e) {
            resultMap.put('Result', false);
            resultMap.put('Count', -1);
        }
        return resultMap;
    }

    // TODO 소유자 변경( 필요 없을지도.. )
    @AuraEnabled
    global static Map<String, Object> changeOwner(String recordIdList){
        Map<String, Object> resultMap = new Map<String, Object>();
        return resultMap;
    }
}