public with sharing class PMS_PjtEvalSettleTriggerHandler {

	private Boolean isExecuting {get;set;} 	// Web Service와 구분하기 위한 Context 파라미터
	private Integer size {get;set;} 		// Trigger에서 Execute된 List Size

	public PMS_PjtEvalSettleTriggerHandler(Boolean isExecuting, Integer size){
		this.isExecuting = isExecuting;
		this.size = size;

		System.debug('#isExecuting [' + isExecuting + '] #size [' + size + ']');
	}

	public void onBeforeDelete(List<sObject> dels, Map<Id, sObject> delMap){
		// Business Logic
	}

	public void onBeforeInsert(List<PMS_PjtEvalSettle__c> news){
		if(this.size == 1) {
            if(news.get(0).ProjectId__c != null && news.get(0).PjtResourceId__c != null) {
                List<PMS_PjtManpower__c> pList = [select Rank__c, OrgName__c, HQ__c, Division__c, Team__c, PjtResourceId__r.FM_SFGrade__c, PjtResourceId__r.FM_TechGrade__c
                                                  from PMS_PjtManpower__c 
                                                  where ProjectId__c = :news.get(0).ProjectId__c
                                                  and PjtResourceId__c = :news.get(0).PjtResourceId__c];
                if(pList.size() == 1) {                    
                    news.get(0).Rank__c = pList.get(0).Rank__c;
                    news.get(0).OrgName__c = pList.get(0).OrgName__c;
                    news.get(0).HQ__c = pList.get(0).HQ__c;
                    news.get(0).Division__c = pList.get(0).Division__c;
                    news.get(0).Team__c = pList.get(0).Team__c;
                    
                    news.get(0).SFGrade__c = pList.get(0).PjtResourceId__r.FM_SFGrade__c;
                    news.get(0).TechGrade__c  = pList.get(0).PjtResourceId__r.FM_TechGrade__c;
                    //news.get(0).WorkStatus__c  = pList.get(0).Team__c;
                }
            }
        }
	}

	public void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
		// Business Logic
	}

	public void onAfterDelete(List<sObject> dels, Map<Id, sObject> delMap){
		// Business Logic
	}

	public void onAfterInsert(List<sObject> news){
		// Business Logic
	}

	public void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> newMap){
		// Business Logic
	}
}