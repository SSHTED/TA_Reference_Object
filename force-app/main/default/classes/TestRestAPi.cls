//@RestResource(urlMapping='/Event/*')
global with sharing class TestRestAPi  {
   

     global static  List<String> doGet() {
         String TestId =System.Label.TestId;
        String TestId2 =System.Label.TestId2;
Httprequest httpReq = new Httprequest();
HttpResponse httpRes = new HttpResponse();
Http http = new Http();
String resBody = null;
String SearchString = 'SELECT++id,+WhatId+FROM+EVENT+Where+WhatId='+TestId2; //
httpReq.setMethod('GET');
String endPoint = System.Label.endPoint;
String myUrl = '/services/data/v55.0/queryAll/?q='+SearchString;
httpReq.setEndpoint(endPoint + myUrl);
httpReq.setTimeout(120000);                   
httpReq.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());     
httpReq.setHeader('Content-Type', 'application/json');
//httpReq.setHeader('Sforce-Query-Options', 'batchSize=200');
httpRes = http.send(httpReq);
resBody = httpRes.getBody();
         System.debug('aaaaaaaaa          ::'+resBody);
Object outputObject = (Object)JSON.deserializeUntyped(resBody);
Map<string,Object> outputMap = (Map<string,Object>)outputObject;
List<Object> records = (List<Object>)outputMap.get('records');
List<String> resultList = new List<String>();
 for(Object o : records) {
    Map<String, Object> m = (Map<String, Object>) o;
    resultList.add(String.valueOf(m.get('Id')));
}         
         System.debug(resultList);

return resultList;
     }

}