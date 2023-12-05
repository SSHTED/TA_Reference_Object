global class PMS_PjtResourceActualSumBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    global String BatchName = 'PMS_PjtResourceActualSumBatch';
    global String OrgName = '';
    global String resultLog = '';
    global Integer SuccessCount = 0;
    global Integer FailCount = 0;
    global Integer BatchExecuteCount = 0;
    global Long BatchStartDateTimeLong = 0;

    global PMS_PjtResourceActualSumBatch() {
       
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        System.debug('[START] ' + BatchName);

        String SOQL = ' select '
                    + ' 	ActualCnt__c '
                    + ' 	, ActualType__c '
                    + ' 	, EmployeeId__c '
                    + ' 	, Id '
                    + ' 	, IsActive__c '
                    + ' 	, IsActual__c '
                    + ' 	, IsActual_Bill__c '
                    + ' 	, IsActual_NonBill__c '
                    + ' 	, IsActual_Training__c '
                    + ' 	, Name '
                    + ' 	, PjtPartnerEmpId__c '
                    + ' 	, ResourceType__c '
                    + ' 	, FM_WorkStatus__c '
                    + ' from '
                    + ' 	PMS_PjtResource__c '
                   // + ' where '
            		//+ '		PjtPartnerEmpId__c != null '
            		//+' and EmployeeId__c = null '
            		+ '	order by '
            		+ '		Name ';

        return Database.getQueryLocator(SOQL);
    }
    
    global void execute(Database.BatchableContext BC, List<PMS_PjtResource__c> scope) {
        
        try {
            for(PMS_PjtResource__c c : scope) {
                List<PMS_PjtManpower__c> manList = [
                    select 
                        FM_ActualType__c
                        , FM_IsActual__c
                        , FM_IsActual_Bill__c
                        , FM_IsActual_NonBill__c
                        , FM_IsActual_Training__c
                        , Id
                        , Name
                        , BillingType__c
                        , InputStartDate__c

                    from
                        PMS_PjtManpower__c
                    where
                    	PjtResourceId__c = :c.Id
                    and (FM_IsActual__c = true AND FM_EmploymentStatus__c = true)
                    order by BillingType__c, InputStartDate__c
                ];
                
                if(manList.size() > 0) {
                    c.ActualCnt__c = manList.size();
                    c.ActualType__c = manList.get(0).FM_ActualType__c;
                    c.IsActual__c = manList.get(0).FM_IsActual__c;
                    c.IsActual_Bill__c = manList.get(0).FM_IsActual_Bill__c;
                    c.IsActual_NonBill__c = manList.get(0).FM_IsActual_NonBill__c;
                    c.IsActual_Training__c = manList.get(0).FM_IsActual_Training__c;
                    if(c.PjtPartnerEmpId__c != null && c.EmployeeId__c == null){
                        c.IsActive__c = true;
                        System.debug('협력사 인원, 자원 활성여부 활성화');
                    }
                   
                }
                if(manList.size() <= 0 || manList == null){
                    // System.debug('이름 ? ' + c.Name);
                    c.ActualCnt__c = 0;
                    c.ActualType__c = '대기(비가동)';
                    c.IsActual__c = false;
                    c.IsActual_Bill__c = false;
                    c.IsActual_NonBill__c = false;
                    c.IsActual_Training__c = false;
                    if(c.PjtPartnerEmpId__c != null && c.EmployeeId__c == null){
                        c.IsActive__c = false;
                        System.debug('협력사 인원, 자원 활성여부 비활성화');
                    }
                    
                     if(c.FM_WorkStatus__c == '퇴직') c.IsActive__c = false;
                }
            }
            
            upsert scope;
            
            SuccessCount++;
            
        } catch(Exception e) {
            
            FailCount++;
            
            System.debug('[EXECUTE Error] ' + BatchName);
            System.debug(e);
            resultLog += '\n[EXECUTE Error] (' + scope.get(0).Id + ') ' + e;
            
            throw e;
        }
    } 

    global void finish(Database.BatchableContext BC) {
        System.debug('[FINISH] ' + BatchName + ' ( ' + BatchExecuteCount + ' )' + ' [S] ' + SuccessCount + ' [F] ' + FailCount);

        // Notification 알림
          UTIL_CustomNoti.sendNoti_Batch(
            new List<String>{
                System.UserInfo.getUserId()
                , 'PMS_PjtResourceActualSumBatch 배치완료'
                , FailCount == 0 ? '데이터 집계가 완료 되었습니다.' : '데이터 집계 오류 : ' + resultLog
            }
            , new List<Id>{ 
                System.UserInfo.getUserId()
            }
        );
        
    }
}