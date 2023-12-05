public with sharing class HolidayUtil{
    public static void createEvent(HolidayAction__c hlAct){
        date date1 = hlAct.HolidayAction_Date1__c;
        date date2 = hlAct.HolidayAction_Date2__c;
        date date3 = hlAct.HolidayAction_Date3__c;
        date date4 = hlAct.HolidayAction_Date4__c;
        date date5 = hlAct.HolidayAction_Date5__c;
        date date6 = hlAct.HolidayAction_Date6__c;
        date date7 = hlAct.HolidayAction_Date7__c;
        date date8 = hlAct.HolidayAction_Date8__c;
        date date9 = hlAct.HolidayAction_Date9__c;
        date date10 = hlAct.HolidayAction_Date10__c;
        
        date date11 = hlAct.HolidayAction_Date11__c;
        date date12 = hlAct.HolidayAction_Date12__c;
        date date13 = hlAct.HolidayAction_Date13__c;
        date date14 = hlAct.HolidayAction_Date14__c;
        date date15 = hlAct.HolidayAction_Date15__c;
        date date16 = hlAct.HolidayAction_Date16__c;
        date date17 = hlAct.HolidayAction_Date17__c;
        date date18 = hlAct.HolidayAction_Date18__c;
        date date19 = hlAct.HolidayAction_Date19__c;
        date date20 = hlAct.HolidayAction_Date20__c;
        
        date date21 = hlAct.HolidayAction_Date21__c;
        date date22 = hlAct.HolidayAction_Date22__c;
        date date23 = hlAct.HolidayAction_Date23__c;
        date date24 = hlAct.HolidayAction_Date24__c;
        date date25 = hlAct.HolidayAction_Date25__c;
        date date26 = hlAct.HolidayAction_Date26__c;
        date date27 = hlAct.HolidayAction_Date27__c;
        date date28 = hlAct.HolidayAction_Date28__c;
        date date29 = hlAct.HolidayAction_Date29__c;
        date date30 = hlAct.HolidayAction_Date30__c;
        Event e;
        if(hlAct.HolidayAction_Days__c > 0){            e = setEvent(hlAct,date1);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 1){            e = setEvent(hlAct,date2);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 2){            e = setEvent(hlAct,date3);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 3){            e = setEvent(hlAct,date4);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 4){            e = setEvent(hlAct,date5);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 5){            e = setEvent(hlAct,date6);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 6){            e = setEvent(hlAct,date7);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 7){            e = setEvent(hlAct,date8);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 8){            e = setEvent(hlAct,date9);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 9){            e = setEvent(hlAct,date10);            insert e;        }
        
        if(hlAct.HolidayAction_Days__c > 10){            e = setEvent(hlAct,date11);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 11){            e = setEvent(hlAct,date12);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 12){            e = setEvent(hlAct,date13);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 13){            e = setEvent(hlAct,date14);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 14){            e = setEvent(hlAct,date15);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 15){            e = setEvent(hlAct,date16);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 16){            e = setEvent(hlAct,date17);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 17){            e = setEvent(hlAct,date18);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 18){            e = setEvent(hlAct,date19);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 19){            e = setEvent(hlAct,date20);            insert e;        }
        
        if(hlAct.HolidayAction_Days__c > 20){            e = setEvent(hlAct,date21);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 21){            e = setEvent(hlAct,date22);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 22){            e = setEvent(hlAct,date23);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 23){            e = setEvent(hlAct,date24);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 24){            e = setEvent(hlAct,date25);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 25){            e = setEvent(hlAct,date26);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 26){            e = setEvent(hlAct,date27);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 27){            e = setEvent(hlAct,date28);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 28){            e = setEvent(hlAct,date29);            insert e;        }
        if(hlAct.HolidayAction_Days__c > 29){            e = setEvent(hlAct,date30);            insert e;        }
    }
    
    public static Event setEvent(HolidayAction__c hlAct,date dt){
        string userId = hlAct.OwnerId;
        string actId = hlAct.Id;
        string subject = hlAct.Name;
        Event e = new Event();
        e.IsAllDayEvent = true;
        e.OwnerId = hlAct.OwnerId;
        e.ActivityDate = dt;
        e.EndDateTime = dt;
        e.Description = hlAct.HolidayAction_Description__c;
        e.WhatId = hlAct.Id;
        e.StartDateTime = dt;
        e.ShowAs = 'OutOfOffice';
        e.Subject = 'On holiday';
        return e;
    }
    
    public static boolean sendEmail(string pType, User pUsr, Holiday__c pHld){
        try{
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new string[]{pUsr.Email};
           	//String[] toAddresses = new string[]{'yj.cha@dkbmc.com'};
            string subject = '';
            string msgBody =  pUsr.Name + '님 안녕하세요. \r\n';
            msgBody += '\r\n';
            if(pHld.Holiday_IsAnnualleave__c)
                subject = '연차';
            else
                subject = '월차';
            if(pType == 'Info'){
                msgBody += '귀하의 '+ subject + '내역에 대한 안내 메일입니다. \r\n';
                subject += ' 내역 안내';
            }
            else if(pType == '1st'){
                subject += ' 사용 촉진 안내';
                msgBody += '근로기준법 제60조제1항·제3항 및 제4항에 따른 유급휴가의 사용 촉진 안내 메일입니다. \r\n';
                msgBody += '10일 내로 서면을 통해 사용 계획을 회신 부탁드립니다. \r\n';
            }
            else if(pType == '2nd'){
                subject += ' 소멸 안내';
                msgBody += '근로기준법 제60조제7항에 따른 유급휴가의 소멸 안내 메일입니다. \r\n';
                msgBody += '사용기한까지 사용하지 않은 휴가는 소멸되오니 계획 등록 부탁드립니다. \r\n';
                msgBody += '단 프로젝트 일정등의 이유로 사용이 불가피한 경우 기한 만료 후 관리자에게 문의 하시기 바랍니다. \r\n';
            }
            
            
            else if(pType == 'Y1Over_1stDate'){
                subject += ' 1년 이상 근무자 1차 사용 촉진 안내';
                
                msgBody += '근로기준법 제60조(연차 유급휴가)에 따른 유급휴가의 사용 촉진 안내 메일입니다. \r\n';
                msgBody += '10일 내로 서면을 통해 사용 계획을 회신 부탁드립니다. \r\n';
            }
            else if(pType == 'Y1Over_2ndDate'){
                subject += ' 1년 이상 근무자 2차 사용 촉진 및 소멸 안내';
                
                msgBody += '근로기준법 제60조(연차 유급휴가) 제7항에 따른 유급휴가의 소멸 안내 메일입니다. \r\n';
                msgBody += '사용기한까지 사용하지 않은 휴가는 소멸되오니 계획 등록 부탁드립니다. \r\n';
                msgBody += '단 프로젝트 일정등의 이유로 사용이 불가피한 경우 기한 만료 후 관리자에게 문의 하시기 바랍니다. \r\n';
            }
            else if(pType == 'Y1Under_1stDate_9'){
                subject += ' 1년 미만 근무자 연차휴가 9일 1차 사용 촉진 안내';
                
                msgBody += '근로기준법 제61조(연차 유급휴가의 사용 촉진)에 따른 유급휴가의 사용 촉진 안내 메일입니다. \r\n';
                msgBody += '10일 내로 서면을 통해 사용 계획을 회신 부탁드립니다. \r\n';
            }
            else if(pType == 'Y1Under_2ndDate_9'){
                subject += ' 1년 미만 근무자 연차휴가 9일 2차 사용 촉진 및 소멸 안내';
                
                msgBody += '근로기준법 제61조(연차 유급휴가의 사용 촉진)에 따른 유급휴가의 소멸 안내 메일입니다. \r\n';
                msgBody += '사용기한까지 사용하지 않은 휴가는 소멸되오니 계획 등록 부탁드립니다. \r\n';
                msgBody += '단 프로젝트 일정등의 이유로 사용이 불가피한 경우 기한 만료 후 관리자에게 문의 하시기 바랍니다. \r\n';
            }
            else if(pType == 'Y1Under_1stDate_2'){
                subject += ' 1년 미만 근무자 연차휴가 2일 1차 사용 촉진 안내';
                
                msgBody += '근로기준법 제61조(연차 유급휴가의 사용 촉진)에 따른 유급휴가의 사용 촉진 안내 메일입니다. \r\n';
                msgBody += '5일 내로 서면을 통해 사용 계획을 회신 부탁드립니다. \r\n';
            }
            else if(pType == 'Y1Under_2ndDate_2'){
                subject += ' 1년 미만 근무자 연차휴가 2일 2차 사용 촉진 및 소멸 안내';
                
                msgBody += '근로기준법 제61조(연차 유급휴가의 사용 촉진)에 따른 유급휴가의 소멸 안내 메일입니다. \r\n';
                msgBody += '사용기한까지 사용하지 않은 휴가는 소멸되오니 계획 등록 부탁드립니다. \r\n';
                msgBody += '단 프로젝트 일정등의 이유로 사용이 불가피한 경우 기한 만료 후 관리자에게 문의 하시기 바랍니다. \r\n\r\n';
            }
            msgBody += '계획 등록 양식은 이 링크 [미사용 연차유급휴가 사용시기 지정 통보서] (https://dkbmc.lightning.force.com/lightning/r/ContentDocument/0690I00000H64VSQAZ/view)를 통해 다운 받으시기 바랍니다.\r\n\r\n';
            msgBody += '아래의 휴가 관련 내역을 휴가 사용에 참고하시기 바랍니다. \r\n\r\n';

            msgBody += '입사일자 : ' + date.valueOf(pHld.Holiday_JoinDate__c).format() + '\r\n';
            msgBody += '사용기한 : ' + date.valueOf(pHld.Holiday_PeriodEnd__c).format() + '\r\n\r\n';
            
            msgBody += '휴가일수 : ' + string.valueOf(pHld.Holiday_Calculated__c) + '일\r\n';
            msgBody += '사용일수 : ' + string.valueOf(pHld.Holiday_UseDays__c) + '일\r\n';
            msgBody += '잔여일수 : ' + string.valueOf(pHld.Holiday_Remain__c) + '일\r\n\r\n';
            
            msgBody += '프로젝트 휴가일수 : ' + string.valueOf(pHld.Holiday_GivenHolidays__c) + '일\r\n';
            msgBody += '프로젝트 사용일수 : ' + string.valueOf(pHld.Holiday_GivenUseDays__c) + '일\r\n';
            msgBody += '프로젝트 잔여일수 : ' + string.valueOf(pHld.Holiday_GivenRemain__c) + '일\r\n\r\n';
            
            msgBody += '전체 잔여일수 : ' + string.valueOf(pHld.Holiday_TotalRemain__c) + '일\r\n\r\n';
            
            msgBody += '\r\n';
            msgBody += '자세한 내역은 ' + URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/n/MyHolidaySubmit 에서 확인 가능합니다.\r\n';
            msgBody += '위 내역이 이상 있을 경우 매니저에게 문의하시기 바랍니다.\r\n';
            msgBody += '\r\n';
            msgBody += '귀하의 노고에 감사드립니다.\r\n';
            msgBody += '\r\n';
            msgBody += 'DKBMC co. ltd.';
            
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            
            List<String> mEmails = getMonitoringEmailList();
            if(mEmails.size() > 0) {
                email.setBccAddresses(mEmails);
            }            
            email.setPlainTextBody(msgBody);
            
            if(!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }catch(Exception e){
            System.debug(e);
            return false;
        }
        return true;
    }
    
    private static List<String> getMonitoringEmailList()
    {
        List<String> BccAddresses = new List<String>();
        
        // Email Monitoring 여부
        if('Y' == System.Label.IsEmailMonitoring) {
            try {
                // Monitoring 대상 Email 추가
                Map<String, Object> MEmap = (Map<String, Object>) JSON.deserializeUntyped(System.Label.MonitoringTargetEmail);
                Set<String> addEmails = MEmap.keyset();
                for(String email_addr : addEmails) {
                     BccAddresses.add(email_addr);
                }
            } catch(Exception e) {
                System.debug(e);
            }
        }
        return BccAddresses;
    }
}