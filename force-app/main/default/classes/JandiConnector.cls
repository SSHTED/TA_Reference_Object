/**
* Desc : JandiConnector
*
* @Method : 
*		- sendByTrigger(webhookName, connectColor, body_Link_Url, body_Link_Text, body_Text, title, description, imageUrl)
*		- sendByBatch(webhookName, connectColor, body_Link_Url, body_Link_Text, body_Text, connectInfoList)
*		- sendByBatch(webhookName, connectColor, body_Link_Url, body_Link_Text, body_Text, connectInfo)
* 
* @Author : Yong-Jin, Cha
* @Date : 2019-08-11
* @Version : 1.0
* @Modified : 
*  ---------------------------------------------
*  NO | Date       | Modifier      | Description
*  ---------------------------------------------
*  1. | 2019-08-11 | Yong-Jin, Cha | 최초작성
*/
global without sharing class JandiConnector {
    
    @future (callout=true)
    global static void sendByTrigger(String webhookName, String connectColor, String body_Link_Url, String body_Link_Text, String body_Text, String title, String description, String imageUrl) {   
        sendWebService(webhookName, setValue(connectColor, body_Link_Url, body_Link_Text, body_Text, new List<ConnectInfoWarp>{new ConnectInfoWarp(title, description, imageUrl)}));
    }
    
    global static void sendByBatch(String webhookName, String connectColor, String body_Link_Url, String body_Link_Text, String body_Text, List<ConnectInfoWarp> connectInfoList) {      
        sendWebService(webhookName, setValue(connectColor, body_Link_Url, body_Link_Text, body_Text, connectInfoList));
    }
    
    global static void sendByBatch(String webhookName, String connectColor, String body_Link_Url, String body_Link_Text, String body_Text, ConnectInfoWarp connectInfo) {
        sendWebService(webhookName, setValue(connectColor, body_Link_Url, body_Link_Text, body_Text, new List<ConnectInfoWarp>{connectInfo}));
    }
    
    global static void sendByBatch(String webhookName, String connectColor, String body_Link_Url, String body_Link_Text, String body_Text, String title, String description, String imageUrl) {
        sendWebService(webhookName, setValue(connectColor, body_Link_Url, body_Link_Text, body_Text, new List<ConnectInfoWarp>{new ConnectInfoWarp(title, description, imageUrl)}));
    }
    
    global static void saveJandiQueue(String webhookName, String connectColor, String body_Link_Url, String body_Link_Text, String body_Text, String title, String description, String imageUrl) {
        JandiQueue__c JQ = new JandiQueue__c(
            webhookName__c = webhookName
            , connectColor__c = connectColor
            , body_Link_Url__c = body_Link_Url
        	, body_Link_Text__c = body_Link_Text
            , body_Text__c = body_Text
            , title__c = title
            , description__c = description
            , imageUrl__c = imageUrl
        );
        
        insert JQ;
        
        createJandiScheduler();
    }
    
    private static void createJandiScheduler() {
        
        Datetime schDate = System.now().addSeconds(5);
        
        JandiSendScheduler SCH_BATCH = new JandiSendScheduler();
        
        String SCH_NAME = 'Jandi Send Scheduler : ' + schDate.getTime();
        String SCH_TIME = String.format('{0} {1} {2} {3} {4} ? {5}', new String[]{
            String.valueOf(schDate.second())
                , String.valueOf(schDate.minute())
                , String.valueOf(schDate.hour())
                , String.valueOf(schDate.day())
                , String.valueOf(schDate.month())
                , String.valueOf(schDate.year())
            }
        );
        Id cronjobId = system.schedule(SCH_NAME, SCH_TIME, SCH_BATCH);
        
        System.debug('# cronjobId : ' + cronjobId);
    } 
    
    private static void sendWebService(String webhookName, JandiConnectWarp reqBody) {
        
        Jandi_Webhook_Setting__mdt WebhookInfo = (Jandi_Webhook_Setting__mdt) Cache.Org.get(JandiWebhookCache.class, webhookName);
        
        if(WebhookInfo != null) {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            
            // Color 미 지정시 Default Color 적용
            if(reqBody.connectColor == null || reqBody.connectColor == '') {
                reqBody.connectColor = WebhookInfo.Connect_Color__c;
            }                
            
            req.setEndpoint(WebhookInfo.Webhook_URL__c);
            req.setMethod('POST');
            req.setHeader('Accept', 'application/vnd.tosslab.jandi-v2+json');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize((Object)reqBody));
            if(!Test.isRunningTest())	res = h.send(req);
        }        
    }


   	private static JandiConnectWarp setValue(String connectColor, String body_Link_Url, String body_Link_Text, String body_Text, List<ConnectInfoWarp> connectInfoList) {
       String template = '[{0}](https://{1}{2}) {3}';
       String body = String.format(template, new List<String>{body_Link_Text, URL.getSalesforceBaseUrl().getHost(), body_Link_Url, body_Text});
       return new JandiConnectWarp(body, connectColor, connectInfoList);
   	}

    global class ConnectInfoWarp {
        global String title {set; get;}
        global String description {set; get;}
        global String imageUrl {set; get;}
        
        global ConnectInfoWarp(String title, String description, String imageUrl) {
            this.title = title;
            this.description = description == null ? '' : description.replaceAll('<[^>]+>','Å').replaceAll('ÅÅ','\n').replaceAll('Å','');
            this.imageUrl = imageUrl;
        }
    }

    global class JandiConnectWarp {
        global String body {set; get;}
        global String connectColor {set; get;}
        global List<ConnectInfoWarp> connectInfo {set; get;}
        
        global JandiConnectWarp(String body, String connectColor, List<ConnectInfoWarp> connectInfo) {
            this.body = body;
            this.connectColor = connectColor;
            this.connectInfo = connectInfo;
        }
    }
}