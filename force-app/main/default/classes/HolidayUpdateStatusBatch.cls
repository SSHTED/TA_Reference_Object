global class HolidayUpdateStatusBatch implements Database.Batchable<sObject> {
    
    global Date tDate = system.today();

    global Date Y1Over_1stDate = tDate.addMonths(6);
    global Date Y1Over_2ndDate = tDate.addMonths(2);
    global Date Y1Under_1stDate_9 = tDate.addMonths(3);
    global Date Y1Under_2ndDate_9 = tDate.addMonths(1).addDays(1);
    global Date Y1Under_1stDate_2 = tDate.addMonths(1);
    global Date Y1Under_2ndDate_2 = tDate.addDays(10);
    
    global List<Date> tatgetDateList = new List<Date>{
        tDate
        , Y1Over_1stDate
        , Y1Over_2ndDate
        , Y1Under_1stDate_9
        , Y1Under_2ndDate_9
        , Y1Under_1stDate_2
        , Y1Under_2ndDate_2
    };
        
    global HolidayUpdateStatusBatch() {
		System.debug(tatgetDateList);
    }

    global database.querylocator start(Database.BatchableContext BC){
        
        String SOQL = ' select  '
                    + '     	Holiday_User__c '
                    + '     	, Holiday_User__r.Name '
                    + '     	, Holiday_JoinDate__c '
                    + '     	, Holiday_IsAnnualleave__c '
                    + '     	, Holiday_PeriodEnd__c '
                    + '     	, Holiday_Calculated__c '
                    + '     	, Holiday_Additionaldays__c '
                    + '     	, Holiday_UseDays__c '
                    + '     	, Holiday_Remain__c '
                    + '     	, Holiday_NoticeLevel__c '
                    + '     	, Holiday_Uncountable__c '
                    + '     	, Holiday_LastActivity__c '
                    + '     	, Holiday_GivenHolidays__c '
                    + '     	, Holiday_GivenUseDays__c '
                    + '     	, Holiday_GivenRemain__c '
                    + '     	, Holiday_TotalRemain__c '
            		+ '			, Holiday_Last_Remaining1__c '
            		+ '			, Holiday_Last_Remaining2__c '
                    + '     from '
                    + '     	Holiday__c '
                    + '     where '
                    + '     	Holiday_PeriodEnd__c in :tatgetDateList '
            		+ '		and Holiday_IsActive__c = true ';
        
        return Database.getQueryLocator(SOQL);
    }

    global void execute(Database.BatchableContext BC, List<Holiday__c> scope){
        for(Holiday__c h : scope) {
            System.debug('## ------------------- : ' + h.Holiday_User__r.Name + ' - ' + h.Holiday_PeriodEnd__c);
            if(tDate == h.Holiday_PeriodEnd__c)
            {
                System.debug('## type : Reset');
                if(tDate >= h.Holiday_JoinDate__c.addYears(1).addDays(-1)){
                    decimal useDay = 0;
                    string actStr = '연차 초기화';
                    if(h.Holiday_Remain__c < 0){
                        useDay = h.Holiday_Remain__c * -1;
                        actStr += ', 전년도 추가사용 ' + useDay + '일이 반영 되었습니다.';
                    }
                    h.Holiday_UseDays__c = useDay;
                    h.Holiday_Uncountable__c = 0;
                    h.Holiday_LastActivity__c = actStr;
                }
                h.Holiday_NoticeLevel__c = '서면통지전';
                h.Holiday_Last_Remaining2__c = h.Holiday_Last_Remaining1__c;
                h.Holiday_Last_Remaining1__c = h.Holiday_Remain__c;                
            } 
            else if(Y1Over_1stDate == h.Holiday_PeriodEnd__c && h.Holiday_IsAnnualleave__c)
            {
                System.debug('## type : Y1Over_1stDate');
                User usr = [SELECT Email, Name FROM User WHERE Id = :h.Holiday_User__c];
                HolidayUtil.sendEmail('Y1Over_1stDate', usr, h);
                h.Holiday_NoticeLevel__c = '1차 사용촉진(1년이상)';
            }
            else if(Y1Over_2ndDate == h.Holiday_PeriodEnd__c && h.Holiday_IsAnnualleave__c)
            {
                System.debug('## type : Y1Over_2ndDate');
                User usr = [SELECT Email, Name FROM User WHERE Id = :h.Holiday_User__c];
                HolidayUtil.sendEmail('Y1Over_2ndDate', usr, h);
                h.Holiday_NoticeLevel__c = '2차 사용촉진(1년이상)';
            }
            else if(Y1Under_1stDate_9 == h.Holiday_PeriodEnd__c && h.Holiday_IsAnnualleave__c == false)
            {
                System.debug('## type : Y1Under_1stDate_9');
                User usr = [SELECT Email, Name FROM User WHERE Id = :h.Holiday_User__c];
                HolidayUtil.sendEmail('Y1Under_1stDate_9', usr, h);
                h.Holiday_NoticeLevel__c = '1차 사용촉진(1년미만, 9일)';
            }
            else if(Y1Under_2ndDate_9 == h.Holiday_PeriodEnd__c && h.Holiday_IsAnnualleave__c == false)
            {
                System.debug('## type : Y1Under_2ndDate_9');
                User usr = [SELECT Email, Name FROM User WHERE Id = :h.Holiday_User__c];
                HolidayUtil.sendEmail('Y1Under_2ndDate_9', usr, h);
                h.Holiday_NoticeLevel__c = '2차 사용촉진(1년미만, 9일)';
            }
            else if(Y1Under_1stDate_2 == h.Holiday_PeriodEnd__c && h.Holiday_IsAnnualleave__c == false)
            {
                System.debug('## type : Y1Under_1stDate_2');
                User usr = [SELECT Email, Name FROM User WHERE Id = :h.Holiday_User__c];
                HolidayUtil.sendEmail('Y1Under_1stDate_2', usr, h);
                h.Holiday_NoticeLevel__c = '1차 사용촉진(1년미만, 2일)';
            }
            else if(Y1Under_2ndDate_2 == h.Holiday_PeriodEnd__c && h.Holiday_IsAnnualleave__c == false)
            {
                System.debug('## type : Y1Under_2ndDate_2');
                User usr = [SELECT Email, Name FROM User WHERE Id = :h.Holiday_User__c];
                HolidayUtil.sendEmail('Y1Under_2ndDate_2', usr, h);
                h.Holiday_NoticeLevel__c = '2차 사용촉진(1년미만, 2일)';
            }
            else
            {
                System.debug('## 대상아님');
            }
        }
        
        update scope;
    }

    global void finish(Database.BatchableContext BC){
        
    }
}