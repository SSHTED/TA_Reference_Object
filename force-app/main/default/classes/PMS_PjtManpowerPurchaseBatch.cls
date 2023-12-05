/*
 * @Class : PMS_PjtManpowerPurchaseBatch
 *
 * @Method : 
 *	- start(BC)
 *	- execute(BC, scope)
 *	- finish(BC)
 * 
 * @Author : hojae-lee
 * @Date : 2022-10-12
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2022-10-12 | hojae-lee     | 최초작성
 *  1. | 2022-12-07 | hojae-lee     | 필드 미사용으로 인한 잠정 스케줄 해제
 */
global class PMS_PjtManpowerPurchaseBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    
    global String BatchName = 'PMS_PjtManpowerBatch';
    global String OrgName = '';
    global String resultLog = '';
    global Integer SuccessCount = 0;
    global Integer FailCount = 0;
    global Integer BatchExecuteCount = 0;
    global Long BatchStartDateTimeLong = 0;
    
    global PMS_PjtManpowerPurchaseBatch() {}

    global Database.QueryLocator start(Database.BatchableContext BC){

        System.debug('[START] ' + BatchName);
		
        String SOQL = ' SELECT  '
                    + ' 	Id '
            		+ ' 	, Name '
                    + ' 	, IsPurchase__c '
                    + ' 	, ContractPlanEndDate__c '
                    + ' 	, InputEndDate__c '
                    + ' FROM '
                    + ' 	PMS_PjtManpower__c '
            		+ ' ORDER BY Name ';
            
        return Database.getQueryLocator(SOQL);
    }

    global void execute(Database.BatchableContext BC, List<PMS_PjtManpower__c> scope){
        try{
            for(PMS_PjtManpower__c pm : scope){
                // 계약/계획 철수일 지났을 때, 철수 완료일 입력 됐을 때, 입력 한 날짜가 지난 경우
                // 매입 발행 확인여부 체크 해제
                System.debug('scope01 : ' + scope);
                System.debug('pm.IsPurchase__c01 : ' + pm.IsPurchase__c); 
                if(pm.ContractPlanEndDate__c < System.today() || (pm.InputEndDate__c != null && pm.InputEndDate__c < System.today())){
                    pm.IsPurchase__c = False;
                }
                update scope;
                System.debug('pm.IsPurchase__c02 : ' + pm.IsPurchase__c);
                System.debug('scope02 : ' + scope);
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