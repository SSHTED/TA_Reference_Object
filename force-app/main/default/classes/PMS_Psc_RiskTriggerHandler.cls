public with sharing class PMS_Psc_RiskTriggerHandler {

    private Boolean isExecuting {get;set;}  // Web Service와 구분하기 위한 Context 파라미터
    private Integer size {get;set;}         // Trigger에서 Execute된 List Size

    public PMS_Psc_RiskTriggerHandler(Boolean isExecuting, Integer size){
        this.isExecuting = isExecuting;
        this.size = size;

        System.debug('#isExecuting [' + isExecuting + '] #size [' + size + ']');
    }

    public void onBeforeDelete(List<sObject> dels, Map<Id, sObject> delMap){
        // Business Logic
    }

    public void onBeforeInsert(List<PMS_Psc_Risk__c> news){
        if(this.size == 1) {
            if(news.get(0).PSCId__c != null) {
                List<PMS_PSC__c> pscList = [select ProjectId__c, ProjectId__r.EndCustomer__c from PMS_PSC__c where Id = :news.get(0).PSCId__c];
                if(pscList.size() == 1) {
                    if(news.get(0).ProjectId__c == null) {
                        news.get(0).ProjectId__c = pscList.get(0).ProjectId__c;
                    }
                    if(news.get(0).AccountId__c == null) {
                        news.get(0).AccountId__c = pscList.get(0).ProjectId__r.EndCustomer__c;
                    }
                }
            } else if(news.get(0).ProjectId__c != null) {
                List<PMS_Project__c> pList = [select Id, EndCustomer__c from PMS_Project__c where Id = :news.get(0).ProjectId__c];
                if(pList.size() == 1) {
                    if(news.get(0).AccountId__c == null) {
                        news.get(0).AccountId__c = pList.get(0).EndCustomer__c;
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

    public void onAfterInsert(List<PMS_Psc_Risk__c> news){
        // Business Logic
        if(this.size == 1) {
            if(news.get(0).ProjectId__c != null) {
                String ProjectId = news.get(0).ProjectId__c;
                String typeName = '위험 사항';                
                String projectName = [select Name from PMS_Project__c where Id = :ProjectId limit 1].Name;
                String createdByName = System.UserInfo.getName();
                String name = news.get(0).Name;
                String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/PMS_Psc_Risk__c/' + news.get(0).Id + '/view';
                String activatorId = news.get(0).EmpActivatorId__c;                
                
                List<String> toAddresses = UTIL_Email.getPMS_ToAddresses(ProjectId, activatorId);
                toAddresses.addAll(UTIL_Email.getEPMOAddresses());
                List<String> ccAddresses = UTIL_Email.getCXHQAddresses();
                
                UTIL_Email.sendEmailPmsNoti(toAddresses, ccAddresses, typeName, projectName, createdByName, name, recordUrl, news.get(0).Id);
            }
        }
    }

    public void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> newMap){
        // Business Logic
    }

}