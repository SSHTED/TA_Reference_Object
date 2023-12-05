public with sharing class PMS_PjtPartnerEmpTriggerHandler {
    
    private Boolean isExecuting {get;set;} 	// Web Service와 구분하기 위한 Context 파라미터
    private Integer size {get;set;} 		// Trigger에서 Execute된 List Size
    
    public PMS_PjtPartnerEmpTriggerHandler(Boolean isExecuting, Integer size){
        this.isExecuting = isExecuting;
        this.size = size;
        
        System.debug('#isExecuting [' + isExecuting + '] #size [' + size + ']');
    }
    
    public void onBeforeDelete(List<sObject> dels, Map<Id, sObject> delMap){
        // Business Logic
    }
    
    public void onBeforeInsert(List<PMS_PjtPartnerEmp__c> news){
        if(size == 1) {
            Integer year = System.today().year();
            String yy = String.valueOf(year).subString(2, 4);
            String filter = yy + '%';
            
            List<PMS_PjtPartnerEmp__c> empList = [select EmpNumber__c from PMS_PjtPartnerEmp__c where EmpNumber__c like :filter order by EmpNumber__c desc limit 1];
            
            if(empList.size() == 0) {
                news[0].EmpNumber__c = yy + '9001';
            } else {
                Integer empNum = Integer.valueOf(empList.get(0).EmpNumber__c.subString(3, 6)) + 1;
                news[0].EmpNumber__c = yy + '9' + String.valueOf(empNum).leftPad(3, '0');
            }
        }
    }
    
    public void onBeforeUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
        // Business Logic
    }
    
    public void onAfterDelete(List<sObject> dels, Map<Id, sObject> delMap){
        // Business Logic
    }
    
    public void onAfterInsert(List<PMS_PjtPartnerEmp__c> news){
        List<PMS_PjtResource__c> prList = new List<PMS_PjtResource__c>();
        if(size == 1){
            for(PMS_PjtPartnerEmp__c e : news){
                List<PMS_PjtPartner__c> PjtPartnerList=  [select id , name from PMS_PjtPartner__c where id =:e.PjtPartnerId__c limit 1];
              
                // 프로젝트 자원 자동 등록
                prList.add(
                    new PMS_PjtResource__c (
                        PjtPartnerEmpId__c  = e.Id
                        , IsActive__c = true
                        , Name = e.Name + ' (' + PjtPartnerList[0].name + ')'
                        , ResourceType__c = '협력사 인력'
                    )
                );
            }
            insert prList;
        }
        
    }
    
    public void onAfterUpdate(List<sObject> olds, List<sObject> news, Map<Id, sObject> newMap){
        // Business Logic
    }
}