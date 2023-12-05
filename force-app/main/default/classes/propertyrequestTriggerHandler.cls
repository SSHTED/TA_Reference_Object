public class propertyrequestTriggerHandler {
    
    public static void updateStageFieldSendEmail(List<property_request__c> propList, Map<Id, property_request__c> oldMap){

            List<RecordType> RtList = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'property_request__c'];
            Map<String,String> RtMap = new Map<String,String>();
            
            for(RecordType rt : RtList){
                RtMap.put(rt.Id,rt.DeveloperName);
            }
 			System.debug('RTMap======' + RtMap);
            
            List<String> SendEmailList = new List<String>();
            EmailTemplate propTemp = [SELECT Subject, HtmlValue, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'propertyPaymentRequest' LIMIT 1];
            
            try{
                for(property_request__c Send : propList){         
                        
                    // 레코드 타입이 New거나 Add이거나 Change일 때
                    if(RtMap.get(Send.RecordTypeId) == 'New' || RtMap.get(Send.RecordtypeId) == 'Add' || RtMap.get(Send.RecordTypeId) == 'Change'){
                        
                        Map<String, String> temp = AllEmailTemplated.getEmailTemplateMaps(Send, propTemp);
                        
                        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        
                        // 해당 레코드의 바뀐 단계
                        String NewStatus = Send.status__c;
                        // 해당 레코드의 바뀌기 이전 단계
                        String OldStatus = oldMap.get(Send.Id).status__c;
                        System.debug(NewStatus);
                        System.debug(OldStatus);


                        System.debug('OwnerId 존재할때 시작-----------------------');
                        // 소유자 Id를 SendEmailLlist에 넣어주기
                        SendEmailList.add(String.valueOf(Send.OwnerId));
                        
                        System.debug('OwnerId 존재할때 끝-----------------------');
                        System.debug(SendEmailList);
                        
                        System.debug('message 세팅 시작-----------------------');
                        // 이메일 템플릿의 address에 SendEmailList(소유자 Id)를 넣어주기
                        message.setToAddresses(SendEmailList);
                        // 제목
                        message.setSubject(temp.get('subject'));
                        // 내용
                        message.setHtmlBody(temp.get('body'));
                        // mailist에 message넣어주기
                        mailList.add(message);

                        System.debug('message 세팅 끝-----------------------');
                        
                        System.debug('Send-------------------------');
                        // 바뀐단계와 이전단계가 다르고 바뀐 단계가 '진행'일 때
                        
                        
                        //-test-----------------------------------------------------------------------
                        
                        // 요청작성 -> 팀장승인대기일때 (팀장에게 메일, 상태필드 팀장승인대기로업데이트)  //메일받는사람 변경해야함(팀장)                     
                        if(OldStatus == 'createRequest' && NewStatus == 'teamLeaderApprovalSet'){
                            Messaging.sendEmail(mailList);
                        }
                        // 요청작성 -> 팀장승인요청을 했는데 거절일때 (사용자에게 메일, 상태필드 중단으로 업데이트)  //메일받는사람 변경해야함(사용자)
                        else if(OldStatus == 'teamLeaderApprovalSet' && NewStatus == 'stop'){
                            Messaging.sendEmail(mailList); 
                        }
                        // 팀장승인대기 -> 팀장승인 일때 (IT Service 에게 메일, 상태필드 IT Service 검토중으로 업데이트)  //메일받는사람 변경해야함(IT Service)
                        else if(OldStatus == 'teamLeaderApprovalSet' && NewStatus == 'IT_Service_done'){
                            Messaging.sendEmail(mailList); 
                        }
                        // IT Service에서 검토를 했는데 거절일때 (사용자에게 메일, 상태필드 중단으로 업데이트)  //메일받는사람 변경해야함(사용자)
                        else if(OldStatus == 'IT_Service_done' && NewStatus == 'stop'){
                            Messaging.sendEmail(mailList);
                        }
                        // IT Service 검토중 -> 완료 일때 (사용자에게 메일, 상태필드 완료로 업데이트)  //메일받는사람 변경해야함(사용자)
                        else if(OldStatus == 'IT_Service_done' && NewStatus == 'complete'){
                            Messaging.sendEmail(mailList);
                        }
                        
                        //----------------------------------------------------------------------------
                        
                        
                        
                        
                        System.debug('End-------------------------');
                    }
                }
            } // try문 종료
            catch (Exception e){
                System.debug(e);
            } // catch문 종료
    }
}