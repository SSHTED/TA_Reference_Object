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
global without sharing class RelatedListCustomController {

    // 이전 참조하는 필드
    /*
        RestAPI로 데이터를 가져올 때 1Lv의 데이터는 무조건 Id를 조건으로 쿼리를 실행하지만
        2Lv 부터는 1Lv의 하위 오브젝트에서 상위 오브젝트를 참조하는 필드를 조건으로 쿼리 해야한다.
        그러려면 이전 하위 오브젝트의 상위 오브젝트를 참조하는 필드 정보가 필요하기 때문에 해당 변수를 전역으로 선언.
    */
    private class BeforeReferenceField {
        @AuraEnabled public String fldNm {get; set;}
    }

    // 관련 목록 가져오기
    /*
        특정 레코드의 데이터를 볼 때 관련 목록을 가져올 수 있다.
        parentObjName 변수는 레코드 오브젝트의 하위 관련 목록이어야 한다.
        ex. getRelatedList('a1op0000000wfVzAAI', 'Employee__c')
    */
    // @AuraEnabled
    @AuraEnabled(cacheable=true)
    global static Map<String, Object> getRelatedList(Id recordId, String parentObjName){
        Map<String, Object> resultMap = new Map<String, Object>();
        List<Object> tempList = new List<Object>();
        List<Object> relatedList = new List<Object>();
        Map<String, Object> relatedListMap = new Map<String, Object>();

        String recordObjName = recordId.getSObjectType().getDescribe().getName();

        if(parentObjName == '' || parentObjName == null){
            relatedList = getRelatedDataList(recordId, recordObjName, '');
        } else {
            relatedList = getRelatedDataList(recordId, recordObjName, parentObjName);
        }

        if(relatedList.size() > 0){
            for(Object r : relatedList){
                Map<String, Object> tempMap = new Map<String, Object>();
                relatedListMap = (Map<String, Object>)r;
                tempMap.put('Label', String.valueOf(relatedListMap.get('label')));
                tempMap.put('Name', String.valueOf(relatedListMap.get('name')));
                tempMap.put('SObject', String.valueOf(relatedListMap.get('sobject')));
                tempList.add(tempMap);
            }
        }

        resultMap.put('Result', tempList);
        return resultMap;
    }

    // 추후 삭제
    @AuraEnabled
    global static Map<String, Object> getData2(Id recordId, String parentObjName, String componentObjName){
        Map<String, Object> resultMap = new Map<String, Object>();
        Map<String, Object> tempMap = new Map<String, Object>();
        List<Object> relatedDataList = new List<Object>();
        Map<String, Object> componentDataMap = new Map<String, Object>();
        BeforeReferenceField befoRefFld = new BeforeReferenceField();
        
        String recordObjName = recordId.getSObjectType().getDescribe().getName();
        String tempParentObjName = recordObjName;
        String tempChildObjName = '';
        
        System.debug('recordId : ' + recordId);
        System.debug('parentObjName : ' + parentObjName);
        System.debug('componentObjName : ' + componentObjName);
        System.debug('tempParentObjName : ' + tempParentObjName);
        
        if(componentObjName == '' || componentObjName == null){
            parentObjName = 'Employee__c'; // 추후 삭제
            tempChildObjName = parentObjName;
            tempMap.put('1Lv', setRelatedData(recordId, tempParentObjName, tempChildObjName, befoRefFld));
        } else {
            parentObjName = 'Employee__c'; // 추후 삭제
            componentObjName = 'PMS_Certificate__c'; // 추후 삭제
            List<String> objNameList = new List<String>{parentObjName, componentObjName};
            Integer cnt = 1;

            for(String objNm : objNameList){
                // 첫 for문 이후 하위 오브젝트를 상위 오브젝트로 대입하여 더 깊이 탐색
                if(objNameList.get(0) != objNm){
                    tempParentObjName = tempChildObjName;
                }

                tempChildObjName = objNm;
                tempMap.put(cnt + 'Lv', setRelatedData(recordId, tempParentObjName, tempChildObjName, befoRefFld));

                cnt++;
            }
        }

        resultMap.put('Result', tempMap); // 컴포넌트 오브젝트의 데이터 가져오기
        return resultMap;
    }

    // 컴포넌트 데이터 가져오기
    /*
        컴포넌트로 추가된 오브젝트의 데이터를 가져온다.
        컴포넌트 추가 시 parentObjName 변수만 입력되면 1Lv의 데이터만 표출.
        parentObjName, componentObjName 변수 모두 입력되면 2Lv까지 표출.
        추후 더 깊은 레벨로 보여주고 싶다면 파라미터를 List로 받기.
        ex. getData('a1op0000000wfVzAAI', 'Employee__c', 'PMS_Certificate__c')
    */
    // @AuraEnabled
    @AuraEnabled(cacheable=true)
    global static Map<String, Object> getData(Id recordId, String parentObjName, String componentObjName){
        Map<String, Object> resultMap = new Map<String, Object>();
        Map<String, Object> tempMap = new Map<String, Object>();
        List<Object> relatedDataList = new List<Object>();
        Map<String, Object> componentDataMap = new Map<String, Object>();
        BeforeReferenceField befoRefFld = new BeforeReferenceField();
        
        String recordObjName = recordId.getSObjectType().getDescribe().getName();
        String tempParentObjName = recordObjName;
        String tempChildObjName = '';
        
        System.debug('recordId : ' + recordId);
        System.debug('parentObjName : ' + parentObjName);
        System.debug('componentObjName : ' + componentObjName);
        System.debug('tempParentObjName : ' + tempParentObjName);
        
        if(componentObjName == '' || componentObjName == null){
            parentObjName = 'Employee__c'; // 추후 삭제
            tempChildObjName = parentObjName;
            tempMap.put('1Lv', setRelatedData(recordId, tempParentObjName, tempChildObjName, befoRefFld));
        } else {
            parentObjName = 'Employee__c'; // 추후 삭제
            componentObjName = 'PMS_Certificate__c'; // 추후 삭제
            List<String> objNameList = new List<String>{parentObjName, componentObjName};
            Integer cnt = 1;

            for(String objNm : objNameList){
                // 첫 for문 이후 하위 오브젝트를 상위 오브젝트로 대입하여 더 깊이 탐색
                if(objNameList.get(0) != objNm){
                    tempParentObjName = tempChildObjName;
                }

                tempChildObjName = objNm;
                tempMap.put(cnt + 'Lv', setRelatedData(recordId, tempParentObjName, tempChildObjName, befoRefFld));

                cnt++;
            }
        }

        resultMap.put('Result', tempMap); // 컴포넌트 오브젝트의 데이터 가져오기
        return resultMap;
    }

    // 관련 목록 데이터 세팅
    /*
        parentObjName의 하위 관련 목록 중 childObjName와 일치하는 오브젝트의 데이터만 세팅.
        ex. BeforeReferenceField befoRefFld = new BeforeReferenceField();
            setRelatedData('a1op0000000wfVzAAI', 'Employee__c', 'PMS_Certificate__c', befoRefFld)
    */
    private static Map<String, Object> setRelatedData(String recordId, String parentObjName, String childObjName, BeforeReferenceField befoRefFld){
        Map<String, Object> resultMap = new Map<String, Object>();
        List<Object> relatedDataList = new List<Object>();
        Map<String, Object> childDataMap = new Map<String, Object>();

        relatedDataList = getRelatedDataList(recordId, parentObjName, childObjName);
    
        System.debug('relatedDataList.size >>> ' + relatedDataList.size());
        if(relatedDataList.size() > 0){
            for(Object r : relatedDataList){
                childDataMap = (Map<String, Object>)r;
                String sObjectName = String.valueOf(childDataMap.get('sobject'));
                if(sObjectName == childObjName){
                    resultMap = setRelatedDataMap(recordId, parentObjName, childDataMap, befoRefFld);
                    break;
                }
            }
        } else {

        }
        return resultMap;
    }

    // 관련 목록을 List로 가져오기
    /*
        관련 목록을 처음 불러왔다면 RestAPI로 데이터를 가져오고 오브젝트에 해당 데이터 저장
        처음이 아니라면 오브젝트에서 데이터 가져오기
        ex. getRelatedDataList('a1op0000000wfVzAAI', 'Employee__c', 'PMS_Certificate__c')
    */
    private static List<Object> getRelatedDataList(Id recordId, String parentObjName, String childObjName){
        String recordTypeId = getRecordTypeId(recordId, parentObjName); // 레코드 타입 ID 가져오기
        String externalKey = parentObjName + '_' + recordTypeId + '_' + childObjName; // 레코드 objName, 레코드 타입 ID, 컴포넌트 objName으로 키 생성

        // 오브젝트에 기존에 저장한 데이터가 있는지 확인( 해당 데이터가 없을 때만 restAPI 통신 사용 )
        List<TA_ComponentData__c> taRelList = [SELECT ComponentData__c, LastModifiedDate FROM TA_ComponentData__c WHERE ExternalKey__c = :externalKey];
        System.debug('taRelList.size() >>> ' + taRelList.size());
        if(taRelList.size() > 0){
            return (List<Object>)JSON.deserializeUntyped(taRelList[0].ComponentData__c);
        } else {
            Map<String, Object> layout = (Map<String, Object>)JSON.deserializeUntyped(getRelatedLayoutsByRestAPI(recordTypeId, parentObjName));
            // saveComponentData(parentObjName, childObjName, recordTypeId, externalKey, JSON.serializePretty((List<Object>)layout.get('relatedLists')));
            return (List<Object>)layout.get('relatedLists');
        }
    }

    // 관련 목록 데이터 세팅
    /*
        쿼리 시 idField 변수에는 상위 오브젝트를 참조하는 하위 오브젝트의 필드가 대입되어야 한다. ex. 상위: Employee__c, 하위: PMS_Certificate__c 참조필드(PMS_Certificate__c오브젝트): EmployeeId__c
        ex. BeforeReferenceField befoRefFld = new BeforeReferenceField();
            setRelatedDataMap('a1op0000000wfVzAAI', 'Employee__c', '{"relatedLists":[{"accessLevelRequiredForCreate":null,"buttons":[{"behavior":...', befoRefFld)

        리턴 되는 Map의 키 : 데이터
        ColumnList  : 컴포넌트 하위 오브젝트 필드 정보 List( List<Object> )
        Rows        : 컴포넌트 하위 오브젝트 관련 목록 데이터 List
        TypeMap     : 컴포넌트 하위 오브젝트 필드 타입 Map( 필드 API name(키), 필드 유형(값) )
        Label       : 컴포넌트 하위 오브젝트 관련 목록의 Label
        SObjectName : 컴포넌트 하위 오브젝트 관련 목록의 ObjectName
    */
    private static Map<String, Object> setRelatedDataMap(Id recordId, String parentObjName, Map<String, Object> dataMap, BeforeReferenceField befoRefFld){
        Map<String, Object> resultMap = new Map<String, Object>();
        String label = '';
        String name = '';
        String sObjectName = '';
        String field = '';
        List<Object> columnList = new List<Object>();
        List<Object> sortList = new List<Object>();
        String fields = 'Id';
        String sortingField = '';
        String sortingDirect = '';
        String soql = '';
        String idField = 'Id';
        // Map<String, String> fieldTypeMap = new Map<String, String>(); // 추후 필요 시 주석 해제
        
        label = String.valueOf(dataMap.get('label'));
        name = String.valueOf(dataMap.get('name'));
        sObjectName = String.valueOf(dataMap.get('sobject'));
        columnList = (List<Object>)dataMap.get('columns');
        // fieldTypeMap = getFieldTypeMap(sObjectName, columnList); // 필드의 name과 type 가져오기. 추후 필요 시 주석 해제
        
        // 하위 오브젝트의 필드 목록을 fields 변수에 저장
        for(Object col : columnList) {
            Map<String, Object> colMap = (Map<String, Object>)col;
            fields += ',' + colMap.get('name');
        }
        
        // sort 되어있다면 정렬 적용
        sortList = (List<Object>)dataMap.get('sort');
        if(sortList.size() > 0) {
            Map<String, Object> sortMap = (Map<String, Object>)sortList.get(0);
            sortingField = ' order by ' + sortMap.get('column') + ' ';
            sortingDirect = Boolean.valueOf(sortMap.get('ascending')) ? ' ' : 'DESC ';
        }

        // 이전 참조 필드가 존재하면
        if(befoRefFld.fldNm != '' && befoRefFld.fldNm != null){
            idField = befoRefFld.fldNm;
        }
        
        befoRefFld.fldNm = String.valueOf(dataMap.get('field')); // 컴포넌트의 데이터 깊이 2Lv 부터 사용되는 변수

        try {
            // 예) select Id, (select Id from Contacts) from Account where id = ''
            soql = 'select Id, (select ' + fields + ' from ' + name + sortingField + sortingDirect + ') from ' +parentObjName+ ' where ' +idField+ '=\'' +recordId+ '\'';
            System.debug('soql >>> ' + soql);
            resultMap.put('Rows', Database.query(soql));
            resultMap.put('ColumnList', columnList);
            resultMap.put('Label', label);
            resultMap.put('ReferencdObjApiName', name);
            resultMap.put('SObjectName', sObjectName);
            // resultMap.put('TypeMap', fieldTypeMap); // 추후 필요 시 주석 해제
        } catch (QueryException e) {
            System.debug('QueryException ERROR >>>' + e.getMessage());
            resultMap.put('ErrorMessage', e.getMessage());
        }

        return resultMap;
    }

    // 필드의 name과 type 가져오기
    private static Map<String, String> getFieldTypeMap(String objName, List<Object> columnList){
        Map<String, String> fieldTypeMap = new Map<String, String>();

        for (Object column : columnList) {
            Map<String, Object> fieldInfoMap = (Map<String, Object>)column;
            String fieldName = (String)fieldInfoMap.get('fieldApiName');
            String fieldType = getFieldType(objName, fieldName); // 필드의 type 가져오기

            fieldTypeMap.put(fieldName, fieldType);
        }

        return fieldTypeMap;
    }

    // 필드의 type 가져오기
    private static String getFieldType(String objName, String fieldName) {
        String fieldType = 'STRING';

        String currentFieldName = fieldName;
        String currentObjName = objName;

        Map<String, Schema.SObjectType> globalObjectMap = Schema.getGlobalDescribe();

        while (true) {
            if (currentFieldName.contains('.')) {
                Integer idx = currentFieldName.indexOf('.');
                String relationName = currentFieldName.substring(0, idx);

                Map<String, Schema.SObjectField> fieldMap = globalObjectMap.get(currentObjName).getDescribe().fields.getMap();
                for (String fieldKey : fieldMap.keySet()) {
                    Schema.DescribeFieldResult fieldInfo = fieldMap.get(fieldKey).getDescribe();

                    if (relationName == fieldInfo.getRelationshipName()) {
                        currentObjName = fieldInfo.getReferenceTo()[0].getDescribe().getName();

                        currentFieldName = currentFieldName.substring(idx+1);
                    }
                }
            } else {
                Map<String, Schema.SObjectField> fieldMap = globalObjectMap.get(currentObjName).getDescribe().fields.getMap();
                for (String fieldKey : fieldMap.keySet()) {
                    Schema.DescribeFieldResult fieldInfo = fieldMap.get(fieldKey).getDescribe();

                    if (currentFieldName == fieldInfo.getName()) {
                        // fieldType = String.valueOf(fieldInfo.getType());
                        if (fieldInfo.isNameField()) {
                            if(currentObjName ==  'RecordType') {
                                fieldType = 'STRING';
                            } else {
                                fieldType = 'NAME';
                            }
                            
                        } else {
                            // fieldType = String.valueOf(fieldInfo.getSOAPType());
                            fieldType = String.valueOf(fieldInfo.getType());
                        }
                    }
                }

                // SOAPType 종류 : anytype, base64binary, Boolean, Date, Datetime, Double, Integer, String, Time
                // 반환값 종류 : NAME, STRING, BOOLEAN, DATE, DATETIME, TIME, NUMBER
                switch on fieldType {
                    when 'ANYTYPE', 'BASE64BINARY', 'ID', 'MULTIPICKLIST', 'PICKLIST', 'TEXTAREA' {
                        fieldType = 'STRING';
                    }
                    when 'DOUBLE', 'INTEGER', 'CURRENCY' {
                        fieldType = 'NUMBER';
                    }
                }

                // System.debug('End : ' + currentFieldName + ' / ' + fieldType);
                break;
            }
        }
        return fieldType;
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
        String endpoint = DomainCreator.getOrgMyDomainHostname(); // ex. dkbmc--pms.sandbox.my.salesforce.com

        httpReq.setMethod('GET');
        httpReq.setEndpoint('https://' + endpoint + '/services/data/v59.0/sobjects/' + objName + '/describe/layouts/' + recordTypeId);
        httpReq.setTimeout(120000);
        httpReq.setHeader('Authorization', 'Bearer ' + sessionId);
        // httpReq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
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

    @AuraEnabled
    global static void saveComponentData(String parentObj, String relatedObj, String recordTypeId, String extKey, String componentData) {
        TA_ComponentData__c r = new TA_ComponentData__c();

        r.ParentObject__c = parentObj;
        r.RelatedObject__c = relatedObj;
        r.RecordTypeId__c = recordTypeId;
        r.ExternalKey__c = extKey;
        r.ComponentData__c = componentData;

        try {
            upsert r ExternalKey__c;
        } catch (DmlException e) {
            System.debug(e.getMessage());
        }

    }

    // Session Id 가져오기
    @AuraEnabled
    global static String getSession(){
        if(Test.isRunningTest()) {
            return 'SESSION_ID';
        } else {
            String pageContent = Page.DK_SessionIdFromVFPage.getContent().toString();
            System.debug('pageContent >>> ' + pageContent);
            Integer startIndex = pageContent.indexOf('SESSION_ID_START') + 'SESSION_ID_START'.length();
            Integer endIndex = pageContent.indexOf('SESSION_ID_END');
            return pageContent.substring(startIndex, endIndex);
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
        // 해당 오브젝트의 레코드 타입이 존재하는 경우
        if(rtList.size() > 0) {
            Sobject sObj = (Sobject)Database.query('select RecordTypeId from ' + objName + ' where Id = :recordId').get(0);
            recordTypeId = String.valueOf(sObj.get('RecordTypeId'));
        // 레코드 타입이 존재하지 않을 경우 마스터 레코드 타입
        } else {
            recordTypeId = '012000000000000AAA';
        }
            
        return recordTypeId;
    }

    // 참조하는 상위 필드 가져오기
    private static String getReferencedField(String parentObj, String childObj){
        String resultString = '';

        parentObj = parentObj.right(3) == '__r' ? parentObj.split('__')[0] + '__c' : parentObj;
        childObj = childObj.right(3) == '__r' ? childObj.split('__')[0] + '__c' : childObj;
        List<String> fnList = getFieldNameList(childObj);
        Map<String, Schema.SObjectField> sofMap = Schema.getGlobalDescribe().get(childObj).getDescribe().fields.getMap();
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
        } catch (Exception e) {
            return 'getReferencedField ERROR ::: ' + e.getMessage();
        }
        return resultString;
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