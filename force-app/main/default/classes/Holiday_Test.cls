@isTest //(SeeAllData=true)
public class Holiday_Test{
    
    static User testUser;
    static Date dy = Date.newInstance(2018, 8, 22);
    static Profile p;
    
    static {
        p = TestDataFactory.getProfile('System Administrator');
        if(p == null) {
            p = TestDataFactory.getProfile('시스템 관리자');
        }
    }

    static TestMethod void HolidayEditListController_Test(){        
        
        testUser = TestDataFactory.createUser(p);   
        
        Test.startTest();
        
        HolidayEditListController hel = new HolidayEditListController();
        hel.doCreate();
        hel.search();
        hel.hldChkLst[0].hld.Holiday_JoinDate__c = system.today().addYears(-1).addDays(-1);
        hel.hldChkLst[0].hld.Holiday_Unpaid__c = 1;
        hel.hldChkLst[0].hld.Holiday_Uncountable__c = 1;
        Integer haCnt = 0;
        hel.hldChkLst[0].hld.Holiday_RemainAlternative__c = ++haCnt; 
        hel.doSave();
        hel.checkChange();
        hel.doSendInfo();
        hel.checkChange();
        hel.doResetUnpaid();
        hel.checkChange();
        hel.doResetUncountable();
        hel.doRefreshRemainAlternative();
        hel.checkChange();
        hel.addDays = '2';
        hel.addDesc = null;
        hel.doAdd();
        hel.checkChange();
        hel.addDays = '3';
        hel.addDesc = 'test';
        hel.doAdd();
        hel.checkChange();
        hel.addDays = 'a';
        hel.addDesc = 'test';
        hel.doAdd();
        
        hel.checkChange();
        hel.addDaysLastRemaining = '0';
        hel.addDescLastRemaining = null;
        hel.doAddLastRemaining();
        hel.checkChange();
        hel.addDaysLastRemaining = '3';
        hel.addDescLastRemaining = null;
        hel.doAddLastRemaining();
        hel.checkChange();
        hel.addDaysLastRemaining = 'a';
        hel.addDescLastRemaining = null;
        hel.doAddLastRemaining();
        
        hel.checkChange();
        hel.addDaysUseDays = '0';
        hel.addDescUseDays = null;
        hel.doAddUseDays();
        hel.checkChange();
        hel.addDaysUseDays = '3';
        hel.addDescUseDays = null;
        hel.doAddUseDays();
        hel.checkChange();
        hel.addDaysUseDays = 'a';
        hel.addDescUseDays = null;
        hel.doAddUseDays();        
        
        hel.checkChange();
        hel.checkChange();
        hel.doCancel();
        Test.stopTest();
    }

