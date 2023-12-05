/*
* @Desc : OfficeTeamsSendBatch
* @Author : Yeseul.Jin
* @Date : 2019-11-07
* @Version : 1.0
* 
* @Method :
*  
* 
* @Modified : 
* 	---------------------------------------------
* 	NO | Date       | Modifier      | Description 
* 	---------------------------------------------
* 	1. | 2019-11-07 | Yeseul.Jin    | 최초작성
* 	2. | 2020-12-04 | Yeseul.Jin    | 최초작성
*/ 
global class OfficeTeamsSendBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String query = ' SELECT '
                    + '		Id '
                    + ' 	, recordId__c '
            		+ ' 	, Webhook_Name__c '
                    + ' 	, text__c '
                    + ' 	, themeColor__c '
                    + ' 	, title__c '
                    + ' 	, IsSent__c '
                    + ' 	, SentDatime__c '
                    + ' FROM '
                    + ' 	OfficeTeamsQueue__c '
                    + ' WHERE '
                    + ' 	IsSent__c = false '
                    + ' ORDER BY CreatedDate ';
           
		return Database.getQueryLocator(query);                
    }
    
    global void execute(Database.BatchableContext BC, List<OfficeTeamsQueue__c> queue) {
        OfficeTeamsQueue__c officeQueue = queue.get(0);
        // 팀즈(Teams)에 메시지 전송
  		OfficeTeamsConnector.send_batch(officeQueue.Webhook_Name__c, officeQueue.themeColor__c, officeQueue.title__c, officeQueue.text__c, officeQueue.recordId__c);
        officeQueue.IsSent__c = true;
        officeQueue.SentDatime__c = System.now();
        update officeQueue;    
    }
    
    global void finish(Database.BatchableContext BC) {
         List<CronTrigger> cronList = [SELECT Id
                                      FROM CronTrigger
                                      WHERE CronJobDetail.Name like 'Office Teams Send Scheduler%' 
                                      ORDER BY CreatedDate limit 1];
        // JOB 조회 후 중단시킨다. 
        if(cronList.size() > 0) {
            for(Integer i = 0; i<cronList.size(); i++) {
                System.abortJob(cronList.get(i).Id);
            }
        }
    }
}