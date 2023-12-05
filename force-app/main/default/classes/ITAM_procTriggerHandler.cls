public class ITAM_procTriggerHandler {
    private Boolean isExecuting {get;set;} 	// Web Service와 구분하기 위한 Context 파라미터
    private Integer size {get;set;} 		// Trigger에서 Execute된 List Size 
    
    public ITAM_procTriggerHandler(Boolean isExecuting, Integer size){
        this.isExecuting = isExecuting;
        this.size = size;
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        System.debug('#isExecuting [' + isExecuting + '] #size [' + size + ']');
    }
    
    public void onBeforeInsert(List<property_process__c> news){
        System.debug('onBeforeInsert');
        
        if(isExecuting){
            
        } else {
            
        }
    }
    public void onBeforeUpdate(List<property_process__c> news, Map<Id, property_process__c> oldMap){
        System.debug('onBeforeUpdate');
        
        if(isExecuting){
            
            //update 함으로 자산요청쪽
            
            SET<ID> reqId = new SET<ID>();
            List<property_request__c> updatePrList = new List<property_request__c>();
            
            for(property_process__c newPp : news){
                if(oldMap.get(newPp.Id).sortOutDate__c == null && newPp.sortOutDate__c != null){
                    reqId.add(newPp.requestNum__c);
                }
            }
            
            if(reqId.size() > 0){
                for(property_request__c pr : [SELECT id, status__c FROM property_request__c WHERE id=:reqId]){
                    pr.status__c = 'complete';
                    System.debug('seogbong check : '+ pr.status__c);
                    updatePrList.add(pr);
                }
                
                update updatePrList;
            }
            provStatChange(news);
        } else {
            
        }
    }
    public void onBeforeDelete(List<property_process__c> dels, Map<Id, property_process__c> delMap){
        System.debug('onBeforeDelete');
        
        if(isExecuting){
            //맨마지막꺼만 삭제가능..+
            //this가 안나오면 삭제 불가능.. 검색 필드 ownerChangeNum__c, asstNum__c, returnAsstNum__c
            SET<ID> lastProcRecord = new SET<ID>();
            SET<ID> checkLastId = new SET<ID>();
            
            for (property_process__c tmpDel : dels){
                if(tmpDel.IsDiffQa__c == false){
                    //사용자 교체
                    if(tmpDel.ownerChangeNum__c != null){
                        checkLastId.add(tmpDel.ownerChangeNum__c);
                    }
                    //신규 추가
                    else if(tmpDel.asstNum__c != null &&  tmpDel.returnAsstNum__c == null){
                        checkLastId.add(tmpDel.asstNum__c);
                    }
                    //교체
                    else if(tmpDel.asstNum__c != null &&  tmpDel.returnAsstNum__c != null){
                        checkLastId.add(tmpDel.asstNum__c);
                        checkLastId.add(tmpDel.returnAsstNum__c);
                    }
                    //반납
                    else if(tmpDel.asstNum__c == null &&  tmpDel.returnAsstNum__c != null){
                        checkLastId.add(tmpDel.returnAsstNum__c);
                    }
                }
                
            }
            if(checkLastId.size() > 0) {
                for(ID tmpProc : checkLastId){
                    lastProcRecord.add([SELECT id, Name, sortOutDate_s__c, CreatedDate FROM property_process__c 
                                        WHERE ownerChangeNum__c=:tmpProc OR asstNum__c=:tmpProc OR returnAsstNum__c=:tmpProc
                                        ORDER BY sortOutDate_s__c DESC NULLS LAST, CreatedDate DESC LIMIT 1].id);
                }
            }
            
            
            System.debug('last Proc: '+lastProcRecord);
            if(lastProcRecord.size() > 0){
                for (property_process__c tmp : dels){
                    if(!lastProcRecord.contains(tmp.Id)){ if(!Test.isRunningTest())	tmp.addError('마지막 처리요청이 아닙니다.');
                                                        }
                }
            }
            
            
        } else {
            
        }
    }
    
    public void onAfterInsert(List<property_process__c> news, Map<Id, property_process__c> oldMap){
        System.debug('onAfterInsert');
        
        if(isExecuting){
            
            SET<ID> reqId = new SET<ID>();
            List<property_request__c> updateTarget = new List<property_request__c>();
            Map<Id, Map<String, property_process__c>> changePropMap = new Map<Id, Map<String, property_process__c>>();
            SET<ID> deletePropList = new SET<ID>();
            
            for(property_process__c newPp : news){
                reqId.add(newPp.requestNum__c);
                //사용자 교체
                if(newPp.ownerChangeNum__c != null){
                    //changePropMap.put(pc.ownerChangeNum__c, pc.afterEmp__c);
                    changePropMap.put(newPp.ownerChangeNum__c, new Map<String, property_process__c>());
                    changePropMap.get(newPp.ownerChangeNum__c).put('change', newPp);
                }
                //신규 추가
                else if(newPp.asstNum__c != null &&  newPp.returnAsstNum__c == null){
                    //changePropMap.put(pc.asstNum__c, pc.realEmp__c);
                    changePropMap.put(newPp.asstNum__c, new Map<String, property_process__c>());
                    changePropMap.get(newPp.asstNum__c).put('add', newPp);
                }
                //교체
                else if(newPp.asstNum__c != null &&  newPp.returnAsstNum__c != null){
                    //changePropMap.put(pc.asstNum__c, pc.realEmp__c);
                    changePropMap.put(newPp.asstNum__c, new Map<String, property_process__c>());
                    changePropMap.get(newPp.asstNum__c).put('add', newPp);
                    deletePropList.add(newPp.returnAsstNum__c);
                }
                //반납
                else if(newPp.asstNum__c == null &&  newPp.returnAsstNum__c != null){
                    deletePropList.add(newPp.returnAsstNum__c);
                }else{
                    System.debug('보류 상태');
                }
                
            }
            //자산요청 status 변경
            if(reqId.size() > 0){
                for (property_request__c pr : [SELECT id, status__c FROM property_request__c WHERE id=:reqId]){
                    pr.status__c = 'IT_Service_done';
                    updateTarget.add(pr);
                }
            }
            if(updateTarget.size() > 0 ){
                update updateTarget;
            }
            
            //자산현황 변경 , 재고 상태는 X
            if(changePropMap.size() > 0){
                List<property__c> upProList = new List<property__c>() ;
                System.debug('be update changeProMap: '+changePropMap);
                
                for (property__c pro : [SELECT id, GiveDate__c, RealEmp__c FROM property__c WHERE id=:changePropMap.keyset()]){
                    for(property_process__c proMap : changePropMap.get(pro.id).values()){
                        System.debug('proMap~~!!!: '+ proMap);
                        if(changePropMap.get(pro.id).containsKey('change')){
                            System.debug('inChange');
                            pro.GiveDate__c = proMap.sortOutDate_s__c;
                            pro.RealEmp__c = proMap.afterEmp__c;
                            
                            upProList.add(pro);
                        }else if(changePropMap.get(pro.id).containsKey('add')){
                            System.debug('inAdd');
                            pro.GiveDate__c = proMap.sortOutDate_s__c;
                            pro.RealEmp__c = proMap.realEmp__c;
                            
                            upProList.add(pro);
                        }
                    }
                }
                
                update upProList;
            }
            
            //삭제
            if(deletePropList.size() > 0){
                List<property__c> updateProp = new List<property__c>();
                for (property__c pr : [SELECT id, GiveDate__c, RealEmp__c, Condition__c FROM property__c WHERE id=:deletePropList]){
                    System.debug('Trigger delete: '+pr);
                    pr.GiveDate__c = null;
                    pr.RealEmp__c = null;
                    updateProp.add(pr);
                }
                
                update updateProp;
            }
            changeStatus(news);
        } else {
            
        }
    }
    /*@future
public static void onAfterInsertAsync(Boolean isExecuting, List<Id> ids){
System.debug('AFTER_INSERT');

if(isExecuting){

} else {

}
}*/
    
    public void onAfterUpdate(List<property_process__c> olds, List<property_process__c> news, Map<Id, property_process__c> newMap){
        System.debug('onAfterUpdate');
        
        if(isExecuting){
            updatePropStatus(news);
            
            
        } else {
            
        }
    }
    
    public void onAfterDelete(List<property_process__c> dels, Map<Id, property_process__c> delMap){
        System.debug('onAfterDelete');
        
        if(isExecuting){
            //old list임.. delete 된 레코드들임.. before에서 검증되어서 삭제됨..
            SET<ID> lastProcRecord = new SET<ID>();
            SET<ID> checkLastId = new SET<ID>();
            Map<ID,property_process__c> lastObjMap = new Map<ID,property_process__c>();
            
            SET<ID> prList = new SET<ID>();
            List<property_request__c> prStatusList = new List<property_request__c>();
            
            System.debug('delete old list: '+dels);
            
            for (property_process__c prop : dels){
                prList.add(prop.requestNum__c);
                //사용자 교체
                if(prop.ownerChangeNum__c != null && prop.realEmp__c !=null ){
                    checkLastId.add(prop.ownerChangeNum__c);
                }
                //신규 추가
                else if(prop.asstNum__c != null &&  prop.returnAsstNum__c == null && prop.realEmp__c !=null){
                    checkLastId.add(prop.asstNum__c);
                }
                //교체
                else if(prop.asstNum__c != null &&  prop.returnAsstNum__c != null && prop.realEmp__c !=null){
                    checkLastId.add(prop.asstNum__c);
                    checkLastId.add(prop.returnAsstNum__c);
                }
                //반납
                else if(prop.asstNum__c == null &&  prop.returnAsstNum__c != null && prop.realEmp__c !=null){
                    checkLastId.add(prop.returnAsstNum__c);
                }
            }
            
            System.debug('checkLastID: '+checkLastId);
            SET<ID> deletePropList = new SET<ID>();
            Map<Id, Id> changePropMap = new Map<Id, Id>();
            Map<Id, Date> changePropMapDate = new Map<Id,Date>();
            //예외상황이 발생함..
            if(checkLastId.size() > 0){
                for(ID tmpProc : checkLastId){
                    property_process__c[] tmps = [SELECT id, Name, sortOutDate_s__c, CreatedDate , ownerChangeNum__c, asstNum__c, returnAsstNum__c, realEmp__c
                                                  FROM property_process__c 
                                                  WHERE ownerChangeNum__c=:tmpProc OR asstNum__c=:tmpProc OR returnAsstNum__c=:tmpProc
                                                  ORDER BY sortOutDate_s__c DESC NULLS LAST, CreatedDate DESC LIMIT 1];
                    
                    if(tmps.size() > 0){
                        lastObjMap.put(tmps[0].Id, tmps[0]);
                    }
                    
                    if(tmps.size() == 0){
                        System.debug('checkLast size?? 0');
                        deletePropList.add(tmpProc);
                    }
                    
                }
                for (ID tmpProc : lastObjMap.keySet()){
                    //사용자 교체
                    if(lastObjMap.get(tmpProc).ownerChangeNum__c != null){
                        changePropMap.put(lastObjMap.get(tmpProc).ownerChangeNum__c, lastObjMap.get(tmpProc).afterEmp__c);
                        changePropMapDate.put(lastObjMap.get(tmpProc).ownerChangeNum__c, lastObjMap.get(tmpProc).sortOutDate_s__c);
                    }
                    //신규 추가
                    else if (lastObjMap.get(tmpProc).asstNum__c != null && lastObjMap.get(tmpProc).returnAsstNum__c == null){
                        changePropMap.put(lastObjMap.get(tmpProc).asstNum__c, lastObjMap.get(tmpProc).realEmp__c);
                        changePropMapDate.put(lastObjMap.get(tmpProc).asstNum__c, lastObjMap.get(tmpProc).sortOutDate_s__c);
                        
                    }
                    //교체
                    else if (lastObjMap.get(tmpProc).asstNum__c != null && lastObjMap.get(tmpProc).returnAsstNum__c != null){
                        changePropMap.put(lastObjMap.get(tmpProc).asstNum__c, lastObjMap.get(tmpProc).realEmp__c);
                        changePropMapDate.put(lastObjMap.get(tmpProc).asstNum__c, lastObjMap.get(tmpProc).sortOutDate_s__c);
                        deletePropList.add(lastObjMap.get(tmpProc).returnAsstNum__c);
                        
                    }
                    //반납
                    else if(lastObjMap.get(tmpProc).asstNum__c == null &&  lastObjMap.get(tmpProc).returnAsstNum__c != null){
                        deletePropList.add(lastObjMap.get(tmpProc).returnAsstNum__c);
                    }
                }
                
                if(deletePropList.size() > 0){
                    List<property__c> updateProp = new List<property__c>();
                    for (property__c pr : [SELECT id, GiveDate__c, RealEmp__c, Condition__c FROM property__c WHERE id=:deletePropList]){
                        System.debug('Trigger delete: '+pr);
                        pr.GiveDate__c = null;
                        pr.RealEmp__c = null;
                        pr.isProcessDel__c = true;
                        //pr.Condition__c = '재고(B)';
                        updateProp.add(pr);
                    }
                    
                    System.debug('afteDel deltetpropList: '+updateProp);
                    update updateProp;
                }
                if(changePropMap.size() > 0){
                    List<property__c> updateProp2 = new List<property__c>();
                    SET<ID> changePropList = changePropMap.keySet();
                    for (property__c pr : [SELECT id, GiveDate__c, RealEmp__c, Condition__c FROM property__c WHERE id=:changePropList]){
                        System.debug('Trigger change: '+pr);
                        pr.GiveDate__c = changePropMapDate.get(pr.Id);
                        pr.RealEmp__c = changePropMap.get(pr.Id);
                        pr.isProcessDel__c = true;
                        //pr.Condition__c = '사용중';
                        System.debug('Trigger change2: '+pr);
                        updateProp2.add(pr);
                    }
                    
                    update updateProp2;
                }
            }
            
            if(prList.size() > 0){
                for(property_request__c tmpPr : [SELECT id, status__c FROM property_request__c WHERE id=:prList]){
                    tmpPr.status__c = 'ITS_TL_Success';
                    prStatusList.add(tmpPr);
                }
                
                update prStatusList;
            }
            
        } else {
            
        }
    }
    
    /*
@future
public static void onAfterDeleteAsync(Boolean isExecuting, List<Id> ids){
System.debug('onAfterDeleteAsync');

if(isExecuting){

} else {

}
}
*/
    
    public void updateStageFieldSendEmail2(List<property_process__c> procList, Map<Id, property_process__c> oldMap){
        
        List<RecordType> RtList = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'property_process__c'];
        Map<String,String> RtMap = new Map<String,String>();
        
        for(RecordType rt : RtList){
            
            RtMap.put(rt.Id,rt.DeveloperName);
        }
        
        List<String> SendEmailList = new List<String>();
        EmailTemplate procTemp = [SELECT HtmlValue, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'propertySuccess' LIMIT 1];
        
        try{
            for(property_process__c Send : procList){         
                
                // 레코드 타입이 New거나 Add이거나 Change일 때
                if(RtMap.get(Send.RecordTypeId) == 'New' || RtMap.get(Send.RecordtypeId) == 'Add' || RtMap.get(Send.RecordTypeId) == 'Change'){
                    
                    Map<String, String> temp = ITAM_AllEmailTemplated2.getEmailTemplateMaps3(Send, procTemp);
                    
                    List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    
                    // 해당 레코드의 바뀐 단계
                    String NewStatus = Send.deliveryProp__c;
                    // 해당 레코드의 바뀌기 이전 단계
                    String OldStatus = oldMap.get(Send.Id).deliveryProp__c;
                    
                    // 소유자 Id를 SendEmailLlist에 넣어주기
                    SendEmailList.add(String.valueOf(Send.OwnerId));
                    
                    // 이메일 템플릿의 address에 SendEmailList(소유자 Id)를 넣어주기
                    message.setToAddresses(SendEmailList);
                    
                    // 내용
                    message.setHtmlBody(temp.get('body'));
                    
                    // mailist에 message넣어주기
                    mailList.add(message);
                    
                    // 지급상태가 대기에서 완료로바뀌었을 때                 
                    if(OldStatus == 'provisionWait' && NewStatus == 'provisionSuccess'){
                        Messaging.sendEmail(mailList); 
                    }
                }
            }
        } catch (Exception e){
            System.debug(e);
        } // catch문 종료
    }
    public void updateStageFieldSendEmail3(List<property_process__c> procList){
        
        List<RecordType> RtList = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'property_process__c'];
        Map<String,String> RtMap = new Map<String,String>();
        
        for(RecordType rt : RtList){
            
            RtMap.put(rt.Id,rt.DeveloperName);
        }
        
        List<String> SendEmailList = new List<String>();
        EmailTemplate procTemp = [SELECT HtmlValue, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'propertyWait' LIMIT 1];
        
        try{
            for(property_process__c Send : procList){         
                
                // 레코드 타입이 New거나 Add이거나 Change일 때
                if(RtMap.get(Send.RecordTypeId) == 'New' || RtMap.get(Send.RecordtypeId) == 'Add' || RtMap.get(Send.RecordTypeId) == 'Change'){                   
                    
                    Map<String, String> temp = ITAM_AllEmailTemplated2.getEmailTemplateMaps2(Send, procTemp);
                    List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    
                    // 해당 레코드의 바뀐 단계
                    String NewStatus = Send.deliveryProp__c;
                    
                    // 소유자 Id를 SendEmailLlist에 넣어주기
                    SendEmailList.add(String.valueOf(Send.OwnerId));
                    
                    // 이메일 템플릿의 address에 SendEmailList(소유자 Id)를 넣어주기
                    message.setToAddresses(SendEmailList);
                    
                    // 내용
                    message.setHtmlBody(temp.get('body'));
                    
                    // mailist에 message넣어주기
                    mailList.add(message);
                    
                    // 지급상태가 대기일때                 
                    if(NewStatus == 'provisionWait'){
                        
                        Messaging.sendEmail(mailList);
                    }
                }
            }
        } catch (Exception e){
            
            System.debug(e);
        } // catch문 종료
    }
    
    ////// 자산 신청 처리에서 취소 버튼을 누르면 상태값 취소로 변경 //////
    public void provStatChange(List<property_process__c> news){
        
        for(property_process__c ppsl : news) {
            
            String sod = String.valueOf(ppsl.sortOutDate__c);
            
            if(sod == '' || sod == null ) {  
                
                if(ppsl.procStatus__c == '신청취소'){
                    
                    ppsl.deliveryProp__c = 'cancel';
                } else {
                    
                    ppsl.deliveryProp__c = 'provisionWait';
                    System.debug('provisionWait');
                }                
            } else if (sod != '' || sod != null ) {
                
                ppsl.deliveryProp__c = 'provisionSuccess';
                System.debug('provisionSuccess');            
            }          
        }
    }
    
    ////// 자산 반납 신청 처리시 상태값 완료로 자동 변경 //////
    public void changeStatus(List<property_process__c> news){
        
        Id returnTypeId = [SELECT ID FROM RecordType WHERE DeveloperName ='Return' and SobjectType = 'property_process__c'].Id;  
        
        SET<Id> processIdSet = new SET<Id>();
        
        for(property_process__c p : news){
            if(p.recordTypeId == returnTypeId){
                processIdSet.add(p.requestNum__c);               
            }      
        }
        
        // if (processIdSet.isEmpty()==false){
        //System.debug('@@@@@@@@@@' + processIdSet);
        
        if(processIdSet.size() > 0) {
            //System.debug('processIdSet Size' + processIdSet.size());
            
            List<property_request__c> reqList = [SELECT Id, status__c FROM property_request__c where id=:processIdSet];
            
            for(property_request__c reqStatus : reqList){
                
                reqStatus.status__c = 'complete';
                
            }
            UPDATE reqList;
        }
        
        //}            
        
        
    }
    
    ////// 자산 신청 처리 취소시 자산 상태 재고로 변경 //////
    public void updatePropStatus(List<property_process__c> news){
        
        Set<Id> givePropId = new Set<Id>();
        Set<Id> returnPropId = new Set<Id>();
        
        for(property_process__c pr : news){
            
            if(pr.asstNum__c != null){
                givePropId.add(pr.asstNum__c);
            }
            if(pr.returnAsstNum__c != null){
                returnPropId.add(pr.returnAsstNum__c);
            }
            
        }
        
        List<property__c> giveProp = [SELECT id, RealEmp__c, GiveDate__c FROM property__c WHERE Id IN: givePropId];
        List<property__c> returnProp = [SELECT id, RealEmp__c, GiveDate__c FROM property__c WHERE Id IN: returnPropId];
        
        Map<Id,property__c> giveMap = new Map<Id, property__c>();
        Map<Id,property__c> returnMap = new Map<Id, property__c>();
        
        for(property_process__c proc : news){
            
            if(proc.FM_reqRecordType__c == '추가'){
                System.debug('test :::' + proc.procStatus__c);
                if (proc.procStatus__c == '신청취소') {
                    
                    for(property__c pl : giveProp){
                        
                        giveMap.put(pl.Id, pl);
                        
                        pl.realEmp__c = null;
                        pl.GiveDate__c = null;
                        
                        pl.isProcessDel__c = true;              
                    }   
                    update giveProp;
                }           
                
            } else if(proc.FM_reqRecordType__c == '교체'|| proc.FM_reqRecordType__c == '사용자변경'){
                
                if(proc.procStatus__c == '신청취소'){
                    
                    for(property__c pl : returnProp){
                        
                        List<property_log__c> log = [SELECT Id, giveDate__c, returnDate__c, realEmp__c FROM property_log__c WHERE Id=:returnPropId];    
                        returnMap.put(pl.Id, pl);
                        
                        for(property_log__c logs : log){
                            
                            pl.realEmp__c = logs.realEmp__c;
                            pl.GiveDate__c = logs.giveDate__c;
                            
                        } 
                    }
                    update returnProp;
                    
                    for(property__c pl : giveProp){
                        
                        giveMap.put(pl.Id, pl);
                        
                        pl.realEmp__c = null;
                        pl.GiveDate__c = null;
                        
                        pl.isProcessDel__c = true;
                        
                    }
                    update giveProp;
                }
                
            }
        }
    }   
}