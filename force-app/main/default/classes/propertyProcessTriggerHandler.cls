/**
 * @description       : 
 * @author            : hojoon.park@dkbmc.com
 * @group             : 
 * @last modified on  : 06-21-2022
 * @last modified by  : hojoon.park@dkbmc.com
**/
public class propertyProcessTriggerHandler {
	
    public static void updateStageFieldSendEmail2(List<property_process__c> procList, Map<Id, property_process__c> oldMap){

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
                        
                        Map<String, String> temp = AllEmailTemplated2.getEmailTemplateMaps3(Send, procTemp);
                        
                        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                        
                        // 해당 레코드의 바뀐 단계
                        String NewStatus = Send.deliveryProp__c;
                        // 해당 레코드의 바뀌기 이전 단계
                        String OldStatus = oldMap.get(Send.Id).deliveryProp__c;
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
                        // 내용
                        message.setHtmlBody(temp.get('body'));
                        // mailist에 message넣어주기
                        mailList.add(message);

                        System.debug('message 세팅 끝-----------------------');
                        
                        System.debug('Send-------------------------');
                        // 바뀐단계와 이전단계가 다르고 바뀐 단계가 '진행'일 때
                        
                        
                        //-test-----------------------------------------------------------------------
                        
                        // 지급상태가 대기에서 완료로바뀌었을 때                 
                        if(OldStatus == 'provisionWait' && NewStatus == 'provisionSuccess'){
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
    public static void updateStageFieldSendEmail3(List<property_process__c> procList){
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
                    
                    Map<String, String> temp = AllEmailTemplated2.getEmailTemplateMaps2(Send, procTemp);
                    
                    List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    
                    // 해당 레코드의 바뀐 단계
                    String NewStatus = Send.deliveryProp__c;
                    // 해당 레코드의 바뀌기 이전 단계
                    //String OldStatus = oldMap.get(Send.Id).deliveryProp__c;
                    System.debug(NewStatus);
                    //System.debug(OldStatus);


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
                    
                    
                    //-test-----------------------------------------------------------------------
                    
                    // 지급상태가 대기일때                 
                    if(NewStatus == 'provisionWait'){
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