    static TestMethod void HolidayActionExtension_Test(){
        
        Test.startTest();
        
        testUser = TestDataFactory.createUser(p);
        
        User user = new User(Alias = 'testUser'
                            , Email='SysAdminTestuser@earth.org'
                            , EmailEncodingKey='UTF-8'
                            , LastName='Testing'
                            , LanguageLocaleKey='en_US'
                            , LocaleSidKey='en_US'
                            , EmployeeNumber='AC100000'
                            , ProfileId = p.Id
                            , TimeZoneSidKey='Asia/Seoul'
                            , UserName='SysAdminTestuser@earth.org2'
                            , IsHoliday_Target__c = true);
                                
        insert user;
        
        system.debug(user.Id);
        system.debug(testUser.Id);
        
        System.runAs(user) {

            HolidayEditListController hel = new HolidayEditListController();
            hel.doCreate();
            hel.search();
            
            system.debug(hel);
            
            string ids = hel.hldChkLst[0].hld.Id;
            
            system.debug(ids);
    
            HolidayAction__c ha = new HolidayAction__c();
            ha.HolidayAction_Parent__c = ids;
            ApexPages.StandardController ctrl = new ApexPages.StandardController(ha);  
            
            system.debug(ha);
            
            system.debug(ctrl);
            
            HolidayActionExtension hae = new HolidayActionExtension(ctrl);
            hae.hldyActn.Name = 'test';
            hae.hldyActn.HolidayAction_Approver__c = user.Id;
            hae.hldyActn.HolidayAction_Description__c = 'test';
            hae.hldyActn.HolidayAction_Parent__c = ids;
            hae.hldyActn.HolidayAction_IsConfirm__c = false;
            hae.hldyActn.HolidayAction_IsEmergency__c = false;
            hae.hldyActn.HolidayAction_Type__c = '대체휴가 등록';
            hae.typeCheck();
            hae.hldyActn.HolidayAction_Type__c = '월차';
            hae.typeCheck();
            hae.hldyActn.HolidayAction_Days__c = 6;
            hae.changeDay();
            hae.hldyActn.HolidayAction_Days__c = 5;
            hae.doSave();
            hae.doCancel();
            
            ha = new HolidayAction__c();
            ha.HolidayAction_Parent__c = ids;
            ctrl = new ApexPages.StandardController(ha); 
            hae = new HolidayActionExtension(ctrl);
            hae.hldyActn.Name = 'test';
            hae.hldyActn.HolidayAction_Approver__c = user.Id;
            hae.hldyActn.HolidayAction_Description__c = 'test';
            hae.hldyActn.HolidayAction_Parent__c = ids;
            hae.hldyActn.HolidayAction_IsConfirm__c = false;
            hae.hldyActn.HolidayAction_IsEmergency__c = false;
            hae.hldyActn.HolidayAction_Type__c = '보건휴가';
            hae.typeCheck();
            hae.doSave();
            hae.doCancel();
            hae.checkWeekend();
                
            ha = new HolidayAction__c();
            ha.HolidayAction_Parent__c = ids;
            ctrl = new ApexPages.StandardController(ha); 
            hae = new HolidayActionExtension(ctrl);
            hae.hldyActn.Name = 'test';
            hae.hldyActn.HolidayAction_Approver__c = user.Id;
            hae.hldyActn.HolidayAction_Description__c = 'test';
            hae.hldyActn.HolidayAction_Parent__c = ids;
            hae.hldyActn.HolidayAction_IsConfirm__c = false;
            hae.hldyActn.HolidayAction_IsEmergency__c = false;
            hae.hldyActn.HolidayAction_Type__c = '연차';
            hae.typeCheck();
            hae.doSave();
            hae.doCancel();  
            
            ha = new HolidayAction__c();
            ha.HolidayAction_Parent__c = ids;
            ctrl = new ApexPages.StandardController(ha); 
            hae = new HolidayActionExtension(ctrl);
            hae.hldyActn.Name = 'test';
            hae.hldyActn.HolidayAction_Approver__c = user.Id;
            hae.hldyActn.HolidayAction_Description__c = 'test';
            hae.hldyActn.HolidayAction_Parent__c = ids;
            hae.hldyActn.HolidayAction_IsConfirm__c = false;
            hae.hldyActn.HolidayAction_IsEmergency__c = false;
            hae.hldyActn.HolidayAction_Type__c ='공무';
            hae.typeCheck();
            hae.doSave();
            hae.doCancel();
            
            ha = new HolidayAction__c();
            ha.HolidayAction_Parent__c = ids;
            ctrl = new ApexPages.StandardController(ha); 
            hae = new HolidayActionExtension(ctrl);
            hae.hldyActn.Name = 'test';
            hae.hldyActn.HolidayAction_Approver__c = user.Id;
            hae.hldyActn.HolidayAction_Description__c = 'test';
            hae.hldyActn.HolidayAction_Parent__c = ids;
            hae.hldyActn.HolidayAction_IsConfirm__c = false;
            hae.hldyActn.HolidayAction_IsEmergency__c = false;
            hae.hldyActn.HolidayAction_Type__c = '병가';
            hae.typeCheck();
            hae.doSave();
            hae.doCancel();
            
            string refId = '';
            ha = new HolidayAction__c();
            ha.HolidayAction_Parent__c = ids;
            ctrl = new ApexPages.StandardController(ha);  
            hae = new HolidayActionExtension(ctrl);
            hae.hldyActn.Name = 'test';
            hae.hldyActn.HolidayAction_Approver__c = user.Id;
            hae.hldyActn.HolidayAction_Description__c = 'test';
            hae.hldyActn.HolidayAction_Parent__c = ids;
            hae.hldyActn.HolidayAction_IsConfirm__c = false;
            hae.hldyActn.HolidayAction_IsEmergency__c = false;
            hae.hldyActn.HolidayAction_Type__c = '대체휴가 등록';
            hae.typeCheck();
            hae.doSave();
            hae.doCancel();
            
            ha = new HolidayAction__c();
            ha.HolidayAction_Parent__c = ids;
            ctrl = new ApexPages.StandardController(ha);  
            hae = new HolidayActionExtension(ctrl);
            hae.hldyActn.Name = 'test';
            hae.hldyActn.HolidayAction_Approver__c = user.Id;
            hae.hldyActn.HolidayAction_Description__c = 'test';
            hae.hldyActn.HolidayAction_Parent__c = ids;
            hae.hldyActn.HolidayAction_IsConfirm__c = true;
            hae.hldyActn.HolidayAction_IsEmergency__c = false;
            hae.hldyActn.HolidayAction_Type__c = '대체휴가 등록';
            hae.typeCheck();
            hae.doSave();
            hae.doCancel();
    
            ha = new HolidayAction__c();
            ha.HolidayAction_Parent__c = ids;
            ha.HolidayAction_Type__c = '대체휴가 등록';
            insert ha;
            refId = ha.Id;
                    
            ha = new HolidayAction__c();
            ha.HolidayAction_Parent__c = ids;
            ctrl = new ApexPages.StandardController(ha);   
            hae = new HolidayActionExtension(ctrl);
            hae.hldyActn.Name = 'test';
            hae.hldyActn.HolidayAction_Approver__c = user.Id;
            hae.hldyActn.HolidayAction_Description__c = 'test';
            hae.hldyActn.HolidayAction_Parent__c = ids;
            hae.hldyActn.HolidayAction_IsConfirm__c = false;
            hae.hldyActn.HolidayAction_IsEmergency__c = true;
            hae.hldyActn.HolidayAction_Type__c = '대체휴가';
            hae.hldyActn.HolidayAction_AlternativeBase__c = refId;
            hae.typeCheck();
            hae.doSave();
            hae.doCancel();
            
            
    
            list<HolidayAction__c> haLst = [SELECT Id, HolidayAction_IsConfirm__c, HolidayAction_Date1__c, HolidayAction_Days__c FROM HolidayAction__c];
            for(HolidayAction__c has : haLst) {
                has.HolidayAction_IsConfirm__c = true;
                has.HolidayAction_Date1__c = dy;
                has.HolidayAction_Days__c = 1;
            }
            
            update haLst;
    
            
            Test.stopTest();
        }
    }

