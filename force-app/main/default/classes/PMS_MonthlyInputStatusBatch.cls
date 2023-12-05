global class PMS_MonthlyInputStatusBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    global String BatchName = 'PMS_MonthlyInputStatusBatch';
    global String OrgName = '';
    global String resultLog = '';
    global Integer SuccessCount = 0;
    global Integer FailCount = 0;
    global Integer BatchExecuteCount = 0;
    global Long BatchStartDateTimeLong = 0;
    global String resVal ='';
    global Id resourceId = null;
    
    global PMS_MonthlyInputStatusBatch(){}
    global PMS_MonthlyInputStatusBatch(Id resId){
        if(resId != null){
            this.resourceId = resId;
            this.resVal = ' AND Id = :resourceId ';
        }        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('[START] ' + BatchName);
        
        String SOQL = ' SELECT '
            + '    Id '
            + '    , Name '
            + ' FROM '
            + '    PMS_Project__c '
            + ' WHERE '
            + '	   Id IN (SELECT Project__c FROM PMS_PjtManpowerMonth__c WHERE Project__c != null) '
        	+ resVal
            + ' ORDER BY '
            + '     Id ';                
        return Database.getQueryLocator(SOQL);
    }
    
    global void execute(Database.BatchableContext BC, List<PMS_Project__c> scope){
        try{
            System.debug('프로젝트 이름은 ? ' + scope.get(0).Name);
            Set<Id> pjtIdSet = new Set<Id>();
            for(PMS_Project__c c : scope) pjtIdSet.add(c.Id);
            // System.debug('pjtIdSet ? ' + pjtIdSet);
            List<PMS_MonthlyInputStatus__c> updateMonthlyInputStatus = new List<PMS_MonthlyInputStatus__c>();
            List<PMS_MonthlyInputStatus__c> deleteMonthlyInputStatus = new List<PMS_MonthlyInputStatus__c>();
            
            List<PMS_MonthlyInputStatus__c> MonthlyInputStatusList = [
                SELECT Id, DKBMC_Bill_Plan_MM__c , DKBMC_NonBill_Plan_MM__c , DKBMC_Training_Plan_MM__c , DKBMC_Bill_Actual_MM__c , DKBMC_NonBill_Actual_MM__c , DKBMC_Training_Actual_MM__c
                , Partner_Bill_Plan_MM__c , Partner_NonBill_Plan_MM__c , Partner_Training_Plan_MM__c , Partner_Bill_Actual_MM__c , Partner_NonBill_Actual_MM__c , Partner_Training_Actual_MM__c
                FROM PMS_MonthlyInputStatus__c
                WHERE ProjectId__c =: scope.get(0).Id
            ];
            
            System.debug('MonthlyInputStatusList '+ MonthlyInputStatusList);
            
            List<PMS_MonthlyInputStatus__c> newDkPlanBillList = new List<PMS_MonthlyInputStatus__c>();
            List<AggregateResult> dkPlanBillList = [SELECT BaseDate__c, SUM(ManpowerMM__c)sumMM, Project__c
                                                    FROM PMS_PjtManpowerMonth__c
                                                    WHERE Project__c = :pjtIdSet
                                                    // AND PjtManpower__r.OrgName__c = 'DK BMC'
                                                    AND PjtManpower__r.PjtResourceId__r.EmployeeId__c != null
                                                    AND Type__c = '계획'
                                                    AND Billing__c = 'Billable'
                                                    GROUP BY BaseDate__c, Project__c
                                                    ORDER BY BaseDate__c];
            if(dkPlanBillList.size() > 0){
                for(AggregateResult a : dkPlanBillList){
                    newDkPlanBillList.add(
                        new PMS_MonthlyInputStatus__c(
                            BaseDate__c = Date.valueOf(a.get('BaseDate__c'))
                            , DKBMC_Bill_Plan_MM__c = Double.valueOf(a.get('sumMM'))
                            , ExId__c = String.valueOf(a.get('BaseDate__c')) + String.valueOf(a.get('Project__c'))
                            , ProjectId__c = String.valueOf(a.get('Project__c'))
                        )
                    );
                }
                upsert newDkPlanBillList ExId__c;
            }
            if(dkPlanBillList.size() == 0){
                for(PMS_MonthlyInputStatus__c pms : MonthlyInputStatusList){
                    pms.DKBMC_Bill_Plan_MM__c =NULL;
                    updateMonthlyInputStatus.add(pms);
                } 
            }
            List<PMS_MonthlyInputStatus__c> newDkPlanNonBillList = new List<PMS_MonthlyInputStatus__c>();
            List<AggregateResult> dkPlanNonBillList = [SELECT BaseDate__c, SUM(ManpowerMM__c)sumMM, Project__c
                                                       FROM PMS_PjtManpowerMonth__c
                                                       WHERE Project__c = :pjtIdSet
                                                       AND PjtManpower__r.PjtResourceId__r.EmployeeId__c != null
                                                       AND Type__c = '계획'
                                                       AND Billing__c = 'Non-Billable' AND BillingType__c != 'Training'
                                                       GROUP BY BaseDate__c, Project__c
                                                       ORDER BY BaseDate__c];
            if(dkPlanNonBillList.size() > 0){
                for(AggregateResult a : dkPlanNonBillList){
                    newDkPlanNonBillList.add(
                        new PMS_MonthlyInputStatus__c(
                            BaseDate__c = Date.valueOf(a.get('BaseDate__c'))
                            , DKBMC_NonBill_Plan_MM__c = Double.valueOf(a.get('sumMM'))
                            , ExId__c = String.valueOf(a.get('BaseDate__c')) + String.valueOf(a.get('Project__c'))
                            , ProjectId__c = String.valueOf(a.get('Project__c'))
                        )
                    );
                }
                upsert newDkPlanNonBillList ExId__c;
            }
            if(dkPlanNonBillList.size() == 0){
                for(PMS_MonthlyInputStatus__c pms : MonthlyInputStatusList){
                    pms.DKBMC_NonBill_Plan_MM__c =NULL;
                    updateMonthlyInputStatus.add(pms);
                } 
            }
            List<PMS_MonthlyInputStatus__c> newDkPlanTrainList = new List<PMS_MonthlyInputStatus__c>();
            List<AggregateResult> dkPlanTrainList = [SELECT BaseDate__c, SUM(ManpowerMM__c)sumMM, Project__c
                                                     FROM PMS_PjtManpowerMonth__c
                                                     WHERE Project__c = :pjtIdSet
                                                     AND PjtManpower__r.PjtResourceId__r.EmployeeId__c != null
                                                     AND Type__c = '계획'
                                                     AND BillingType__c = 'Training' AND Billing__c = 'Non-Billable'
                                                     GROUP BY BaseDate__c, Project__c
                                                     ORDER BY BaseDate__c];
            if(dkPlanTrainList.size() > 0){
                for(AggregateResult a : dkPlanTrainList){
                    newDkPlanTrainList.add(
                        new PMS_MonthlyInputStatus__c(
                            BaseDate__c = Date.valueOf(a.get('BaseDate__c'))
                            , DKBMC_Training_Plan_MM__c = Double.valueOf(a.get('sumMM'))
                            , ExId__c = String.valueOf(a.get('BaseDate__c')) + String.valueOf(a.get('Project__c'))
                            , ProjectId__c = String.valueOf(a.get('Project__c'))
                        )
                    );
                }
                upsert newDkPlanTrainList ExId__c;
            }
            if(dkPlanTrainList.size() == 0){
                for(PMS_MonthlyInputStatus__c pms : MonthlyInputStatusList){
                    pms.DKBMC_Training_Plan_MM__c =NULL;
                    updateMonthlyInputStatus.add(pms);
                } 
            }            
            List<PMS_MonthlyInputStatus__c> newDkRealBillList = new List<PMS_MonthlyInputStatus__c>();
            List<AggregateResult> dkRealBillList = [SELECT BaseDate__c, SUM(ManpowerMM__c)sumMM, Project__c
                                                    FROM PMS_PjtManpowerMonth__c
                                                    WHERE Project__c = :pjtIdSet
                                                    AND PjtManpower__r.PjtResourceId__r.EmployeeId__c != null
                                                    AND Type__c = '실적'
                                                    AND Billing__c = 'Billable'
                                                    GROUP BY BaseDate__c, Project__c
                                                    ORDER BY BaseDate__c];
            if(dkRealBillList.size() > 0){
                for(AggregateResult a : dkRealBillList){
                    newDkRealBillList.add(
                        new PMS_MonthlyInputStatus__c(
                            BaseDate__c = Date.valueOf(a.get('BaseDate__c'))
                            , DKBMC_Bill_Actual_MM__c = Double.valueOf(a.get('sumMM'))
                            , ExId__c = String.valueOf(a.get('BaseDate__c')) + String.valueOf(a.get('Project__c'))
                            , ProjectId__c = String.valueOf(a.get('Project__c'))
                        )
                    );
                }
                upsert newDkRealBillList ExId__c;
            }
            if(dkRealBillList.size() == 0){
                for(PMS_MonthlyInputStatus__c pms : MonthlyInputStatusList){
                    pms.DKBMC_Bill_Actual_MM__c =NULL;
                    updateMonthlyInputStatus.add(pms);
                } 
            }              
            List<PMS_MonthlyInputStatus__c> newDkRealNonBillList = new List<PMS_MonthlyInputStatus__c>();
            List<AggregateResult> dkRealNonBillList = [SELECT BaseDate__c, SUM(ManpowerMM__c)sumMM, Project__c
                                                       FROM PMS_PjtManpowerMonth__c
                                                       WHERE Project__c = :pjtIdSet
                                                       AND PjtManpower__r.PjtResourceId__r.EmployeeId__c != null
                                                       AND Type__c = '실적'
                                                       AND Billing__c = 'Non-Billable' AND BillingType__c != 'Training'
                                                       GROUP BY BaseDate__c, Project__c
                                                       ORDER BY BaseDate__c];
            if(dkRealNonBillList.size() > 0){
                for(AggregateResult a : dkRealNonBillList){
                    newDkRealNonBillList.add(
                        new PMS_MonthlyInputStatus__c(
                            BaseDate__c = Date.valueOf(a.get('BaseDate__c'))
                            , DKBMC_NonBill_Actual_MM__c = Double.valueOf(a.get('sumMM'))
                            , ExId__c = String.valueOf(a.get('BaseDate__c')) + String.valueOf(a.get('Project__c'))
                            , ProjectId__c = String.valueOf(a.get('Project__c'))
                        )
                    );
                }
                upsert newDkRealNonBillList ExId__c;
            }
            if(dkRealNonBillList.size() == 0){
                for(PMS_MonthlyInputStatus__c pms : MonthlyInputStatusList){
                    pms.DKBMC_NonBill_Actual_MM__c =NULL;
                    updateMonthlyInputStatus.add(pms);
                } 
            }              
            List<PMS_MonthlyInputStatus__c> newDkRealTrainingList = new List<PMS_MonthlyInputStatus__c>();
            List<AggregateResult> dkRealTrainingList = [SELECT BaseDate__c, SUM(ManpowerMM__c)sumMM, Project__c
                                                        FROM PMS_PjtManpowerMonth__c
                                                        WHERE Project__c = :pjtIdSet
                                                        AND PjtManpower__r.PjtResourceId__r.EmployeeId__c != null
                                                        AND Type__c = '실적'
                                                        AND BillingType__c = 'Training' AND Billing__c = 'Non-Billable'
                                                        GROUP BY BaseDate__c, Project__c
                                                        ORDER BY BaseDate__c];
            if(dkRealTrainingList.size() > 0){
                for(AggregateResult a : dkRealTrainingList){
                    newDkRealTrainingList.add(
                        new PMS_MonthlyInputStatus__c(
                            BaseDate__c = Date.valueOf(a.get('BaseDate__c'))
                            , DKBMC_Training_Actual_MM__c = Double.valueOf(a.get('sumMM'))
                            , ExId__c = String.valueOf(a.get('BaseDate__c')) + String.valueOf(a.get('Project__c'))
                            , ProjectId__c = String.valueOf(a.get('Project__c'))
                        )
                    );
                }
                upsert newDkRealTrainingList ExId__c;
            }
            if(dkRealTrainingList.size() == 0){
                for(PMS_MonthlyInputStatus__c pms : MonthlyInputStatusList){
                    pms.DKBMC_Training_Actual_MM__c = NULL;
                    updateMonthlyInputStatus.add(pms);
                } 
            }             
            List<PMS_MonthlyInputStatus__c> newParPlanBillList = new List<PMS_MonthlyInputStatus__c>();
            List<AggregateResult> parPlanBillList = [SELECT BaseDate__c, SUM(ManpowerMM__c)sumMM, Project__c
                                                     FROM PMS_PjtManpowerMonth__c
                                                     WHERE Project__c = :pjtIdSet
                                                     AND PjtManpower__r.OrgName__c != 'DK BMC'
                                                     AND Type__c = '계획'
                                                     AND Billing__c = 'Billable'
                                                     GROUP BY BaseDate__c, Project__c
                                                     ORDER BY BaseDate__c];
            if(parPlanBillList.size() > 0){
                for(AggregateResult a : parPlanBillList){
                    newParPlanBillList.add(
                        new PMS_MonthlyInputStatus__c(
                            BaseDate__c = Date.valueOf(a.get('BaseDate__c'))
                            , Partner_Bill_Plan_MM__c = Double.valueOf(a.get('sumMM'))
                            , ExId__c = String.valueOf(a.get('BaseDate__c')) + String.valueOf(a.get('Project__c'))
                            , ProjectId__c = String.valueOf(a.get('Project__c'))
                        )
                    );
                }
                upsert newParPlanBillList ExId__c;
            }
            if(parPlanBillList.size() == 0){
                for(PMS_MonthlyInputStatus__c pms : MonthlyInputStatusList){
                    pms.Partner_Bill_Plan_MM__c =NULL;
                    updateMonthlyInputStatus.add(pms);
                }
                
            }
            List<PMS_MonthlyInputStatus__c> newParPlanNonBillList = new List<PMS_MonthlyInputStatus__c>();
            List<AggregateResult> parPlanNonBillList = [SELECT BaseDate__c, SUM(ManpowerMM__c)sumMM, Project__c
                                                        FROM PMS_PjtManpowerMonth__c
                                                        WHERE Project__c = :pjtIdSet
                                                        AND PjtManpower__r.OrgName__c != 'DK BMC'
                                                        AND Type__c = '계획'
                                                        AND Billing__c = 'Non-Billable' AND BillingType__c != 'Training'
                                                        GROUP BY BaseDate__c, Project__c
                                                        ORDER BY BaseDate__c];
            if(parPlanNonBillList.size() > 0){
                for(AggregateResult a : parPlanNonBillList){
                    newParPlanNonBillList.add(
                        new PMS_MonthlyInputStatus__c(
                            BaseDate__c = Date.valueOf(a.get('BaseDate__c'))
                            , Partner_NonBill_Plan_MM__c = Double.valueOf(a.get('sumMM'))
                            , ExId__c = String.valueOf(a.get('BaseDate__c')) + String.valueOf(a.get('Project__c'))
                            , ProjectId__c = String.valueOf(a.get('Project__c'))
                        )
                    );
                }
                upsert newParPlanNonBillList ExId__c;
            }
            if(parPlanNonBillList.size() == 0){
                for(PMS_MonthlyInputStatus__c pms : MonthlyInputStatusList){
                    pms.Partner_NonBill_Plan_MM__c =NULL;
                    updateMonthlyInputStatus.add(pms);
                }
                
            }
            List<PMS_MonthlyInputStatus__c> newParPlanTrainList = new List<PMS_MonthlyInputStatus__c>();
            List<AggregateResult> parPlanTrainList = [SELECT BaseDate__c, SUM(ManpowerMM__c)sumMM, Project__c
                                                      FROM PMS_PjtManpowerMonth__c
                                                      WHERE Project__c = :pjtIdSet
                                                      AND PjtManpower__r.OrgName__c != 'DK BMC'
                                                      AND Type__c = '계획'
                                                      AND BillingType__c = 'Training' AND Billing__c = 'Non-Billable'
                                                      GROUP BY BaseDate__c, Project__c
                                                      ORDER BY BaseDate__c];
            if(parPlanTrainList.size() > 0){
                for(AggregateResult a : parPlanTrainList){
                    newParPlanTrainList.add(
                        new PMS_MonthlyInputStatus__c(
                            BaseDate__c = Date.valueOf(a.get('BaseDate__c'))
                            , Partner_Training_Plan_MM__c = Double.valueOf(a.get('sumMM'))
                            , ExId__c = String.valueOf(a.get('BaseDate__c')) + String.valueOf(a.get('Project__c'))
                            , ProjectId__c = String.valueOf(a.get('Project__c'))
                        )
                    );
                }
                upsert newParPlanTrainList ExId__c;
            }
            if(parPlanTrainList.size() == 0){
                for(PMS_MonthlyInputStatus__c pms : MonthlyInputStatusList){
                    pms.Partner_Training_Plan_MM__c =NULL;
                    updateMonthlyInputStatus.add(pms);
                }
                
            }
            
            List<PMS_MonthlyInputStatus__c> newParRealBillList = new List<PMS_MonthlyInputStatus__c>();
            List<PMS_MonthlyInputStatus__c> updateParRealBillList = new List<PMS_MonthlyInputStatus__c>();
            List<AggregateResult> parRealBillList = [SELECT BaseDate__c, SUM(ManpowerMM__c)sumMM, Project__c
                                                     FROM PMS_PjtManpowerMonth__c
                                                     WHERE Project__c = :pjtIdSet
                                                     AND PjtManpower__r.OrgName__c != 'DK BMC'
                                                     AND Type__c = '실적'
                                                     AND Billing__c = 'Billable'
                                                     GROUP BY BaseDate__c, Project__c
                                                     ORDER BY BaseDate__c];
            if(parRealBillList.size() > 0){
                for(AggregateResult a : parRealBillList){
                    newParRealBillList.add(
                        new PMS_MonthlyInputStatus__c(
                            BaseDate__c = Date.valueOf(a.get('BaseDate__c'))
                            , Partner_Bill_Actual_MM__c = Double.valueOf(a.get('sumMM'))
                            , ExId__c = String.valueOf(a.get('BaseDate__c')) + String.valueOf(a.get('Project__c'))
                            , ProjectId__c = String.valueOf(a.get('Project__c'))
                        )
                    );
                }
                upsert newParRealBillList ExId__c;
            }
            
            if(parRealBillList.size() == 0) {
                for(PMS_MonthlyInputStatus__c pms : MonthlyInputStatusList){
                    pms.Partner_Bill_Actual_MM__c =NULL;
                    updateMonthlyInputStatus.add(pms);
                }
            }
            
            List<PMS_MonthlyInputStatus__c> newParRealNonBillList = new List<PMS_MonthlyInputStatus__c>();
            List<AggregateResult> parRealNonBillList = [SELECT BaseDate__c, SUM(ManpowerMM__c)sumMM, Project__c
                                                        FROM PMS_PjtManpowerMonth__c
                                                        WHERE Project__c = :pjtIdSet
                                                        AND PjtManpower__r.OrgName__c != 'DK BMC'
                                                        AND Type__c = '실적'
                                                        AND Billing__c = 'Non-Billable' AND BillingType__c != 'Training'
                                                        GROUP BY BaseDate__c, Project__c
                                                        ORDER BY BaseDate__c];
            if(parRealNonBillList.size() > 0){
                for(AggregateResult a : parRealNonBillList){
                    newParRealNonBillList.add(
                        new PMS_MonthlyInputStatus__c(
                            BaseDate__c = Date.valueOf(a.get('BaseDate__c'))
                            , Partner_NonBill_Actual_MM__c = Double.valueOf(a.get('sumMM'))
                            , ExId__c = String.valueOf(a.get('BaseDate__c')) + String.valueOf(a.get('Project__c'))
                            , ProjectId__c = String.valueOf(a.get('Project__c'))
                        )
                    );
                }
                upsert newParRealNonBillList ExId__c;
            }
            if(parRealNonBillList.size() == 0) {
                for(PMS_MonthlyInputStatus__c pms : MonthlyInputStatusList){
                    pms.Partner_NonBill_Actual_MM__c =NULL;
                    updateMonthlyInputStatus.add(pms);
                }
            }
            
            List<PMS_MonthlyInputStatus__c> newParRealTrainList = new List<PMS_MonthlyInputStatus__c>();
            List<AggregateResult> parRealTrainList = [SELECT BaseDate__c, SUM(ManpowerMM__c)sumMM, Project__c
                                                      FROM PMS_PjtManpowerMonth__c
                                                      WHERE Project__c = :pjtIdSet
                                                      AND PjtManpower__r.OrgName__c != 'DK BMC'
                                                      AND Type__c = '실적'
                                                      AND BillingType__c = 'Training' AND Billing__c = 'Non-Billable'
                                                      GROUP BY BaseDate__c, Project__c
                                                      ORDER BY BaseDate__c];
            if(parRealTrainList.size() > 0){
                for(AggregateResult a : parRealTrainList){
                    newParRealTrainList.add(
                        new PMS_MonthlyInputStatus__c(
                            BaseDate__c = Date.valueOf(a.get('BaseDate__c'))
                            , Partner_Training_Actual_MM__c = Double.valueOf(a.get('sumMM'))
                            , ExId__c = String.valueOf(a.get('BaseDate__c')) + String.valueOf(a.get('Project__c'))
                            , ProjectId__c = String.valueOf(a.get('Project__c'))
                        )
                    );
                }
                upsert newParRealTrainList ExId__c;
            }
            if(parRealTrainList.size() == 0) {
                for(PMS_MonthlyInputStatus__c pms : MonthlyInputStatusList){
                    pms.Partner_Training_Actual_MM__c =NULL;
                    updateMonthlyInputStatus.add(pms);
                }
            }
            Map<id , PMS_MonthlyInputStatus__c> MonthlyInputStatusMap = new Map<id , PMS_MonthlyInputStatus__c>();
            MonthlyInputStatusMap.putAll(updateMonthlyInputStatus);
            
            if(MonthlyInputStatusMap.size() > 0){
                update MonthlyInputStatusMap.values();
            }
            SuccessCount++;
        }catch(Exception e){
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
                    , 'PMS_MonthlyInputStatusBatch 배치완료'
                    , FailCount == 0 ? '데이터 집계가 완료 되었습니다.' : '데이터 집계 오류 : ' + resultLog
                        }
            , new List<Id>{ 
                System.UserInfo.getUserId()
                    }
        );
        
    }
}