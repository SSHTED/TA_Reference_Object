/*
* @Desc : SupportManagerTrigger_TEST
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
public class SupportManagerTrigger_TEST {
    
    static Account acc;
    static PMS_Project__c pms_project;
    static Customer_Org__c org;
    static ContentVersion cv;
    static Support_Manager__c  sm2;
    static {
        acc = new Account(
            Name = 'Test1234');
        
        insert acc;
        
        org = new Customer_Org__c(
            Org_Id__c = '1234567'
            , Customer__c = acc.Id
        );
        
        insert org;

        pms_project = new PMS_Project__c(
        	Name ='23년 현대산업개발 유지보수 계약 (23년)_Mant_Ren',
            PerformedStage__c = '운영(SM)',
            ContractStartDate__c =Date.newInstance(2023, 01, 01),
            ContractEndDate__c= Date.newInstance(2024, 12, 31),
            Status__c = 'Active',
            ProjectType__c ='SM'
        );

        insert pms_project;
        
        cv = new ContentVersion(title='dddd.txt', PathOnClient='test', VersionData = Blob.valueOf('Unit Test Attachment Body'));
        insert cv;
        
        Support_Manager_Queues__c smq1 = new Support_Manager_Queues__c(
            Name='문의'
            , Request_Type__c = '단순문의'
            , Request_Content__c = '내용'
            , Requester__c = System.UserInfo.getUserId()
            , Requester_Email__c = 'test@test.com'
            , Customer_Org__c = org.Id
            , Channel__c = 'Site');
        insert smq1;
        
        Support_Manager__c sm2 = new Support_Manager__c(
            Name= smq1.Name
            , Request_Type__c = smq1.Request_Type__c
            , Request_Content__c = smq1.Request_Content__c
            , Requester__c = smq1.Requester__c
            , Requester_Email__c = smq1.Requester_Email__c
            , Channel__c = smq1.Channel__c
            , Support_Manager_Queues__c = smq1.Id
            , Customer_Org__c = org.Id
            , State__c = '담당자 할당'
            , ImplementType__c = 'Interface'
            , Expected_MM__c =6
            , Person_In_Charge__c  = System.UserInfo.getUserId()
            , PMS_Project__c = pms_project.Id
        	, Flag__c = false);
        insert sm2;
    }    
    
    testMethod static void myTest() {
        Test.startTest();
        
        Support_Manager_Queues__c smq = new Support_Manager_Queues__c(
            Name='문의'
            , Request_Type__c = '단순문의'
            , Request_Content__c = '내용'
            , Requester__c = System.UserInfo.getUserId()
            , Requester_Email__c = 'test@test.com'
            , Customer_Org__c = org.Id
            , Channel__c = 'Site');
        insert smq;
        
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = smq.Id;
        contentlink.ShareType = 'V';
        contentlink.ContentDocumentId = testContent.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        Support_Manager__c sm = new Support_Manager__c(
            Name= smq.Name
            , Request_Type__c = smq.Request_Type__c
            , Request_Content__c = smq.Request_Content__c
            , Requester__c = smq.Requester__c
            , Requester_Email__c = smq.Requester_Email__c
            , Channel__c = smq.Channel__c
            , Support_Manager_Queues__c = smq.Id
            , Customer_Org__c = org.Id
            , State__c = '담당자 할당'
            , Expected_MM__c =6
            , Person_In_Charge__c  = System.UserInfo.getUserId()
            , PMS_Project__c = pms_project.Id
        	, Flag__c = false);
        insert sm;
     
        update sm;

        List<Support_Manager__c> smList = [select Id, Person_In_Charge__c, PMS_Project__c from Support_Manager__c];

        System.debug(smList);

        update smList;

        Test.stopTest();
    }
    
}