/*
* @Desc : ContentDocumentTrigger_TEST
* @Author : Ha-eun, Lee
* @Date : 2019-09-17
* @Version : 1.0
* 
* @Method :
* 
* 
* @Modified : 
*   ---------------------------------------------
*   NO | Date       | Modifier      | Description 
*   ---------------------------------------------
*   1. | 2019-09-17 | Ha-Eun, Lee   | 최초작성
*/

@isTest
public class ContentDocumentTrigger_TEST {
    
    static Support_Manager__c sm;
    static Support_Manager_Queues__c  smq;
    static ContentVersion cv;
    static Blob beforeblob;
    
    static {
        
        smq = new Support_Manager_Queues__c(
            Name='문의'
            , Request_Type__c = '단순문의'
            , Request_Content__c = '내용'
            , Requester__c = System.UserInfo.getUserId()
            , Requester_Email__c = 'test@test.com'
            , Channel__c = 'Site');
        insert smq;
        
        sm = new Support_Manager__c(
            Name= smq.Name
            , Request_Type__c = smq.Request_Type__c
            , Request_Content__c = smq.Request_Content__c
            , Requester__c = smq.Requester__c
            , Requester_Email__c = smq.Requester_Email__c
            , Channel__c = smq.Channel__c
            , Support_Manager_Queues__c = smq.Id
            , State__c = '담당자 할당');
        insert sm;
        
        beforeblob=Blob.valueOf('Unit Test Attachment Body');
        cv = new ContentVersion (title = 'test content trigger', PathOnClient ='test', VersionData = beforeblob);
        insert cv;    
    }
    
    testMethod static void myTest() {
        
        Test.startTest();      
        
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = sm.Id;
        contentlink.ShareType = 'I';
        contentlink.ContentDocumentId = testcontent.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        Test.stopTest();
        
    }    
}