    static TestMethod void HolidayMyInfoController_Test(){

        testUser = TestDataFactory.createUser(p);  
        HolidayEditListController hel = new HolidayEditListController();
        hel.doCreate(); 
        
        PageReference myVfPage = Page.MyHolidayInfo;
        Test.setCurrentPageReference(myVfPage);
       
        ApexPages.currentPage().getParameters().put('sfdc.userId',hel.hldChkLst[0].hld.Holiday_User__c);
        String id = ApexPages.currentPage().getParameters().get('sfdc.userId');
        system.assertEquals(true,id!=null);
        Holiday__History hh = new Holiday__History(ParentId = hel.hldChkLst[0].hld.Id, Field = 'Holiday_LastActivity__c');
        Holiday__History hh2 = new Holiday__History(ParentId = hel.hldChkLst[0].hld.Id, Field = 'Holiday_LastActivity__c');
        Holiday__History hh3 = new Holiday__History(ParentId = hel.hldChkLst[0].hld.Id, Field = 'Holiday_LastActivity__c');
        
        insert hh;
        insert hh2;
        hel.hldChkLst[0].hld.Holiday_LastActivity__c = 'test';
        update hel.hldChkLst[0].hld;
        insert hh3;
        
        Test.startTest();
        System.runAs(testUser){
            HolidayMyInfoController ac = new HolidayMyInfoController();
            hel.hldChkLst[0].hld.Holiday_LastActivity__c = 'test2';
            update hel.hldChkLst[0].hld;
            ac.Action();
        }
        Test.stopTest();
    }

