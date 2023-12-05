/**
* @Class : CustomNotification
*
* @Method : 
s*   - 
*
* @Author : JiMin, Kim
* @Date : 2019. 06. 26
* @Version : 1.0
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ----------------------------------------------
*  1. | 2019-06-26 | JiMin, Kim 	| 최초작성
*/
public inherited sharing class CustomNotification {

    private static final String BASE_URL = URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v46.0/';
    private static final String POST_URL = 'actions/standard/customNotificationAction';

    public class NotificationBody {
        String targetId {get;set;}
        String title {get;set;}
        String body {get;set;}

        public NotificationBody(String targetId, String title, String body){
            this.targetId = targetId;
            this.title = title;
            this.body = body;            
        }
    }

    public static void send(String strNotifiTypeDevName, list<NotificationBody> lstObjects, list<Id> lstRecipients) {
        String strResponse = null;
        if(String.isNotBlank(strNotifiTypeDevName)) {
            // Tooling API query
            String strResourceQuery = 'tooling/query/?q=select+id,customNotifTypeName+from+CustomNotificationType+where+DeveloperName=\''+ strNotifiTypeDevName +'\'';
            
            // OrgREST Custom Class returns the response as string
            strResponse = retriveResult(strResourceQuery, 'GET', null);
        }
        
        /* 
        Sample Response
        ----------------
        {
            done=true, 
            entityTypeName=CustomNotificationType, 
            queryLocator=null, 
            records=({
                CustomNotifTypeName=TEST, 
                Id=0MLB0000000PAwjOAG, 
                attributes={
                    type=CustomNotificationType, 
                    url=/services/data/v46.0/tooling/sobjects/CustomNotificationType/0MLB0000000PAwjOAG}    
                }),
            size=1, 
            totalSize=1
        }
        */
        map<String, Object> objData;
        
        if(String.isNotBlank(strResponse)) {
            // Deserializeing the response body
            map<String, Object> mapJsonData = (map<String, Object>)JSON.deserializeUntyped(strResponse);
            
            // Getting records
            list<Object> lstRecordsData = (list<Object>)mapJsonData.get('records');
            
            if(!lstRecordsData.isEmpty()) {
                // Converting each object to readable map to get the data
                objData = (map<String, Object>)lstRecordsData[0];      
            } 
            System.debug('Id ====> '+(String)objData.get('Id'));
        }
        
        /* 
         *   Sample JSON Body
         *   ---------------
         *   { "inputs" :
         *        [
         *          {
         *            "customNotifTypeId" : "0MLB0000000PAwjOAG",
         *            "recipientIds" : ["005B0000005lewTIAQ"],
         *            "title" : "opportunity Closed!",
         *            "body" : "Your High Priority Opportunity has been Closed.",
         *            "targetId" : "006B00000058gHEIAY"
         *          }
         *        ]
         *    }
         */
        
        
        /* 
         * Generating JSON body.
         * Below code work for bulk record process.
         * Recipients are User, Owner, Group or Queue Ids
         */
        if(!lstObjects.isEmpty() && !lstRecipients.isEmpty()) {
            JSONGenerator jsGen = JSON.createGenerator(true);
            jsGen.writeStartObject();
            jsGen.writeFieldName('inputs');
            jsGen.writeStartArray();
            
            for(NotificationBody noti : lstObjects) {
                jsGen.writeStartObject();
                // Custom Notification type id
                jsGen.writeStringField('customNotifTypeId', (String)objData.get('Id'));
                jsGen.writeFieldName('recipientIds');
                jsGen.writeStartArray();
                
                // adding mulitiple recipients if any 
                for(Id idRecipient : lstRecipients) {
                    jsGen.writeId(idRecipient);
                }
                
                jsGen.writeEndArray();
                // Notification titile
                jsGen.writeStringField('title', noti.title);
                // Notification body
                jsGen.writeStringField('body', noti.body);
                jsGen.writeStringField('targetId', noti.targetId);
                jsGen.writeEndObject();
            }
    
            jsGen.writeEndArray();
            jsGen.writeEndObject();
            
            // Converting JSON as String
            String strJson = jsGen.getAsString();
            System.debug('strJson ====> '+strJson);
            
            // POST URL to send custom notification
            
            // Sending post request to send custom notification
            String strPostResponse = retriveResult(POST_URL, 'POST', strJson);
        }
    }
    
    @TestVisible
    private static String retriveResult(String strResourceName, String strMethod, String strBody) {
        String response;
        String strEndPonitURL = BASE_URL + strResourceName;
        if(String.isNotBlank(strResourceName)) {
            HttpRequest httpRequest = new HttpRequest();  
            httpRequest.setMethod(strMethod);   
            httpRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());        
            httpRequest.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID()); 
            
            if(String.isNotBlank(strBody)) {
                httpRequest.setBody(strBody);
                httpRequest.setHeader('Content-Type', 'application/json');
            	httpRequest.setHeader('Accept', 'application/json');
            }
            
            httpRequest.setEndpoint(strEndPonitURL); 
            
            try {  
                Http http = new Http();
                if(!Test.isRunningTest()) {
                	HttpResponse httpResponse = http.send(httpRequest);  
                    if (httpResponse.getStatusCode() == 200 ) {  
                        response = httpResponse.getBody();  
                    } 
                    else {  
                        throw new CalloutException(httpResponse.getBody());  
                    }
                } else {
                    response = '{"done":true,"entityTypeName":"CustomNotificationType","queryLocator":null,"records":[{"CustomNotifTypeName":"TEST","Id":"0MLB0000000PAwjOAG","attributes":{"type":"CustomNotificationType","url":"/services/data/v46.0/tooling/sobjects/CustomNotificationType/0MLB0000000PAwjOAG"}}],"size":1,"totalSize":1}';
                }
            } 
            catch(Exception ex) {  
                throw ex;  
            }  
        } 
        return response;
    }
}