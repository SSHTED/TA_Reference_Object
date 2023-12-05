/*
* @Class : EmployeeResourceActiveBatch
*
* @Method : 

*	- start(BC)
*	- execute(BC, scope)
*	- finish(BC)
* 
* @Author : hojae-lee
* @Date : 2023-03-06
* @Version : 1.0
* @Modified : 
*  ---------------------------------------------
*  NO | Date       | Modifier      | Description
*  ---------------------------------------------
*  1. | 2023-03-06 | hojae-lee     | 최초작성
*/
global class EmployeeResourceActiveBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    
    global String BatchName = 'EmployeeResourceActiveBatch';
    global String OrgName = '';
    global String resultLog = '';
    global Integer SuccessCount = 0;
    global Integer FailCount = 0;
    global Integer BatchExecuteCount = 0;
    global Long BatchStartDateTimeLong = 0;
    
    global EmployeeResourceActiveBatch(){}
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        System.debug('[START] ' + BatchName);
        
        String SOQL = ' SELECT  '
                    + ' 	Id '
                    + ' 	, Name '
                    + ' 	, User__c '
                    + ' 	, OrganizationId__c '
                    + ' 	, Start__c '
                    + ' 	, Position__c '
                    + ' 	, Affiliation_company__c '
                    + ' 	, FM_Team__c '
                    + ' 	, FM_HQ__c '
            		+'		, Status__c'
                    + ' FROM '
                    + ' 	Employee__c '
                    + ' ORDER BY Name ';
        
        return Database.getQueryLocator(SOQL);
    }
    
    global void execute(Database.BatchableContext BC, List<Employee__c> scope){
        try{
            if(scope.size() > 0){
                Set<Id> eIdSet = new Set<Id>();
                Set<Id> eOrgIdSet = new Set<Id>();
                
                for(Employee__c e : scope){
                    eIdSet.add(e.Id);
                    eOrgIdSet.add(e.OrganizationId__c);
                }
                System.debug('eIdSet ? ' + eIdSet);
                System.debug('eOrgIdSet ? ' + eOrgIdSet);

                List<Organization__c> isOrgActiveList = [SELECT Id, Name, IsResourceActive__c, IsActive__c FROM Organization__c WHERE Id = :eOrgIdSet LIMIT 1];
                List<PMS_PjtResource__c> resIdList = [SELECT Id, IsActive__c FROM PMS_PjtResource__c WHERE EmployeeId__c = :eIdSet // AND (EmployeeId__r.Position__c != '본부장' AND EmployeeId__r.Position__c != '센터장') 
                                                      ORDER BY CreatedDate ASC LIMIT 1];

                List<PMS_PjtResource__c> resList = new List<PMS_PjtResource__c>();

                for(Employee__c emp : scope){
                    System.debug('emp ? ' + emp);
                    System.debug('emp ? ' + emp.Id);

                    String rBizType = '해당없음'; // 230308_이호재 자원 유형 추가
                    if(emp.FM_Team__c != null && emp.FM_Team__c.indexOf('CBU') > -1) rBizType = 'CBU';
                    if(emp.FM_HQ__c != null && emp.FM_HQ__c.indexOf('CRM컨설팅') > -1) rBizType = 'EBU';

                    // 230306_이호재 입사일 이후 입사예정인 직원 자원 생성
                    Boolean isResourceActive = false;
                    Boolean isOrgActive = false;
                    if(isOrgActiveList.size() > 0){
                        for(Organization__c o : isOrgActiveList){
                            isResourceActive = o.IsResourceActive__c;
                            isOrgActive = o.IsActive__c;
                        }
                    }
                    Boolean isStart = false;
                    Boolean isAct = false;
                    if(emp.Start__c <= System.today()) isStart = true;
                    if(isOrgActive == true && isResourceActive == true) isAct = true;
                    if(isOrgActive == true && isResourceActive == false) isAct = false;
                    if(isOrgActive == false){
                        isStart = false;
                        isAct = false;
                    }
                    if(isAct && (emp.Position__c == '본부장' || emp.Position__c == '센터장')) isAct = false;
                    if(emp.Status__c == '휴직') isAct = false; // 6월 30일 기성훈 추가
                    if(emp.Status__c == '입사예정') isAct = false; // 7월 27일 기성훈 추가
                    if(emp.Status__c == '퇴직') isAct = false;

                    if((resIdList.size() == 0 || resIdList == null) && isStart){
                        resList.add(
                            new PMS_PjtResource__c(
                                EmployeeId__c = emp.Id
                                , IsActive__c = isAct
                                , Name = emp.Name + ' (' + emp.Affiliation_company__c + ')'
                                , ResourceType__c = '직원'
                                , ResourceBizType__c = rBizType
                            )
                        );
                        System.debug('생성완료!');
                    }
                 
                    System.debug('isAct ? ' + isAct);
                    
                    if(emp.Status__c == '퇴직'){
                        if(resIdList.size() == 1 || resIdList != null){
                            for(PMS_PjtResource__c res : resIdList){
                                res.IsActive__c = false;
                                res.IsActual__c = false;
                                res.IsActual_Bill__c = false;
                                res.IsActual_NonBill__c = false;
                                res.IsActual_Training__c = false;
                                res.ActualCnt__c = 0;
                                res.ActualType__c = '대기(비가동)';
                            }                  
                        }                        
                    }else{
                        if(resIdList.size() == 1 || resIdList != null){
                            for(PMS_PjtResource__c res : resIdList){
                                res.IsActive__c = isAct;
                            }                  
                        }                        
                    }

                }
                insert resList;
                update resIdList;
            }
        }catch(System.Exception e){
            FailCount++;
            System.debug('[EXECUTE Error] ' + BatchName);
            System.debug(e);
            resultLog += '\n[EXECUTE Error] (' + scope.get(0).Id + ') ' + e;
            // throw e;

            System.debug('Error is ' + e.getLineNumber() + ' / ' + e.getMessage());
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