public class ITAM_reqTriggerHandler {
private Boolean isExecuting {get;set;} 	// Web Service와 구분하기 위한 Context 파라미터
    private Integer size {get;set;} 		// Trigger에서 Execute된 List Size 
    
    public ITAM_reqTriggerHandler(Boolean isExecuting, Integer size){
        this.isExecuting = isExecuting;
        this.size = size;
        
        System.debug('#isExecuting [' + isExecuting + '] #size [' + size + ']');
    }
    
    public void onBeforeInsert(List<property_request__c> news, Map<Id, property_request__c> oldMap){
        System.debug('onBeforeInsert');
        
        if(isExecuting){
            addNumbering(news, oldMap);
            
            User getUser;
            User itLeaderUser;
            User reqApproval;
            
            reqApproval = [SELECT id, ManagerId FROM USER WHERE id =:Userinfo.getUserId()];
            
            for (property_request__c tmp : news){
                tmp.requestApproval__c = reqApproval.ManagerId;
            }
            
            List<PermissionSetAssignment> tmpAssObj = new List<PermissionSetAssignment>();
            for(PermissionSet tmp : [SELECT id, Label, (SELECT AssigneeId FROM Assignments) FROM PermissionSet WHERE Name='ITAM_ItService' LIMIT 1]){
                System.debug('tmp1: '+ tmp.Assignments);
                for(PermissionSetAssignment a : tmp.Assignments){
                    tmpAssObj.add(a);
                }
            }
            System.debug('reqTrigger IT담당자: '+ tmpAssObj);
            System.debug('reqTrigger IT담당자: '+ tmpAssObj[0]);
            if(tmpAssObj.size() > 0){
                getUser = [SELECT id, Name, ManagerId FROM User WHERE id=:tmpAssObj[0].AssigneeId LIMIT 1];
            }
            
            
            if(getUser != null){
                for(property_request__c setNew : news){
                    setNew.itApproval__c = getUser.id;
                }
            }else{
                if(!Test.isRunningTest())	news[0].addError('담당자 검색 실패.');
            }
            
            //IT 부서장 검색
            List<PermissionSetAssignment> tmpAssObj1 = new List<PermissionSetAssignment>();
            for(PermissionSet tmp : [SELECT id, Label, (SELECT AssigneeId FROM Assignments) FROM PermissionSet WHERE Name='ITAM_ItServiceLeader' LIMIT 1]){
                System.debug('tmp1: '+ tmp.Assignments);
                for(PermissionSetAssignment a : tmp.Assignments){
                    tmpAssObj1.add(a);
                }
            }
            if(tmpAssObj1.size() > 0){
                itLeaderUser = [SELECT id, Name, ManagerId FROM User WHERE id=:tmpAssObj1[0].AssigneeId LIMIT 1];
            }
            
            
            if(itLeaderUser != null){
                for(property_request__c setNew : news){
                    setNew.itLeaderApproval__c = itLeaderUser.id;
                }
            }else{
                if(!Test.isRunningTest())	news[0].addError('부서장 검색 실패.');
            }
            
            
        } else {
            
        }
    }
    public void onBeforeUpdate(List<property_request__c> olds, List<property_request__c> news, Map<Id, property_request__c> oldMap, Map<Id, property_request__c> newMap){
        System.debug('onBeforeUpdate');
        
        if(isExecuting){
            addNumbering(news, oldMap);
        } else {
            
        }
    }
    public void onBeforeDelete(List<property_request__c> dels, Map<Id, property_request__c> delMap){
        System.debug('onBeforeDelete');
        
        if(isExecuting){
            
            for (property_request__c pr : dels){
                switch on pr.status__c {
                    when 'teamLeaderApprovalSet' {
                        pr.addError('이미 승인 중 이거나 승인 처리가 완료된 신청서는 삭제할 수 없습니다.');
                    }	
                    when 'IT_Service_done' {		
                        pr.addError('이미 승인 중 이거나 승인 처리가 완료된 신청서는 삭제할 수 없습니다.');
                    }
                    when 'complete' {		
                        pr.addError('이미 승인 중 이거나 승인 처리가 완료된 신청서는 삭제할 수 없습니다.');
                    }
                    when 'stop' {		
                        pr.addError('이미 승인 중 이거나 승인 처리가 완료된 신청서는 삭제할 수 없습니다.');
                    }
                    when 'ITS_TL_Wait' {		
                        pr.addError('이미 승인 중 이거나 승인 처리가 완료된 신청서는 삭제할 수 없습니다.');
                    }
                    when 'ITS_TL_Success' {		
                        pr.addError('이미 승인 중 이거나 승인 처리가 완료된 신청서는 삭제할 수 없습니다.');
                    }
                    when else {
                    }
                }
            }
            
            
        } else {
            
        }
    }
    
