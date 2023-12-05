/**
* Desc : BatchOppTransfer Test
*
* @Author : Min-Gyu, Bang
* @Date : 2022. 9. 8.
* @Version : 1.0
*/
  @isTest
   public class BatchOppTransfer_Test {

 @TestSetup
    static void setup(){        
        String TestId =System.Label.TestId;

        Opportunity op = new Opportunity(
            Name='TestOp'
          , StageName='초기접촉'
          , Sales_Division__c='Tableau'
          , CloseDate= date.Today()+ 10
        );
        insert op;

        Opportunity__c opc = new Opportunity__c(
            Name='TestOp'
          , Field2__c='Tableau'
          , StageName__c='초기접촉'
          , Sales_Estimated_Date__c= date.Today()+ 10
          , OpportunityId__c=op.id
            
        );
        insert opc;

        Task t = new Task  (Subject = 'Test'
                            , OwnerId = System.UserInfo.getUserId()
                            , WhatId =opc.id
                            );
        insert t;

        Event e = new Event(Subject = 'Test'
                            , OwnerId = System.UserInfo.getUserId()
                            , StartDateTime = DateTime.now()
                            , EndDateTime = DateTime.now().addHours(1)
                            , Description = 'text'
                            , ShowAs = 'Free'
                            , WhatId =opc.id
                            );
        insert e;

        EmailMessage em = new EmailMessage(Subject = 'Test'
        , FromAddress ='Test@test.com'
        , TextBody  = 'text'
        , RelatedToId  =opc.id
        );
insert em;
        
        
        
    }
    static testMethod void Transfer()
    {
        // Batch Test Code
        String EndPoint =System.Label.EndPoint;  
        Test.setMock(HttpCalloutMock.class, new TestMock());
        Test.startTest();          
        Httprequest httpReq = new Httprequest();
        HttpResponse httpRes = new HttpResponse();
        httpReq.setEndpoint(EndPoint);
        Http http = new Http();       
        string resBody = httpRes.getBody();
        
        
        BatchOppTransfer batch = new BatchOppTransfer();
        String query = 'SELECT id, OpportunityId__c FROM Opportunity__c where OpportunityId__c != null ';
        Database.executeBatch(batch, 200);
                Test.stopTest(); 

    }
      
       
       
    }