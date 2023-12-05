@isTest
public class UTIL_CustomNoti_TEST {
@TestSetup
    static void setup(){
        Id pId = [SELECT Id, UserLicenseId FROM Profile WHERE UserLicense.Name = 'Salesforce' and Name in ('System Administrator', '시스템 관리자') LIMIT 1].Id;
        
        User u = new User(UserName='MaterialManagement@Test.com'
                     , LastName='Test'
                     , Email='MaterialManagement@Test.com'
                     , Alias='Test'
                     , TimeZoneSidKey='America/Los_Angeles'
                     , EmailEncodingKey='UTF-8'
                     , LanguageLocaleKey='en_US'
                     , LocaleSidKey='en_US'
                     , EmployeeNumber = '1234567890'
                     , ProfileId = pId);
        
        insert u;

        Account acc = new Account(Name='Test');
        insert acc;
    }

    @isTest
    static void UTIL_CustomNotiTest(){
        Test.setMock(HttpCalloutMock.class, new CustomNotification_MOCK());  
        Test.startTest();
        User u = [SELECT ID FROM User WHERE LastName = 'Test'];
        Account acc = [SELECT ID FROM Account LIMIT 1];
        List<String> param = new List<String>{acc.Id, 'title', 'body'};
        List<ID> userIds = new List<ID>{u.Id};

        UTIL_CustomNoti uq = new UTIL_CustomNoti();
        UTIL_CustomNoti.sendNoti(param, userIds);
        UTIL_CustomNoti.sendNoti_Batch(param, userIds);
        
        Test.stopTest();
    }

    public with sharing class CustomNotification_MOCK implements HttpCalloutMock  {


        public HTTPResponse respond(HTTPRequest req) {

            String method = req.getMethod();
            
            if('GET'.equals(method.toUpperCase())){
                notiResWrapper resItem = new notiResWrapper(
                    true,
                    'CustomNotificationType',
                    null,
                    new List<notiItemResWrapper>{
                        new notiItemResWrapper(
                            'TEST',
                            '0MLB0000000PAwjOAG',
                            new notiAttrResWrapper(
                                'CustomNotificationType',
                                'services/data/v46.0/tooling/sobjects/CustomNotificationType/0MLB0000000PAwjOAG'
                            )
                        )
                    },
                    1,
                    1
                );
                HttpResponse res = new HttpResponse();
                res.setStatus('OK');
                res.setStatusCode(200);
                res.setBody(
                    JSON.serialize(resItem)
                );
                return res;
            } else {
                HttpResponse res = new HttpResponse();
                res.setStatus('OK');
                res.setStatusCode(200);
                return res;
            }
        }
    }
    public class notiResWrapper {
        Boolean done;
        String entityTypeName;
        String queryLocator;
        List<notiItemResWrapper> records;
        Decimal size;
        Decimal totalSize;
        public notiResWrapper(Boolean done, String entityTypeName, String queryLocator,List<notiItemResWrapper> records, Decimal size, Decimal totalSize ){
            this.done = done;
            this.entityTypeName = entityTypeName;
            this.queryLocator = queryLocator;
            this.records = records;
        }
    }

    public class notiItemResWrapper{
        String CustomNotifTypeName;
        String Id;
        notiAttrResWrapper attributes;        
        
        public notiItemResWrapper( String CustomNotifTypeName, String Id, notiAttrResWrapper attributes){
            this.CustomNotifTypeName = CustomNotifTypeName;
            this.Id = Id;
            this.attributes = attributes;
        }
    }

    public class notiAttrResWrapper{
        String type;
        String url;
        
        public notiAttrResWrapper( String type, String url){
            this.type = type;
            this.url = url;
        }
    }
}