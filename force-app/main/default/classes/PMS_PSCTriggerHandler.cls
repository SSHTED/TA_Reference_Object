public with sharing class PMS_PSCTriggerHandler {

	private Boolean isExecuting {get;set;} 	// Web Service와 구분하기 위한 Context 파라미터
	private Integer size {get;set;} 		// Trigger에서 Execute된 List Size

	public PMS_PSCTriggerHandler(Boolean isExecuting, Integer size){
		this.isExecuting = isExecuting;
		this.size = size;

		System.debug('#isExecuting [' + isExecuting + '] #size [' + size + ']');
	}

	public void onBeforeDelete(List<sObject> dels, Map<Id, sObject> delMap){
		// Business Logic
	}

	public void onBeforeInsert(List<PMS_PSC__c> news){
        if(this.size == 1) {
            if(news.get(0).ProjectId__c != null) {
                List<PMS_Project__c> pjtList = [select PerformedStage__c from PMS_Project__c where Id = :news.get(0).ProjectId__c];
                if(pjtList.size() == 1) {
                    if(news.get(0).PerformedStage__c == null) {
                        news.get(0).PerformedStage__c = pjtList.get(0).PerformedStage__c;
                    }                    
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

	public void onAfterInsert(List<PMS_PSC__c> news){
		if(this.size == 1) {
            String typeName = 'PSC';
            String createdByName = System.UserInfo.getName();
            String name = news.get(0).Name;
            String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/PMS_PSC__c/' + news.get(0).Id + '/view';
            
            List<String> toAddresses = UTIL_Email.getEPMOAddresses();
            List<String> ccAdresses = UTIL_Email.getSC_SUPPORTAddress();
            
            UTIL_Email.sendEmailPMONoti(toAddresses, ccAdresses ,typeName, createdByName, name, recordUrl);
        }
	}

	public void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> newMap){
		// Business Logic
	}

}