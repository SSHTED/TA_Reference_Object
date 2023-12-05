@RestResource(urlmapping = '/batchlog/*')
global without sharing class INF_Batch_Log {

    @HttpPost
    global static PostResultWrap doPost() {

        PostResultWrap result = new PostResultWrap();

        RestRequest request = RestContext.request;
        
        String reqURI = request.requestURI;
        String uriType = reqURI.substring(reqURI.lastIndexOf('/')+1);

        System.debug('# reqURI : ' + reqURI);
        System.debug('# uriType : ' + uriType);

        /**
        for(String key : request.headers.keySet()) {
            System.debug(key + ' : ' + request.headers.get(key));
        }
        /**/

        String param = RestContext.request.requestBody.toString();

        //Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(param);
        BatchLogParamWrap m = (BatchLogParamWrap)JSON.deserialize(param, BatchLogParamWrap.class);
        
        if('start' == uriType) {
            List<Customer_Org__c> coList = [select Id from Customer_Org__c where Org_Id__c = :m.OrgId];
            String CustomerOrgId = null;
            if(coList.size() == 1) {
                CustomerOrgId = coList.get(0).Id;
            }   
            insert new DK_BatchLog__c(
            	BatchName__c = m.BatchName
                , IsSandbox__c = m.IsSandbox
                , LogExternalKey__c = m.LogExternalKey
                , OrgId__c = m.OrgId
                , CustomerOrgId__c = CustomerOrgId
            );
        } else if('finish' == uriType) {
            DK_BatchLog__c log = new DK_BatchLog__c(
            	LogExternalKey__c = m.LogExternalKey
                , TotalBatches__c = m.TotalBatches
                , BatchesProcessed__c = m.BatchesProcessed
                , BatchesFailed__c = m.BatchesFailed
                , TotalRows__c = m.TotalRows
                , RowsProcessed__c = m.RowsProcessed
                , RowsFailed__c = m.RowsFailed                
                , ResultMessage__c = m.ResultMessage
                , EndDate__c = System.now()
            );
            
            upsert log LogExternalKey__c;
        }
        
        result.RequestCode = '200';
        result.Message = 'OK';
        
        return result;
    }
    
    global class BatchLogParamWrap {
        global String BatchName;
        global Boolean IsSandbox;
        global String LogExternalKey;
        global String OrgId;
        
        global Decimal TotalBatches;
        global Decimal BatchesProcessed;
        global Decimal BatchesFailed;
        global Decimal TotalRows;
        global Decimal RowsProcessed;        
        global Decimal RowsFailed;
        global String ResultMessage;
    }
    
    global class PostResultWrap {
        global String RequestCode;
        global String Message;
    }
}