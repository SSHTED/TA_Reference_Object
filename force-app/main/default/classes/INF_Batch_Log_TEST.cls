@isTest
public class INF_Batch_Log_TEST {

    static testMethod void myUnitTest() {
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        INF_Batch_Log.BatchLogParamWrap param = new INF_Batch_Log.BatchLogParamWrap();
        
        param.BatchName = 'sampleBatch';
        param.IsSandbox = true;
        param.LogExternalKey  = '123456789012345678_sampleBatch_asfadsfdf';
        param.OrgId  = '123456789012345678';
        
        param.TotalBatches = 0;
        param.BatchesProcessed = 0;
        param.BatchesFailed = 0;
        param.TotalRows = 0;
        param.RowsProcessed = 0;
        param.RowsFailed = 0;
        param.ResultMessage = '';

        String reqBody      = JSON.serialize(param);
        req.requestBody     = Blob.valueOf(reqBody);

        req.requestURI = '/services/apexrest/batchlog/start'; //Request URL
        req.httpMethod = 'POST';        

        RestContext.request = req;
        RestContext.response= res;
        
        INF_Batch_Log.doPost();
        
        INF_Batch_Log.BatchLogParamWrap param2 = new INF_Batch_Log.BatchLogParamWrap();
        
        param2.BatchName = 'sampleBatch';
        param2.IsSandbox = true;
        param2.LogExternalKey  = '123456789012345678_sampleBatch_asfadsfdf';
        param2.OrgId  = '123456789012345678';
        
        param2.TotalBatches = 0;
        param2.BatchesProcessed = 0;
        param2.BatchesFailed = 0;
        param2.TotalRows = 0;
        param2.RowsProcessed = 0;
        param2.RowsFailed = 0;
        param2.ResultMessage = '';

        String reqBody2      = JSON.serialize(param);
        req.requestBody     = Blob.valueOf(reqBody2);

        req.requestURI = '/services/apexrest/batchlog/finish'; //Request URL
        req.httpMethod = 'POST';        

        RestContext.request = req;
        RestContext.response= res;

        // String textBody = RestContext.request.params.get('textBody');
/*
        String template_code = 'CONT0001';
        String to = '01011112222';
        String contents = '내용';
        String contactId = null;
        String accountId = null;
        String openhouseId = null;
        String happycallId = null;
        String templateId = hdc_smstemplate.Id;
        String content = '내용';
        Datetime reservationDatime = null;
*/
        
 
		INF_Batch_Log.doPost();
        
        Test.stopTest();
    }
}