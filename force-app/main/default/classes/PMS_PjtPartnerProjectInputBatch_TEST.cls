@isTest
public class PMS_PjtPartnerProjectInputBatch_TEST {

    static Id recordId;
    
    @TestSetUp
    static void setUp(){
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
            Name = '정인지',
            Rank__c = '사원',
            Start__c = system.today()
        );
        insert emc;
        
        Organization__c organization = new Organization__c(
            Code__c = 'Tset9'
            , DisplayOrder__c = 8
            , IsActive__c = true
            , Level__c = '1'
            , Name = 'Tset4'
            , Note__c = 'Tset3'
        );
        insert organization;
        
        PMS_PjtPartner__c partner = new PMS_PjtPartner__c(
        	Name ='씨케이넷'
            
        );
        insert partner;
        
        PMS_PjtPartnerEmp__c partnerEmp = new PMS_PjtPartnerEmp__c(
        	PjtPartnerId__c = partner.Id,
            Name = '정인지'
        );
        insert partnerEmp;
        
        PMS_PjtResource__c Res = new PMS_PjtResource__c(
            EmployeeId__c = emc.Id,
            ResourceType__c = '협력사 인력',
            PjtPartnerEmpId__c = partnerEmp.Id
        );
        insert Res;
        
        PMS_PjtManpower__c pjtManPower = new PMS_PjtManpower__c(
            PjtResourceId__c = Res.Id,
            ProjectId__c = prj.Id,
            JoinHQ__c = organization.Id
            
        );
        
        insert pjtManPower;
        Datetime yesterday = Datetime.now().addDays(-1);
        Test.setCreatedDate(pjtManPower.Id, yesterday);
    }
    
    @isTest
    static void PMS_PjtPartnerProjectInputBatch_TEST(){
        SchedulableContext sc = null;
        PMS_PjtPartnerProjectInputBatchScheduler scheduler = new PMS_PjtPartnerProjectInputBatchScheduler();
        scheduler.execute(sc);
    }
    
}