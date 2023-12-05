/**
 * @Class : PMS_ObjShareUpdateBatch
 *
 * @Method : 

 *  - start(BC)
 *  - execute(BC, scope)
 *  - finish(BC)
 * 
 * @Author : Yong-jin, Cha
 * @Date : 2022-03-14
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2022-03-14 | Yong-jin, Cha | 최초작성
 */

 global class PMS_ObjShareUpdateBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    global String BatchName = 'PMS_ObjShareUpdateBatch';
    global String OrgName = '';
    global String resultLog = '';
    global Integer SuccessCount = 0;
    global Integer FailCount = 0;
    global Integer BatchExecuteCount = 0;
    global Long BatchStartDateTimeLong = 0;

    global PMS_ObjShareUpdateBatch() {
       
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        System.debug('[START] ' + BatchName);

        String SOQL = ' select '
                    + '     Id '
                    + '     , Name '
                    + '     , User__c '
                    + '     , Start__c '
                    + ' from '
                    + '     Employee__c '
                    + ' where '
                    + '     Status__c = \'재직\' '
                    + ' and User__c != null '
                    + ' and User__r.IsActive = true '
                    + ' order by '
                    + '     Id ';

        return Database.getQueryLocator(SOQL);
    }
    
    global void execute(Database.BatchableContext BC, List<Employee__c> scope) {
        
        try {

            for(Employee__c c : scope) {
                
                // 최종학력
                List<PMS_LastEduBackground__c> eduList = [select Id, EmployeeId__r.User__c from PMS_LastEduBackground__c where EmployeeId__c = :c.Id];
                
                if(eduList.size() > 0) {
                    Set<Id> ownerEduShareSet = new Set<Id>();
                    
                    List<PMS_LastEduBackground__Share> ownerEduShareList = [
                        select 
                            ParentId
                        from
                            PMS_LastEduBackground__Share
                        where
                            AccessLevel = 'All'
                        and UserOrGroupId = :c.User__c
                    ];
                    
                    for(PMS_LastEduBackground__Share s1 : ownerEduShareList) {
                        ownerEduShareSet.add(s1.ParentId);
                    }
                    
                    List<PMS_LastEduBackground__Share> eduShareList = new List<PMS_LastEduBackground__Share>();
                    
                    for(PMS_LastEduBackground__c e : eduList) {
                        if(!ownerEduShareSet.contains(e.Id)) {
                            eduShareList.add(
                                new PMS_LastEduBackground__Share(
                                    AccessLevel = 'Edit'
                                    , ParentId = e.Id
                                    , RowCause = 'Manual'
                                    , UserOrGroupId = e.EmployeeId__r.User__c
                                )
                            );
                        }
                    }
                    
                    upsert eduShareList;
                }
                
                // 자격증
                List<PMS_Certificate__c> certList = [select Id, EmployeeId__r.User__c from PMS_Certificate__c where EmployeeId__c = :c.Id];
                
                if(certList.size() > 0) {
                    Set<Id> ownerCertShareSet = new Set<Id>();
                    
                    List<PMS_Certificate__Share> ownerCertShareList = [
                        select 
                            ParentId
                        from
                            PMS_Certificate__Share
                        where
                            AccessLevel = 'All'
                        and UserOrGroupId = :c.User__c
                    ];
                    
                    for(PMS_Certificate__Share s2 : ownerCertShareList) {
                        ownerCertShareSet.add(s2.ParentId);
                    }
                    
                    List<PMS_Certificate__Share> certShareList = new List<PMS_Certificate__Share>();
                    
                    for(PMS_Certificate__c e : certList) {
                        if(!ownerCertShareSet.contains(e.Id)) {
                            certShareList.add(
                                new PMS_Certificate__Share(
                                    AccessLevel = 'Edit'
                                    , ParentId = e.Id
                                    , RowCause = 'Manual'
                                    , UserOrGroupId = e.EmployeeId__r.User__c
                                )
                            );
                        }
                    }
                    
                    upsert certShareList;
                }

                // 프로젝트 경력
                List<PMS_PjtCareer__c> careerList = [select Id, EmployeeId__r.User__c from PMS_PjtCareer__c where EmployeeId__c = :c.Id];
                
                if(careerList.size() > 0) {                    
                    Set<Id> ownerCareerShareSet = new Set<Id>();
                    
                    List<PMS_PjtCareer__Share> ownerCareerShareList = [
                        select 
                            ParentId
                        from
                            PMS_PjtCareer__Share
                        where
                            AccessLevel = 'All'
                        and UserOrGroupId = :c.User__c
                    ];
                    
                    for(PMS_PjtCareer__Share s1 : ownerCareerShareList) {
                        ownerCareerShareSet.add(s1.ParentId);
                    }
                    
                    List<PMS_PjtCareer__Share> careerShareList = new List<PMS_PjtCareer__Share>();
                    
                    for(PMS_PjtCareer__c e : careerList) {
                        if(!ownerCareerShareSet.contains(e.Id)) {
                            careerShareList.add(
                                new PMS_PjtCareer__Share(
                                    AccessLevel = 'Edit'
                                    , ParentId = e.Id
                                    , RowCause = 'Manual'
                                    , UserOrGroupId = e.EmployeeId__r.User__c
                                )
                            );
                        }
                    }
                    
                    upsert careerShareList;
                }
                
                // 교육이력
                List<PMS_EduHistory__c> eduHisList = [select Id, EmployeeId__r.User__c from PMS_EduHistory__c where EmployeeId__c = :c.Id];
                
                if(eduHisList.size() > 0) {
                    Set<Id> ownerEduHisShareSet = new Set<Id>();
                    
                    List<PMS_EduHistory__Share> ownerEduHisShareList = [
                        select 
                            ParentId
                        from
                            PMS_EduHistory__Share
                        where
                            AccessLevel = 'All'
                        and UserOrGroupId = :c.User__c
                    ];
                    
                    for(PMS_EduHistory__Share s1 : ownerEduHisShareList) {
                        ownerEduHisShareSet.add(s1.ParentId);
                    }
                    
                    List<PMS_EduHistory__Share> eduHisShareList = new List<PMS_EduHistory__Share>();
                    
                    for(PMS_EduHistory__c e : eduHisList) {
                        if(!ownerEduHisShareSet.contains(e.Id)) {
                            eduHisShareList.add(
                                new PMS_EduHistory__Share(
                                    AccessLevel = 'Edit'
                                    , ParentId = e.Id
                                    , RowCause = 'Manual'
                                    , UserOrGroupId = e.EmployeeId__r.User__c
                                )
                            );
                        }
                    }
                    upsert eduHisShareList;
                }
                
                // Action Item
                List<PMS_ActionItem__c> actionItemList = [select Id, IssueId__c, RiskId__c from PMS_ActionItem__c where Activator__c = :c.Id];

                Set<Id> issueIdSet = new Set<Id>();
                Set<Id> riskIdSet = new Set<Id>();
                
                if(actionItemList.size() > 0) {
                    Set<Id> ownerActionItemShareSet = new Set<Id>();
                    
                    List<PMS_ActionItem__Share> ownerActionItemShareList = [
                        select 
                            ParentId
                        from
                            PMS_ActionItem__Share
                        where
                            AccessLevel = 'All'
                        and UserOrGroupId = :c.User__c
                    ];
                    
                    for(PMS_ActionItem__Share s1 : ownerActionItemShareList) {
                        ownerActionItemShareSet.add(s1.ParentId);
                    }
                    
                    List<PMS_ActionItem__Share> actionItemShareList = new List<PMS_ActionItem__Share>();
                    
                    for(PMS_ActionItem__c e : actionItemList) {
                        if(!ownerActionItemShareSet.contains(e.Id)) {
                            actionItemShareList.add(
                                new PMS_ActionItem__Share(
                                    AccessLevel = 'Edit'
                                    , ParentId = e.Id
                                    , RowCause = 'Manual'
                                    , UserOrGroupId = c.User__c
                                )
                            );
                        }
                        if(e.IssueId__c != null) {
                            issueIdSet.add(e.IssueId__c);
                        }
                        if(e.RiskId__c != null) {
                            riskIdSet.add(e.RiskId__c);
                        }
                    }
                    upsert actionItemShareList;
                }
                
                List<PMS_PjtResource__c> pjtResList = [select Id, EmpBeforeSfCareer__c, EmpBeforeCareer__c, PartnerBeforeCareer__c, PartnerBeforeSfCareer__c 
                                                       from PMS_PjtResource__c where EmployeeId__c = :c.Id limit 1];
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
                        and InputStartDate__c < :c.Start__c
                        group by
                            BusinessType__c
                    ];
                                        
                    pjtResList.get(0).EmpBeforeSfCareer__c = 0;
                    pjtResList.get(0).PartnerBeforeSfCareer__c = 0;
                    pjtResList.get(0).EmpBeforeCareer__c = 0;
                    pjtResList.get(0).PartnerBeforeCareer__c = 0;
                    
                    if(pcList.size() > 0) {
                        String rt = '';
                        Decimal sumDays = 0;
                        
                        for(AggregateResult ar : pcList) {
                            rt = String.valueOf(ar.get('rt'));                            
                            if(rt == '직원') {                                
                                if(String.valueOf(ar.get('bt')) == 'Salesforce') {
                                    pjtResList.get(0).EmpBeforeSfCareer__c = ar.get('days') == null ? 0 : Decimal.valueOf(String.valueOf(ar.get('days')));
                                    sumDays += ar.get('days') == null ? 0 : Decimal.valueOf(String.valueOf(ar.get('days')));
                                } else if(String.valueOf(ar.get('bt')) == 'IT일반') {
                                    sumDays += ar.get('days') == null ? 0 : Decimal.valueOf(String.valueOf(ar.get('days')));
                                }
                            } else {
                                
                                if(String.valueOf(ar.get('bt')) == 'Salesforce') {
                                    pjtResList.get(0).PartnerBeforeSfCareer__c = ar.get('days') == null ? 0 : Decimal.valueOf(String.valueOf(ar.get('days')));
                                    sumDays += ar.get('days') == null ? 0 : Decimal.valueOf(String.valueOf(ar.get('days')));
                                } else if(String.valueOf(ar.get('bt')) == 'IT일반') {
                                    sumDays += ar.get('days') == null ? 0 : Decimal.valueOf(String.valueOf(ar.get('days')));
                                }
                            }                            
                        }
                        if(rt == '직원') {
                            pjtResList.get(0).EmpBeforeCareer__c = sumDays;
                        } else {
                            pjtResList.get(0).PartnerBeforeCareer__c = sumDays;
                        }
                    }
                    
                    update pjtResList;
                        
                    // 이슈관리
                    List<PMS_Psc_Issue__c> issueList = [select Id from PMS_Psc_Issue__c where EmpActivatorId__c = :c.Id OR Id in :issueIdSet];
                    
                    if(issueList.size() > 0) {
                        Set<Id> ownerIssueShareSet = new Set<Id>();
                        
                        List<PMS_Psc_Issue__Share> ownerIssueShareList = [
                            select 
                                ParentId
                            from
                                PMS_Psc_Issue__Share
                            where
                                AccessLevel = 'All'
                            and UserOrGroupId = :c.User__c
                        ];
                        
                        for(PMS_Psc_Issue__Share s1 : ownerIssueShareList) {
                            ownerIssueShareSet.add(s1.ParentId);
                        }
                        
                        List<PMS_Psc_Issue__Share> issueShareList = new List<PMS_Psc_Issue__Share>();
                        
                        for(PMS_Psc_Issue__c e : issueList) {
                            if(!ownerIssueShareSet.contains(e.Id)) {
                                issueShareList.add(
                                    new PMS_Psc_Issue__Share(
                                        AccessLevel = 'Read'
                                        , ParentId = e.Id
                                        , RowCause = 'Manual'
                                        , UserOrGroupId = c.User__c
                                    )
                                );
                            }
                            
                        }
                        upsert issueShareList;
                    }
                    
                    // 위험관리
                    List<PMS_Psc_Risk__c> riskList = [select Id from PMS_Psc_Risk__c where EmpActivatorId__c = :c.Id OR Id in :riskIdSet];
                    
                    if(riskList.size() > 0) {
                        Set<Id> ownerRiskShareSet = new Set<Id>();
                        
                        List<PMS_Psc_Risk__Share> ownerRiskShareList = [
                            select 
                                ParentId
                            from
                                PMS_Psc_Risk__Share
                            where
                                AccessLevel = 'All'
                            and UserOrGroupId = :c.User__c
                        ];
                        
                        for(PMS_Psc_Risk__Share s1 : ownerRiskShareList) {
                            ownerRiskShareSet.add(s1.ParentId);
                        }
                        
                        List<PMS_Psc_Risk__Share> riskShareList = new List<PMS_Psc_Risk__Share>();
                        
                        for(PMS_Psc_Risk__c e : riskList) {
                            if(!ownerRiskShareSet.contains(e.Id)) {
                                riskShareList.add(
                                    new PMS_Psc_Risk__Share(
                                        AccessLevel = 'Read'
                                        , ParentId = e.Id
                                        , RowCause = 'Manual'
                                        , UserOrGroupId = c.User__c
                                    )
                                );
                            }
                        }
                        upsert riskShareList;
                    }
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
                , 'PMS_ObjShareUpdateBatch 배치완료'
                , FailCount == 0 ? '데이터 집계가 완료 되었습니다.' : '데이터 집계 오류 : ' + resultLog
            }
            , new List<Id>{ 
                System.UserInfo.getUserId()
            }
        );
        
    }
}