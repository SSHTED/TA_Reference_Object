public with sharing class HolidayEditListController{
    public list<HolidayCheck> hldChkLst {get;set;}
    public string addDays {get;set;}
    public string addDesc {get;set;}
    public string chkStr  {get;set;}
    
    public string addDaysLastRemaining {get;set;}
    public string addDescLastRemaining {get;set;}
    
    public string addDaysUseDays {get;set;}
    public string addDescUseDays {get;set;}
    
    public HolidayEditListController(){
        search();
        chkStr = '전체선택';
    }
    
    public void doCreate(){
        list<User> usrLst = [SELECT Id, CreatedDate FROM User 
                              WHERE Id NOT IN (SELECT Holiday_User__c FROM Holiday__c) 
                              AND   IsActive = true
                              AND   IsHoliday_Target__c = true
                              AND   Alias != 'Chatter'
                              AND   ProfileId in(SELECT Id From Profile WHERE UserLicense.Name in( 'Force.com - App Subscription','Salesforce') )];
        if(usrLst.isEmpty()){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, '신규 직원이 없습니다.'));
            return;
        }
        list<Holiday__c> hLst = new list<Holiday__c>();
        for(User usr : usrLst){
            date joinDate = date.valueOf(usr.CreatedDate);
            Holiday__c h = new Holiday__c(Holiday_JoinDate__c = joinDate , Holiday_LastActivity__c = '신규생성', Holiday_NoticeLevel__c = '서면통지전', Holiday_User__c = usr.Id);
            hLst.add(h);
        }
        insert hLst;
        
        list<Holiday__Share> hsLst = new list<Holiday__Share>();
        for(Holiday__c h : hLst){
            Holiday__Share hldShr = new Holiday__Share ();
            hldShr.ParentId = h.Id;
            hldShr.RowCause = Schema.Holiday__Share.RowCause.Holiday_Owner__c;
            hldShr.UserOrGroupId = h.Holiday_User__c ;
            hldShr.AccessLevel = 'Read';
            hsLst.add(hldShr);
        }
        insert hsLst;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, '생성완료.'));
        search();
    }
    
    public void doSave(){
        list<Holiday__c> hldLst = new list<Holiday__c>();
        for(HolidayCheck hc : hldChkLst){
            hldLst.add(hc.hld);
        }
        update hldLst;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, '저장완료.'));
        search();
    }
    
    public PageReference doCancel(){
        return new PageReference('/');
    }
    
    public void doSendInfo(){
        doSend('Info');
            
    }
    
    public void doSendWarning(){
        doSend('1st');
    }
    
    public void doSendExpire(){
        doSend('2nd');
    }
    
    public void doSend(string pType){
        list<Holiday__c> upLst = new list<Holiday__c>();
        List<User> uList = [SELECT Email, Name FROM User WHERE IsActive = true AND IsHoliday_Target__c = true];
        Map<String, User> uMap = new Map<String, User>();
        for(User u : uList) {
            uMap.put(u.Id, u);
        }
        for(HolidayCheck hc : hldChkLst){
            if(hc.chk){
                //User usr = [SELECT Email,Name FROM User WHERE Id = :hc.hld.Holiday_User__c];
                boolean finish = HolidayUtil.sendEmail(pType, uMap.get(hc.hld.Holiday_User__c), hc.hld);
                string noticeLevel = '';
                if(pType == '1st')
                    noticeLevel = '사용촉진통지';
                else if(pType == '2nd')
                    noticeLevel = '소멸안내통지';
                if(finish){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, '메일 발송 완료.'));
                    if(pType != 'Info'){
                        hc.hld.Holiday_NoticeLevel__c = noticeLevel ;
                        upLst.add(hc.hld);
                    }
                }
                else
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '메일 발송 중 오류가 발생했습니다.'));
                hc.chk = false;
            }
        }
        chkStr = '전체선택';
        if(pType != 'Info'){
            update upLst;
            search();
        }
    }
    
    public void checkChange(){
        boolean chk = false;
        if(chkStr == '전체선택'){
            chkStr = '선택해제';
            chk = true;
        }
        else{
            chkStr = '전체선택';
            chk = false;
        }
        
        
        for(HolidayCheck hc : hldChkLst)
                hc.chk = chk ;
    }
    
    public void doResetUnpaid(){
         list<Holiday__c> hldLst = new list<Holiday__c>();
        for(HolidayCheck hc : hldChkLst){
            if(hc.chk && hc.hld.Holiday_Unpaid__c > 0){
                hc.hld.Holiday_Unpaid__c = 0;
                hldLst.add(hc.hld);
            }
        }
        update hldLst;
        search();
    }
    
    public void doResetUncountable(){
        string msg = UserInfo.getLastName() + '님이 제외일수를 초기화 하였습니다.';
         list<Holiday__c> hldLst = new list<Holiday__c>();
        for(HolidayCheck hc : hldChkLst){
            if(hc.chk && hc.hld.Holiday_Uncountable__c> 0){
                hc.hld.Holiday_Uncountable__c = 0;
                hc.hld.Holiday_LastActivity__c = msg ;
                hldLst.add(hc.hld);
            }
        }
        update hldLst;
        search();
    }
    
    public void doRefreshRemainAlternative(){
        
        list<Holiday__c> hldUpLst = new list<Holiday__c>();
        list<Holiday__c> hldLst = [SELECT Id FROM Holiday__c WHERE Holiday_IsActive__c = true];
        Map<Id, Integer> raMap = new Map<Id, Integer>();
        
        AggregateResult[] raLst = [SELECT HolidayAction_Parent__c , Count(Id) cnt
                                     FROM HolidayAction__c 
                                    WHERE HolidayAction_IsConfirm__c = true 
                                      AND HolidayAction_AlternativeBase__c = null
                                      AND HolidayAction_Type__c = '대체휴가 등록' 
                                    Group By HolidayAction_Parent__c ];
        for(AggregateResult ar : raLst){
            raMap.put((Id)ar.get('HolidayAction_Parent__c' ),(Integer)ar.get('cnt'));
        }
            
        for(Holiday__c hld : hldLst) {          
            Integer raCnt = raMap.get(hld.Id);
            if(raCnt == null)
                raCnt = 0;
            hld.Holiday_RemainAlternative__c = raCnt;
        }
        
        update hldLst ;
        search();
    }
    
    public void doAddUseDays(){
        decimal day = 0;
        string msg = UserInfo.getLastName();
        try{
            day = decimal.valueOf(addDaysUseDays);
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '일수가 잘못 입력되었습니다.'));
            addDaysUseDays = '0';
            return;
        }
        if(day == 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '일수가 0입니다.'));
            return;
        }
        msg += '님이 추가일수 ' + string.valueOf(day) + '일을 추가하였습니다. 사유 : ';
        if(addDescUseDays == null || addDescUseDays == '')
            msg += ' 추가일수 부여';
        else
            msg += ' ' + addDescUseDays;
        
        list<Holiday__c> hldLst = new list<Holiday__c>();
        
        for(HolidayCheck hc : hldChkLst){
            if(hc.chk){
                hc.hld.Holiday_UseDays__c += day ;
                hc.hld.Holiday_LastActivity__c = msg ;
                hldLst.add(hc.hld);
            }
        }
        update hldLst;
        search();
    }
    
    public void doAddLastRemaining(){
        decimal day = 0;
        string msg = UserInfo.getLastName();
        try{
            day = decimal.valueOf(addDaysLastRemaining);
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '일수가 잘못 입력되었습니다.'));
            addDaysLastRemaining = '0';
            return;
        }
        if(day == 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '일수가 0입니다.'));
            return;
        }
        msg += '님이 추가일수 ' + string.valueOf(day) + '일을 추가하였습니다. 사유 : ';
        if(addDescLastRemaining == null || addDescLastRemaining == '')
            msg += ' 추가일수 부여';
        else
            msg += ' ' + addDescLastRemaining;
        
        list<Holiday__c> hldLst = new list<Holiday__c>();
        
        for(HolidayCheck hc : hldChkLst){
            if(hc.chk){
                hc.hld.Holiday_Last_Remaining1__c += day ;
                hc.hld.Holiday_LastActivity__c = msg ;
                hldLst.add(hc.hld);
            }
        }
        update hldLst;
        search();
    }
    
    public void doAdd(){
        
        decimal day = 0;
        string msg = UserInfo.getLastName();
        
        try{
            day = decimal.valueOf(addDays);
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '일수가 잘못 입력되었습니다.'));
            addDays = '0';
            return;

        }
        if(day == 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '일수가 0입니다.'));
            return;
        }
        msg += '님이 추가일수 ' + string.valueOf(day) + '일을 추가하였습니다. 사유 : ';
        if(addDesc==null || addDesc=='')
            msg += ' 추가일수 부여';
        else
            msg += ' ' + addDesc;
        
        list<Holiday__c> hldLst = new list<Holiday__c>();
        for(HolidayCheck hc : hldChkLst){
            if(hc.chk){
                hc.hld.Holiday_GivenHolidays__c += day ;
                hc.hld.Holiday_LastActivity__c = msg ;
                hldLst.add(hc.hld);
            }
        }
        update hldLst;
        search();
    }
    
    public void search(){
        list<Holiday__c> hldLst = 
            [SELECT Id, Name, Holiday_Additionaldays__c, Holiday_Calculated__c, Holiday_GivenHolidays__c, Holiday_IsActive__c, Holiday_IsAnnualleave__c,
                    Holiday_JoinDate__c, Holiday_LastActivity__c, Holiday_NoticeLevel__c, Holiday_PeriodEnd__c, Holiday_Remain__c,
                    Holiday_StartDate__c, Holiday_Uncountable__c, Holiday_RemainAlternative__c, Holiday_Unpaid__c, Holiday_UseDays__c, Holiday_User__c, Holiday_User__r.Name, 
                    Holiday_WorkingYears__c, Holiday_GivenUseDays__c, Holiday_TotalRemain__c, Holiday_GivenRemain__c, Holiday_IsNewLawApply__c
             		, Holiday_IsNewLaw2Apply__c, Holiday_Last_Remaining1__c, Holiday_Last_Remaining2__c
               FROM Holiday__c
              WHERE Holiday_IsActive__c = true order by Holiday_JoinDate__c];
    
        hldChkLst = new list<HolidayCheck>();
        for(Holiday__c hld : hldLst)
            hldChkLst.add(new HolidayCheck(false,hld));
        chkStr = '전체선택';
    }
    
    public class HolidayCheck{
        public boolean chk {get;set;}
        public Holiday__c hld {get;set;}
        public HolidayCheck(boolean pChk, Holiday__c pHld){
            chk = pChk;
            hld = pHld;
        }
    }
}