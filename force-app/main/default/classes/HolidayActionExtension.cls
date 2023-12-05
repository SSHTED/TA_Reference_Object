public with sharing class HolidayActionExtension{
    private ApexPages.StandardController controller {get; set;}
    private HolidayAction__c hldyActn{get;set;}
    private set<Date> holidaySet {get;set;}
    private string retId {get;set;}
    private Holiday__c h {get;set;}
    private Integer days {get;set;}
    private Date dates {get;set;}
    
    public HolidayActionExtension(ApexPages.StandardController stdctrl){
        retId =  ApexPages.currentPage().getParameters().get('retId');
        controller = stdctrl;
        hldyActn = (HolidayAction__c )controller.getRecord();
        hldyActn.HolidayAction_Days__c = 1;
        //hldyActn.HolidayAction_Approver__c = UserInfo.getUserId();
        hldyActn.OwnerId = UserInfo.getUserId();
        hldyActn.HolidayAction_Date1__c = system.today().addDays(1);
        List<User> uList = [select ManagerId from User where Id = :UserInfo.getUserId()];
        if(uList.size() == 1) {
            hldyActn.HolidayAction_Approver__c = uList.get(0).ManagerId;
        }
        
        string usrId = UserInfo.getUserId();
        
        h = [
            SELECT 
            	Id
            	,Holiday_IsAnnualleave__c
            	, Holiday_Remain__c
            	, Holiday_GivenRemain__c
            	, Holiday_Last_Remaining1__c
            FROM
            	Holiday__c
            WHERE 
            	Holiday_User__c = :usrId 
            limit 1
        ];
        string parentId = h.Id;
        hldyActn.HolidayAction_Parent__c = parentId;
        
        if(h.Holiday_IsAnnualleave__c){
            hldyActn.HolidayAction_Type__c = '연차';
        }
        else if(!h.Holiday_IsAnnualleave__c){
            hldyActn.HolidayAction_Type__c = '월차';
        }
    }
    
    public void typeCheck(){
        if(hldyActn.HolidayAction_Type__c == '대체휴가 등록'){
            hldyActn.HolidayAction_Days__c = 0;
        }
        else if(hldyActn.HolidayAction_Type__c == '반차(오전)' || hldyActn.HolidayAction_Type__c == '반차(오후)'){
            hldyActn.HolidayAction_Days__c = 0.5;
        }
        else{
            hldyActn.HolidayAction_Days__c = 1;
        }
        if(hldyActn.HolidayAction_Type__c == '월차' && h.Holiday_IsAnnualleave__c){
            hldyActn.HolidayAction_Type__c = '연차';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, '연차대상자이므로 유형을 연차로 변경하였습니다.'));
        }
        else if(hldyActn.HolidayAction_Type__c == '연차' && !h.Holiday_IsAnnualleave__c){
            hldyActn.HolidayAction_Type__c = '월차';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, '월차대상자이므로 유형을 월차로 변경하였습니다.'));
        }
    }
    
    public void changeDay(){
        if(hldyActn.HolidayAction_Days__c > 30 || hldyActn.HolidayAction_Days__c < 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '1에서 30까지 입력 가능합니다.'));
            hldyActn.HolidayAction_Days__c = 1;
        }
        
        if(hldyActn.HolidayAction_Type__c == '반차(오전)' || hldyActn.HolidayAction_Type__c == '반차(오후)') {
            if(hldyActn.HolidayAction_Days__c != 0.5){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '반차는 일수 0.5 만 입력 가능합니다.'));
                hldyActn.HolidayAction_Days__c = 0.5;
            }
        }
        
     	days = 1;
        dates = hldyActn.HolidayAction_Date1__c;
        
        //if(hldyActn.HolidayAction_Days__c == 1) { hldyActn.HolidayAction_Date1__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 2) { hldyActn.HolidayAction_Date2__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 3) { hldyActn.HolidayAction_Date3__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 4) { hldyActn.HolidayAction_Date4__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 5) { hldyActn.HolidayAction_Date5__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 6) { hldyActn.HolidayAction_Date6__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 7) { hldyActn.HolidayAction_Date7__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 8) { hldyActn.HolidayAction_Date8__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 9) { hldyActn.HolidayAction_Date9__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 10) { hldyActn.HolidayAction_Date10__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 11) { hldyActn.HolidayAction_Date11__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 12) { hldyActn.HolidayAction_Date12__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 13) { hldyActn.HolidayAction_Date13__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 14) { hldyActn.HolidayAction_Date14__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 15) { hldyActn.HolidayAction_Date15__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 16) { hldyActn.HolidayAction_Date16__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 17) { hldyActn.HolidayAction_Date17__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 18) { hldyActn.HolidayAction_Date18__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 19) { hldyActn.HolidayAction_Date19__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 20) { hldyActn.HolidayAction_Date20__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 21) { hldyActn.HolidayAction_Date21__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 22) { hldyActn.HolidayAction_Date22__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 23) { hldyActn.HolidayAction_Date23__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 24) { hldyActn.HolidayAction_Date24__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 25) { hldyActn.HolidayAction_Date25__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 26) { hldyActn.HolidayAction_Date26__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 27) { hldyActn.HolidayAction_Date27__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 28) { hldyActn.HolidayAction_Date28__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 29) { hldyActn.HolidayAction_Date29__c = NextDate(); }
        if(hldyActn.HolidayAction_Days__c >= 30) { hldyActn.HolidayAction_Date30__c = NextDate(); }
            
        checkDate();
    }
    
    public void checkWeekend() {
        
        Datetime myDT = Datetime.newInstance(hldyActn.HolidayAction_Date1__c, system.now().time()) ;
		String myDate = myDT.format('u');
        if('6' == myDate || '7' == myDate) {
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '주말은 선택할 수 없습니다.'));
            hldyActn.HolidayAction_Date1__c = null;
            checkDate();
        } else {
            changeDay();
        }
        
    }
    
    public Date NextDate() {

        // Day number of week (1 = Monday, ..., 7 = Sunday)
        dates = dates.addDays(1);
        
        Datetime myDT = Datetime.newInstance(dates, system.now().time()) ;
		String myDate = myDT.format('u');
        if('6' == myDate) {
        	dates = dates.addDays(2);
        } else if('7' == myDate) {
        	dates = dates.addDays(1);
        }
        
        return dates;
    }
    
    public void checkDate(){
        holidaySet = new set<Date>();
        holidaySet.add(hldyActn.HolidayAction_Date30__c);
        holidaySet.add(hldyActn.HolidayAction_Date29__c);
        holidaySet.add(hldyActn.HolidayAction_Date28__c);
        holidaySet.add(hldyActn.HolidayAction_Date27__c);
        holidaySet.add(hldyActn.HolidayAction_Date26__c);
        holidaySet.add(hldyActn.HolidayAction_Date25__c);
        holidaySet.add(hldyActn.HolidayAction_Date24__c);
        holidaySet.add(hldyActn.HolidayAction_Date23__c);
        holidaySet.add(hldyActn.HolidayAction_Date22__c);
        holidaySet.add(hldyActn.HolidayAction_Date21__c);
        
        holidaySet.add(hldyActn.HolidayAction_Date20__c);
        holidaySet.add(hldyActn.HolidayAction_Date19__c);
        holidaySet.add(hldyActn.HolidayAction_Date18__c);
        holidaySet.add(hldyActn.HolidayAction_Date17__c);
        holidaySet.add(hldyActn.HolidayAction_Date16__c);
        holidaySet.add(hldyActn.HolidayAction_Date15__c);
        holidaySet.add(hldyActn.HolidayAction_Date14__c);
        holidaySet.add(hldyActn.HolidayAction_Date13__c);
        holidaySet.add(hldyActn.HolidayAction_Date12__c);
        holidaySet.add(hldyActn.HolidayAction_Date11__c);
        
        holidaySet.add(hldyActn.HolidayAction_Date10__c);
        holidaySet.add(hldyActn.HolidayAction_Date9__c);
        holidaySet.add(hldyActn.HolidayAction_Date8__c);
        holidaySet.add(hldyActn.HolidayAction_Date7__c);
        holidaySet.add(hldyActn.HolidayAction_Date6__c);
        holidaySet.add(hldyActn.HolidayAction_Date5__c);
        holidaySet.add(hldyActn.HolidayAction_Date4__c);
        holidaySet.add(hldyActn.HolidayAction_Date3__c);
        holidaySet.add(hldyActn.HolidayAction_Date2__c);
        holidaySet.add(hldyActn.HolidayAction_Date1__c);
        
        if(hldyActn.HolidayAction_Days__c < 30) { holidaySet.remove(hldyActn.HolidayAction_Date30__c); hldyActn.HolidayAction_Date30__c = null; }
        if(hldyActn.HolidayAction_Days__c < 29) { holidaySet.remove(hldyActn.HolidayAction_Date29__c); hldyActn.HolidayAction_Date29__c = null; }
        if(hldyActn.HolidayAction_Days__c < 28) { holidaySet.remove(hldyActn.HolidayAction_Date28__c); hldyActn.HolidayAction_Date28__c = null; }
        if(hldyActn.HolidayAction_Days__c < 27) { holidaySet.remove(hldyActn.HolidayAction_Date27__c); hldyActn.HolidayAction_Date27__c = null; }
        if(hldyActn.HolidayAction_Days__c < 26) { holidaySet.remove(hldyActn.HolidayAction_Date26__c); hldyActn.HolidayAction_Date26__c = null; }
        if(hldyActn.HolidayAction_Days__c < 25) { holidaySet.remove(hldyActn.HolidayAction_Date25__c); hldyActn.HolidayAction_Date25__c = null; }
        if(hldyActn.HolidayAction_Days__c < 24) { holidaySet.remove(hldyActn.HolidayAction_Date24__c); hldyActn.HolidayAction_Date24__c = null; }
        if(hldyActn.HolidayAction_Days__c < 23) { holidaySet.remove(hldyActn.HolidayAction_Date23__c); hldyActn.HolidayAction_Date23__c = null; }
        if(hldyActn.HolidayAction_Days__c < 22) { holidaySet.remove(hldyActn.HolidayAction_Date22__c); hldyActn.HolidayAction_Date22__c = null; }
        if(hldyActn.HolidayAction_Days__c < 21) { holidaySet.remove(hldyActn.HolidayAction_Date21__c); hldyActn.HolidayAction_Date21__c = null; }
        
        if(hldyActn.HolidayAction_Days__c < 20) { holidaySet.remove(hldyActn.HolidayAction_Date20__c); hldyActn.HolidayAction_Date20__c = null; }
        if(hldyActn.HolidayAction_Days__c < 19) { holidaySet.remove(hldyActn.HolidayAction_Date19__c); hldyActn.HolidayAction_Date19__c = null; }
        if(hldyActn.HolidayAction_Days__c < 18) { holidaySet.remove(hldyActn.HolidayAction_Date18__c); hldyActn.HolidayAction_Date18__c = null; }
        if(hldyActn.HolidayAction_Days__c < 17) { holidaySet.remove(hldyActn.HolidayAction_Date17__c); hldyActn.HolidayAction_Date17__c = null; }
        if(hldyActn.HolidayAction_Days__c < 16) { holidaySet.remove(hldyActn.HolidayAction_Date16__c); hldyActn.HolidayAction_Date16__c = null; }
        if(hldyActn.HolidayAction_Days__c < 15) { holidaySet.remove(hldyActn.HolidayAction_Date15__c); hldyActn.HolidayAction_Date15__c = null; }
        if(hldyActn.HolidayAction_Days__c < 14) { holidaySet.remove(hldyActn.HolidayAction_Date14__c); hldyActn.HolidayAction_Date14__c = null; }
        if(hldyActn.HolidayAction_Days__c < 13) { holidaySet.remove(hldyActn.HolidayAction_Date13__c); hldyActn.HolidayAction_Date13__c = null; }
        if(hldyActn.HolidayAction_Days__c < 12) { holidaySet.remove(hldyActn.HolidayAction_Date12__c); hldyActn.HolidayAction_Date12__c = null; }
        if(hldyActn.HolidayAction_Days__c < 11) { holidaySet.remove(hldyActn.HolidayAction_Date11__c); hldyActn.HolidayAction_Date11__c = null; }
        
        if(hldyActn.HolidayAction_Days__c < 10) { holidaySet.remove(hldyActn.HolidayAction_Date10__c); hldyActn.HolidayAction_Date10__c = null; }
        if(hldyActn.HolidayAction_Days__c < 9) { holidaySet.remove(hldyActn.HolidayAction_Date9__c); hldyActn.HolidayAction_Date9__c = null; }
        if(hldyActn.HolidayAction_Days__c < 8) { holidaySet.remove(hldyActn.HolidayAction_Date8__c); hldyActn.HolidayAction_Date8__c = null; }
        if(hldyActn.HolidayAction_Days__c < 7) { holidaySet.remove(hldyActn.HolidayAction_Date7__c); hldyActn.HolidayAction_Date7__c = null; }
        if(hldyActn.HolidayAction_Days__c < 6) { holidaySet.remove(hldyActn.HolidayAction_Date6__c); hldyActn.HolidayAction_Date6__c = null; }
        if(hldyActn.HolidayAction_Days__c < 5) { holidaySet.remove(hldyActn.HolidayAction_Date5__c); hldyActn.HolidayAction_Date5__c = null; }
        if(hldyActn.HolidayAction_Days__c < 4) { holidaySet.remove(hldyActn.HolidayAction_Date4__c); hldyActn.HolidayAction_Date4__c = null; }
        if(hldyActn.HolidayAction_Days__c < 3) { holidaySet.remove(hldyActn.HolidayAction_Date3__c); hldyActn.HolidayAction_Date3__c = null; }
        if(hldyActn.HolidayAction_Days__c < 2) { holidaySet.remove(hldyActn.HolidayAction_Date2__c); hldyActn.HolidayAction_Date2__c = null; }
        //if(hldyActn.HolidayAction_Days__c < 1) { holidaySet.remove(hldyActn.HolidayAction_Date1__c); hldyActn.HolidayAction_Date1__c = null; }
    }
    
    public PageReference doCancel(){
        return new PageReference('/apex/MyHolidayInfo?sfdc.userId='+retId);
    }
    
    public PageReference doSave(){
        try{
            string usrId = UserInfo.getUserId();
            checkDate();
            if(hldyActn.HolidayAction_Type__c == '반차(오전)' || hldyActn.HolidayAction_Type__c == '반차(오후)') {
                if(hldyActn.HolidayAction_Days__c != 0.5 ||  holidaySet.size() != 1){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '일자를 확인하세요.'));
                    return null;
                }
            } else {
                if(hldyActn.HolidayAction_Days__c != holidaySet.size()){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '일자를 확인하세요.'));
                    return null;
                }
            }
            // 2020-04-02 추가 / 2020-06-02 라벨로 사용 여부 체크
            if('Y' == System.Label.HOLIDAY_CHECK_YN) {
				if(hldyActn.HolidayAction_Type__c == '연차' || hldyActn.HolidayAction_Type__c == '월차') {                
                    if(h.Holiday_Remain__c < hldyActn.HolidayAction_Days__c){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '신청할 수 있는 ' + hldyActn.HolidayAction_Type__c + '일수('+h.Holiday_Remain__c+'일)를 초과 하였습니다.'));
                        return null;
                    }
                } else if(hldyActn.HolidayAction_Type__c == '프로젝트휴가') {                
                    if(h.Holiday_GivenRemain__c < hldyActn.HolidayAction_Days__c){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '신청할 수 있는 ' + hldyActn.HolidayAction_Type__c + '일수('+h.Holiday_GivenRemain__c+'일)를 초과 하였습니다.'));
                        return null;
                    }
                } else if(hldyActn.HolidayAction_Type__c == '이월연차') {                
                    if(h.Holiday_Last_Remaining1__c < hldyActn.HolidayAction_Days__c){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '신청할 수 있는 ' + hldyActn.HolidayAction_Type__c + '일수('+h.Holiday_Last_Remaining1__c +'일)를 초과 하였습니다.'));
                        return null;
                    }
                }
            }
            if(hldyActn.HolidayAction_Type__c =='보건휴가'){
                integer year = system.today().year();                
                integer mon = system.today().month();
                date fromdt = date.newInstance(year, mon, 1);
                integer cnt = [SELECT Id FROM HolidayAction__c WHERE HolidayAction_Parent__c =:hldyActn.HolidayAction_Parent__c AND HolidayAction_Date1__c >= :fromdt AND HolidayAction_Type__c ='보건휴가'].size();
                if(cnt > 0 ){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '당월 보건휴가를 이미 사용했습니다.'));
                    return null;
                 }   
            }
            else If(hldyActn.HolidayAction_Type__c =='대체휴가'&& hldyActn.HolidayAction_AlternativeBase__c == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '대체휴가 근거가 입력되지 않았습니다.'));
                return null;
            }
            if(hldyActn.HolidayAction_Approver__c == null  || hldyActn.HolidayAction_Approver__c == usrId ){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '승인자가 입력되지 않았습니다.'));
                return null;
            }

            insert hldyActn;
            
            string message = ' ' + hldyActn.HolidayAction_Type__c + '가(이)     요청되었습니다.';
            if(hldyActn.HolidayAction_IsEmergency__c){
                HolidayUtil.createEvent(hldyActn);
                message = ' ' + hldyActn.HolidayAction_Type__c + '가(이) 등록되었습니다.';
            }
            //createFeed(hldyActn.HolidayAction_Approver__c, hldyActn.Id, message);
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('휴무관리 승인 요청입니다.');
            req1.setObjectId(hldyActn.id);
            req1.setNextApproverIds(new list<string>{hldyActn.HolidayAction_Approver__c});
            Approval.ProcessResult result = Approval.process(req1);     

        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
                return null;
        }
        return new PageReference('/apex/MyHolidayInfo?sfdc.userId='+retId);
    }
    public void createFeed(string pWho, string pWhat, string pMessage){
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();

        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        list<string> readerLst = new list<string>();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        mentionSegmentInput.id = pWho ;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        textSegmentInput.text = pMessage;
        messageBodyInput.messageSegments.add(textSegmentInput);
        
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = pWhat;
        
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
    }
    /*
    public void addShare(string pHaId, list<string> pUsrLst){
        list<HolidayAction__Share> haLst= new list<HolidayAction__Share>();
        for(string s:pUsrLst){
            HolidayAction__Share haShr = new HolidayAction__Share();
            haShr.ParentId = pHaId;
            haShr.RowCause = Schema.HolidayAction__Share.RowCause.ActionReader__c;
            haShr.UserOrGroupId = s;
            haShr.AccessLevel = 'Read';
            haLst.add(haShr);
        }
        insert haLst;
    }
    */
}
/*
public with sharing class HolidayActionExtension{
    private ApexPages.StandardController controller {get; set;}
    private HolidayAction__c hldyActn{get;set;}
    private set<Date> holidaySet {get;set;}
    private string retId {get;set;}
    private Holiday__c h {get;set;}
    
    public HolidayActionExtension(ApexPages.StandardController stdctrl){
        retId =  ApexPages.currentPage().getParameters().get('retId');
        controller = stdctrl;
        hldyActn = (HolidayAction__c )controller.getRecord();
        hldyActn.HolidayAction_Days__c = 1;
        //hldyActn.HolidayAction_Approver__c = UserInfo.getUserId();
        hldyActn.OwnerId = UserInfo.getUserId();
        hldyActn.HolidayAction_Date1__c = system.today().addDays(1);
        string usrId = UserInfo.getUserId();
        
        h = [SELECT Id,Holiday_IsAnnualleave__c FROM Holiday__c WHERE Holiday_User__c = :usrId  limit 1];
        string parentId = h.Id;
        hldyActn.HolidayAction_Parent__c = parentId;
        
        if(h.Holiday_IsAnnualleave__c){
            hldyActn.HolidayAction_Type__c = '연차';
        }
        else if(!h.Holiday_IsAnnualleave__c){
            hldyActn.HolidayAction_Type__c = '월차';
        }
    }
    
    public void typeCheck(){
        if(hldyActn.HolidayAction_Type__c == '대체휴가 등록'){
            hldyActn.HolidayAction_Days__c = 0;
        }
        else{
            hldyActn.HolidayAction_Days__c = 1;
        }
        if(hldyActn.HolidayAction_Type__c == '월차' && h.Holiday_IsAnnualleave__c){
            hldyActn.HolidayAction_Type__c = '연차';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, '연차대상자이므로 유형을 연차로 변경하였습니다.'));
        }
        else if(hldyActn.HolidayAction_Type__c == '연차' && !h.Holiday_IsAnnualleave__c){
            hldyActn.HolidayAction_Type__c = '월차';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, '월차대상자이므로 유형을 월차로 변경하였습니다.'));
        }
    }
    
    public void changeDay(){
        If(hldyActn.HolidayAction_Days__c >5 || hldyActn.HolidayAction_Days__c < 0){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '1에서 5까지 입력 가능합니다.'));
            hldyActn.HolidayAction_Days__c = 1;
        }
        If(hldyActn.HolidayAction_Days__c == 1)
            hldyActn.HolidayAction_Date1__c = system.today().addDays(1);
        If(hldyActn.HolidayAction_Days__c >= 2)
        hldyActn.HolidayAction_Date2__c = system.today().addDays(2);
        If(hldyActn.HolidayAction_Days__c >= 3)
        hldyActn.HolidayAction_Date3__c = system.today().addDays(3);
        If(hldyActn.HolidayAction_Days__c >= 4)
        hldyActn.HolidayAction_Date4__c = system.today().addDays(4);
        If(hldyActn.HolidayAction_Days__c == 5)
        hldyActn.HolidayAction_Date5__c = system.today().addDays(5);
        checkDate();
    }
    
    public void checkDate(){
        holidaySet = new set<Date>();
        holidaySet.add(hldyActn.HolidayAction_Date5__c);
        holidaySet.add(hldyActn.HolidayAction_Date4__c);
        holidaySet.add(hldyActn.HolidayAction_Date3__c);
        holidaySet.add(hldyActn.HolidayAction_Date2__c);
        holidaySet.add(hldyActn.HolidayAction_Date1__c);
        if(hldyActn.HolidayAction_Days__c < 5){
            holidaySet.remove(hldyActn.HolidayAction_Date5__c);
            hldyActn.HolidayAction_Date5__c = null;
        }
        if(hldyActn.HolidayAction_Days__c < 4){
            holidaySet.remove(hldyActn.HolidayAction_Date4__c);
            hldyActn.HolidayAction_Date4__c = null;
        }
        if(hldyActn.HolidayAction_Days__c < 3){
            holidaySet.remove(hldyActn.HolidayAction_Date3__c);
            hldyActn.HolidayAction_Date3__c = null;
        }
        if(hldyActn.HolidayAction_Days__c < 2){
            holidaySet.remove(hldyActn.HolidayAction_Date2__c);
            hldyActn.HolidayAction_Date2__c = null;
        }
        if(hldyActn.HolidayAction_Days__c < 1){
            holidaySet.remove(hldyActn.HolidayAction_Date1__c);
            hldyActn.HolidayAction_Date1__c = null;
        }
    }
    public PageReference doCancel(){
        return new PageReference('/apex/MyHolidayInfo?sfdc.userId='+retId);
    }
    
    public PageReference doSave(){
        try{
            string usrId = UserInfo.getUserId();
            checkDate();
            if(hldyActn.HolidayAction_Days__c != holidaySet.size()){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '일자를 확인하세요.'));
                return null;
            }
            if(hldyActn.HolidayAction_Type__c =='보건휴가'){
                integer year = system.today().year();                
                integer mon = system.today().month();
                date fromdt = date.newInstance(year, mon, 1);
                integer cnt = [SELECT Id FROM HolidayAction__c WHERE HolidayAction_Parent__c =:hldyActn.HolidayAction_Parent__c AND HolidayAction_Date1__c >= :fromdt AND HolidayAction_Type__c ='보건휴가'].size();
                if(cnt > 0 ){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '당월 보건휴가를 이미 사용했습니다.'));
                    return null;
                 }   
            }
            else If(hldyActn.HolidayAction_Type__c =='대체휴가'&& hldyActn.HolidayAction_AlternativeBase__c == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '대체휴가 근거가 입력되지 않았습니다.'));
                return null;
            }
            if(hldyActn.HolidayAction_Approver__c == null  || hldyActn.HolidayAction_Approver__c == usrId ){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, '승인자가 입력되지 않았습니다.'));
                return null;
            }
            
            insert hldyActn;
            
            string message = ' ' + hldyActn.HolidayAction_Type__c + '가(이)     요청되었습니다.';
            if(hldyActn.HolidayAction_IsEmergency__c){
                HolidayUtil.createEvent(hldyActn);
                message = ' ' + hldyActn.HolidayAction_Type__c + '가(이) 등록되었습니다.';
            }
            createFeed(hldyActn.HolidayAction_Approver__c, hldyActn.Id, message);
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('휴무관리 승인 요청입니다.');
            req1.setObjectId(hldyActn.id);
            req1.setNextApproverIds(new list<string>{hldyActn.HolidayAction_Approver__c});
            Approval.ProcessResult result = Approval.process(req1);     
        }catch(Exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
            system.debug(e.getMessage());
                return null;
        }
        return new PageReference('/apex/MyHolidayInfo?sfdc.userId='+retId);
    }
    public void createFeed(string pWho, string pWhat, string pMessage){
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();

        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        list<string> readerLst = new list<string>();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        mentionSegmentInput.id = pWho ;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        textSegmentInput.text = pMessage;
        messageBodyInput.messageSegments.add(textSegmentInput);
        
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = pWhat;
        
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
    }
}*/