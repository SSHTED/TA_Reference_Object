public with sharing class PMS_PjtResourceTriggerHandler {

	private Boolean isExecuting {get;set;} 	// Web Service와 구분하기 위한 Context 파라미터
	private Integer size {get;set;} 		// Trigger에서 Execute된 List Size

	public PMS_PjtResourceTriggerHandler(Boolean isExecuting, Integer size){
		this.isExecuting = isExecuting;
		this.size = size;

		System.debug('#isExecuting [' + isExecuting + '] #size [' + size + ']');
	}

	public void onBeforeDelete(List<sObject> dels, Map<Id, sObject> delMap){
		// Business Logic
	}

	public void onBeforeInsert(List<PMS_PjtResource__c> news){
		// Business Logic
        if(size == 1) {
            PMS_PjtResource__c n = news.get(0);
            
            n.ResourceBizType__c = '해당없음';
            /*if(n.ResourceType__c == '직원' && n.EmployeeId__c != null) { // 230308_이호재 주석, EmployeeCreate 트리거로 이동
                List<Employee__c> empList = [select Name, Affiliation_company__c, FM_Team__c, FM_HQ__c from Employee__c where Id = :n.EmployeeId__c limit 1];
                if(empList.size() == 1) {
                    n.Name = empList.get(0).Name + ' (' + empList.get(0).Affiliation_company__c + ')';
                    if(empList.get(0).FM_Team__c != null && empList.get(0).FM_Team__c.indexOf('CBU') > -1) {
                        n.ResourceBizType__c = 'CBU';
                    } else if(empList.get(0).FM_HQ__c != null && empList.get(0).FM_HQ__c.indexOf('CRM컨설팅') > -1) {
                        n.ResourceBizType__c = 'EBU';
                    }
                }
            } else*/
			/*if(n.ResourceType__c == '협력사 인력' && n.PjtPartnerEmpId__c != null) { // 230329_이호재 주석, PMS_PjtPartnerEmpTriggerHandler로 이동
               	List<PMS_PjtPartnerEmp__c> partnerEmpList = [select Name, PjtPartnerId__r.Name from PMS_PjtPartnerEmp__c where Id = :n.PjtPartnerEmpId__c limit 1];
                if(partnerEmpList.size() == 1) {
                    n.Name = partnerEmpList.get(0).Name + ' (' + partnerEmpList.get(0).PjtPartnerId__r.Name + ')';
                }
            }*/
        }
	}

	public void onBeforeUpdate(List<PMS_PjtResource__c> olds, List<PMS_PjtResource__c> news, Map<Id, PMS_PjtResource__c> oldMap, Map<Id, PMS_PjtResource__c> newMap){
		// Business Logic
        if(size == 1){
            PMS_PjtResource__c n = news.get(0);
            System.debug('onBeforeUpdate');
            if(n.FM_WorkStatus__c =='휴직'){
                n.IsActive__c = false;
            }
            if(n.FM_WorkStatus__c =='재직'){
                n.IsActive__c = true;
            }            
        } 
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