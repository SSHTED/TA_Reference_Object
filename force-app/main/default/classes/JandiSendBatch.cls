/**
* Desc : JandiSendBatch
*
* @Method : 
*		- start(BC)
*		- execute(BC, scope)
*		- finish(BC)
* 
* @Author : Yong-Jin, Cha
* @Date : 2019-08-27
* @Version : 1.0
* @Modified : 
*  ---------------------------------------------
*  NO | Date       | Modifier      | Description
*  ---------------------------------------------
*  1. | 2019-08-27 | Yong-Jin, Cha | 최초작성
*/global class JandiSendBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    global Database.QueryLocator start(Database.BatchableContext BC) {

        System.debug('[START]');

        String SOQL = ' select  '
                    + ' 	body_Link_Text__c '
                    + ' 	, body_Link_Url__c '
                    + ' 	, body_Text__c '
                    + ' 	, connectColor__c '
                    + ' 	, description__c '
                    + ' 	, imageUrl__c '
                    + ' 	, title__c '
                    + ' 	, webhookName__c '
            		+ '		, IsSent__c '
            		+ '		, SentDatime__c '
                    + ' from '
                    + ' 	JandiQueue__c '
            		+ ' where '
            		+ '		IsSent__c = false '
                    + ' order by CreatedDate '
            		+ '		limit 10 ';

        return Database.getQueryLocator(SOQL);
    }
    
    global void execute(Database.BatchableContext BC, List<JandiQueue__c> scope) {
        
        JandiQueue__c JQ = scope.get(0);
        JandiConnector.sendByBatch(JQ.webhookName__c, JQ.connectColor__c, JQ.body_Link_Url__c, JQ.body_Link_Text__c, JQ.body_Text__c, JQ.title__c, JQ.description__c, JQ.imageUrl__c);
        JQ.IsSent__c = true;
        JQ.SentDatime__c = System.now();
        update JQ;
    }
    
    global void finish(Database.BatchableContext BC) {
        
        System.debug('[FINISH]');
        
        List<CronTrigger> ctList = [SELECT Id, CronJobDetailId, NextFireTime, PreviousFireTime, State, StartTime, EndTime
                          , CronExpression, TimeZoneSidKey, OwnerId, LastModifiedById, CreatedById, CreatedDate, TimesTriggered 
                          FROM CronTrigger
                         where CronJobDetail.Name like 'Jandi Send Scheduler%' order by CreatedDate limit 1];
        
        if(ctList.size() > 0) {
            for(Integer i = 0; i<ctList.size(); i++) {
				System.abortJob(ctList.get(i).Id);
            }
        }
    }
}