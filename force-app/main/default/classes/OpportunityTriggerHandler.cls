public without sharing class OpportunityTriggerHandler {

	private Boolean isExecuting {get;set;} 	// Web Service와 구분하기 위한 Context 파라미터
	private Integer size {get;set;} 		// Trigger에서 Execute된 List Size

	public OpportunityTriggerHandler(Boolean isExecuting, Integer size){
		this.isExecuting = isExecuting;
		this.size = size;

		System.debug('#isExecuting [' + isExecuting + '] #size [' + size + ']');
	}

	public void onBeforeDelete(List<Opportunity> dels, Map<Id, Opportunity> delMap){
		if(size == 1) {
            Opportunity__c cOP = [SELECT Id FROM Opportunity__c WHERE Opportunity_External_Key__c = :dels.get(0).Id LIMIT 1];
            delete cOP;
        }
	}

    public void onBeforeInsert(List<Opportunity> news){
        System.debug('size ? : ' + news.size());

        if(news.size() == 1){ // 221222_이호재 AutoNumber 기능 추가
            // System.debug('코드는 1 ? : ' + news.get(0).OpportunityCode__c);

            String thisYear = String.valueOf(System.today().year());
            String cutThisYear = 'O-' + thisYear.substring(2) + '-%';
            System.debug('올해는 ? ' + cutThisYear);
            List<Opportunity> pCodeList = [SELECT Id, OpportunityCode__c
                                           FROM Opportunity
                                           WHERE OpportunityCode__c LIKE :cutThisYear
                                           ORDER BY OpportunityCode__c DESC
                                           LIMIT 1];
            System.debug('pCodeList는 ? ' + pCodeList);
            System.debug('pCodeList size는 ? ' + pCodeList.size());
            
            // O-22-0011
            if(pCodeList == null || pCodeList.size() == 0){
                System.debug('new !');
                news.get(0).OpportunityCode__c = 'O-' + thisYear.substring(2) + '-0001';
            }else if(pCodeList != null || pCodeList.size() == 1){
                System.debug('old !');
                String pCode;
                for(Opportunity p : pCodeList){
                    pCode = String.valueOf(p.OpportunityCode__c);
                }
                System.debug('pCode는 ? ' + pCode);

                Integer subCode = Integer.valueOf(pCode.substring(5));
                System.debug('subCode ? ' + subCode);
                String plusOneCode = String.valueOf(subCode + 1);
                System.debug('plusOneCode ? ' + plusOneCode);

                String lpadedCode = plusOneCode.leftPad(4, '0');
                System.debug('엘패드 ? ' + lpadedCode);
                news.get(0).OpportunityCode__c = 'O-' + thisYear.substring(2) + '-' + lpadedCode;
            }
        }
	}

	public void onAfterInsert(List<Opportunity> news){
        System.debug('Id ? ' + news.get(0).Id);
        if(size == 1) {
            OpportunityToOppty(news.get(0).Id);
        }
	}

	public void onAfterUpdate(List<Opportunity> olds, List<Opportunity> news, Map<Id, Opportunity> newMap){
		if(size == 1) {
            OpportunityToOppty(news.get(0).Id);
        }
	}

    public void OpportunityToOppty(Id opId){
        Opportunity OP = [SELECT Id, Name, AccountId, Vendor_Sales_Reps__c, Type__c, StageName, Sales_Division__c
                          , Win_Probability__c, CloseDate, Fld_Renewal__c, Type, LeadSource
                          , F_ParentOppty__c, F_ParentOppty__r.Name, ExpectedRevenue__c, Resource_MM__c, Main_Contact__c
                          , F_Mobile__c, F_Position__c, F_Mail__c, F_dept__c, F_phone__c, Fld_SalesInfo__c, Order_Reason__c
                          , F_Partner__c, F_PartnerPerson__c, Customer_Scheduled_Date__c, Resource_Prepared_Date__c, Amount__c
                          // 220818 아래 행 추가
                          , CreatedDate, ProjectExpectEndDate__c, ProjectExpectStartDate__c, Priority__c, InputPersonNum__c, LastModifiedDate
                          FROM Opportunity
                          WHERE Id = :opId
                          LIMIT 1];

        List<Opportunity__c> cOPList = [SELECT Id FROM Opportunity__c WHERE Name = :OP.F_ParentOppty__r.Name LIMIT 1];

        String pOPId = null;

        if(cOPList.size() == 1) pOPId = cOPList.get(0).Id;

        Opportunity__c cOP = new Opportunity__c(
            Name = OP.Name
            , Opportunity_External_Key__c = OP.Id
            , Account__c = OP.AccountId
            , SFDC_Reps__c = OP.Vendor_Sales_Reps__c
            , Type__c = OP.Type__c
            , StageName__c = OP.StageName
            , Field2__c = OP.Sales_Division__c
            , Sales_Estimated_Date__c = OP.CloseDate
            , Fld_Renewal__c = OP.Fld_Renewal__c
            , WinType__c = OP.Type
            , LeadSource__c = OP.LeadSource
            , F_ParentOppty__c = pOPId
            // 영업기회(상위기회) <= opportunity
            , Amount__c = OP.Amount__c
            , Resource_MM__c = OP.Resource_MM__c
            , Main_Contact__c = OP.Main_Contact__c
            , Fld_SalesInfo__c = OP.Fld_SalesInfo__c
            , Field1__c = OP.Order_Reason__c
            , F_Partner__c = OP.F_Partner__c
            , F_PartnerPerson__c = OP.F_PartnerPerson__c
            , Customer_Scheduled_Date__c = OP.Customer_Scheduled_Date__c
            , Resource_Prepared_Date__c = OP.Resource_Prepared_Date__c
            // 220818 아래 행 추가
            , ProjectExpectEndDate__c = OP.ProjectExpectEndDate__c
            , ProjectExpectStartDate__c = OP.ProjectExpectStartDate__c
            , Priority__c = OP.Priority__c
            , InputPersonNum__c = OP.InputPersonNum__c
            , OpportunityId__c = OP.Id
        );
        upsert cOP Opportunity_External_Key__c; 
    }
}