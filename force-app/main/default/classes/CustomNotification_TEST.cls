/**
* @Class : CustomNotification_TEST
*
* @Description : CustomNotification을 테스트 하기 위한 클래스 
*
* @Author : JiMin, Kim
* @Date : 2019. 06. 26
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ----------------------------------------------
*  1. | 2019-06-26 | JiMin, Kim 	| 최초작성
*/
@isTest
private class CustomNotification_TEST {
    @TestSetup static void makeData(){
        Lead l = new Lead(LastName = 'TEST Lead', Company = 'KAL');
        insert l;
    }

    @isTest static void unitTest(){
        
        Test.setMock(HttpCalloutMock.class, new CustomNotification_MOCK());        
        Test.startTest();
        Lead l = [SELECT Id FROM Lead LIMIT 1];
        CustomNotification.send(
            'TEST' // Notification Type 명
            , new List<CustomNotification.NotificationBody>{ // Send할 대상
                new CustomNotification.NotificationBody(
                    l.Id // targetId
                    , 'TEST Notification' // title <- sObject Name
                    , 'TEST NOTI BODY' // body <- 회람에 코멘트가 등록되었습니다. || 회람에 Action Detail이 등록되었습니다.
                )
            }
            , new list<Id>{ UserInfo.getUserId() } // 보낼 대상 (Users) -> Owner + Uni key 일치하는 회람 대상자들 전부
        );
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