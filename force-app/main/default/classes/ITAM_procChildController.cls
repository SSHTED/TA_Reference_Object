public class ITAM_procChildController {
    
    @AuraEnabled 
    public static Map<Integer,User> getReqDatas() {
        List<ID> roleId = new List<ID>();
        //Map<ID,String> returnValue = new Map<ID,String>();
        Map<Integer,User> result = new Map<Integer,User>();
        String userId = UserInfo.getUserId();
        ID userRole = UserInfo.getUserRoleId();
        
        return result;
    }
    @AuraEnabled 
    public static List<String> getRecordTypeName(String recordId) {
        //RecordTypeName, recordId, requestEmp__c, realEmp__c, status__c
        List<String> result = new List<String>();
        System.debug('getRecordTypeName : ');
        
        //recordId
        result.add(recordId);
        //SOQL
        property_request__c tmpObj = [SELECT Id, realEmp__c, requestEmp__c, status__c, RecordTypeId FROM property_request__c WHERE Id =:recordId LIMIT 1];
        //requestEmp__c => 요청자
        result.add(tmpObj.requestEmp__c);
        //realEmp__c => 실사용자
        result.add(tmpObj.realEmp__c);
        //status__c =? 상태
        result.add(tmpObj.status__c);
        //recordTypeName
        result.add([SELECT Name FROM RecordType WHERE id =: tmpObj.RecordTypeId].Name);
        
        return result;
    }
    
    @AuraEnabled 
    public static Map<String,String> getRecordDatas(String recordId) {
        //RecordTypeName, recordId, requestEmp__c, realEmp__c, status__c
        Map<String,String> result = new Map<String,String>();
        System.debug('getRecordTypeName : ');
        
        
        //SOQL
        property_request__c tmpObj = [SELECT Id, realEmp__c, requestEmp__c, status__c, RecordTypeId,requestRemarks__c, IsResign__c, returnAsstNum__c,
                                      asstNum__c, beforeEmp__c, afterEmp__c, Name, requestPropType_2nd__c
                                      FROM property_request__c WHERE Id =:recordId LIMIT 1];
        if(String.isNotBlank(tmpObj.returnAsstNum__c)){
            property__c tmpObj2 = [SELECT Id, Name, ProductName__c, ModelName__c FROM property__c WHERE ID=:tmpObj.returnAsstNum__c LIMIT 1];
            result.put('returnAsstNum_ManageNum', tmpObj2.Name);
            result.put('returnAsstNum_ProductName', tmpObj2.ProductName__c);
            result.put('returnAsstNum_ModelName', tmpObj2.ModelName__c);
        }
        if(String.isNotBlank(tmpObj.asstNum__c)){
            property__c tmpObj3 = [SELECT Id, Name, ProductName__c, ModelName__c FROM property__c WHERE ID=:tmpObj.asstNum__c LIMIT 1];
            result.put('asstNum_ManageNum', tmpObj3.Name);
            result.put('asstNum_ProductName', tmpObj3.ProductName__c);
            result.put('asstNum_ModelName', tmpObj3.ModelName__c);
        }
        result.put('Name', tmpObj.Name);
        //recordId
        result.put('ID', tmpObj.Id);
        result.put('requestEmp', tmpObj.requestEmp__c);
        result.put('realEmp', tmpObj.realEmp__c);
        result.put('status', tmpObj.status__c);
        result.put('RecordTypeId', tmpObj.RecordTypeId);
        result.put('requestPropType_2nd__c', tmpObj.requestPropType_2nd__c);
        String recordTypeName = [SELECT Name FROM RecordType WHERE id =: tmpObj.RecordTypeId].Name;
        result.put('RecordTypeNmae',recordTypeName);
        result.put('procRecordTypeId', [SELECT Id FROM RecordType WHERE Name=:recordTypeName AND sObjectType='property_process__c' LIMIT 1].Id);
        result.put('requestRemarks', tmpObj.requestRemarks__c);
        result.put('IsResign', tmpObj.IsResign__c ? 'true' : 'false');
        //tmpObj.IsResign__c ? result.put('IsResign', 'true'); : result.put('IsResign', 'false');
        result.put('returnAsstNum', tmpObj.returnAsstNum__c);
        result.put('asstNum', tmpObj.asstNum__c);
        result.put('beforeEmp', tmpObj.beforeEmp__c);
        result.put('afterEmp', tmpObj.afterEmp__c);
        
        System.debug('ddd???');
        List<PermissionSetAssignment> tmpAssObj = new List<PermissionSetAssignment>();
        for(PermissionSet tmp : [SELECT id, Label, (SELECT AssigneeId FROM Assignments) FROM PermissionSet WHERE Name='ITAM_ItService']){
            System.debug('tmp1: '+ tmp.Assignments);
            for(PermissionSetAssignment a : tmp.Assignments){
                tmpAssObj.add(a);
            }
        }
        System.debug('tmp2: '+tmpAssObj);
		String userId = UserInfo.getUserId();
        String accesIT_User = 'false';
        if(tmpAssObj.size() > 0){
            for (PermissionSetAssignment tmp : tmpAssObj){
                if(tmp.AssigneeId == userId){
                    accesIt_User = 'true';
                }
            }
        }
		result.put('acces',accesIT_User);		
        
        return result;
    }
    

 ///////////

    
/*
//public class PropertyCommonController {
    
    public static void addNumbering(List<SObject> propList, Map<Id, SObject> oldMap){
        Set<String> propYM = new Set<String>();
        Set<String> pdt2s = new Set<String>();
        String ObjName = String.valueOf(propList.getSObjectType());
        System.debug('objName :: ' + objName);
        try {
            for(SObject prop : propList){
                Datetime dt = null;
                if(objName == 'property_request__c'){
                    dt = Date.valueOf(prop.get('requestDate__c'));
                } else if(objName == 'property__c'){
                    dt = Date.valueOf(prop.get('ReceivingDate__c'));
                    pdt2s.add(String.valueOf(prop.get('productType_2nd__c')));
                } else if(objName == 'property_process__c'){
                    dt = Date.valueOf(prop.get('sortOutDate_s__c'));
                }
                prop.put('YearMonth__c', dt.format('YYMM'));
                propYM.add(String.valueOf(prop.get('YearMonth__c')));
            }
            
            List<AggregateResult> maxPropList = new List<AggregateResult>();
            System.debug('propYM :::: ' + propYM);
            
            if(propYM.size() > 0){
                String query = '';

                if(objName == 'property__c'){
                    query = 'SELECT YearMonth__c , MAX(OrderBy__c) MaxOrder, ProductType_2nd__c ';
                    query += ' FROM ' + objName;
                    query += ' WHERE YearMonth__c IN :propYM AND ProductType_2nd__c IN :pdt2s Group BY YearMonth__c, ProductType_2nd__c ';
                } else {
                    query = 'SELECT YearMonth__c , MAX(OrderBy__c) MaxOrder ';
                    query += ' FROM ' + objName;
                    query += ' WHERE YearMonth__c IN :propYM Group BY YearMonth__c';
                }
                System.debug('query ::: ' + query);
                maxPropList = System.Database.query(query);
                System.debug('maxPropList ::: ' + maxPropList);
            }

            Map<String, String> maxOrderMaps = new Map<String, String>();
            if(maxPropList.size() > 0){
                for(AggregateResult prop : maxPropList){
                    String yearMonth = String.valueOf(prop.get('YearMonth__c'));
                    String maxOrder = String.valueOf(prop.get('MaxOrder'));
                    String pdt2 = '';
                    if(objName == 'property__c'){
                        pdt2 = String.valueOf(prop.get('ProductType_2nd__c'));
                    }
                    maxOrderMaps.put(yearMonth + pdt2, maxOrder);
                }
            }
            setOrder(propList, maxOrderMaps, oldMap, objName);
        }
        catch (Exception ex) {
            System.debug('error :: ' + ex.getMessage());
        }
        
    }
    
    
    public static void setOrder(List<SObject> propList, Map<String, String> maxOrderMaps, Map<Id, SObject> oldMap, String objName){
        Map<Object, Integer> recentNum = new Map<Object, Integer>();
                
        System.debug('maxOrderMaps :::: ' + maxOrderMaps);
        
        for(SObject prop : propList){
            Integer orderNum = 1;

            String yearMonth = String.valueOf(prop.get('YearMonth__c'));
            String pdt2 = '';
            if(objName == 'property__c'){
                pdt2 = String.valueOf(prop.get('ProductType_2nd__c'));
            }

            if(recentNum.get(yearMonth + pdt2) != null){
                orderNum = recentNum.get(yearMonth + pdt2) + 1;
                System.debug('누적 값');
            } else if(maxOrderMaps.get(yearMonth + pdt2) != null){
                orderNum = Integer.valueOf(maxOrderMaps.get(yearMonth + pdt2))+1;
                System.debug('맥스 값');
            }

            String recordId = String.valueOf(prop.get('Id'));
            if(oldMap != null && oldMap.get(recordId) != null && yearMonth.equals(oldMap.get(recordId).get('YearMonth__c'))){
                orderNum = Integer.valueOf(oldMap.get(recordId).get('OrderBy__c'));
                System.debug('자기 값');
            } 
            
            if(propList.size() > 1 && (recentNum.get(yearMonth + pdt2) == null || recentNum.get(yearMonth + pdt2) < orderNum)){
                recentNum.put(yearMonth + pdt2, orderNum);
                System.debug('풋풋');
            }
            
            System.debug('recentNum :::: ' + recentNum);
            String orderBy = String.valueOf(orderNum).leftPad(2, '0');
            prop.put('OrderBy__c', orderBy);

            String propName = '';

            if(objName == 'property_request__c'){
                propName = 'REQ';         
            } else if(objName == 'property__c'){
                propName = pdt2;
            } else if(objName == 'property_process__c'){
                propName = 'PROC';
            }
            propName += '-' + yearMonth + orderBy;  
            prop.put('Name', propName);
        }
    }
	
    
//}
*/
}