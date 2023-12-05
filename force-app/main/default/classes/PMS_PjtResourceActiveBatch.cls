/*
 * @Class : PMS_PjtResourceActiveBatch
 *
 * @Method : 

 *	- start(BC)
 *	- execute(BC, scope)
 *	- finish(BC)
 * 
 * @Author : hojae-lee
 * @Date : 2022-10-31
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2022-10-31 | hojae-lee     | 최초작성
 *  2. | 2023-02-21 | hojae-lee     | 스케줄 해제
 */
global class PMS_PjtResourceActiveBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    global String BatchName = 'PMS_PjtResourceActualSumBatch';
    global String OrgName = '';
    global String resultLog = '';
    global Integer SuccessCount = 0;
    global Integer FailCount = 0;
    global Integer BatchExecuteCount = 0;
    global Long BatchStartDateTimeLong = 0;
    global String employmentStatus = '재직';
    global String leaveStatus = '휴직';

    global PMS_PjtResourceActiveBatch() {}

    global Database.QueryLocator start(Database.BatchableContext BC){

        System.debug('[START] ' + BatchName);

        String SOQL = ' SELECT '
                    + ' 	Id '
                    + ' 	, IsActive__c '
                    + ' 	, FM_WorkStatus__c '
                    + ' 	, EmployeeId__r.Start__c '
                    + ' FROM '
                    + ' 	PMS_PjtResource__c '
                    + ' WHERE '
                    + '		FM_WorkStatus__c = :employmentStatus '
                    + ' OR '
            		+ '		FM_WorkStatus__c = :leaveStatus '
                    + ' OR '
                    + '		EmployeeId__r.Start__c = TODAY '
            
            		+ '	ORDER BY '
            		+ '		Name ';

        return Database.getQueryLocator(SOQL);
    }
    
    global void execute(Database.BatchableContext BC, List<PMS_PjtResource__c> scope) {
        
        try {
            
            for(PMS_PjtResource__c pr : scope){
               
                if(scope.size() > 0 && pr.FM_WorkStatus__c =='재직' || pr.EmployeeId__r.Start__c == System.today()){
                    pr.IsActive__c = true;
                }
                if(scope.size() > 0 && pr.FM_WorkStatus__c =='휴직'){
                    pr.IsActive__c = false;
                }
                
            }
            update scope;
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
                , 'PMS_PjtResourceActiveBatch 배치완료'
                , FailCount == 0 ? '데이터 집계가 완료 되었습니다.' : '데이터 집계 오류 : ' + resultLog
            }
            , new List<Id>{ 
                System.UserInfo.getUserId()
            }
        );
        
    }
}