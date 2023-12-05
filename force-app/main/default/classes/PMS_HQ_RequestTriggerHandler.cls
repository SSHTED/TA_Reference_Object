public with sharing class PMS_HQ_RequestTriggerHandler {

	private Boolean isExecuting {get;set;} 	// Web Service와 구분하기 위한 Context 파라미터
	private Integer size {get;set;} 		// Trigger에서 Execute된 List Size

	public PMS_HQ_RequestTriggerHandler(Boolean isExecuting, Integer size){
		this.isExecuting = isExecuting;
		this.size = size;

		System.debug('#isExecuting [' + isExecuting + '] #size [' + size + ']');
	}

	public void onBeforeDelete(List<sObject> dels, Map<Id, sObject> delMap){
		// Business Logic
	}

	public void onBeforeInsert(List<sObject> news){
		// Business Logic
	}

	public void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
		// Business Logic
	}

	public void onAfterDelete(List<sObject> dels, Map<Id, sObject> delMap){
		// Business Logic
	}

	public void onAfterInsert(List<PMS_HQ_Request__c> news){
		// Business Logic
		if(this.size == 1) {
            String ProjectId = '';
            String projectName = null;            
            String typeName = '본부 요청 사항';
            String createdByName = System.UserInfo.getName();
            String name = news.get(0).Name;
            String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/PMS_HQ_Request__c/' + news.get(0).Id + '/view';
            String activatorId = news.get(0).Activator__c;
            
            List<String> toAddresses = new List<String>();
			
            
            if(news.get(0).ProjectId__c != null) {
                ProjectId = news.get(0).ProjectId__c;                
                projectName = [select Name from PMS_Project__c where Id = :ProjectId limit 1].Name;
                toAddresses.addAll(UTIL_Email.getPMS_ToAddresses(ProjectId, activatorId));
            }

            toAddresses.add(System.UserInfo.getUserEmail());

			System.debug('ActionHQ__c ? : ' + news.get(0).ActionHQ__c);

			// 221219_이호재 영업기획팀이 요청접수부서일 경우 주진용 상무 알림 메일 발송
			String salesPlan = [SELECT Id, Name, Email FROM User WHERE Name = '주진용'].Email;
			System.debug('salesPlan 1 ? ' + salesPlan);

			if(news.get(0).ActionHQ__c != null && news.get(0).ActionHQ__c == '영업기획 팀'){
				toAddresses.add(salesPlan);
				System.debug('salesPlan 2 ? ' + salesPlan);
			}else if(news.get(0).ActionHQ__c == null || news.get(0).ActionHQ__c == 'EPMO'){
				toAddresses.addAll(UTIL_Email.getEPMOAddresses());
			}
			System.debug('toAddresses ? ' + toAddresses);
            
			// 221110_이호재 박승호 본부장 수신 중복으로 인한 참조에서 제외 요청
             List<String> ccAddresses = UTIL_Email.getEPMOAddresses();
           
               
            
            UTIL_Email.sendEmailPmsNoti(toAddresses, ccAddresses, typeName, projectName, createdByName, name, recordUrl, news.get(0).Id);
            /* 221220_이호재 김동식 팀장 요청으로 [알림] 메일과 중복으로 인한 주석 처리
			UTIL_Email.sendEmailPMONoti(UTIL_Email.getPMOAddresses(), typeName, createdByName, name, recordUrl);*/
        }
	}

	public void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> newMap){
		// Business Logic
	}
}