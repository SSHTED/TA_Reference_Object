/**
* Desc : ResultRestInboundController
*
* @Method : 
*  - handleInboundCustomerOrg() : 고객 Org에서 넘어온 문의사항 데이터 Queue에 저장
* @Author : Yong-Jin, Cha
* @Date : 2019-08-11
* @Version : 1.0
* @Modified : 
*  ---------------------------------------------
*  NO | Date       | Modifier      | Description
*  ---------------------------------------------
*  1. | 2019-08-11 | Yong-Jin, Cha | 최초작성
*  2. | 2019-08-11 | Ye-Seul, Jin  | 고객 문의사항 접수 메서드 추가
*  3. | 2019-08-16 | Ha-Eun, Lee   | urlMapping 주소, handleInboundCustomerOrg 메서드 수정
*/
@RestResource(urlMapping='/support/*')
global class ResultRestInboundController {
    
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
        rsCls.orgId = req.requestURI.replace('/support/', '').substring(0, req.requestURI.replace('/support/', '').lastIndexOf('/'));
        rsCls.recordId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        handleInboundCustomerOrg(resMap, rsCls.orgId, rsCls.recordId);
        
        return rsCls;
    }
    
    global static void handleInboundCustomerOrg(Map<String, Object> resMap, String orgId, String recordId) {
        
        DateTime dt = DateTime.newInstance((Long)resMap.get('RequestDate'));
        
        Support_Manager_Queues__c queue = new Support_Manager_Queues__c();
        queue.Name = (String)resMap.get('Name');
        queue.Channel__c = 'Customer Org';
        queue.Request_Date__c = dt;
        queue.Emergency__c =  (String)resMap.get('Emergency');
        queue.Request_Content__c = (String)resMap.get('RequestContent');
        queue.Request_Type__c = (String)resMap.get('RequestType');
        queue.Requester__c = (String)resMap.get('Requester');
        queue.Requester_Email__c = (String)resMap.get('RequesterEmail');
        queue.Requester_Phone__c = (String)resMap.get('RequesterPhone');
        queue.Record_Id__c = (String)resMap.get('Id');
        queue.Request_Title__c = (String)resMap.get('Title');
        queue.Request_Deadline__c = resMap.get('RequestDeadline') == null || String.valueOf(resMap.get('RequestDeadline')) == '' ? null : parseDate((String)resMap.get('RequestDeadline'));
        
        try {
            Customer_Org__c corg = [
                SELECT
                	id 
                    , Customer__r.Name 
                FROM
                	Customer_Org__c 
                WHERE
                	Org_Id__c =: orgId
            ];
            
            if(corg != null) {
                queue.Customer_Org__c = corg.id; 
                if(corg.Customer__r.Name != null) {
                    //Account acc = [SELECT Id, Name FROM Account WHERE Id = :corg.Customer__c];
                    queue.Customer__c = corg.Customer__r.Name;
                }
                insert queue;  
            }
        } catch(Exception e) {
            System.debug('Exception : ' + e);
        }
        
    }
           
    private static Date parseDate(String dt) {
        Integer y = Integer.valueOf(dt.substring(0, 4));
        Integer m = Integer.valueOf(dt.substring(4, 6));
        Integer d = Integer.valueOf(dt.substring(6, 8));        
        return date.newinstance(y, m, d);
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