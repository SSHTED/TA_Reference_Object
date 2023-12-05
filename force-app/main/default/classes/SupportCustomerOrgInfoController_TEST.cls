/**
* Desc : SupportCustomerOrgInfoController_TEST
*
* @Method : 
* 
* @Author : Ha-Eun, Lee
* @Date : 2019-08-16
* @Version : 1.0
* @Modified : 
*  ---------------------------------------------
*  NO | Date       | Modifier      | Description
*  ---------------------------------------------
*  1. | 2019-08-16 | Ha-Eun, Lee   | 최초작성
*/

@isTest
public class SupportCustomerOrgInfoController_TEST {
    
    static Organization org;
    static String myJSON;
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
        org = [select 
               Division
               , Id
               , InstanceName
               , IsSandbox
               , Name
               , NamespacePrefix
               , OrganizationType
               , UiSkin
               , Country
               , DefaultLocaleSidKey
               , LanguageLocaleKey
               , PrimaryContact
               , SignupCountryIsoCode
               , TimeZoneSidKey
               from
               Organization
               limit 1
              ].get(0);  
        
        myJSON = JSON.serialize(org);
        
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
        corg = new Customer_Org__c(Name = '회사'
                                  , Org_Id__c  = org.Id
                                  , Instance_Name__c  = org.InstanceName
                                  , IsSandbox__c  = org.IsSandbox
                                  , NamespacePrefix__c  = org.NamespacePrefix
                                  , OrganizationType__c = org.OrganizationType
                                  , Country__c = org.Country
                                  , DefaultLocaleSidKey__c = org.DefaultLocaleSidKey
                                  , LanguageLocaleKey__c = org.LanguageLocaleKey
                                  , PrimaryContact__c = org.PrimaryContact
                                  , SignupCountryIsoCode__c = org.SignupCountryIsoCode
                                  , TimeZoneSidKey__c = org.TimeZoneSidKey
                                  , UiSkin__c = org.UiSkin
                                  , Team__c = 'CS1'
                                  , Instance_Url__c  = '123');
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
        insert saf;
        e = new Event(ActivityDateTime = Datetime.now(), DurationInMinutes = 3, ActivityDate= Date.today() , Subject='On holiday' ,OwnerId = saf.Person_In_Charge__c);
        cv = new ContentVersion(title='dddd.txt', PathOnClient='test', VersionData = Blob.valueOf('Unit Test Attachment Body'));
        
        insert e;     
        insert cv;
        
        sm = new Support_Manager__c(Name='test'
                                    , Support_Manager_Queues__c = smq.Id
                                    , Requester_Email__c = smq.Requester_Email__c
                                    , Person_In_Charge__c = u.Id
                                    , Customer_Org__c = corg.Id);
        insert sm;
    }
    
    static testMethod void myUnitTest() {
        
        Map<String, Object> resMap = new Map<String, Object>();
        resMap.put('orgInfo', myJSON);
        resMap.put('InstanceUrl', '123');        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/org/';  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof('{"orgInfo" : {"Name":"회사", "InstanceName":"CS5","IsSandbox":true,"NamespacePrefix":null,"OrganizationType":"Enterprise Edition","Country":"KR","DefaultLocaleSidKey":"ko_KR","LanguageLocaleKey":"ko","PrimaryContact":"Bae Chang Wook","SignupCountryIsoCode":"KR","TimeZoneSidKey":"Asia/Seoul","UiSkin":"Theme3", "Id":"a1NO000000NcRZkMAN"}, "instanceUrl":"123"}');
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        SupportCustomerOrgInfoController.doPost();
        //SupportCustomerOrgInfoController.InsertCustomerOrgInfo(resMap);
        Test.stopTest();
    }
    
}