@isTest
public with sharing class INF_Connector_Dooray_TEST {

    static Customer_Org__c customer_org;
    static Account account;
    static PMS_Project__c pms_Project;

    static {

        account = new Account (
            Name = 'HDC 현대산업개발'
            , OwnerId = System.UserInfo.getUserId()
        );

        insert account;
        
        customer_org = new Customer_Org__c (
            Customer__c = account.Id
            , Name = 'HDC 현대산업개발'
        );

        insert customer_org;

        pms_Project= new PMS_Project__c (
            EndCustomer__c = customer_org.Customer__c
            , Name = '23년 현대산업개발 유지보수 계약 (23년)_Mant_Ren'
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
        String reqBody = '{"source":{"type":"member","member":{"id":"2606364147532967461","name":"차용진","userCode":"a101dkbmc3","emailAddress":"dkbmc3@hdc-dvp.com"}},"post":{"createdAt":"2023-04-06T08:41:09.396+09:00","dueDate":"2023-04-07T08:00:00+09:00","dueDateFlag":true,"updatedAt":"2023-04-06T08:41:09.396+09:00","priority":"highest","body":{"mimeType":"text/x-markdown","content":"내용(data:image/ㄹㄴㄴㄴㄴㄴㄴㄴ=)","emptyContent":false},"id":"3510079381992133136","subject":"두레이 제목3333","number":10,"attachFileIds":[]}}';
        req.requestBody     = Blob.valueOf(reqBody);

        req.requestURI = '/services/apexrest/dooray/iclick'; //Request URL
        req.httpMethod = 'POST';        

        RestContext.request = req;
        RestContext.response= res;
        
        INF_Connector_Dooray.doPost();

        //String reqBody2      = JSON.serialize(param);
        String reqBody2 = '{"source":{"type":"member","member":{"id":"2606364147532967461","name":"차용진","userCode":"a101dkbmc3","emailAddress":"dkbmc3@hdc-dvp.com"}},"post":{"createdAt":"2023-04-06T08:41:09.396+09:00","dueDate":"2023-04-07T08:00:00+09:00","dueDateFlag":true,"updatedAt":"2023-04-06T08:41:09.396+09:00","priority":"highest","body":{"mimeType":"text/x-markdown","content":"내용(data:image/ㄹㄴㄴㄴㄴㄴㄴㄴ=)","emptyContent":false},"id":"3510079381992133136","subject":"두레이 제목3333","number":10,"attachFileIds":[]}}';
        req.requestBody     = Blob.valueOf(reqBody2);

        req.requestURI = '/services/apexrest/dooray/icontrols'; //Request URL
        req.httpMethod = 'POST';        

        RestContext.request = req;
        RestContext.response= res;
        
		INF_Connector_Dooray.doPost();
        
        Test.stopTest();
    }
}