public with sharing class PMS_PjtManpowerTriggerHandler {

	private Boolean isExecuting {get;set;} 	// Web Service와 구분하기 위한 Context 파라미터
	private Integer size {get;set;} 		// Trigger에서 Execute된 List Size
    private Map<String,String> OrgIdMapping = new Map<String,String>();
    private Map<String,String> projectHQMapping = new Map<String,String>();
    private Boolean partnerCheck {get;set;}

	public PMS_PjtManpowerTriggerHandler(Boolean isExecuting, Integer size){
		this.isExecuting = isExecuting;
		this.size = size;
        
        List<Organization__c> OrgNameList = [SELECT Id, Name  FROM  Organization__c];
        
        for(Organization__c org : OrgNameList){
            OrgIdMapping.put(org.Name , org.Id);
            projectHQMapping.put(org.Name , org.Id);
        }

		System.debug('#isExecuting [' + isExecuting + '] #size [' + size + ']');
	}

	public void onBeforeDelete(List<sObject> dels, Map<Id, sObject> delMap){
		// Business Logic
	}

	public void onBeforeInsert(List<PMS_PjtManpower__c> news){
        System.debug(news.get(0).FM_PartnerCheck__c);
        
		if(this.size == 1) {
            if(news.get(0).PjtResourceId__c != null) {
                List<PMS_PjtResource__c> pList = [select FM_Rank__c, FM_OrgName__c, FM_HQ__c, FM_Division__c, FM_Team__c from PMS_PjtResource__c where Id = :news.get(0).PjtResourceId__c];
                if(pList.size() == 1) {                  
                	news.get(0).Rank__c = pList.get(0).FM_Rank__c;
                    news.get(0).OrgName__c = pList.get(0).FM_OrgName__c;
                    news.get(0).HQ__c = pList.get(0).FM_HQ__c;
                    news.get(0).Division__c = pList.get(0).FM_Division__c;
                    news.get(0).Team__c = pList.get(0).FM_Team__c;
                }
            }
            if(news.get(0).FM_PartnerCheck__c == false) news.get(0).JoinHQ__c = OrgIdMapping.get(news.get(0).FM_EmpJoinHQ__c);
            if(news.get(0).FM_PartnerCheck__c == true) news.get(0).JoinHQ__c = projectHQMapping.get(news.get(0).FM_ProjectJoinHQ__c);
            if(news.get(0).FM_PartnerCheck__c == false) news.get(0).JoinDivision__c = OrgIdMapping.get(news.get(0).FM_JoinDivision__c);
            if(news.get(0).FM_PartnerCheck__c == true) news.get(0).JoinDivision__c = projectHQMapping.get(news.get(0).FM_JoinDivision_Partner__c);
            if(news.get(0).PlannedNonBillableMM__c == null) news.get(0).PlannedNonBillableMM__c = 0;
            if(news.get(0).PlannedBillableMM__c == null) news.get(0).PlannedBillableMM__c = 0;
            if(news.get(0).ActualNonBillableMM__c == null) news.get(0).ActualNonBillableMM__c = 0;
            if(news.get(0).ActualBillableMM__c == null) news.get(0).ActualBillableMM__c = 0;
			news.get(0).PlannedTotalInputMM__c = news.get(0).PlannedNonBillableMM__c + news.get(0).PlannedBillableMM__c; // 230405_이호재 계획 및 실제 총 투입 M/M 계산
            if(news.get(0).PlannedTotalInputMM__c ==0) news.get(0).PlannedTotalInputMM__c = null;
			news.get(0).ActualInputMM__c = news.get(0).ActualNonBillableMM__c + news.get(0).ActualBillableMM__c;
            if(news.get(0).ActualInputMM__c ==0) news.get(0).ActualInputMM__c = null;
 			if(news.get(0).PlannedNonBillableMM__c == 0) news.get(0).PlannedNonBillableMM__c = null;
        if(news.get(0).PlannedBillableMM__c == 0) news.get(0).PlannedBillableMM__c = null;
        if(news.get(0).ActualNonBillableMM__c == 0) news.get(0).ActualNonBillableMM__c = null;
        if(news.get(0).ActualBillableMM__c == 0) news.get(0).ActualBillableMM__c = null;
        }
	}

	public void onBeforeUpdate(List<PMS_PjtManpower__c> olds, List<PMS_PjtManpower__c> news, Map<Id, PMS_PjtManpower__c> oldMap, Map<Id, PMS_PjtManpower__c> newMap){
        List<PMS_PjtResource__c> pList = [select FM_Rank__c, FM_OrgName__c, FM_HQ__c, FM_Division__c, FM_Team__c from PMS_PjtResource__c where Id = :news.get(0).PjtResourceId__c];
        System.debug(news.get(0).FM_OrgId__c);
        if(pList.size() == 1) {
                	//news.get(0).Rank__c = pList.get(0).FM_Rank__c;
                    //news.get(0).OrgName__c = pList.get(0).FM_OrgName__c;
                    //news.get(0).HQ__c = pList.get(0).FM_HQ__c;
                    //news.get(0).Division__c = pList.get(0).FM_Division__c;
                    //news.get(0).Team__c = pList.get(0).FM_Team__c;
                }
         if(news.get(0).FM_PartnerCheck__c == false) news.get(0).JoinDivision__c = OrgIdMapping.get(news.get(0).FM_JoinDivision__c);
		if(news.get(0).FM_PartnerCheck__c == true) news.get(0).JoinDivision__c = projectHQMapping.get(news.get(0).FM_JoinDivision_Partner__c);        
        if(news.get(0).FM_PartnerCheck__c == false) news.get(0).JoinHQ__c = OrgIdMapping.get(news.get(0).FM_EmpJoinHQ__c);
        if(news.get(0).FM_PartnerCheck__c == true) news.get(0).JoinHQ__c = projectHQMapping.get(news.get(0).FM_ProjectJoinHQ__c);
        if(news.get(0).PlannedNonBillableMM__c == null) news.get(0).PlannedNonBillableMM__c = 0;
        if(news.get(0).PlannedBillableMM__c == null) news.get(0).PlannedBillableMM__c = 0;
        if(news.get(0).ActualNonBillableMM__c == null) news.get(0).ActualNonBillableMM__c = 0;
        if(news.get(0).ActualBillableMM__c == null) news.get(0).ActualBillableMM__c = 0;
        news.get(0).PlannedTotalInputMM__c = news.get(0).PlannedNonBillableMM__c + news.get(0).PlannedBillableMM__c;
        if(news.get(0).PlannedTotalInputMM__c ==0) news.get(0).PlannedTotalInputMM__c = null;
        news.get(0).ActualInputMM__c = news.get(0).ActualNonBillableMM__c + news.get(0).ActualBillableMM__c;
        if(news.get(0).ActualInputMM__c ==0) news.get(0).ActualInputMM__c = null;
		if(news.get(0).PlannedNonBillableMM__c == 0) news.get(0).PlannedNonBillableMM__c = null;
        if(news.get(0).PlannedBillableMM__c == 0) news.get(0).PlannedBillableMM__c = null;
        if(news.get(0).ActualNonBillableMM__c == 0) news.get(0).ActualNonBillableMM__c = null;
        if(news.get(0).ActualBillableMM__c == 0) news.get(0).ActualBillableMM__c = null;
	}

	public void onAfterDelete(List<sObject> dels, Map<Id, sObject> delMap){
		// Business Logic
	}

	public void onAfterInsert(List<PMS_PjtManpower__c> news){
	}

	public void onAfterUpdate(List<PMS_PjtManpower__c> olds, List<PMS_PjtManpower__c> news, Map<Id, PMS_PjtManpower__c> newMap){
	}
}