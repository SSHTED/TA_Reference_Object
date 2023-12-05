/**
* Desc : BatchOppTransfer
*        1. 커스텀 영업기회 Task,Event,Email 이관
*
* @Author : Min-Gyu, Bang
* @Date : 2022. 9. 8.
* @Version : 1.0
* @Modify :
*/       
global class BatchOppTransfer implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{

global Set<Id> opcIds;
global Map<id, Opportunity__c> oppMap;
global database.querylocator start(Database.BatchableContext BC){
    String query = 'SELECT id, OpportunityId__c,LastModifiedDate  FROM Opportunity__c where OpportunityId__c != null AND IsBatchCk__c =False';
    system.debug('# query : ' + query);
    
    return Database.getQueryLocator(query);
}

global void execute(Database.BatchableContext BC, List<Opportunity__c> scope){

    opcIds = new Set<id>();   
    oppMap = new Map<id,Opportunity__c>();
    String idC ;
    String result = 'S';
    String errorMsg = '';
    String endPoint = System.Label.endPoint;

    for(Opportunity__c opc : scope){
        

        String OpcIds = '\''+ opc.id + '\'';
        Httprequest httpReq = new Httprequest();
    HttpResponse httpRes = new HttpResponse();
    Http http = new Http();
    List<String> resultList = new List<String>();

    String resBody = null;
    String SearchString = 'SELECT+id+FROM+EVENT+Where+WhatId='+OpcIds+'+AND+WhatId!=null'; //
    httpReq.setMethod('GET');
    String myUrl = '/services/data/v55.0/queryAll/?q='+SearchString;
    httpReq.setEndpoint(endPoint + myUrl);
    httpReq.setTimeout(120000);                   
    httpReq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());     
    httpReq.setHeader('Content-Type', 'application/json');   
    httpRes = http.send(httpReq);
    resBody = httpRes.getBody();
    Object outputObject = (Object)JSON.deserializeUntyped(resBody);
                    System.debug('resBody       '+resBody);

    Map<string,Object> outputMap = (Map<string,Object>)outputObject;
                            System.debug('outputMap         '+outputMap);

    List<Object> records = (List<Object>)outputMap.get('records');
    if( (Decimal)outputMap.get('totalSize')>0){
    if(records.size()>0){
    for(Object o : records) {
        Map<String, Object> m = (Map<String, Object>) o;
        resultList.add(String.valueOf(m.get('Id')));
    }      	   
    //WhatId TestID 인 이벤트의 아이디 가지고있음
            System.debug(resultList.size());
    }
}
                 
        List<Opportunity__c> pathOpp = [SELECT id,OpportunityId__c from Opportunity__c Where id=:opc.id];

        for(Integer p =0; p < resultList.size(); p++){
            try{
        Httprequest req = new Httprequest();
        Http h = new Http();
        req.setEndpoint(endPoint+'/services/data/v54.0/sobjects/Event/'+resultList[p]+'?_HttpMethod=PATCH');
        req.setMethod('POST');

        req.setTimeout(120000);
                   
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());     
        req.setHeader('Content-Type', 'application/json');
        req.setBody('{ "Whatid" :"'+opc.OpportunityId__c +'"}');
                HttpResponse res = h.send(req);
       
            }
            catch(Exception e) {
            result = 'E';
            errorMsg = e.getMessage();
        }
      
        }
        opc.IsBatchCk__c =true;
    
            Httprequest httpReqT= new Httprequest();
            HttpResponse httpResT = new HttpResponse();
            List<String> resultListT = new List<String>();
            Http httpT = new Http();
            String resBodyT = null;
            String SearchStringT = 'SELECT+id+FROM+Task+Where+WhatId='+OpcIds+'+AND+WhatId!=null'; //
            String myUrlT = '/services/data/v55.0/queryAll/?q='+SearchStringT;
            httpReqT.setMethod('GET');
            httpReqT.setEndpoint(endPoint + myUrlT);
            httpReqT.setTimeout(120000);                   
            httpReqT.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());     
            httpReqT.setHeader('Content-Type', 'application/json');   
            httpResT = httpT.send(httpReqT);
            resBodyT = httpResT.getBody();
            Object outputObjectT = (Object)JSON.deserializeUntyped(resBodyT);
            Map<string,Object> outputMapT = (Map<string,Object>)outputObjectT;
            if( (Decimal)outputMapT.get('totalSize')>0){
            List<Object> recordsT = (List<Object>)outputMapT.get('records');
            if(recordsT.size()>0){
            for(Object o : recordsT) {
                Map<String, Object> m = (Map<String, Object>) o;
                resultListT.add(String.valueOf(m.get('Id')));
            }      	            
            }
        }
      

     for(Integer p =0; p < resultListT.size(); p++){
        try{

        Httprequest reqT = new Httprequest();
        Http ht = new Http();        
        reqT.setEndpoint(endPoint+'/services/data/v54.0/sobjects/Task/'+resultListT[p]+'?_HttpMethod=PATCH');
        reqT.setMethod('POST');
        reqT.setTimeout(120000);
        reqT.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());     
        reqT.setHeader('Content-Type', 'application/json');
        reqT.setBody('{ "Whatid" :"'+ opc.OpportunityId__c+'"}');
                HttpResponse resT = ht.send(reqT);
            
            opc.IsBatchCk__c =true;
        }

            catch(Exception e) {
                result = 'E';
                errorMsg = e.getMessage();
            }
        }                    





    }
    /*for(Opportunity__c opc : scope){
//List 형태 
opcIds.add(opc.id);// 중복 불가
//sopIds.add(opc.opc);
oppMap.put(opc.id,opc);
}*/
    
    
   


}
global void finish(Database.BatchableContext BC){
system.debug('# Finish Batch Process');
}
}