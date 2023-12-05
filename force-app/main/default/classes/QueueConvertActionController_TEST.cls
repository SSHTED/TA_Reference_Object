/*
* @Desc : QueueConvertActionController_TEST
* @Author : Yeseul.Jin
* @Date : 2019-09-16
* @Version : 1.0
* 
* @Method :
*  - 
*
* @Modified : 
*   ---------------------------------------------
*   NO | Date       | Modifier      | Description 
*   ---------------------------------------------
*   1. | 2019-09-16 | Yeseul.Jin    | 최초작성
*/
@isTest
public class QueueConvertActionController_TEST {
    static Support_Manager_Queues__c smq;
    static Support_Manager__c sm;
    static Support_Assign_Rule__c saf;
    static Contact con;
    static Event e;
    static ContentVersion cv;
    static Profile profile;
    static User u;
    static Customer_Org__c corg;
    static Account acc;

    static {
        acc = new Account(
            Name = 'Test');
        insert acc;
        

        
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
        corg = new Customer_Org__c(Name = '회사', Customer__c = acc.Id, Team__c = 'CS1');
        insert corg;
  
        
        con = new Contact(LastName='네임', Email = u.Email);
        insert con;

        saf = new Support_Assign_Rule__c(Name='test'
                                         , Person_In_Charge__c = u.Id
                                         , Sub_Person_In_Charge__c = u.Id
                                         , Customer_Org__c = corg.Id
                                         , domain__c='dkbmc.com'); 
        e = new Event(ActivityDateTime = Datetime.now(), DurationInMinutes = 3, ActivityDate= Date.today() , Subject='On holiday' ,OwnerId = saf.Person_In_Charge__c);
        cv = new ContentVersion(title='dddd.txt', PathOnClient='test', VersionData = Blob.valueOf('Unit Test Attachment Body'));
        insert saf;
        insert e;     
        insert cv;
        
        smq = new Support_Manager_Queues__c(
            Name='test'
            , Request_Content__c = 'content'
            , Request_Date__c = System.now()
            , Requester_Email__c = u.Email
            , Customer_Org__c = corg.Id
            , Customer__c = corg.Customer__r.Name
            , Channel__c = 'Email'
            , Request_Type__c = '단순문의'
            , Emergency__c = '최상'
            , Reception_Date__c = System.now()
            , Reception_Status__c = false            
        );
        insert smq;
        
        smq.Request_Content__c = '테스트';
        update smq;
        
        sm = new Support_Manager__c(Name='tewwst'
                                    , Customer__c = smq.Customer__c
                                    , Support_Manager_Queues__c = smq.Id
                                    , Requester_Email__c = smq.Requester_Email__c
                                    , Customer_Org__c = smq.Customer_Org__c
                                    , Request_Content__c  = smq.Request_Content__c
                                    , Request_Date__c  = smq.Request_Date__c
                                    , Channel__c = smq.Channel__c
                                    , Request_Type__c = smq.Request_Type__c
                                    , Emergency__c = smq.Emergency__c
                                    , Person_In_Charge__c = System.UserInfo.getUserId()
                                   );
        insert sm;
    }
    @isTest
    static void ExecuteTest(){
        
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = smq.Id;
        contentlink.ShareType = 'V';
        contentlink.ContentDocumentId = testContent.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        QueueConvertActionController.getInfo(smq.Id);
        
        QueueConvertActionController.UpdateSupportManagerQueues(smq.Id, System.UserInfo.getUserId(), '단순문의', '상');
        //QueueConvertActionController.getOPTeamUsers();
        //QueueConvertActionController.UpdateSupportManagerQueues(smq.Id, saf.Name);
        //QueueConvertActionController.InsertLead(smq.Id);        

    }
}