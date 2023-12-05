@isTest
public class SupportRestOutboundController_TEST {
    static Support_Manager_Queues__c smq;
    static Support_Manager__c sm;
    static Support_Assign_Rule__c saf;
    static Contact con;
    static Event e;
    static ContentVersion cv;
    static Customer_Org__c org;
    static Profile profile;
    static User u;
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
        
        con = new Contact(LastName='LastName'
                          , Email=u.Email);
        insert con;
   
        saf = new Support_Assign_Rule__c(
            Name='test'
            , Person_In_Charge__c = u.Id
            , Sub_Person_In_Charge__c = u.Id
            , domain__c='dkbmc.com'); 
        insert saf;
        
        e = new Event(
            ActivityDateTime = Datetime.now()
            , DurationInMinutes = 3
            , ActivityDate= Date.today() 
            , Subject='On holiday' 
            , OwnerId = saf.Person_In_Charge__c);
        insert e;
        
        cv = new ContentVersion(
            title='dddd.txt'
            , PathOnClient='test'
            , VersionData = Blob.valueOf('Unit Test Attachment Body')
        );
        insert cv;
        
        org = new Customer_Org__c (
            Name = '고객센터'
            , Team__c = 'CS1'
        ); 
        
        insert org;
        
        smq = new Support_Manager_Queues__c(
            Name='test'
            , Request_Content__c = 'content'
            , Request_Date__c = System.now()
            , Requester_Email__c = u.Id
        );
        insert smq;
        
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = smq.Id;
        contentlink.ShareType = 'V';
        contentlink.ContentDocumentId = testcontent.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        
        insert contentlink;
        
        sm = new Support_Manager__c(
            Name='문의'
            , Request_Type__c = '단순문의'
            , Request_Content__c = '내용'
            , Requester__c = smq.Id
            , Customer_Org__c = org.Id
            , Support_Manager_Queues__c = smq.Id
            , Requester_Email__c = u.Email
            , Person_In_Charge__c = u.Id
        );
        
        insert sm;
    }
    testMethod static void myTest() {
        Test.startTest();
        
        SupportRestOutboundController.oauth2Token(sm.Id);
        
        Test.stopTest();
    }
    
}