/*
* @Desc : InboundEmailHandler
* @Author : Yeseul.Jin
* @Date : 2019-08-08
* @Version : 1.0
* 
* @Method :
*  - handleInboundEmail() : 수신된 메일 Object에 저장
*  - saveEmailAttachment() : 첨부파일 저장
*  - getPicklistValue() : email subject의 Request_Type, Emergency 여부 조회
* @Modified : 
* 	---------------------------------------------
* 	NO | Date       | Modifier      | Description 
* 	---------------------------------------------
* 	1. | 2019-08-08 | Yeseul.Jin    | 최초작성
*/
global class InboundEmailHandler implements Messaging.InboundEmailHandler {
    global static Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        Support_Manager_Queues__c queue = new Support_Manager_Queues__c();
        List<Remove_Css_In_Email_Contents__mdt> RCInfo = [SELECT Id, Erased_Target__c 
                                                          FROM Remove_Css_In_Email_Contents__mdt];
        
        
        // 메일 상단에 들어오는 style 및 HTML 제거
        String content = email.htmlBody;
        for(Remove_Css_In_Email_Contents__mdt rcec : RCInfo) {
            content = content.replace(rcec.Erased_Target__c, '');
        }
        // 이메일 답장으로 보냈을 경우 
        if(content.indexOf('<div style="display:none;clear:none;">') > -1) {
            Support_Manager__c sm = [SELECT Id, Email_Reply__c, Requester_Email__c, Name, Request_Content__c FROM Support_Manager__c WHERE Id = :content.substringBetween('<div style="display:none;clear:none;">','</div>')];
            sm.Email_Reply__c =  '<br/><br/><blockquote style="margin:0;padding:4px 0 4px 16px;border-left:3px solid #176db5;font-size:14px;">'
                + '<hr style="border:none;border:1px dashed #333;">' 
                + '<p style="margin:0 0 4px 0;"><b>From : </b>' + sm.Requester_Email__c + '</p>'
                + '<p style="margin:4px 0 4px 0;"><b>To : </b>support.salesforce@dkbmc.com</p>'
                + '<p style="margin:4px 0 4px 0;"><b>Sent : </b>' + Datetime.now() + '</p>'
                + '<p style="margin:0 0 4px 0;"><b>Subject : </b>' + sm.Name + '</p><br/><br/>'
                + '<blockquote>' + content.replaceAll(sm.Id, '') 
                + '</blockquote></blockquote>';
            // sm 수정시 어느쪽에서 수정했는지에 대한 Flag값
            sm.Flag__c = true;
            update sm;
            connectJandi(sm);
        } else {
            System.debug(content.stripHtmlTags());
            queue.Name = email.subject;
            queue.Request_Content__c = content;
            queue.Requester__c = email.fromName;
            queue.Channel__c = 'Email';
            queue.Requester_Email__c = email.fromAddress;
            queue.Request_Date__c = Datetime.now();
            // 메일 제목 파싱(Request Type, Emergency)
            queue.Request_Type__c = getPicklistValue(email.subject).get('Request_Type');
            queue.Emergency__c = getPicklistValue(email.subject).get('Emergency'); 
            insert queue;
        } 
        
        // 첨부파일 처리
        if(email.binaryAttachments != null || email.textAttachments != null) saveEmailAttachment(email, queue);  
        return result;
    }
    
    global static void saveEmailAttachment(Messaging.InboundEmail email, Support_Manager_Queues__c queue) {
        List<ContentVersion> cvlist = new List<ContentVersion>();
        List<ContentDocumentLink> cdlist = new List<ContentDocumentLink>();
        
        if(email.textAttachments != null) {
            for(Messaging.InboundEmail.TextAttachment textAttach : email.textAttachments) {
                ContentVersion cversion = new ContentVersion();
                cversion.Title = textAttach.fileName;
                cversion.VersionData = Blob.valueOf(textAttach.body);
                cversion.PathOnClient = '/' + textAttach.fileName;
                cvlist.add(cversion);
            }
        }
        
        if(email.binaryAttachments != null) {
            for(Messaging.InboundEmail.BinaryAttachment binAttach : email.binaryAttachments) {
                ContentVersion cversion = new ContentVersion();
                cversion.Title = binAttach.fileName;
                cversion.VersionData = binAttach.body;
                cversion.PathOnClient = '/' + binAttach.fileName;
                cvlist.add(cversion);
            }
        }
        
        insert cvlist;
        
        cvlist = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :cvlist];
        
        for(ContentVersion cv : cvlist) { 
            ContentDocumentLink cdlink = new ContentDocumentLink();
            cdlink.ContentDocumentId = cv.ContentDocumentId;
            cdlink.LinkedEntityId = queue.Id;
            cdlink.ShareType = 'V';
            cdlink.Visibility = 'AllUsers';
            cdlist.add(cdlink);
        }
        insert cdlist;
        // Queue에서 Support Manager로 바로 Insert 되었을 경우 queue와 동일하게 링크시켜준다.
        List<Support_Manager__c> slist = [SELECT Id, Support_Manager_Queues__r.Id
                                          FROM Support_Manager__c 
                                          WHERE Support_Manager_Queues__r.Id = :queue.Id];
        if(slist.size() == 1) {
            List<ContentDocumentLink> cdId = [SELECT Id, ContentDocumentId
                                              FROM ContentDocumentLink
                                              WHERE LinkedEntityId = :queue.Id];
            
            List<ContentDocumentLink> cdlist_s = new List<ContentDocumentLink>();
            for(ContentDocumentLink cl : cdId) { 
                ContentDocumentLink cdlink = new ContentDocumentLink();
                cdlink.ContentDocumentId = cl.ContentDocumentId;
                cdlink.LinkedEntityId = slist[0].Id;
                cdlink.ShareType = 'V';
                cdlink.Visibility = 'AllUsers';
                cdlist_s.add(cdlink);
            }
            insert cdlist_s;
        }
    }
    
    global static Map<String, String> getPicklistValue(String subject) {
        List<String> lst1 = new List<String>();
        List<String> lst2 = new List<String>();
        List<Schema.PicklistEntry> entry1  = Support_Manager_Queues__c.Request_Type__c.getDescribe().getPicklistValues();
        List<Schema.PicklistEntry> entry2  = Support_Manager_Queues__c.Emergency__c.getDescribe().getPicklistValues();
        Map<String, String> m = new Map<String, String>();
        
        for(Schema.PicklistEntry pickval: entry1) {
            if(subject.contains('[' + pickval.getLabel() + ']')) {
                m.put('Request_Type',  pickval.getLabel());
            }
        }
        
        for(Schema.PicklistEntry pickval: entry2) {
            if(subject.contains('[' + pickval.getLabel() + ']')) {
                m.put('Emergency',  pickval.getLabel());
            }
        }
        return m;
    }
    global static void connectJandi(Support_Manager__c smanager) {
        String webhookName = 'Support_OpTeam';
        String connectColor = '';
        String body_Link_Url = '/' + smanager.Id;
        String body_Link_Text = smanager.Name;
        String body_Text = '게시글의 답변이 등록되었습니다. ';
        String title = smanager.Name;
        String description = smanager.Request_Content__c;
        String imageUrl = '';
        
        if(!Test.isRunningTest()) JandiConnector.saveJandiQueue(webhookName, connectColor, body_Link_Url, body_Link_Text, body_Text, title, description, imageUrl);
    }
}