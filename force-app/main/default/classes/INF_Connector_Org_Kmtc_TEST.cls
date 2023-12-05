@isTest
public with sharing class INF_Connector_Org_Kmtc_TEST {

    static Customer_Org__c customer_org;
    static Account account;
    static PMS_Project__c pms_Project;

    static {

        account = new Account (
            Name = '고려해운'
            , OwnerId = System.UserInfo.getUserId()
        );

        insert account;
        
        customer_org = new Customer_Org__c (
            Customer__c = account.Id
            , Name = '고려해운'
        );

        insert customer_org;

        pms_Project= new PMS_Project__c (
            EndCustomer__c = customer_org.Customer__c
            , Name = '23년 고려해운 유지보수 계약 (23년)_Mant_Ren'
            , Status__c = 'Active'
            , ContractStartDate__c = System.today()
            , ContractEndDate__c = System.today()
            , PerformedStage__c = '운영(SM)'
            , ProjectType__c ='SM'
        );

        insert pms_Project;
    }

    static testMethod void myUnitTest() {
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        //String reqBody      = JSON.serialize(param);
        String reqBody = '{"rId":"a0f2u000009xCS5AAM","title":"데이터 연동 테스트2","rNo":"SR-2023-000004","rType":"Change request","requester":"CHOEIJH","reqDate":"20230711120000","deadline":"20230714","expectedDays":0.5,"actualDays":0.5,"status":"Waiting for customer reply","importance":"High"}';
        req.requestBody     = Blob.valueOf(reqBody);

        req.requestURI = '/services/apexrest/org-kmtc/upsert'; //Request URL
        req.httpMethod = 'POST';        

        RestContext.request = req;
        RestContext.response= res;
        
        INF_Connector_Org_Kmtc.doPost();
        
        Test.stopTest();
    }
}