    public void onAfterInsert(List<property_request__c> news){
        System.debug('onAfterInsert');
        
        if(isExecuting){
			updateStageFieldSendEmail3T(news);
            
        } else {
            
        }
    }

	public void onAfterUpdate(List<property_request__c> news, Map<Id, property_request__c> oldMap){
        System.debug('onAfterUpdate');
        
        if(isExecuting){
			//updateStageFieldSendEmail2T(news, oldMap);
            
        } else {
            
        }
    }
    
    public void onAfterDelete(List<property_request__c> dels, Map<Id, property_request__c> delMap){
        System.debug('onAfterDelete');
        
        if(isExecuting){
            
        } else {
            
        }
    }
    
    
    ////// 자산 신청 레코드 생성시 자동채번 기능 ////// - START
	public void addNumbering(List<SObject> propList, Map<Id, SObject> oldMap){
        Set<String> propYM = new Set<String>();
        
        String ObjName = String.valueOf(propList.getSObjectType());
        System.debug('objName :: ' + objName);
        for(SObject prop : propList){
            if(objName == 'property_request__c'){
                Datetime dt = Date.today();
                prop.put('YearMonth__c', dt.format('YYMM'));
            }

            
            if(objName == 'property_request__c' && prop.get('Name') == null){
                System.debug('동작제한');
                propYM.add(String.valueOf(prop.get('YearMonth__c')));
            }else{
                propYM.add(String.valueOf(prop.get('YearMonth__c')));
            }
			
            
        }
        
        List<AggregateResult> maxPropList = new List<AggregateResult>();
        System.debug('propYM :::: ' + propYM);
        
        if(propYM.size() > 0){
            String query = 'SELECT YearMonth__c , MAX(OrderBy__c) MaxOrder ';
            query += ' FROM ' + objName;
            query += ' WHERE YearMonth__c IN :propYM Group BY YearMonth__c';
            System.debug('query ::: ' + query);
            maxPropList = System.Database.query(query);
            System.debug('maxPropList ::: ' + maxPropList);
        }
         
        Map<String, String> maxOrderMaps = new Map<String, String>();
        if(maxPropList.size() > 0){
            for(AggregateResult prop : maxPropList){
                String yearMonth = String.valueOf(prop.get('YearMonth__c'));
                String maxOrder = String.valueOf(prop.get('MaxOrder'));
                maxOrderMaps.put(yearMonth, maxOrder);
            }
        }
        massInsert(propList, maxOrderMaps, oldMap, objName);
    }
    
    
    public void massInsert(List<SObject> propList, Map<String, String> maxOrderMaps, Map<Id, SObject> oldMap, String objName){
        Map<Object, Integer> recentNum = new Map<Object, Integer>();
                
        System.debug('maxOrderMaps :::: ' + maxOrderMaps);
        
        for(SObject prop : propList){
            Integer orderNum = 1;

            if(recentNum.get(prop.get('YearMonth__c')) != null){
                orderNum = recentNum.get(prop.get('YearMonth__c')) + 1;
                System.debug('누적 값');
            } else if(maxOrderMaps.get(String.valueOf(prop.get('YearMonth__c'))) != null){
                orderNum = Integer.valueOf(maxOrderMaps.get(String.valueOf(prop.get('YearMonth__c'))))+1;
                System.debug('맥스 값');
            }
            if(oldMap != null && oldMap.get(String.valueOf(prop.get('Id'))) != null && prop.get('YearMonth__c').equals(oldMap.get(String.valueOf(prop.get('Id'))).get('YearMonth__c'))){
                orderNum = Integer.valueOf(oldMap.get(String.valueOf(prop.get('Id'))).get('OrderBy__c'));
                System.debug('자기 값');
            } 
            
            if(recentNum.get(prop.get('YearMonth__c')) == null || recentNum.get(prop.get('YearMonth__c')) < orderNum){
                recentNum.put(prop.get('YearMonth__c'), orderNum);
                System.debug('풋풋');
            }
            
            System.debug('recentNum :::: ' + recentNum);
            String orderBy = String.valueOf(orderNum).leftPad(2, '0');
            prop.put('OrderBy__c', orderBy);
            String Name = '';
            if(objName == 'property_request__c'){
                Name = 'REQ-' + prop.get('YearMonth__c') + prop.get('OrderBy__c');                 
            }
            prop.put('Name', Name);
        }
    }
    ////// 자산 신청 레코드 생성시 자동채번 기능 ////// - END
    
    
    ////// 반납 신청시 IT Service 관리자에게 이메일 전송////// - START  
    public void updateStageFieldSendEmail3T(List<property_request__c> reqList){
        Set<String> recordId = new Set<String>();
        for(property_request__c p : reqList){
            recordId.add(p.itApproval__c);
        }
        
        List<RecordType> RtList = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'property_request__c'];
        Map<String,String> RtMap = new Map<String,String>();
        for(RecordType rt : RtList){
            RtMap.put(rt.Id,rt.DeveloperName);
        }
        List<String> SendEmailList = new List<String>();
        EmailTemplate reqTemp = [SELECT HtmlValue, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'property_return' LIMIT 1];
        
