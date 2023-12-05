/*
 * @Class : PMS_PjtManpowerBatch
 *
 * @Method : 
 *  - PMS_PjtManpowerBatch(Id recordId)
 *	- start(BC)
 *	- execute(BC, scope)
 *	- finish(BC)
 * 
 * @Author : hojae-lee
 * @Date : 2022-09-29
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2022-09-29 | hojae-lee     | 최초작성
 */
global class PMS_PjtManpowerBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{

    global String BatchName = 'PMS_PjtManpowerBatch';
    global String OrgName = '';
    global String resultLog = '';
    global Integer SuccessCount = 0;
    global Integer FailCount = 0;
    global Integer BatchExecuteCount = 0;
    global Long BatchStartDateTimeLong = 0;
    
    global String id;
    global PMS_PjtManpowerBatch(Id recordId){
        System.debug('recordId : ' + recordId);
        this.id = recordId;
        if(Test.isRunningTest()){
            id = [SELECT Id FROM PMS_Project__c LIMIT 1].Id;
        }
    }
   
    global Database.QueryLocator start(Database.BatchableContext BC){

        System.debug('[START] ' + BatchName);
		
        String SOQL = ' SELECT  '
                    + ' 	Id '
            		+ ' 	, Name '
                    + ' 	, IsPurchase__c '
                    + ' 	, ContractPlanEndDate__c '
                    + ' 	, InputEndDate__c '
                    + ' 	, PjtResourceId__r.EmployeeId__r.User__r.Name '
            		+ ' 	, PjtResourceId__r.Name '
                    + ' 	, PjtResourceId__r.PjtPartnerEmpId__r.Name '
                    + ' 	, ProjectId__c '
                    + ' 	, ProjectId__r.Name '
                    + ' 	, OrgName__c '
                    + ' 	, JoinHQ__c '
                    + ' 	, JoinDivision__c '
                    + ' 	, PlannedTotalInputMM__c '
                    + ' 	, ActualInputMM__c '
           			+ ' 	, ProjectId__r.ProjectManagerId__r.Name '
                    + ' 	, ProjectId__r.ProjectManagerId__c '
                    + ' 	, PjtResourceId__c '
                    + ' FROM '
                    + ' 	PMS_PjtManpower__c '
                    + ' WHERE '
                    + ' 	ProjectId__c = :id '
            		+ ' ORDER BY Name ';
            
        return Database.getQueryLocator(SOQL);
    }

    global void execute(Database.BatchableContext BC, List<PMS_PjtManpower__c> scope){
        try{
            System.debug('scope : ' + scope);
            System.debug('id : ' + id);
            System.debug('ProjectId__c : ' + scope.get(0).ProjectId__c);

            List<PMS_PjtJoinDivTeam__c> firstList = [SELECT Id FROM PMS_PjtJoinDivTeam__c WHERE ProjectId__c = :scope.get(0).ProjectId__c];
            for(PMS_PjtJoinDivTeam__c fl : firstList){
                fl.IsDeleted__c = true;
                fl.IsPM__c = false;
                fl.FM_DKBMC_Plan_MM__c = null;
                fl.FM_Partner_Plan_MM__c = null;
                fl.FM_DKBMC_Actual_MM__c = null;
                fl.FM_Partner_Actual_MM__c = null;
            }
            update firstList;

            List<AggregateResult> dvList = [SELECT JoinHQ__c, JoinDivision__c, SUM(PlannedTotalInputMM__c)sumP, SUM(ActualInputMM__c)sumA // OrgName__c, 
                                            FROM PMS_PjtManpower__c 
                                            WHERE ProjectId__c = :scope.get(0).ProjectId__c AND JoinHQ__c != null AND (OrgName__c = 'DK BMC' OR OrgName__c = 'Rainlight Soft')
                                            GROUP BY JoinHQ__c, JoinDivision__c];
            List<PMS_PjtManpower__c> pmList01 = [SELECT JoinHQ__c, JoinDivision__c, ProjectId__r.ProjectManagerId__c, PjtResourceId__c 
                                                FROM PMS_PjtManpower__c 
                                                WHERE ProjectId__c = :scope.get(0).ProjectId__c];

            List<PMS_PjtJoinDivTeam__c> jdtList = new List<PMS_PjtJoinDivTeam__c>();

            for(AggregateResult a : dvList){
                Decimal DKsumP_dv;
                Decimal DKsumA_dv;
                Decimal ETCsumP_dv;
                Decimal ETCsumA_dv;

                boolean isPm = false;

                //if(a.get('OrgName__c') == 'DK BMC'){
                    DKsumP_dv =  (Decimal)a.get('sumP');
                    DKsumA_dv =  (Decimal)a.get('sumA');
                //}

                for(PMS_PjtManpower__c pm : pmList01){
                    if(pm.ProjectId__r.ProjectManagerId__c == pm.PjtResourceId__c
                    && pm.JoinHQ__c == a.get('JoinHQ__c')
                    && pm.JoinDivision__c == a.get('JoinDivision__c')){
                        isPm = true;
                    }
                }

                if(a.get('JoinHQ__c') != null
                   // && a.get('OrgName__c') == 'DK BMC'
                  ){
                    jdtList.add(
                        new PMS_PjtJoinDivTeam__c(
                            ProjectId__c = scope.get(0).ProjectId__c
                            , HQ__c = (Id)a.get('JoinHQ__c')
                            , Division__c = (Id)a.get('JoinDivision__c')
                            , exId__c = scope.get(0).ProjectId__c + '_' + a.get('JoinHQ__c') + '_' + a.get('JoinDivision__c')
                            , FM_DKBMC_Plan_MM__c = DKsumP_dv      // DK BMC 누적 계획 MM
                            , FM_DKBMC_Actual_MM__c = DKsumA_dv    // DK BMC 누적 실적 MM
                            , IsPM__c = isPm
                            , IsDeleted__c = false
                        )
                    );
                    System.debug('jdtList : ' + jdtList);
                    upsert jdtList exId__c;
                }
            }
            
            List<AggregateResult> dvList02 = [SELECT JoinHQ__c, JoinDivision__c, SUM(PlannedTotalInputMM__c)sumP, SUM(ActualInputMM__c)sumA 
                                            FROM PMS_PjtManpower__c 
                                            WHERE ProjectId__c = :scope.get(0).ProjectId__c AND JoinHQ__c != null AND (OrgName__c != 'DK BMC' AND OrgName__c != 'Rainlight Soft')
                                            GROUP BY JoinHQ__c, JoinDivision__c];

            List<PMS_PjtJoinDivTeam__c> jdtList02 = new List<PMS_PjtJoinDivTeam__c>();
            
            for(AggregateResult a : dvList02){
                Decimal ETCsumP_dv;
                Decimal ETCsumA_dv;

                boolean isPm = false;

                //if(a.get('OrgName__c') != 'DK BMC'){
                    ETCsumP_dv =  (Decimal)a.get('sumP');
                    ETCsumA_dv =  (Decimal)a.get('sumA');
                //}
                for(PMS_PjtManpower__c pm : pmList01){
                    if(pm.ProjectId__r.ProjectManagerId__c == pm.PjtResourceId__c
                    && pm.JoinHQ__c == a.get('JoinHQ__c')
                    && pm.JoinDivision__c == a.get('JoinDivision__c')){
                        isPm = true;
                    }
                }

                if(a.get('JoinHQ__c') != null // && a.get('OrgName__c') != 'DK BMC'
                ){
                    jdtList02.add(
                        new PMS_PjtJoinDivTeam__c(
                            ProjectId__c = scope.get(0).ProjectId__c
                            , HQ__c = (Id)a.get('JoinHQ__c')
                            , Division__c = (Id)a.get('JoinDivision__c')
                            , exId__c = scope.get(0).ProjectId__c + '_' + a.get('JoinHQ__c') + '_' + a.get('JoinDivision__c')
                            , FM_Partner_Plan_MM__c = ETCsumP_dv   // 협력사 누적 계획 MM
                            , FM_Partner_Actual_MM__c = ETCsumA_dv // 협력사 누적 실적 MM
                            , IsPM__c = isPm
                            , IsDeleted__c = false
                        )
                    );
                    System.debug('jdtList : ' + jdtList);
                    upsert jdtList02 exId__c;
                }
                System.debug('jdtList02 : ' + jdtList);
            }

            // 본부 오브젝트 레코드 초기화
            List<PMS_PjtJoinHQ__c> allList = [SELECT Id FROM PMS_PjtJoinHQ__c WHERE ProjectId__c = :scope.get(0).ProjectId__c];
            for(PMS_PjtJoinHQ__c h : allList){
                h.FM_DKBMC_Plan_MM__c = null;
                h.FM_Partner_Plan_MM__c = null;
                h.FM_DKBMC_Actual_MM__c = null;
                h.FM_Partner_Actual_MM__c = null;
                h.IsDeleted__c = true;
                h.IsPM__c = false;
            }
            update allList;

            List<AggregateResult> hqList = [SELECT HQ__c, SUM(FM_DKBMC_Actual_MM__c)daSum, SUM(FM_DKBMC_Plan_MM__c)dpSum, SUM(FM_Partner_Actual_MM__c)paSum, SUM(FM_Partner_Plan_MM__c)ppSum
                                            FROM PMS_PjtJoinDivTeam__c
                                            WHERE ProjectId__c = :scope.get(0).ProjectId__c AND HQ__c != null AND IsDeleted__c = false
                                            GROUP BY HQ__c];
            List<PMS_PjtJoinDivTeam__c> pmList02 = [SELECT Id, isPM__c, HQ__c FROM PMS_PjtJoinDivTeam__c WHERE ProjectId__c = :scope.get(0).ProjectId__c AND isPM__c != null];        

            List<PMS_PjtJoinHQ__c> jhList = new List<PMS_PjtJoinHQ__c>();

            for(AggregateResult a : hqList){
                Decimal DKsumP_hq = (Decimal)a.get('dpSum');
                Decimal DKsumA_hq = (Decimal)a.get('daSum');
                Decimal ETCsumP_hq = (Decimal)a.get('ppSum');
                Decimal ETCsumA_hq = (Decimal)a.get('paSum');

                boolean isPm = false;
                for(PMS_PjtJoinDivTeam__c pm : pmList02){
                    if(pm.isPM__c == true && pm.HQ__c == a.get('HQ__c')){
                        isPm = true;
                    }
                }
                
                jhList.add(
                    new PMS_PjtJoinHQ__c(
                        ProjectId__c = scope.get(0).ProjectId__c
                        , HQ__c = (Id)a.get('HQ__c')
                        , exId__c = scope.get(0).ProjectId__c + '_' + a.get('HQ__c')
                        , FM_DKBMC_Plan_MM__c = DKsumP_hq      // DK BMC 누적 계획 MM
                        , FM_Partner_Plan_MM__c = ETCsumP_hq   // 협력사 누적 계획 MM
                        , FM_DKBMC_Actual_MM__c = DKsumA_hq    // DK BMC 누적 실적 MM
                        , FM_Partner_Actual_MM__c = ETCsumA_hq // 협력사 누적 실적 MM
                        , isPM__c = isPm
                        , IsDeleted__c = false
                    )
                );
                upsert jhList exId__c;
            }

            // 삭제대상 확인완료 true시 삭제
            List<PMS_PjtJoinDivTeam__c> delDivList = [SELECT Id FROM PMS_PjtJoinDivTeam__c WHERE IsDeletedCheck__c = true];
            for(PMS_PjtJoinDivTeam__c d : delDivList){
                delete d;
            }
            List<PMS_PjtJoinHQ__c> delHqList = [SELECT ID FROM PMS_PjtJoinHQ__c WHERE IsDeletedCheck__c = true];
            for(PMS_PjtJoinHQ__c h : delHqList){
                delete h;
            }
        }catch(Exception e){
                    
            FailCount++;
            
            System.debug('[EXECUTE Error] ' + BatchName);
            System.debug(e);
            resultLog += '\n[EXECUTE Error] (' + scope.get(0).Id + ') ' + e;
            
            throw e;
        }
    }

    global void finish(Database.BatchableContext BC){
        System.debug('[FINISH] ' + BatchName + ' ( ' + BatchExecuteCount + ' )' + ' [S] ' + SuccessCount + ' [F] ' + FailCount);

        // Notification 알림
          UTIL_CustomNoti.sendNoti_Batch(
            new List<String>{
                System.UserInfo.getUserId()
                , BatchName + ' 배치완료'
                , FailCount == 0 ? '데이터 집계가 완료 되었습니다.' : '데이터 집계 오류 : ' + resultLog
            }
            , new List<Id>{ 
                System.UserInfo.getUserId()
            }
        );
    }
}