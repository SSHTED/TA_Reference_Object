/*
 * @Class : PMS_PjtBillScheduleBatch
 *
 * @Method : 

 *	- start(BC)
 *	- execute(BC, scope)
 *	- finish(BC)
 * 
 * @Author : hojae-lee
 * @Date : 2022-09-28
 * @Version : 1.01
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2022-09-28 | hojae-lee     | 최초작성
 *  2. | 2022-12-07 | hojae-lee     | 주석추가
 */
global class PMS_PjtBillScheduleBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
    
    global String BatchName = 'PMS_PjtBillScheduleBatch';
    global String OrgName = '';
    global String resultLog = '';
    global Integer SuccessCount = 0;
    global Integer FailCount = 0;
    global Integer BatchExecuteCount = 0;
    global Long BatchStartDateTimeLong = 0;
    
    global PMS_PjtBillScheduleBatch(){}

    global Database.QueryLocator start(Database.BatchableContext BC){

        System.debug('[START] ' + BatchName);

        String SOQL = ' SELECT  '
                    + ' 	Id '
            		+ ' 	, Name '
                    + '     , InspectDueDate__c '
                    + '     , IsDelay__c '
                    + '     , DelayPeriod__c '
                    + '     , Times__c '
                    + '     , Project__r.Name '
                    + '     , Project__r.ProjectManagerId__c '
                    + '     , Project__r.ProjectManagerId__r.FM_Email__c '
                    + '     , PMS_PjtPartner__r.Name '
                    + '     , ProjectCode__c '
                    + '     , InspectType__c '
                    + '     , InspectDate__c '
                    + '     , Status__c '
                    + '     , Inspector2__c '
                    + '     , Project__r.HQId__r.Name '
                    + ' FROM '
                    + ' 	PMS_PjtBillSchedule__c '
            		+ ' ORDER BY Name ';

        return Database.getQueryLocator(SOQL);
    }

    global void execute(Database.BatchableContext BC, List<PMS_PjtBillSchedule__c> scope){
        try{
            Set<String> dueDateSet = new Set<String>();
            Set<String> emailSet = new Set<String>();
            Set<String> pjtNameSet = new Set<String>();
            Set<String> timesSet = new Set<String>();

            // 프로젝트 본부가 CX본부이면, 김정용 팀장으로 알림 메일 발송
            String csm = [SELECT Email FROM User WHERE Name = '김정용'].Email;

            for(PMS_PjtBillSchedule__c pbs : scope){
                System.debug('# PMS_PjtBillSchedule__c : ' + pbs.Name);
                
                DateTime minusThirtyDate0;
                minusThirtyDate0 = DateTime.newInstance(pbs.InspectDueDate__c.year(), pbs.InspectDueDate__c.month(), pbs.InspectDueDate__c.day() - 30, 10, 0, 0);
                
                String dayWhat = String.valueOf(minusThirtyDate0.format('E'));
                System.debug('dayWhat 1 : ' + dayWhat);

                if(dayWhat == 'Sat'){
                    minusThirtyDate0 = Date.valueOf(DateTime.newInstance(pbs.InspectDueDate__c.year(), pbs.InspectDueDate__c.month(), pbs.InspectDueDate__c.day() - 31, 10, 0, 0));
                    System.debug('minusThirtyDate1 ? ' + minusThirtyDate0);
                }
                if(dayWhat == 'Sun'){
                    minusThirtyDate0 = Date.valueOf(DateTime.newInstance(pbs.InspectDueDate__c.year(), pbs.InspectDueDate__c.month(), pbs.InspectDueDate__c.day() - 32, 10, 0, 0));
                    System.debug('minusThirtyDate2 ? ' + minusThirtyDate0);
                }

                System.debug('날짜는 ? ' + pbs.InspectDueDate__c);
                System.debug('30일 전 날짜는 ? ' + minusThirtyDate0);
                System.debug('30일 전 요일은 1 ? ' + minusThirtyDate0.format('E'));
                System.debug('30일 전 요일은 2 ? ' + minusThirtyDate0.format('EEEE'));
                System.debug('dayWhat 2 : ' + dayWhat);

                // 메일 알람 보내기 PM, PMO
                if((Date.valueOf(minusThirtyDate0) == System.today() && dayWhat != 'Sat' && dayWhat != 'Sun' && pbs.InspectType__c == '매출') || Test.isRunningTest()){
                    String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/PMS_Project__c/' + pbs.Project__c + '/related/Child_PMS_PjtBillSchedule__r/view';
                    System.debug('recordUrl : ' + recordUrl);
        
                    if(pbs.Project__r.ProjectManagerId__c != null){
                        String dueDate = String.valueOf(pbs.InspectDueDate__c);

                        List<String> toAddresses = new List<String>();

                        if(pbs.Project__r.ProjectManagerId__r.FM_Email__c != null && pbs.Project__r.HQId__r.Name != 'CX본부') {
                            toAddresses.add(pbs.Project__r.ProjectManagerId__r.FM_Email__c);
                        }else if(pbs.Project__r.ProjectManagerId__r.FM_Email__c != null && pbs.Project__r.HQId__r.Name == 'CX본부'){
                            toAddresses.add(csm);
                        }
                        System.debug('toAddresses : ' + toAddresses);
                        
                        // 숨은참조에 EPMO(박승호 본부장, 김동식 팀장, 권종인 포함) 넣어서 보내기
                        List<String> bccAddresses = UTIL_Email.getEPMOAddresses();
                        System.debug('bccAddresses : ' + bccAddresses);

                        /* Files URL 230103_이호재 파일 URL 템플릿으로 이동
                        List<ContentDistribution> filesUrlList = [SELECT ContentDocumentId, ContentDownloadUrl
                                                                  FROM ContentDistribution
                                                                  WHERE Name LIKE 'PMS_사용자메뉴얼(프로젝트 검수관리 가이드)%'
                                                                  ORDER BY CreatedDate DESC
                                                                  LIMIT 1];
                        String filesUrl = '';
                        if(filesUrlList != null || filesUrlList.size() > 0){
                            for(ContentDistribution f : filesUrlList){
                                filesUrl = f.ContentDownloadUrl;
                            }
                        }
                        System.debug('filesUrl : ' + filesUrl);*/

                        UTIL_Email.sendEmailPjtBillNoti(toAddresses, bccAddresses, pbs.Project__r.Name, pbs.Times__c, dueDate, recordUrl);
                    }

                    System.debug('평일 발송');
                }

                // 지연(검수예정일 < 현재날짜) 시 true 및 지연일 입력
                Date today = System.today();
                Integer numberDaysDue = pbs.InspectDueDate__c.daysBetween(today); // 날짜 사이 비교 후 일 수 반환
                if(pbs.InspectDueDate__c < today && pbs.InspectDate__c == null && pbs.Status__c != '검수완료'){
                    pbs.IsDelay__c = true;
                    pbs.DelayPeriod__c = numberDaysDue;

                    System.debug('지연 true');
                    update scope;
                }
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