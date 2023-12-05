/**
* Desc : UTIL_Connector_OfficeTeams
*
* @Method : 
* 
* @Author : Yong-Jin, Cha
* @Date : 2021-11-17
* @Version : 1.0
* @Modified : 
*  ---------------------------------------------
*  NO | Date       | Modifier      | Description
*  ---------------------------------------------
*  1. | 2021-11-17 | Yong-Jin, Cha | 최초작성
*/
global without sharing class UTIL_Connector_OfficeTeams {
    
    @future(callout=true)
    global static void calloutSend(String developerName, String title, String text)
    {
        send(developerName, title, text, null, null, null);
    }
    
    @future(callout=true)
    global static void calloutSend(String developerName, String title, String text, String clickText, String clickUrl, String themeColor)
    {
        
        send(developerName, title, text, clickText, clickUrl, themeColor);
    }
    
    global static void unCalloutSend(String developerName, String title, String text)
    {
        send(developerName, title, text, null, null, null);
    }
    
    global static void unCalloutSend(String developerName, String title, String text, String clickText, String clickUrl, String themeColor)
    {
        send(developerName, title, text, clickText, clickUrl, themeColor);
    }
    
    private static void send(String developerName, String title, String text, String clickText, String clickUrl, String themeColor) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();           
        
        MT_Connector_OfficeTeams_Setting__mdt info = getInfo(developerName);
        
        List<PotentialActionWrap> potentialAction = new List<PotentialActionWrap>();
        
        if(clickUrl != null) {
            potentialAction.add(new PotentialActionWrap(clickText, clickUrl));
        } 
      
        TeamsWrap reqBody = new TeamsWrap(
        	title
            , text
            , themeColor == null ? info.Connect_Color__c : themeColor
            , potentialAction
        );
        req.setEndpoint(info.Webhook_URL__c);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(JSON.serialize((Object)reqBody).replace('target_type', '@type'));
        if(!Test.isRunningTest())	res = h.send(req);
    }
    
    private static MT_Connector_OfficeTeams_Setting__mdt getInfo(String developerName) {
        return [
            select
            	Id
            	, MasterLabel
            	, Connect_Color__c
            	, Webhook_URL__c
            from
            	 MT_Connector_OfficeTeams_Setting__mdt
            where
            	DeveloperName = :developerName
            and Active__c = true
        ];
    }
    
    global class TargetsWrap {
        global String os {set; get;}
        global String uri {set; get;}
        global TargetsWrap(String uri) {
            this.os = 'default';
            this.uri = uri;
        }
    }
    
    global class PotentialActionWrap {
        global String target_type {set; get;}
        global String name {set; get;}
        global List<TargetsWrap> targets {set; get;}
        global PotentialActionWrap(String name, String uri) {
            this.target_type = 'OpenUri';
            this.name = name;
            this.targets = new List<TargetsWrap> { new TargetsWrap(uri) };
        }
    }
    
    global class TeamsWrap {
        global String context {set; get;}
        global String body_type {set; get;}
        global String themeColor {set; get;}
        global String title {set; get;}
        global String text {set; get;}
        global List<PotentialActionWrap> potentialAction {set; get;}
        
        global TeamsWrap(String title, String text, String themeColor, List<PotentialActionWrap> potentialAction) {
            this.context = 'https://schema.org/extensions';
            this.body_type = 'MessageCard';
            this.themeColor = themeColor;
            this.title = title;
            this.text = text;
            this.potentialAction = potentialAction;
        }
    }
}