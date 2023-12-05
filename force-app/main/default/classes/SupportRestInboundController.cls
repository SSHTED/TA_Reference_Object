/**
* Desc : SupportRestInboundController
*
* @Method : 
*  - 
* @Author : Ha-Eun, Lee
* @Date : 2019-08-20
* @Version : 1.0
* @Modified : 
*  ---------------------------------------------
*  NO | Date       | Modifier      | Description
*  ---------------------------------------------
*  1. | 2019-08-20 | Ha-Eun, Lee   | 최초작성
*/

@RestResource(urlMapping='/result/*')
global class SupportRestInboundController {
    
    @HttpPost
    global static ResultClass doPost() 
    {
        ResultClass rsCls = new ResultClass();
        RestRequest req = RestContext.request;
        
        System.debug('============================== [S] REST PARAMETERS =================================');
        Map<String, Object> resMap = (map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
        for(String key : resMap.keyset()) {
            System.debug('# '+ key + ' : ' + resMap.get(key));
        }
        System.debug('============================== [E] REST PARAMETERS =================================');
        
        rsCls.result = true;
        rsCls.requestURI = req.requestURI;
        rsCls.orgId = req.requestURI.replace('/result/', '').substring(0, req.requestURI.replace('/result/', '').lastIndexOf('/'));
        rsCls.recordId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        handleInboundRequest(resMap, rsCls.orgId, rsCls.recordId);

        return rsCls;
    }
    
    
    global static void handleInboundRequest(Map<String, Object> resMap, String orgId, String recordId) {
    
        
        Support_Manager__c data = [SELECT Id, Name, Record_Id__c FROM Support_Manager__c WHERE Record_Id__c = :recordId];
        
        System.debug(resMap);
        
        
        data.Name = (String)resMap.get('Name');
        data.Emergency__c =  (String)resMap.get('Emergency');
        data.Request_Content__c = (String)resMap.get('RequestContent');
        //data.Customer_Category__c = (String)resMap.get('CustomerCategory');
        data.Request_Type__c = (String)resMap.get('RequestType');
        data.Requester__c = (String)resMap.get('Requester');
        data.Requester_Email__c = (String)resMap.get('RequesterEmail');
        data.Requester_Phone__c = (String)resMap.get('RequesterPhone');
        data.Record_Id__c = (String)resMap.get('Id');
        
        update data;
    } 
    
    global class ResultClass {
        public Boolean result {get; set;}
        public String requestURI {get; set;}
        public String orgId {get; set;}
        public String recordId {get; set;}
        public String errorMsg {get; set;}
        public String errorCode {get; set;}
    }
}