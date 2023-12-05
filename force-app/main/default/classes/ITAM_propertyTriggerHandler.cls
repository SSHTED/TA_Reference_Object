public class ITAM_propertyTriggerHandler {
    
    private Boolean isExecuting {get;set;} 	// Web Service와 구분하기 위한 Context 파라미터
    private Integer size {get;set;} 		// Trigger에서 Execute된 List Size 
    
    public ITAM_propertyTriggerHandler(Boolean isExecuting, Integer size){
        this.isExecuting = isExecuting;
        this.size = size;
        
        System.debug('#isExecuting [' + isExecuting + '] #size [' + size + ']');
    }
    
    public void onBeforeInsert(List<property__c> news, Map<Id, property__c> oldMap){
        System.debug('onBeforeInsert');
        
        if(isExecuting){
            propSearch(news);
            addNumbering(news, oldMap, 'Insert');
            
        } else {
            
        }
    }
    public void onBeforeUpdate(List<property__c> olds, List<property__c> news, Map<Id, property__c> oldMap, Map<Id, property__c> newMap){
        System.debug('onBeforeUpdate');
        
        if(isExecuting){
            propSearch(news);
            //news oldMap
            //ReceivingDate__c
            //ProductType_2nd__c
            if(news[0].ReceivingDate__c != oldMap.get(news[0].id).ReceivingDate__c ||  news[0].ProductType_2nd__c != oldMap.get(news[0].id).ProductType_2nd__c){
                if(news[0].Name == oldMap.get(news[0].id).Name){
                    addNumbering(news, oldMap, 'Update');
                }
                
            }
            
            List<property_log__c> propLogList = new List<property_log__c>();
            List<property_log__c> propLogListDel = new List<property_log__c>();
            for(property__c prop : news){
                if(prop.RealEmp__c != oldMap.get(prop.Id).RealEmp__c){
                    //realEmp에는 값이 있는데 지급일에 값이 없을때 error
                    
                    if(prop.GiveDate__c == null && prop.RealEmp__c != null){
                        prop.addError('지급일을 설정해주세요.');
                    }else if(prop.GiveDate__c != null && prop.RealEmp__c == null && prop.Condition__c != 'useOther'){
                        prop.addError('사용자를 설정해주세요.');
                    }else{
                        //if(!Test.isRunningTest()) {
                            if(prop.RealEmp__c != null && prop.Condition__c != 'useOther'){
                                prop.Condition__c = 'use';
                                //property_log__c
                                if(prop.isProcessDel__c == false ){
                                    property_log__c propLog = new property_log__c();
                                    propLog.realEmp__c = prop.RealEmp__c;
                                    propLog.property__c = prop.Id;
                                    propLog.giveDate__c = prop.GiveDate__c;
                                    propLogList.add(propLog);
                                }else{
                                    // process에서 삭제되서 작동 realEmp가 되돌아왔단거는 반납이 취소되었다는거..
                                    System.debug('');
                                    property_log__c propLog = [SELECT id FROM property_log__c WHERE realEmp__c =: oldMap.get(prop.id).RealEmp__c AND property__c =:prop.Id ORDER BY CreatedDate DESC LIMIT 1];
                                    
                                    if(propLog != null){
                                        propLog.returnDate__c = null;
                                        propLogList.add(propLog);
                                    }                               	
                                    //수정 후
                                    prop.isProcessDel__c = false;
                                }
                            }else{
                                prop.Condition__c = 'unUse';
                                //olds를 이용하여 검색?
                                if(prop.isProcessDel__c != true ){
                                    property_log__c propLog = [SELECT id FROM property_log__c WHERE realEmp__c =: oldMap.get(prop.id).RealEmp__c AND property__c =:prop.Id ORDER BY CreatedDate DESC LIMIT 1];
                                    if(propLog != null ){
                                        propLog.returnDate__c = System.today();
                                        propLogList.add(propLog);
                                    }
                                    
                                }else{
                                    // process에서 삭제되서 작동 realEmp가 없다는건 지급한걸 삭제했다는 뜻.. 로그 삭제..
                                    property_log__c propLog = [SELECT id FROM property_log__c WHERE realEmp__c =: oldMap.get(prop.id).RealEmp__c AND property__c =:prop.Id ORDER BY CreatedDate DESC LIMIT 1];
                                    if(propLog!= null){
                                        propLogListDel.add(propLog);
                                    }
                                    //수정 후
                                    prop.isProcessDel__c = false;
                                }
                            }
                            if(propLogList.size() > 0){
                                upsert propLogList;
                            }
                            if(propLogListDel.size() > 0){
                                delete propLogListDel;
                            }
                       // }
                    }
                }
            }
            
            
        } else {
            
        }
    }
    public void onBeforeDelete(List<property__c> dels, Map<Id, property__c> delMap){
        System.debug('onBeforeDelete');
        
        if(isExecuting){
            
        } else {
            
        }
    }
    
    public void onAfterInsert(List<property__c> news){
        System.debug('onAfterInsert');
        
        if(isExecuting){
            //propSearch(news);
            
        } else {
            
        }
    }
    public void onAfterUpdate(List<property__c> olds, List<property__c> news, Map<Id, property__c> newMap){
        System.debug('onAfterUpdate');
        
        if(isExecuting){
            
        } else {
            
        }
    }
    public void onAfterDelete(List<property__c> dels, Map<Id, property__c> delMap){
        System.debug('onAfterDelete');
        
        if(isExecuting){
            
        } else {
            
        }
    }
    
    public void addNumbering(List<SObject> propList, Map<Id, SObject> oldMap, String op){
        Set<String> propYM = new Set<String>();
        Set<String> procPL = new Set<String>();
        String ObjName = String.valueOf(propList.getSObjectType());
        System.debug('objName :: ' + objName);
        
        
        for(SObject prop : propList){
            if(objName == 'property__c'){
                Datetime dt = Date.valueOf(prop.get('ReceivingDate__c'));
                prop.put('YearMonth__c', dt.format('YYMM'));
                
                procPL.add(String.valueOf(prop.get('productType_2nd__c')));
                
            }
            propYM.add(String.valueOf(prop.get('YearMonth__c')));
        }
        
        List<AggregateResult> maxPropList = new List<AggregateResult>();
        System.debug('propYM :::: ' + propYM);
        System.debug('procPL :::: ' + procPL);
        
        if(procPL.size() > 0 && objName == 'property__c'){
            
            String query = 'SELECT YearMonth__c, ProductType_2nd__c, MAX(OrderBy__c) MaxOrder';
            query += ' FROM ' + objName;
            query += ' WHERE YearMonth__c IN :propYM AND ProductType_2nd__c IN :procPL Group BY YearMonth__c, ProductType_2nd__c ';
            System.debug('query2 ::: ' + query);
            maxPropList = System.Database.query(query);
            System.debug('maxPropList2 ::: ' + maxPropList);
        }
        
        
        Map<String, String> maxOrderMaps = new Map<String, String>();
        if(maxPropList.size() > 0){
            for(AggregateResult prop : maxPropList){
                String procPLV = String.valueOf(prop.get('ProductType_2nd__c'));
                String yearMonth = String.valueOf(prop.get('YearMonth__c'));
                String maxOrder = String.valueOf(prop.get('MaxOrder'));
                maxOrderMaps.put(yearMonth + procPLV, maxOrder);
                System.debug('maxOrder--->' + maxOrderMaps);               
            }
        }
        setOrder(propList, maxOrderMaps, oldMap, objName, op);
    }
    
    
    public static void setOrder(List<SObject> propList, Map<String, String> maxOrderMaps, Map<Id, SObject> oldMap, String objName, String op){
        Map<Object, Integer> recentNum = new Map<Object, Integer>();
        
        System.debug('maxOrderMaps :::: ' + maxOrderMaps);
        //ReceivingDate__c
        //ProductType_2nd__c 
        for(SObject prop : propList){
            
            Integer orderNum = 1;
            String PT2 = String.valueOf(prop.get('productType_2nd__c'));
            if(recentNum.get(prop.get('YearMonth__c')) != null){
                orderNum = recentNum.get(prop.get('YearMonth__c')) + 1;
                System.debug('누적 값');
            } else if(maxOrderMaps.get(String.valueOf(prop.get('yearMonth__c'))+PT2) != null){
                orderNum = Integer.valueOf(maxOrderMaps.get(String.valueOf(prop.get('YearMonth__c'))+PT2))+1;
                System.debug('맥스 값');
            }
            if(oldMap != null && oldMap.get(String.valueOf(prop.get('Id'))) != null && prop.get('YearMonth__c').equals(oldMap.get(String.valueOf(prop.get('Id'))).get('YearMonth__c'))){
                orderNum = Integer.valueOf(oldMap.get(String.valueOf(prop.get('Id'))).get('OrderBy__c'));
                System.debug('자기 값');
            } 
            
            if(recentNum.get(prop.get('YearMonth__c')) == null || recentNum.get(prop.get('YearMonth__c')) < orderNum){
                recentNum.put(prop.get('YearMonth__c')+ 'PT2', orderNum);
                System.debug('orderNum-------->'+orderNum);
                System.debug('풋풋');
            }
            
            System.debug('recentNum :::: ' + recentNum);
            String orderBy = String.valueOf(orderNum).leftPad(2, '0');
            prop.put('OrderBy__c', orderBy);
            String Name = '';
            Name = prop.get('ProductType_2nd__c') + '-' + prop.get('YearMonth__c') + prop.get('OrderBy__c');
            
            if(op == 'Insert'){
                if(prop.get('Name') == null ){
                    prop.put('Name', Name);
                }
                
            }else if(op == 'Update'){
                /*
if( !prop.get('ReceivingDate__c').equals(oldMap.get(String.valueOf(prop.get('Id'))).get('ReceivingDate__c')) || 
!prop.get('ProductType_2nd__c').equals(oldMap.get(String.valueOf(prop.get('Id'))).get('ProductType_2nd__c'))){
prop.put('Name', Name);
}
*/
                prop.put('Name', Name);
            }
        }
    }
    
    ////// property search list //////
    public void propSearch(List<property__c> news){
        
        Set<Id> empIds = new Set<Id>();                             // Employee__c IDs
        Map<String, String> emoMap = new Map<String, String>();     // key : Emp_No__c, value : Name
        
        //property__c 레코드에서 RealEmp__c 값을 empId에 담아준다
        for(property__c property : news) {
            if(!String.isBlank(property.RealEmp__c)) empIds.add(property.RealEmp__c);
        }
        
        //Employee__c에서 필요한 값 (Name, Emp_No__c)을 emoMap에 담아준다
        for(Employee__c emp : [SELECT Name, Emp_No__c FROM Employee__c WHERE Id IN :empIds]) {
            emoMap.put(emp.Emp_No__c, emp.Name);
        }
        //System.debug('propSearch - emoMap :::' + emoMap);
        
        //RealEmp__c 기준으로 empName__c, empNo__c 필드를 업데이트 한다
        //1. RealEmp__c가 없으면 빈 값
        //2. RealEmp__c가 있으면 emoMap의 Name 값을 empName__c에 담는다.
        //3. empNo__c는 Foumula 필드인 Emp_No01__c로 값 처리 해준다.
        //값 변경할 때만 업데이트 하는 등의 처리는 필요하다면 추가 처리 필요
        for(property__c property : news) {
            String tempEmpNum = property.Emp_No01__c;
            property.empName__c = String.isBlank(property.RealEmp__c) ? '' : emoMap.get(tempEmpNum);
            property.empNo__c = tempEmpNum;
            
            //System.debug('propSearch - property :::' + property);
        }

    }
}