    static testMethod void HolidaySchedulertTest() {

        User tUser = new User(Alias = 'tUser'
                            , Email='hjoo.lee@dkbmc.com'
                            , EmailEncodingKey='UTF-8'
                            , LastName='Testing'
                            , LanguageLocaleKey='en_US'
                            , LocaleSidKey='en_US'
                            , EmployeeNumber='AC100000'
                            , ProfileId = p.Id
                            , TimeZoneSidKey='Asia/Seoul'
                            , UserName='SysAdminTuser@earth.org'
                             , IsHoliday_Target__c = true);
                                
        insert tUser;
        
        User tUser2 = new User(Alias = 'tUser2'
                            , Email='hjoo.lee2@dkbmc.com'
                            , EmailEncodingKey='UTF-8'
                            , LastName='Testing2'
                            , LanguageLocaleKey='en_US'
                            , LocaleSidKey='en_US'
                            , EmployeeNumber='AC100000'
                            , ProfileId = p.Id
                            , TimeZoneSidKey='Asia/Seoul'
                            , UserName='SysAdminTuser2@earth.org'
                             , IsHoliday_Target__c = true);
                                
        insert tUser2;
        
        
        
        HolidayEditListController hel = new HolidayEditListController();
        hel.doCreate();
        hel.search();
        //User u = [select id , name From User where id='']
        //2016-03-02 ,  2016-09-12 , 2016-05-02
        
        //(Holiday__c:{Holiday_User__c=00528000000IBiCAAW, Holiday_JoinDate__c=2014-03-03 00:00:00, Holiday_IsAnnualleave__c=true, Holiday_PeriodEnd__c=2016-03-02 00:00:00, Holiday_Calculated__c=15, Holiday_Additionaldays__c=0, Holiday_UseDays__c=0, Holiday_Remain__c=15, Id=a0jN00000059eOrIAI}, 
        //Holiday__c:{Holiday_User__c=00528000001IpdqAAC, Holiday_JoinDate__c=2014-09-13 00:00:00, Holiday_IsAnnualleave__c=true, Holiday_PeriodEnd__c=2016-09-12 00:00:00, Holiday_Calculated__c=15, Holiday_Additionaldays__c=0, Holiday_UseDays__c=0, Holiday_Remain__c=15, Id=a0jN00000059eOsIAI}, 
        //Holiday__c:{Holiday_User__c=00528000000ILDXAA4, Holiday_JoinDate__c=2014-05-03 00:00:00, Holiday_IsAnnualleave__c=true, Holiday_PeriodEnd__c=2016-05-02 00:00:00, Holiday_Calculated__c=15, Holiday_Additionaldays__c=0, Holiday_UseDays__c=0, Holiday_Remain__c=15, Id=a0jN00000059eOtIAI})
        
        hel.hldChkLst[0].hld.Holiday_JoinDate__c = system.today().addYears(-2).addDays(1);
        hel.hldChkLst[0].hld.Holiday_LastActivity__c = '1';
        hel.hldChkLst[0].hld.Holiday_UseDays__c = 20;
        hel.hldChkLst[1].hld.Holiday_JoinDate__c = system.today().addYears(-1).addDays(11).addMonths(-6);
        hel.hldChkLst[1].hld.Holiday_LastActivity__c = '2';
        hel.hldChkLst[2].hld.Holiday_JoinDate__c = system.today().addYears(-1).addDays(1).addMonths(-10);
        hel.hldChkLst[2].hld.Holiday_LastActivity__c = '3';
        hel.doSave();
        list<Holiday__c> hLst = [SELECT Holiday_LastActivity__c, Holiday_PeriodEnd__c FROM Holiday__c];
        system.debug(hLst);
        // TO DO: implement unit test
  		
        Date dToday = system.today();
        Holiday__c hol = new Holiday__c(Holiday_User__c = tUser.Id, 
                                        Holiday_JoinDate__c = dToday.addYears(-1).addDays(1), 
                                        Holiday_GivenHolidays__c=11,
                                        Holiday_UseDays__c=0);
        
        insert hol;
        
        Holiday__c hol2 = new Holiday__c(Holiday_User__c = tUser2.Id, 
                                        Holiday_JoinDate__c = dToday.addYears(-2).addDays(1).addMonths(6), 
                                        Holiday_GivenHolidays__c=11,
                                        Holiday_UseDays__c=0);
        
        insert hol2;
        
        Holiday__c hol3 = new Holiday__c(Holiday_User__c = tUser2.Id, 
                                        Holiday_JoinDate__c = dToday.addYears(-2).addDays(1).addMonths(2), 
                                        Holiday_GivenHolidays__c=11,
                                        Holiday_UseDays__c=0);
        
        insert hol3;
        
        Holiday__c hol4 = new Holiday__c(Holiday_User__c = tUser2.Id, 
                                        Holiday_JoinDate__c = dToday.addYears(-1).addDays(1).addMonths(1), 
                                        Holiday_GivenHolidays__c=11,
                                        Holiday_UseDays__c=0);
        
        insert hol4;
        
        Holiday__c hol5 = new Holiday__c(Holiday_User__c = tUser2.Id, 
                                        Holiday_JoinDate__c = dToday.addYears(-1).addMonths(1).addDays(2), 
                                        Holiday_GivenHolidays__c=11,
                                        Holiday_UseDays__c=0);
        
        insert hol5;
        
        Holiday__c hol6 = new Holiday__c(Holiday_User__c = tUser2.Id, 
                                        Holiday_JoinDate__c = dToday.addYears(-1).addDays(11), 
                                        Holiday_GivenHolidays__c=11,
                                        Holiday_UseDays__c=0);
        
        insert hol6;
        
        Holiday__c hol7 = new Holiday__c(Holiday_User__c = tUser2.Id, 
                                        Holiday_JoinDate__c = dToday.addYears(-1).addDays(1).addMonths(3), 
                                        Holiday_GivenHolidays__c=11,
                                        Holiday_UseDays__c=0);
        
        insert hol7;
        
        
        Test.startTest();
        
        HolidayUpdateStatusBatch batch = new HolidayUpdateStatusBatch();
        Database.executeBatch(batch, 200);
        
        SchedulableContext sc = null;
        HolidayScheduler scheduler = new HolidayScheduler();
        scheduler.execute(sc);
        
        Test.StopTest();
    }