        try{
            for(property_request__c Send : reqList){         
                    
                // 레코드 타입이 Return일 때
                if(RtMap.get(Send.RecordTypeId) == 'Return'){
                    
                    Map<String, String> temp = ITAM_AllEmailTemplated2.getEmailTemplateMaps2T(Send, reqTemp);
                    
                    List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    
                    // 해당 레코드의 바뀐 단계
                    String NewStatus = Send.status__c;
                    System.debug(NewStatus);

                    System.debug('OwnerId 존재할때 시작-----------------------');
                    // 소유자 Id를 SendEmailLlist에 넣어주기
                    SendEmailList.add(String.valueOf(Send.OwnerId));
                    
                    System.debug('OwnerId 존재할때 끝-----------------------');
                    System.debug(SendEmailList);
                    
                    System.debug('message 세팅 시작-----------------------');
                    // 이메일 템플릿의 address에 SendEmailList(소유자 Id)를 넣어주기
                    message.setToAddresses(SendEmailList);
                    // 내용
                    message.setHtmlBody(temp.get('body'));
                    // mailist에 message넣어주기
                    mailList.add(message);

                    System.debug('message 세팅 끝-----------------------');
                    
                    System.debug('Send-------------------------');
                    // 바뀐단계와 이전단계가 다르고 바뀐 단계가 '진행'일 때
                    
                    
                    // 지급상태가 대기일때                 
                    if(NewStatus == 'returnHold'){
                        Messaging.sendEmail(mailList);
                    }
                           
                    System.debug('End-------------------------');
                }
            }
        } catch (Exception e){
            System.debug(e);
        } // catch문 종료
    }
    ////// 반납 신청시 IT Service 관리자에게 이메일 전송////// - END
    
}