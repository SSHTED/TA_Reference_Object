@isTest
public class OutSupportManager_TEST {
    static Organization__c org;
    static Employee__c emp;
    static Employee__c emp2;
    static User u;
    static User u2;
    static PMS_PjtResource__c res;
    static Account  acc;
    static Customer_Org__c cOrg;
    static PMS_Project__c pms_project;
    static TeamStatusMonthly__c tsm;
    static OutSupportManager__c osm;
    static PMS_PjtManpowerMonth__c pjtManPower;
    static PMS_PjtManpower__c pjt;
    static{
        
        acc = new Account(
        	Name = 'HDC 현대산업개발'
        );
        insert acc;
        
        cOrg = new Customer_Org__c(
        	Name = 'HDC 현대산업개발',
            Customer__c = acc.Id,
            Team__c = '	CS2'
        );
        insert cOrg;
        
        org = new Organization__c (
            Code__c = 'CX HQ'
            , DisplayOrder__c = 9
            , IsActive__c = true
            , Level__c = '2'
            , Name = 'CX본부'
            , Note__c = 'Tset3'
            , OwnerId = System.UserInfo.getUserId()
            , IsResourceActive__c = true
        );
        insert org;
        
        u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'DK BMC System Admin'].Id
            , LastName = '차용진'
            , Email = 'test31213@dkbmc.com'
            , Username = 'test32113@dkbmc.com' + System.currentTimeMillis()
            , CompanyName = 'dkbmc'
            , EmployeeNumber='1'
            , Title = 'title'
            , Alias = 'alias'
            , TimeZoneSidKey = 'Asia/Seoul'
            , EmailEncodingKey = 'UTF-8'
            , LanguageLocaleKey = 'en_US'
            , LocaleSidKey = 'en_US'
            , IsActive = true
        );
        insert u;
        
        u2 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'DK BMC System Admin'].Id
            , LastName = '이호재'
            , Email = 'hojae.lee@dkbmc.com'
            , Username = 'hojae.lee@dkbmc.com' + System.currentTimeMillis()
            , CompanyName = 'dkbmc'
            , EmployeeNumber='2'
            , Title = 'title2'
            , Alias = 'alias2'
            , TimeZoneSidKey = 'Asia/Seoul'
            , EmailEncodingKey = 'UTF-8'
            , LanguageLocaleKey = 'en_US'
            , LocaleSidKey = 'en_US'
            , IsActive = true
        );
        insert u2;
        
        emp = new Employee__c(
            Name = '차용진'
            , Emp_No__c = '111'
            , Rank__c = '인턴'
            , Start__c = System.today()
            , User__c = u.Id
            , Email__c = 'hojae.lee@dkbmc.com'
            , OrganizationId__c = org.Id
        );
        insert emp;
        
        emp2 = new Employee__c(
            Name = '이호재'
            , Emp_No__c = '113'
            , Rank__c = '사원'
            , Start__c = System.today()
            , User__c = u2.Id
            , Email__c = 'OrgAdmin@dkbmc.com'
            ,  OrganizationId__c = org.Id
        );
        insert emp2;
        
        res = new PMS_PjtResource__c(
        	EmployeeId__c = emp.Id
            , IsActive__c = true
            , Name = emp.Name
            , ResourceType__c = '직원'
        );
        insert res;
        
        pms_project =new PMS_Project__c(
        	Name ='23년 현대산업개발 유지보수 계약 (23년)_Mant_Ren',
            PerformedStage__c = '운영(SM)',
            ContractStartDate__c =Date.newInstance(2023, 01, 01),
            ContractEndDate__c= Date.newInstance(2024, 12, 31),
            Status__c = 'Active',
            ProjectType__c ='SM'
        );
        insert pms_project;
         
        
         pjt = new PMS_PjtManpower__c(
            PjtResourceId__c = res.Id,
            ProjectId__c = pms_project.Id,
            JoinHQ__c = org.Id
        );
        
        insert pjt;
        
        
        tsm =new TeamStatusMonthly__c(
        	TSM_Name__c = emp.Id,
            Account__c = acc.Id,
            Customer_Org__c = cOrg.Id,
            ProjectName__c = pms_project.Id,
            Month__c = '05',
            Support_USE_Monthly__c = 2,
            PMS_PjtManpower__c = pjt.Id
        );         
        insert tsm;
        
       
        
		osm = new OutSupportManager__c(
        	 OSM_Name__c = emp.Id
            ,Customer_Org__c = cOrg.Id
            ,ProjectName__c = pms_project.Id
            ,UseMD__c = 20
            ,SelectMonth__c = '05',
            Expected_MD__c = 20
        );
        insert osm;
        
        pjtManPower = new PMS_PjtManpowerMonth__c(
			Project__c = osm.ProjectName__c,
            ManpowerMM__c = 1,
            BaseDate__c = Date.newInstance(2023, 05, 23),
            PjtManpower__c = pjt.Id
        );
        insert pjtManPower;
    }
    
        @isTest
    static void OutSupportManagerBatch(){
        Test.startTest();
        
       
        Test.stopTest();
    }
}