    /*
    static TestMethod void HolidayActionUpdate_Test(){

        Profile p = TestDataFactory.getProfile('System Administrator');
        testUser = TestDataFactory.createUser(p);   
        
        
        //Holiday__c hd = new Holiday__c(Holiday_Uncountable__c=0, Holiday_Unpaid__c=0, Holiday_UseDays__c=0, Holiday_JoinDate__c=Date.newInstance(2016, 7, 12));
        Holiday__c hd = new Holiday__c();
        hd.Holiday_Uncountable__c = 0;
        hd.Holiday_Unpaid__c = 0;
        hd.Holiday_UseDays__c = 0;
        hd.Holiday_JoinDate__c = dy;
        
        insert hd; 
        //HolidayAction ha = new HolidayAction(Name='HAU_HA_TEST', HolidayAction_IsConfirm__c=true, HolidayAction_IsEmergency__c=false, HolidayAction_Type__c='월차', HolidayAction_Days__c=0, HolidayAction_AlternativeBase__c='TEST', Holiday_Uncountable__c=0);
        HolidayAction__c ha = new HolidayAction__c(Name='TEST2', HolidayAction_IsConfirm__c=true, HolidayAction_IsEmergency__c=false, HolidayAction_Type__c='월차', HolidayAction_Days__c=0);
        ha.HolidayAction_Parent__c = hd.Id;
        
        
        Test.startTest();
        

        
        
        
        insert ha;
         
        
        
        
        ha.HolidayAction_Type__c='연차'; 
        update ha;
        hd.Holiday_UseDays__c = ha.HolidayAction_Days__c;
        hd.Holiday_Uncountable__c = 1;
        hd.Holiday_Unpaid__c = 1;
        update hd;
        
        system.debug('test111223' + ha.HolidayAction_Type__c);
        
        ha.Name = 'test';
        ha.HolidayAction_Approver__c = hd.Id;
        ha.HolidayAction_Description__c = 'test';
        ha.HolidayAction_Parent__c = hd.Id;
        ha.HolidayAction_IsConfirm__c = false;
        ha.HolidayAction_IsEmergency__c = true;
        ha.HolidayAction_Type__c = '대체휴가';
        ha.HolidayAction_AlternativeBase__c = hd.Id;
        ha.HolidayAction_Date1__c = dy; 
        
        update hd;
        system.debug('test11122' + ha.HolidayAction_Type__c);
        
        string lstActStr = ha.HolidayAction_Type__c + ' '+ string.valueOf(ha.HolidayAction_Days__c) + '일을 사용했습니다.';
        list<HolidayAction__c> haLst = new list<HolidayAction__c>();
        haLst.add(ha);
    	for(HolidayAction__c hafor: haLst){
            
            lstActStr = ha.HolidayAction_Type__c + ' '+ string.valueOf(ha.HolidayAction_Days__c) + '일을 사용했습니다.';
        }
        Test.stopTest();
    }
*/
}