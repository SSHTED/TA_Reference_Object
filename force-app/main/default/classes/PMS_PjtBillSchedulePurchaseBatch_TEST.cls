@isTest
public with sharing class PMS_PjtBillSchedulePurchaseBatch_TEST {
    static PMS_PjtBillSchedule__c pbs;
    static User u;
    static Employee__c emc;
    static PMS_PjtResource__c Res;
    static PMS_Project__c prj;
    static PMS_PjtPartner__c pp;
    
    static{
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'System Admin' OR Name = '시스템 관리자' LIMIT 1];
        
        u = new User(
            ProfileId = p.Id,
            LastName = '이호재',
            Email = 'test31213@dkbmc.com',
            Username = 'test32113@dkbmc.com' + System.currentTimeMillis(),
            CompanyName = 'dkbmc',
            EmployeeNumber ='1444111',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'Asia/Seoul',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u;
        
        emc = new Employee__c(
            User__c	= u.id
            , Emp_No__c = '1214552'
            , Name = '이호재'
            , Rank__c = '대리'
            , Start__c = system.today()
            , Email__c = 'hojae.lee@dkbmc.com'
        );
        insert emc;
        
        Res = new PMS_PjtResource__c(
            EmployeeId__c = emc.Id
        );
        insert Res;
        
        prj = new PMS_Project__c(
            Name = 'project'
            , OwnerId = System.UserInfo.getUserId()
            , ProjectManagerId__c = Res.Id
        );
        insert prj;
        
        pp = new PMS_PjtPartner__c(
        	Name = '글로벌 퀘스트'
        );
        insert pp;
        
        pbs = new PMS_PjtBillSchedule__c(
        	Project__c = prj.Id
            , PMS_PjtPartner__c = pp.Id
            , Times__c = '3'
            ,InspectType__c = '매입'
            , InspectDueDate__c = system.today()
        );
        insert pbs;
    }
    
    @isTest
    static void test(){
        Test.startTest();
        PMS_PjtBillSchedulePurchaseBatch batch = new PMS_PjtBillSchedulePurchaseBatch();
        batch.query = 'SELECT Project__r.ProjectManagerId__c FROM PMS_PjtBillSchedule__c GROUP BY Project__r.ProjectManagerId__c';
        
        Database.executeBatch(batch, 200);
        SchedulableContext sc = null;
        PMS_PjtBillPurchaseScheduler scheduler = new PMS_PjtBillPurchaseScheduler();
        scheduler.execute(sc);
        Test.stopTest();
    }
}