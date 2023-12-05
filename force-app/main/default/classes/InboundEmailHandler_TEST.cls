/*
* @Desc : InboundEmailHandler_Test
* @Author : Yeseul.Jin
* @Date : 2019-08-16
* @Version : 1.0
* 
* @Method :
*  - 
*
* @Modified : 
* 	---------------------------------------------
* 	NO | Date       | Modifier      | Description 
* 	---------------------------------------------
* 	1. | 2019-08-16 | Yeseul.Jin    | 최초작성
*/

@isTest //(SeeAllData=true)
public class InboundEmailHandler_TEST {
    static Support_Manager_Queues__c smq;
    static Support_Manager__c sm;
    static Support_Assign_Rule__c saf;
    static Contact con;
    static Event e;
    static ContentVersion cv;
    static Profile profile;
    static User u;
    static Customer_Org__c corg;
    static {
         
        profile = [SELECT ID FROM Profile LIMIT 1];
        u = new User(
            LastName='LastName'
            , ProfileId = profile.Id
            , Alias = 'Alias'
            , Email = 'Email@dkbmc.com'
            , Username = 'Email@dkbmc.com'
            , EmployeeNumber = '000012'
            , TimeZoneSidKey = 'Africa/Cairo'
            , LocaleSidKey = 'ar'
            , EmailEncodingKey = 'UTF-8'
            , LanguageLocaleKey = 'en_US'
        );
        insert u;
        corg = new Customer_Org__c(Name = '회사');
        insert corg;
        smq = new Support_Manager_Queues__c(Name='test'
                                            , Request_Content__c = 'content'
                                            , Request_Date__c = System.now()
                                            , Requester_Email__c = u.Email
                                            , Customer_Org__c = corg.Id
                                           );
        insert smq;   
        
        con = new Contact(LastName='네임', Email = u.Email);
        insert con;
        saf = new Support_Assign_Rule__c(Name='test'
                                         , Person_In_Charge__c = u.Id
                                         , Sub_Person_In_Charge__c = u.Id
                                         , domain__c='dkbmc.com'); 
        e = new Event(ActivityDateTime = Datetime.now(), DurationInMinutes = 3, ActivityDate= Date.today() , Subject='On holiday' ,OwnerId = saf.Person_In_Charge__c);
        cv = new ContentVersion(title='dddd.txt', PathOnClient='test', VersionData = Blob.valueOf('Unit Test Attachment Body'));
        insert saf;
        insert e;     
        insert cv;
        
        sm = new Support_Manager__c(Name='test'
                                    , Support_Manager_Queues__c = smq.Id
                                    , Requester_Email__c = smq.Requester_Email__c
                                    , Customer_Org__c = corg.Id
                                    , Email_Reply__c = smq.Request_Content__c
                                    , Flag__c = false);
        insert sm;
        update sm;
    }
    
    static testMethod void isAttachmentFalse() {
        Test.startTest();
        
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        email = new Messaging.InboundEmail();
        envelope = new Messaging.InboundEnvelope();
        email.subject = '[TEST]Subject_FALSE';
        email.fromName = '진예슬';
        email.fromAddress = 'test@dkbmc.com';
        email.htmlBody = '첨부파일 없음~~~ plainTextBody 입니다앙. ';
        
        
        InboundEmailHandler.handleInboundEmail(email, envelope);
        InboundEmailHandler.connectJandi(sm);
        Test.stopTest();
    }
    
    static testMethod
        void isAttachmentTrue() {
            
            Test.startTest();
            
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
            email = new Messaging.InboundEmail();
            envelope = new Messaging.InboundEnvelope();
            email.subject = '[TEST]Subject_TRUE';
            email.fromAddress = 'test@test.com';
            
            // 첨부파일 더미 데이터
            Messaging.InboundEmail.BinaryAttachment battach = new Messaging.InboundEmail.BinaryAttachment();
            Messaging.InboundEmail.TextAttachment tattach = new Messaging.InboundEmail.TextAttachment();
            battach.body = blob.valueOf('attachment text');
            battach.fileName = 'textfile.txt';
            tattach.body = 'dddddd';
            tattach.fileName = 'textfile.txt';
            email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { battach }; 
                email.textAttachments = new Messaging.inboundEmail.TextAttachment[] { tattach }; 
                    email.subject = '[TEST]Subject_TRUE';
            email.fromName = '진예슬';
            email.fromAddress = 'test@dkbmc.com';
            email.htmlBody = '첨부파일 있음!! plainTextBody 입니다앙. ';
            
            ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
            ContentDocumentLink contentlink = new ContentDocumentLink();
            contentlink.LinkedEntityId = smq.Id;
            contentlink.ShareType = 'V';
            contentlink.ContentDocumentId = testContent.ContentDocumentId;
            contentlink.Visibility = 'AllUsers'; 
            insert contentlink;
            
            InboundEmailHandler.handleInboundEmail(email, envelope);
            InboundEmailHandler.saveEmailAttachment(email, smq);
            InboundEmailHandler.connectJandi(sm);
            Test.stopTest();
        }
}