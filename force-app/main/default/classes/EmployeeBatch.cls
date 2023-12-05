/*
* @Class : EmployeeBatch
*
* @Method : 

*	- start(BC)
*	- execute(BC, scope)
*	- finish(BC)
* 
* @Author : hojae-lee
* @Date : 2022-12-19
* @Version : 1.01
* @Modified : 
*  ---------------------------------------------
*  NO | Date       | Modifier      | Description
*  ---------------------------------------------
*  1. | 2022-12-19 | hojae-lee     | 최초작성
*  2. | 2023-02-11 | hojae-lee     | Advanced Approval 추가
*  3. | 2023-02-21 | hojae-lee     | 입사예정인 직원 자원 생성
*  4. | 2023-02-22 | hojae-lee     | 기존 직원 조직 활성여부 업데이트 및 코드 정리
*/
global class EmployeeBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    
    global String BatchName = 'EmployeeBatch';
    global String OrgName = '';
    global String resultLog = '';
    global Integer SuccessCount = 0;
    global Integer FailCount = 0;
    global Integer BatchExecuteCount = 0;
    global Long BatchStartDateTimeLong = 0;
    
    global EmployeeBatch(){}
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        //'WHERE Id = \'' + someId + '\''
        System.debug('[START] ' + BatchName);
        
        String SOQL = ' SELECT  '
                    + ' 	Id '
                    + ' 	, Name '
                    + ' 	, User__c '
                    + ' 	, OrganizationId__c '
                    + ' 	, Start__c '
                    + ' 	, Position__c '
                    + ' FROM '
                    + ' 	Employee__c '
                    + ' WHERE '
                    + ' 	End__c = null ' 
            		+' AND '
            		+' LastModifiedDate  = TODAY '
            		+' AND '
            		+' User__c != NULL '
            		+' AND '
            		+' User__r.IsActive =true '
                    + ' ORDER BY Name ';
        System.debug('SOQL ' +SOQL);
        return Database.getQueryLocator(SOQL);
    }
    
    global void execute(Database.BatchableContext BC, List<Employee__c> scope){
        try{
            if(scope.size() > 0){
                Set<Id> eUserIdSet = new Set<Id>();
				
                for(Employee__c e : scope) eUserIdSet.add(e.User__c); 
                System.debug('eUserIdSet ? ' + eUserIdSet);
                
                List<PermissionSetAssignment> goPSetId01 = [SELECT PermissionSetId
                                                            FROM PermissionSetAssignment
                                                            WHERE PermissionSet.Name = :System.label.PMS_PERM_PERSON
                                                            AND AssigneeId = :eUserIdSet
                                                            LIMIT 1];
                List<PermissionSetAssignment> goPSetId02 = [SELECT PermissionSetId
                                                            FROM PermissionSetAssignment
                                                            WHERE PermissionSet.Name = :System.label.ITAM_User
                                                            AND AssigneeId = :eUserIdSet
                                                            LIMIT 1];
                List<PermissionSetAssignment> goPSetId03 = [SELECT PermissionSetId
                                                            FROM PermissionSetAssignment
                                                            WHERE PermissionSet.Name = :System.label.Advanced_Approval_User
                                                            AND AssigneeId = :eUserIdSet
                                                            LIMIT 1];
                

                List<PermissionSetAssignment> goPSetId04 = [SELECT PermissionSetId
                                                            FROM PermissionSetAssignment
                                                            WHERE PermissionSet.Name = :System.label.MFA
                                                            AND AssigneeId = :eUserIdSet
                                                            LIMIT 1];     
                
                Id pmsId = [SELECT Id FROM PermissionSet WHERE Name = :System.label.PMS_PERM_PERSON LIMIT 1].Id;
                Id itamId = [SELECT Id FROM PermissionSet WHERE Name = :System.label.ITAM_User LIMIT 1].Id;
                Id advId = [SELECT Id FROM PermissionSet WHERE Name = :System.label.Advanced_Approval_User LIMIT 1].Id;
                Id mfaId = [SELECT Id FROM PermissionSet WHERE Name = :System.label.MFA LIMIT 1].Id;

                List<PermissionSetAssignment> goPSetList01 = new List<PermissionSetAssignment>();
                List<PermissionSetAssignment> goPSetList02 = new List<PermissionSetAssignment>();
                List<PermissionSetAssignment> goPSetList03 = new List<PermissionSetAssignment>();
                List<PermissionSetAssignment> goPSetList04 = new List<PermissionSetAssignment>();

                for(Employee__c emp : scope){
                    System.debug('emp ? ' + emp);
                    System.debug('emp ? ' + emp.Id);
                    
                    if(emp.User__c != null){
                        
                        // PMS본인
                        System.debug('PMS본인 라벨은 : ' + System.label.PMS_PERM_PERSON);
                        System.debug('goPSetId01 ? ' + goPSetId01);
                        
                        if(goPSetId01.size() == 0 || goPSetId01 == null){
                            System.debug('size 01 ? ' + goPSetId01.size());
                            goPSetList01.add(
                                new PermissionSetAssignment(
                                    AssigneeId = emp.User__c
                                    , PermissionSetId = pmsId
                                )
                            );
                        }
                        System.debug('goPSetList01 ? ' + goPSetList01);
                        
                        // ITAM_User
                        System.debug('ITAM_User 라벨은 : ' + System.label.ITAM_User);
                        System.debug('goPSetId02 ? ' + goPSetId02);
                        
                        if(goPSetId02.size() == 0){
                            System.debug('size 02 ? ' + goPSetId02.size());
                            goPSetList02.add(
                                new PermissionSetAssignment(
                                    AssigneeId = emp.User__c
                                    , PermissionSetId = itamId
                                )
                            );
                        }
                        System.debug('goPSetList02 ? ' + goPSetList02);
                        
                        // 230211_이호재 Advanced_Approval_User 신규 직원 추가 할당
                        System.debug('goPSetId03 ? ' + goPSetId03);
                        
                        if(goPSetId03.size() == 0){
                            System.debug('size 02 ? ' + goPSetId03.size());
                            goPSetList03.add(
                                new PermissionSetAssignment(
                                    AssigneeId = emp.User__c
                                    , PermissionSetId = advId
                                )
                            );
                        }
                        System.debug('goPSetList03 ? ' + goPSetList03);
                        
                        if(goPSetId04.size() == 0){
                            System.debug('size 04 ? ' + goPSetId04.size());
                            goPSetList04.add(
                                new PermissionSetAssignment(
                                    AssigneeId = emp.User__c
                                    , PermissionSetId = mfaId
                                )
                            );
                        }
                        System.debug('goPSetList04 ? ' + goPSetList04);
                        
                    }
                }
                insert goPSetList01;
                insert goPSetList02;
                insert goPSetList03;
                insert goPSetList04;
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
                    , FailCount == 0 ? '배치 작업이 완료 되었습니다.' : '배치 작업 오류 : ' + resultLog
            }
            , new List<Id>{ 
                System.UserInfo.getUserId()
            }
        );
    }
}