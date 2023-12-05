/**
 * @Class : PMS_PartnerCareerUpdateBatch
 *
 * @Method : 

 *	- start(BC)
 *	- execute(BC, scope)
 *	- finish(BC)
 * 
 * @Author : Yong-jin, Cha
 * @Date : 2022-04-08
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2022-04-08 | Yong-jin, Cha | 최초작성
 */
global class PMS_PartnerCareerUpdateBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    global String BatchName = 'PMS_PartnerCareerUpdateBatch';
    global String OrgName = '';
    global String resultLog = '';
    global Integer SuccessCount = 0;
    global Integer FailCount = 0;
    global Integer BatchExecuteCount = 0;
    global Long BatchStartDateTimeLong = 0;

    global PMS_PartnerCareerUpdateBatch() {
       
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        System.debug('[START] ' + BatchName);

        String SOQL = ' select '
                    + ' 	Id '
                    + ' 	, Name '
            		+ '		, ManagementStartDate__c '
                    + ' from '
                    + ' 	PMS_PjtPartnerEmp__c '
                    + ' where '
            		+ '		ManagementEndDate__c = null '
            		+ ' and ManagementStartDate__c != null '
            		+ '	order by '
            		+ '		Id ';

        return Database.getQueryLocator(SOQL);
    }
    
    global void execute(Database.BatchableContext BC, List<PMS_PjtPartnerEmp__c> scope) {
        
        try {

            for(PMS_PjtPartnerEmp__c c : scope) {
                
                List<PMS_PjtResource__c> pjtResList = [select Id, EmpBeforeSfCareer__c, EmpBeforeCareer__c, PartnerBeforeCareer__c, PartnerBeforeSfCareer__c 
                                                       from PMS_PjtResource__c where PjtPartnerEmpId__c = :c.Id limit 1];
                String resourceId = null;
                if(pjtResList.size() > 0) {
                    resourceId = pjtResList.get(0).Id;
                }
                
                if(resourceId != null) {
                    
                    List<AggregateResult> pcList = [
                        select 
							BusinessType__c bt
							, SUM(FM_InputPeriod_Days__c) days
                        	, Max(PjtResourceId__r.ResourceType__c) rt
						from
							PMS_PjtCareer__c
						where
                        	PjtResourceId__c = :resourceId
                        and InputStartDate__c < :c.ManagementStartDate__c
						group by
                        	BusinessType__c
                    ];
                                        
                    pjtResList.get(0).EmpBeforeSfCareer__c = 0;
                    pjtResList.get(0).PartnerBeforeSfCareer__c = 0;
                    pjtResList.get(0).EmpBeforeCareer__c = 0;
                    pjtResList.get(0).PartnerBeforeCareer__c = 0;
                    
                    if(pcList.size() > 0) {
                        Decimal sumDays = 0;
                        
                        for(AggregateResult ar : pcList) {           
                            if(String.valueOf(ar.get('bt')) == 'Salesforce') {
                                pjtResList.get(0).PartnerBeforeSfCareer__c = ar.get('days') == null ? 0 : Decimal.valueOf(String.valueOf(ar.get('days')));
                                sumDays += ar.get('days') == null ? 0 : Decimal.valueOf(String.valueOf(ar.get('days')));
                            } else if(String.valueOf(ar.get('bt')) == 'IT일반') {
                                sumDays += ar.get('days') == null ? 0 : Decimal.valueOf(String.valueOf(ar.get('days')));
                            }                           
                        }
                        pjtResList.get(0).PartnerBeforeCareer__c = sumDays;
                    }
                    
                    update pjtResList;                   
                }
            }
            
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
                , BatchName + ' 배치완료'
                , FailCount == 0 ? '데이터 집계가 완료 되었습니다.' : '데이터 집계 오류 : ' + resultLog
            }
            , new List<Id>{ 
                System.UserInfo.getUserId()
            }
        );
        
    }
}