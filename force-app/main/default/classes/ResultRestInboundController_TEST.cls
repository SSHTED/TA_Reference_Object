/*
* @Desc : ResultRestInboundController_TEST
* @Author : Yeseul.Jin
* @Date : 2019-08-16
* @Version : 1.0
* 
* @Method :
*  
*
* @Modified : 
* 	---------------------------------------------
* 	NO | Date       | Modifier      | Description 
* 	---------------------------------------------
* 	1. | 2019-08-16 | Yeseul.Jin    | 최초작성
*/

@isTest
public class ResultRestInboundController_TEST {
    
    public static String mockRestData = '{"Id":"'+ System.UserInfo.getUserId() + '" ,"RequestDate" : '+ String.valueOf(Datetime.now().getTime()) +', "Emergency" : "최상", "RequestContent" : "아무말", '
        +'"Name":"12345123", "Requester":"진예슬", "RequesterEmail":"jin.ys@dkbmc.com","RequesterPhone":"010-1111-2222",'
        +'"RequestDeadline" : "20201231", "RequestType" : "단순문의"}';
    static Organization org;
    static Customer_Org__c corg;
    static Support_Manager_Queues__c smq;
    static Support_Manager__c sm;
    static Support_Assign_Rule__c saf;
    static Contact con;
    static Event e;
    static ContentVersion cv;
    static User u;
    static Profile profile;
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
        corg = new Customer_Org__c(Name = '회사', Team__c = 'CS1');
        insert corg;
        smq = new Support_Manager_Queues__c(Name='test'
                                            , Request_Content__c = 'content'
                                            , Request_Date__c = System.now()
                                            , Requester_Email__c = u.Email
                                           );
        insert smq;   
        con = new Contact(LastName='네임', Email = u.Email);
        insert con;
        saf = new Support_Assign_Rule__c(Name='test'
                                         , Person_In_Charge__c = u.Id
                                         , Sub_Person_In_Charge__c = u.Id
                                         , domain__c='dkbmc.com'); 
        insert saf;
        
        e = new Event(ActivityDateTime = Datetime.now()
                      , DurationInMinutes = 3
                      , ActivityDate= Date.today() 
                      , Subject='On holiday'
                      , OwnerId = saf.Person_In_Charge__c);
        insert e; 
        cv = new ContentVersion(title='dddd.txt'
                                , PathOnClient='test'
                                , VersionData = Blob.valueOf('Unit Test Attachment Body')); 
        insert cv;
        
        sm = new Support_Manager__c(Name='test'
                                    , Support_Manager_Queues__c = smq.Id
                                    , Requester_Email__c = smq.Requester_Email__c
                                   	, Person_In_Charge__c = u.Id
                                   );
        insert sm;
    }
    
    @isTest static void doPostTest() {
        System.debug('serialize' + mockRestData);
        Map<String, Object> resMap = (map<String, Object>) JSON.deserializeUntyped(mockRestData);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/support/apexrest/result/'+org.Id + '/' + smq.Id;  
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(mockRestData);
        RestContext.request = req;
        RestContext.response = res;
        
        
        Test.startTest();
        ResultRestInboundController.doPost();
        //ResultRestInboundController.handleInboundCustomerOrg(resMap, org.Id, smq.Id);
        Test.stopTest();
        
    }
}