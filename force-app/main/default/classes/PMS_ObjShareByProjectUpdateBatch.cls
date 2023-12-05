/**
 * @Class : PMS_ObjShareByProjectUpdateBatch
 *
 * @Method : 

 *	- start(BC)
 *	- execute(BC, scope)
 *	- finish(BC)
 * 
 * @Author : Yong-jin, Cha
 * @Date : 2022-04-01
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2022-04-01 | Yong-jin, Cha | 최초작성
 */
global class PMS_ObjShareByProjectUpdateBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    global String BatchName = 'PMS_ObjShareByProjectUpdateBatch';
    global String OrgName = '';
    global String resultLog = '';
    global Integer SuccessCount = 0;
    global Integer FailCount = 0;
    global Integer BatchExecuteCount = 0;
    global Long BatchStartDateTimeLong = 0;

    global PMS_ObjShareByProjectUpdateBatch() {
       
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        System.debug('[START] ' + BatchName);
        String prName = '%DK BMC%';
        String SOQL = ' select  '
                    + ' 	Id '
            		+ ' 	, Name '
                    + ' 	, ActualLaborCost_DKBMC__c '
                    + ' 	, ActualLaborCost_Outsourcing__c '
                    + ' 	, AdditionalAmt__c '
                    + ' 	, Billing__c '
                    + ' 	, ContractAmt__c '
                    + ' 	, ContractEndDate__c '
                    + ' 	, ContractStartDate__c '
                    + ' 	, ContractUnit__c '
                    + ' 	, Currency__c '
                    + ' 	, DeadlineDate__c '
                    + ' 	, DetailedType__c '
                    + ' 	, DifferenceCause__c '
                    + ' 	, DirectCustomer__c '
                    + ' 	, DivisionId__c '
                    + ' 	, EndCustomer__c '
                    + ' 	, EstimatedLaborCost_DKBMC__c '
                    + ' 	, EstimatedLaborCost_Outsourcing__c '
                    + ' 	, ExpectedCost__c '
                    // + ' 	, ExpectedProfitMargin__c '
                    + ' 	, FM_Actual_MM__c '
                    + ' 	, FM_ActualProfitMargin__c '
                    + ' 	, FM_Bill_Actual_MM__c '
                    + ' 	, FM_Bill_Diff_MM__c '
                    + ' 	, FM_Bill_Plan_MM__c '
                    + ' 	, FM_Diff_MM__c '
                    + ' 	, FM_DKBMC_Actual_MM__c '
                    + ' 	, FM_DKBMC_Bill_Diff_MM__c '
                    + ' 	, FM_DKBMC_Diff_MM__c '
                    + ' 	, FM_DKBMC_NonBill_Diff_MM__c '
                    + ' 	, FM_DKBMC_Plan_MM__c '
                    + ' 	, FM_DKBMC_Training_Diff_MM__c '
                    + ' 	, FM_NonBill_Actual_MM__c '
                    + ' 	, FM_NonBill_Diff_MM__c '
                    + ' 	, FM_NonBill_Plan_MM__c '
                    + ' 	, FM_Partner_Actual_MM__c '
                    + ' 	, FM_Partner_Bill_Diff_MM__c '
                    + ' 	, FM_Partner_Diff_MM__c '
                    + ' 	, FM_Partner_NonBill_Diff_MM__c '
                    + ' 	, FM_Partner_Plan_MM__c '
                    + ' 	, FM_Partner_Training_Diff_MM__c '
                    + ' 	, FM_Plan_MM__c '
                    + ' 	, FM_ProjectPeriod__c '
                    + ' 	, FM_SalesScope__c '
                    + ' 	, FM_TotalEmpCnt__c '
                    + ' 	, FM_Training_Actual_MM__c '
                    + ' 	, FM_Training_Diff_MM__c '
                    + ' 	, FM_Training_Plan_MM__c '
                    + ' 	, HQId__c '
            		+ ' 	, HQId__r.Name '
                    + ' 	, Industry__c '
                    + ' 	, IsOnTime__c '
                    + ' 	, KickoffDate__c '                    
                    + ' 	, OnTimeReason__c '
                    + ' 	, PerformedStage__c '
                    + ' 	, PricingModel__c '
                    + ' 	, Product_Solution__c '
                    + ' 	, ProjectCode2__c '
                    + ' 	, ProjectManagerId__c '
                    + ' 	, ProjectOutline__c '
                    + ' 	, ProjectType__c '
                    + ' 	, SalesRepId__c '
                    + ' 	, SignOffConditions__c '
                    + ' 	, SignOffDate__c '
                    + ' 	, Status__c '
                    + ' 	, TotalContractBillableMM__c '
                    + ' 	, WorkArea__c '
                    + ' 	, WorkLocation__c '
                    + ' 	, SalesRepId__r.Id '
                    + '     , (SELECT UserOrGroup.Id FROM Shares) '
                    + '     , (SELECT Id, PjtResourceId__r.EmployeeId__r.User__r.Id FROM PjtManpower__r WHERE PjtResourceId__r.Name LIKE :prName AND PjtResourceId__r.EmployeeId__r.User__r.IsActive = true) '
                    + ' from '
                    + ' 	PMS_Project__c '
            		+ ' order by ProjectCode2__c ';

        return Database.getQueryLocator(SOQL);
    }
    
    global void execute(Database.BatchableContext BC, List<PMS_Project__c> scope) {
        
        try {

            for(PMS_Project__c c : scope) {
                
                System.debug('# Project : ' + c.Name);
                
                // 공유그룹 Id
                Set<Id> groupIdSet = getPublicGroupId(c.HQId__r.Name);
                                
                // 프로젝트 공유
                List<PMS_Project__Share> projectShareList = new List<PMS_Project__Share>();
                
                for(String groupId : groupIdSet) {
                    String accessLevel = getAccessLevel(groupId, 'PMS_Project__c');
                    if(accessLevel != null) {
                        projectShareList.add(
                            new PMS_Project__Share(
                                AccessLevel = accessLevel
                                , ParentId = c.Id
                                , RowCause = 'Manual'
                                , UserOrGroupId = groupId
                            )
                        );
                    }
                }

                upsert projectShareList;
                
                // 프로젝트 평가 및 정산 공유
                List<PMS_PjtEvalSettle__Share> pjtEvalSettleShareList = new List<PMS_PjtEvalSettle__Share>();
                
                List<PMS_PjtEvalSettle__c> pesList = [select Id from PMS_PjtEvalSettle__c where ProjectId__c = :c.Id];
                
                for(String groupId : groupIdSet) {
                    String accessLevel = getAccessLevel(groupId, 'PMS_PjtEvalSettle__c');
                    if(accessLevel != null) {
                        for(PMS_PjtEvalSettle__c pes : pesList) {
                            pjtEvalSettleShareList.add(
                                new PMS_PjtEvalSettle__Share(
                                    AccessLevel = accessLevel
                                    , ParentId = pes.Id
                                    , RowCause = 'Manual'
                                    , UserOrGroupId = groupId
                                )
                            );
                        }                        
                    }                    
                }
                
                upsert pjtEvalSettleShareList;

                // 220927 프로젝트에서 본인 권한 부여 - 이호재
                List<PMS_Project__Share> PjtShareList = new List<PMS_Project__Share>();
                List<Id> userIdListShare = new List<Id>();
                List<Id> userIdListMan = new List<Id>();

                for(PMS_Project__Share s : c.Shares){
                    userIdListShare.add(s.UserOrGroup.Id);
                }
                for(PMS_PjtManpower__c pjtm : c.PjtManpower__r){
                    userIdListMan.add(pjtm.PjtResourceId__r.EmployeeId__r.User__r.Id);
                }

                Set<Id> userIdSet = new Set<Id>();
                userIdSet.addAll(userIdListShare);
                userIdSet.addAll(userIdListMan);

                Set<Id> diffSet = new Set<Id>(userIdListMan);
                diffSet.removeAll(userIdListShare);

                List<Id> results = new List<Id>(diffSet);
                // System.debug('results : ' + results);
                for(Id uid : results){
                    if(uid != null){
                        System.debug('Inserting Id : ' + uid);
                        PjtShareList.add(
                            new PMS_Project__Share(
                                AccessLevel = 'Read'
                                , ParentId = c.Id
                                , RowCause = 'Manual'
                                , UserOrGroupId = uid
                            )
                        );
                    }
                }
                upsert PjtShareList;
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
    
    private static Set<Id> getPublicGroupId(String HQName) {
        
        Set<Id> groupIdSet = new Set<Id>();
        List<String> devName = new List<String>();
        
        if('DA본부' == HQName) {
            devName.add('PMS_PERM_DA');
            devName.add('PMS_PERM_DA_SALES');
        } else if('MC본부' == HQName) {
            devName.add('PMS_PERM_MC');
        } else if('CX본부' == HQName) {
            devName.add('PMS_PERM_CX');
            devName.add('PMS_PERM_CXCS');
        } else if('Rainlight Soft' == HQName) {
            devName.add('PMS_PERM_RL');
        } else if('SF CRM컨설팅 본부' == HQName) {
            devName.add('PMS_PERM_SC_PMO');
        } else if('SF CRM영업 본부' == HQName) {
            devName.add('PMS_PERM_SALES_TEAM');
        }
        
        System.debug('# devName : ' + devName);
            
        Map<Id, Group> groupIdObjMap = new Map<Id, Group>([select Id from Group where DeveloperName in :devName]);
            
        groupIdSet = groupIdObjMap.keySet();
        
        System.debug('# groupIdSet : ' + groupIdSet);
        
        return groupIdSet;
    }
    
    private static String getAccessLevel(String groupId, String objectName) {
        
        String devName = [select DeveloperName from Group where Id = :groupId].get(0).DeveloperName;
        
        String accessLevel = null;

        if('PMS_PERM_SALES' == devName) {
            if('PMS_PjtEvalSettle__c' == objectName) {                accessLevel = null;
            } else if('PMS_Project__c' == objectName) {                accessLevel = 'Edit';
            //} else if('PMS_PjtManpower__c' == objectName) {                accessLevel = 'Edit';
            //} else if('PMS_MonthlyInputStatus__c' == objectName) {                accessLevel = 'Edit';
            }             
        }				
        else if('PMS_PERM_DA' == devName) {
            if('PMS_PjtEvalSettle__c' == objectName) {                accessLevel = 'Edit';
            } else if('PMS_Project__c' == objectName) {                accessLevel = 'Edit';
            //} else if('PMS_PjtManpower__c' == objectName) {                accessLevel = 'Edit';
            //} else if('PMS_MonthlyInputStatus__c' == objectName) {                accessLevel = 'Edit';
            } 
        }
        else if('PMS_PERM_MC' == devName) {
			if('PMS_PjtEvalSettle__c' == objectName) {                accessLevel = 'Edit';
            } else if('PMS_Project__c' == objectName) {                accessLevel = 'Edit';
            //} else if('PMS_PjtManpower__c' == objectName) {                accessLevel = 'Edit';
            //} else if('PMS_MonthlyInputStatus__c' == objectName) {                accessLevel = 'Edit';
            } 
        }        
        else if('PMS_PERM_CX' == devName) {
			if('PMS_PjtEvalSettle__c' == objectName) {                accessLevel = 'Edit';
            } else if('PMS_Project__c' == objectName) {                accessLevel = 'Edit';
            //} else if('PMS_PjtManpower__c' == objectName) {                accessLevel = 'Edit';
            //} else if('PMS_MonthlyInputStatus__c' == objectName) {                accessLevel = 'Edit';
            } 
        }
        else if('PMS_PERM_RL' == devName) {
			if('PMS_PjtEvalSettle__c' == objectName) {                accessLevel = 'Edit';
            } else if('PMS_Project__c' == objectName) {                accessLevel = 'Edit';
            //} else if('PMS_PjtManpower__c' == objectName) {                accessLevel = 'Edit';
            //} else if('PMS_MonthlyInputStatus__c' == objectName) {                accessLevel = 'Edit';
            } 
        }
        else if('PMS_PERM_CXCS' == devName) {
			if('PMS_PjtEvalSettle__c' == objectName) {                accessLevel = null;
            } else if('PMS_Project__c' == objectName) {                accessLevel = 'Edit';
            //} else if('PMS_PjtManpower__c' == objectName) {                accessLevel = 'Edit';
            //} else if('PMS_MonthlyInputStatus__c' == objectName) {                accessLevel = 'Edit';
            } 
        }        
        else if('PMS_PERM_SC_PMO' == devName) {
			if('PMS_PjtEvalSettle__c' == objectName) {                accessLevel = null;
            } else if('PMS_Project__c' == objectName) {                accessLevel = 'Edit';
            //} else if('PMS_PjtManpower__c' == objectName) {                accessLevel = 'Edit';
            //} else if('PMS_MonthlyInputStatus__c' == objectName) {                accessLevel = 'Edit';
            } 
        }
        else if('PMS_PERM_DA_SALES' == devName) {
			if('PMS_PjtEvalSettle__c' == objectName) {                accessLevel = null;
            } else if('PMS_Project__c' == objectName) {                accessLevel = 'Edit';            
           	//} else if('PMS_PjtManpower__c' == objectName) {                accessLevel = 'Edit';            
            //} else if('PMS_MonthlyInputStatus__c' == objectName) {                accessLevel = 'Edit';            
           	} 
        }
        
        System.debug('# accessLevel : ' + accessLevel);

        return accessLevel;            
    }
}