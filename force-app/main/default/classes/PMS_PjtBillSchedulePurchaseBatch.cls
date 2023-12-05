/*
 * @Class : PMS_PjtBillSchedulePurchaseBatch
 *
 * @Method : 

 *	- start(BC)
 *	- execute(BC, scope)
 *	- finish(BC)
 * 
 * @Author : hojae-lee
 * @Date : 2022-10-13
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2022-10-13 | hojae-lee     | 최초작성
 */
global class  PMS_PjtBillSchedulePurchaseBatch implements Database.Batchable<AggregateResult>, Database.Stateful, Database.AllowsCallouts{
    
    global String BatchName = 'PMS_PjtBillSchedulePurchaseBatch';
    global String OrgName = '';
    global String resultLog = '';
    global Integer SuccessCount = 0;
    global Integer FailCount = 0;
    global Integer BatchExecuteCount = 0;
    global Long BatchStartDateTimeLong = 0;
    global String pur = '매입';
    global String dkbmc = 'DK BMC';
    global String rain = 'Rainlight Soft';
    
    global PMS_PjtBillSchedulePurchaseBatch() {}

    global String query = ' SELECT  '
                    + ' 	 Project__r.ProjectManagerId__c '
                    + ' FROM '
                    + ' 	PMS_PjtBillSchedule__c '
                    + ' WHERE '
                    // + ' 	InspectDueDate__c = THIS_MONTH '
                    + ' 	InspectType__c = :pur '
                    + ' 	AND PMS_PjtPartner__r.Name != :dkbmc '
                    + ' 	AND PMS_PjtPartner__r.Name != :rain '
                    + ' GROUP BY Project__r.ProjectManagerId__c ';

    global Iterable<AggregateResult> start(Database.BatchableContext BC){

        return new PMS_PjtBillSchedulePurIterable(query); 
    }

    global void execute(Database.BatchableContext BC, List<AggregateResult> scope){
        try{
            System.debug('scope : ' + scope);

            Set<Id> pbsSet = new Set<Id>();

            for(AggregateResult s : scope){ 
                Id id = String.valueOf(s.get('ProjectManagerId__c'));
                pbsSet.add(id);
            }
            // 매니저 Id
            System.debug('pbsSet : ' + pbsSet);

            // 프로젝트 본부가 CX본부이면, 김정용 팀장으로 알림 메일 발송
            String csm = [SELECT Email FROM User WHERE Name = '김정용'].Email;
            
            List<PMS_PjtBillSchedule__c> pbsList = [SELECT PMS_PjtPartner__r.Name, Times__c, InspectDueDate__c, Project__c, Project__r.ProjectManagerId__r.FM_Email__c, Project__r.HQId__r.Name
                                                    FROM PMS_PjtBillSchedule__c
                                                    WHERE // InspectDueDate__c = THIS_MONTH // 여기에 수정
                                                    // AND 
                                                    InspectType__c = '매입'
                                                    AND PMS_PjtPartner__r.Name != 'DK BMC'
                                                    AND PMS_PjtPartner__r.Name != 'Rainlight Soft'
                                                    AND Project__r.ProjectManagerId__c = :pbsSet];
            // Id로 솎아낸 매입할 업체 정보들
            System.debug('pbsList : ' + pbsList);
            
            List<String> purList = new List<String>();
            List<String> timesList = new List<String>();
            List<String> dueList = new List<String>();
            Set<DateTime> newSet = new Set<DateTime>();
            
            for(PMS_PjtBillSchedule__c pbs : pbsList){
            
                DateTime minusTenDate = DateTime.newInstance(pbs.InspectDueDate__c.year(), pbs.InspectDueDate__c.month(), pbs.InspectDueDate__c.day() - 4);
                System.debug('minusTenDate 1 ? ' + minusTenDate);
                String dayWhat = String.valueOf(minusTenDate.format('E'));
                System.debug('dayWhat ? ' + dayWhat);

                if(dayWhat == 'Sat'){
                    minusTenDate = DateTime.newInstance(pbs.InspectDueDate__c.year(), pbs.InspectDueDate__c.month(), pbs.InspectDueDate__c.day() - 5);
                }
                if(dayWhat == 'Sun'){
                    minusTenDate = DateTime.newInstance(pbs.InspectDueDate__c.year(), pbs.InspectDueDate__c.month(), pbs.InspectDueDate__c.day() - 6);
                }
                System.debug('minusTenDate 2 ? ' + minusTenDate);
                Boolean a = Date.valueOf(minusTenDate) == System.today();
                System.debug('a ? ' + a);
                if(a)newSet.add(minusTenDate);
                
                System.debug('newSet ? ' + newSet);

                if(Date.valueOf(minusTenDate) == System.today() && pbsList.size() > 0){
                    purList.add(pbs.PMS_PjtPartner__r.Name);
                
                    if(pbs.Times__c != null){
                        timesList.add(pbs.Times__c);
                    }else{timesList.add('');}
    
                    if(pbs.InspectDueDate__c != null){
                        dueList.add(String.valueOf(pbs.InspectDueDate__c));
                    }else{dueList.add('');}
                }
            }
            System.debug('newSet 2 ? ' + newSet);

            if(newSet.size() > 0 || Test.isRunningTest()){
                String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/' + pbsList.get(0).Project__c + '/related/PjtManpower__r/view';
                System.debug('recordUrl : ' + recordUrl);
    
                if(pbsSet != null){
                    List<String> toAddresses = new List<String>();
                    for(PMS_PjtBillSchedule__c p : pbsList){
                        if(p.Project__r.HQId__r.Name == 'CX본부'){
                            toAddresses.add(csm);
                        }else if(p.Project__r.ProjectManagerId__r.FM_Email__c != null){
                            toAddresses.add(p.Project__r.ProjectManagerId__r.FM_Email__c);
                        }
                    }

                    System.debug('toAddresses : ' + toAddresses);
                    
                    // 숨은참조에 EPMO(박승호 본부장, 김동식 팀장, 권종인 포함) 넣어서 보내기
                    List<String> bccAddresses = UTIL_Email.getEPMOAddresses();
                    System.debug('bccAddresses : ' + bccAddresses);
                    
                    UTIL_Email.sendEmailPurchasePjtBillNoti(toAddresses, bccAddresses, purList, timesList, dueList, recordUrl);
                }
            }

            System.debug('purList : ' + purList);
            System.debug('timesList : ' + timesList);
            System.debug('dueList : ' + dueList);

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