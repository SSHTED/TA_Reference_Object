/*
* @Desc : OfficeTeamsConnector
* @Author : Yeseul.Jin
* @Date : 2019-11-07
* @Version : 1.0
* 
* @Method :
*  
* 
* @Modified : 
*   ---------------------------------------------
*   NO | Date       | Modifier      | Description 
*   ---------------------------------------------
*   1. | 2019-11-07 | Yeseul.Jin    | 최초작성
*   2. | 2019-11-08 | Ha-eun Lee    | 
*/
global without sharing class OfficeTeamsConnector {
    
    @future (callout=true)
    global static void send(String webhookName, String themeColor, String title, String text, String rId) {
        sendToOfficeTeames(webhookName
                           , setValue(System.Label.OFFICE_TEAMS_CONTEXT_URL, 'MessageCard', themeColor, title, text
                                      , new List<PotentialActionWrap>{new PotentialActionWrap('OpenUri', '상세 내용보기 ↗', new List<TargetsWrap>{new TargetsWrap('default', rId)})}));
    }
    global static void send_batch(String webhookName, String themeColor, String title, String text, String rId) {
        sendToOfficeTeames(webhookName
                           , setValue(System.Label.OFFICE_TEAMS_CONTEXT_URL, 'MessageCard', themeColor, title, text
                                      , new List<PotentialActionWrap>{new PotentialActionWrap('OpenUri', '상세 내용보기 ↗', new List<TargetsWrap>{new TargetsWrap('default', rId)})}));
    }
    
    global static void saveOfficeTeamsQueue(String webhookName, String connectColor, String title, String text, String rId) {
        OfficeTeamsQueue__c data = new OfficeTeamsQueue__c(
            Webhook_Name__c  = webhookName
            , themeColor__c = connectColor
            , text__c = text
            , title__c = title
            , recordId__c  = rId
        );
        
        insert data;          
        
        createOfficeTeamsSendScheduler();
    }
    
    private static void createOfficeTeamsSendScheduler() {
        
        Datetime schDate = System.now().addSeconds(5);
        
        OfficeTeamsSendScheduler SCH_BATCH = new OfficeTeamsSendScheduler();
        
        String SCH_NAME = 'Office Teams Send Scheduler : ' + schDate.getTime();
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
    
    global static void sendToOfficeTeames(String webhookName, TeamsWrap body) {
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        
        if(webhookName == 'Chatter') // 채터 알림
            req.setEndpoint(System.Label.OFFICE_TEAMS_WEBHOOK_URL);
        else if(webhookName == 'Council') // HR
          req.setEndpoint(System.Label.OFFICE_TEAMS_COUNCIL_URL);
        else if(webhookName == 'CS1') // CS1
          req.setEndpoint(System.Label.OFFICE_TEAMS_CS1_URL);
        else if(webhookName == 'CS2') // CS1
          req.setEndpoint(System.Label.OFFICE_TEAMS_CS2_URL);
        else if(webhookName == 'CX') // CX
          req.setEndpoint(System.Label.OFFICE_TEAMS_CX_URL);
        
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json'); 
        req.setBody(JSON.serialize((Object)body).replace('target_type', '@type'));
        if(!Test.isRunningTest())  res = h.send(req);        
    }
     
    public static TeamsWrap setValue(String context, String body_type, String themeColor, String title, String text, List<PotentialActionWrap> potentialAction) {
        return new TeamsWrap(context, body_type, themeColor, title, text, potentialAction);
    }
    
    global class TargetsWrap {
        global String os {set; get;}
        global String uri {set; get;}
        global TargetsWrap(String os, String id) {
            this.os = os;
            this.uri = 'https://' + DomainCreator.getLightningHostname() + '/' + id;
        }
    }
    global class PotentialActionWrap {
        global String target_type {set; get;}
        global String name {set; get;}
        global List<TargetsWrap> targets {set; get;}
        global PotentialActionWrap(String target_type, String name, List<TargetsWrap> targets) {
            this.target_type = target_type;
            this.name = name;
            this.targets = targets;
        }
    }
    global class TeamsWrap {
        global String context {set; get;}
        global String body_type {set; get;}
        global String themeColor {set; get;}
        global String title {set; get;}
        global String text {set; get;}
        global List<PotentialActionWrap> potentialAction {set; get;}
        
        global TeamsWrap(String context, String body_type, String themeColor, String title, String text, List<PotentialActionWrap> potentialAction) {
            this.context = context;
            this.body_type = body_type;
            this.themeColor = themeColor;
            this.title = title;
            this.text = text;
            this.potentialAction = potentialAction;
        }
    }
}