@isTest
public class TestRestApi_Test {
    
    @TestSetup
    static void setup(){
        
        Opportunity__c opc = new Opportunity__c(
            Name='TestOp'
            , Field2__c='Tableau'
            , StageName__c='초기접촉'
            , Sales_Estimated_Date__c= date.Today()+ 10
        );
        insert opc;
        
        
        
        Event e = new Event(Subject = 'Test'
                            , OwnerId = System.UserInfo.getUserId()
                            , StartDateTime = DateTime.now()
                            , EndDateTime = DateTime.now().addHours(1)
                            , Description = 'text'
                            , ShowAs = 'Free'
                            , WhatId =opc.id
                           );
        insert e;
        
    }
    static testMethod void SearchE(){ 
        String EndPoint =System.Label.EndPoint;
        
 		Test.setMock(HttpCalloutMock.class, new TestMock());
        
        Test.startTest();          
        Httprequest httpReq = new Httprequest();
        HttpResponse httpRes = new HttpResponse();
        httpReq.setEndpoint(EndPoint);
        Http http = new Http();     
        string resBody = httpRes.getBody();
        TestRestAPi.doGet();
        
        Test.stopTest();
    }
    
    
}