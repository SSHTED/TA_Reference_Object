@isTest
public with sharing class PMS_PjtManpowerBatch_Test{
    
    static Id recordId;
    
    @TestSetup
    static void setup(){
        PMS_Project__c prj = new PMS_Project__c(
            Name = 'project'
            , OwnerId = System.UserInfo.getUserId()
        );
        insert prj;
        recordId = prj.Id;
        System.debug('recordId1 : ' + recordId);
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = 'System Admin' OR Name = '시스템 관리자' LIMIT 1];
        
        User u = new User(
            ProfileId = p.Id,
            LastName = '황병훈',
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
        
        Employee__c emc = new Employee__c(
            User__c	= u.id,
            Emp_No__c = '1214552',     
            Name = '황병훈',
            Rank__c = '대리',
            Start__c = system.today()
        );
        insert emc;
        
        PMS_PjtResource__c Res = new PMS_PjtResource__c(
            EmployeeId__c = emc.Id
        );
        insert Res;
        
        Organization__c organization = new Organization__c(
            Code__c = 'Tset9'
            , DisplayOrder__c = 8
            , IsActive__c = true
            , Level__c = '1'
            , Name = 'Tset4'
            , Note__c = 'Tset3'
        );
        insert organization;
        
        PMS_PjtManpower__c pm = new PMS_PjtManpower__c(    
            IsPurchase__c = true
            , ContractPlanEndDate__c = System.today() - 10
            , InputEndDate__c = System.today() - 10
            , PjtResourceId__c = Res.id 
            , ProjectId__c = prj.Id
            , OrgName__c = 'DK BMC'
            , JoinHQ__c = organization.Id
            , JoinDivision__c = organization.Id
            , PlannedTotalInputMM__c = 123
            , ActualInputMM__c = 456
        );
        insert pm;
        System.debug('pm : ' + pm);
        System.debug('pm : ' + pm.ProjectId__c);
        
        PMS_PjtManpower__c pm2 = new PMS_PjtManpower__c(    
            IsPurchase__c = true
            , ContractPlanEndDate__c = System.today() - 10
            , InputEndDate__c = System.today() - 10
            , PjtResourceId__c = Res.id 
            , ProjectId__c = prj.Id
            , OrgName__c = '삼성'
            , JoinHQ__c = organization.Id
            , JoinDivision__c = organization.Id
            , PlannedTotalInputMM__c = 1233
            , ActualInputMM__c = 4563
        );
        insert pm2;
        
        PMS_PjtManpower__c pm02 = new PMS_PjtManpower__c(    
            IsPurchase__c = true
            , ContractPlanEndDate__c = System.today() - 10
            , InputEndDate__c = System.today() - 10
            , PjtResourceId__c = Res.id 
            , ProjectId__c = prj.Id
            , OrgName__c = 'DK BMC'
            , JoinHQ__c = organization.Id
            , PlannedTotalInputMM__c = 123
            , ActualInputMM__c = 456
        );
        insert pm02;
        System.debug('pm02 : ' + pm02);
        System.debug('pm02 : ' + pm02.ProjectId__c);
        
        PMS_PjtJoinHQ__c hq = new PMS_PjtJoinHQ__c(
            ProjectId__c = pm02.ProjectId__c
            , HQ__c = pm02.JoinHQ__c
            , exId__c = pm02.JoinHQ__c
            , FM_DKBMC_Plan_MM__c = pm02.PlannedTotalInputMM__c
            , FM_Partner_Plan_MM__c = pm02.PlannedTotalInputMM__c
            , FM_DKBMC_Actual_MM__c = pm02.ActualInputMM__c
            , FM_Partner_Actual_MM__c = pm02.ActualInputMM__c
        );
        insert hq;
        
        PMS_PjtJoinDivTeam__c dt = new PMS_PjtJoinDivTeam__c(
            ProjectId__c = pm.ProjectId__c
            , HQ__c = pm.JoinHQ__c
            , Division__c = pm.JoinDivision__c
            , exId__c = pm.JoinDivision__c
            , FM_DKBMC_Plan_MM__c = pm.PlannedTotalInputMM__c
            , FM_DKBMC_Actual_MM__c = pm.ActualInputMM__c
            , IsPM__c = false
            , IsDeleted__c = false
        );
        insert dt;
        
        PMS_PjtJoinDivTeam__c dt2 = new PMS_PjtJoinDivTeam__c(
        	ProjectId__c = pm2.ProjectId__c
            , HQ__c = pm2.JoinHQ__c
            , Division__c = pm2.JoinDivision__c
            , exId__c = pm2.JoinHQ__c + '_' + pm2.JoinDivision__c
            , FM_Partner_Plan_MM__c = pm.PlannedTotalInputMM__c
            , FM_Partner_Actual_MM__c = pm.ActualInputMM__c
            , IsPM__c = true
            , IsDeleted__c = false
        );
        insert dt2;
    }
    
    @isTest
    static void PMS_PjtManpowerBatch_Test1(){
        
        Test.startTest();
        PMS_PjtManpowerBatch batch = new PMS_PjtManpowerBatch(recordId);
        Database.executeBatch(batch, 200);
        
        SchedulableContext sc = null;
        PMS_PjtManpowerPurchaseScheduler scheduler = new PMS_PjtManpowerPurchaseScheduler();
        scheduler.execute(sc);
        Test.stopTest();
    }
}