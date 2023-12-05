@isTest
public class PMS_ObjShareByProjectUpdateBatch_TEST {

    static PMS_PjtEvalSettle__c pms_pjtevalsettle;
    static Organization__c organization;
    static Organization__c organization2;
    static PMS_Project__c pms_project;
    static PMS_Project__c pms_project2;
    static PMS_PjtManpower__c pms_manpower;
    static PMS_PjtResource__c pms_resource;
    static Employee__c emp;
    
    static {
        organization = new Organization__c (
            Code__c = 'CX HQ'
            , DisplayOrder__c = 9
            , IsActive__c = true
            , Level__c = '2'
            , Name = 'CX본부'
            , Note__c = 'Tset3'
            , OwnerId = System.UserInfo.getUserId()
        );
        insert organization;
        
        organization2 = new Organization__c (
            Code__c = 'DA HQ'
            , DisplayOrder__c = 9
            , IsActive__c = true
            , Level__c = '2'
            , Name = 'DA본부'
            , Note__c = 'Tset3'
            , OwnerId = System.UserInfo.getUserId()
        );
    
        insert organization2;
        
        pms_project = new PMS_Project__c (
            ActualCost__c = 5
            , ActualLaborCost_DKBMC__c = 2
            , ActualLaborCost_Outsourcing__c = 1
            , AdditionalAmt__c = 10
            , Billing__c = 'Billable'
            , ContractAmt__c = 3
            , ContractEndDate__c = date.today()
            , ContractStartDate__c = date.today()
            , ContractUnit__c = 'Man/Month'
            , Currency__c = 'KRW'
            , DeadlineDate__c = date.today()
            , DetailedType__c = '고객 프로젝트'
            , DifferenceCause__c = 'Tset9'
            , EstimatedLaborCost_DKBMC__c = 8
            , EstimatedLaborCost_Outsourcing__c = 1
            , ExpectedCost__c = 3
            // , ExpectedProfitMargin__c = 85
            , HQId__c = organization2.Id
            , Industry__c = 'CBU(비상주)'
            , IsOnTime__c = true
            , KickoffDate__c = date.today()
            , Name = 'Tset10'
            , OnTimeReason__c = 'Tset2'
            , OwnerId = System.UserInfo.getUserId()
            , PerformedStage__c = 'commit'
            , PricingModel__c = 'Fixed Price'
            , Product_Solution__c = 'Tset8'
            , ProjectOutline__c = 'Tset4'
            , ProjectType__c = 'SI'
            , SignOffConditions__c = 'Tset1'
            , SignOffDate__c = date.today()
            , Status__c = 'Planning'
            , TotalContractBillableMM__c = 10
            , WorkArea__c = '서울/수도권'
            , WorkLocation__c = '고객사'
        );
    
        insert pms_project;
        
        pms_project2 = new PMS_Project__c (
            ActualCost__c = 5
            , ActualLaborCost_DKBMC__c = 2
            , ActualLaborCost_Outsourcing__c = 1
            , AdditionalAmt__c = 10
            , Billing__c = 'Billable'
            , ContractAmt__c = 3
            , ContractEndDate__c = date.today()
            , ContractStartDate__c = date.today()
            , ContractUnit__c = 'Man/Month'
            , Currency__c = 'KRW'
            , DeadlineDate__c = date.today()
            , DetailedType__c = '고객 프로젝트'
            , DifferenceCause__c = 'Tset9'
            , EstimatedLaborCost_DKBMC__c = 8
            , EstimatedLaborCost_Outsourcing__c = 1
            , ExpectedCost__c = 3
            // , ExpectedProfitMargin__c = 85
            , HQId__c = organization.Id
            , Industry__c = 'CBU(비상주)'
            , IsOnTime__c = true
            , KickoffDate__c = date.today()
            , Name = 'Tset11'
            , OnTimeReason__c = 'Tset2'
            , OwnerId = System.UserInfo.getUserId()
            , PerformedStage__c = 'commit'
            , PricingModel__c = 'Fixed Price'
            , Product_Solution__c = 'Tset8'
            , ProjectOutline__c = 'Tset4'
            , ProjectType__c = 'SI'
            , SignOffConditions__c = 'Tset1'
            , SignOffDate__c = date.today()
            , Status__c = 'Planning'
            , TotalContractBillableMM__c = 10
            , WorkArea__c = '서울/수도권'
            , WorkLocation__c = '고객사'
        );
    
        insert pms_project2;
    
        pms_pjtevalsettle = new PMS_PjtEvalSettle__c (
            Actual_MM__c = 4
            , ActualEndDate__c = date.today()
            , ActualStartDate__c = date.today()
            , Billable_MM__c = 9
            , BusinessFinancialMngScore__c = 9
            , ContractPlan_MM__c = 6
            , ContractPlanEndDate__c = date.today()
            , ContractPlanStartDate__c = date.today()
            , Division__c = 'Tset10'
            , EvalFeedback__c = 'Tset10'
            , EvalTargetType__c = 'PM 평가'
            , EvaluatorType__c = '본부장'
            , HQ__c = 'Tset8'
            , InCustomer_MM__c = 1
            , InDKBMC_MM__c = 9
            , LeadershipsScore__c = 2
            , Note__c = 'Tset9'
            , OrgName__c = 'Tset8'
            , OwnerId = System.UserInfo.getUserId()
            , ProfessionalEffectivenessScore__c = 5
            , ProjectId__c = pms_project.Id
            , ProjectVacation__c = 2
            , Rank__c = 'Tset1'
            , RelationshipsScore__c = 3
            , ResultsScore__c = 6
            , Role__c = 'Tset4'
            , SFGrade__c = 'Tset4'
            , Team__c = 'Tset9'
            , TechGrade__c = 'Tset9'
            , WorkStatus__c = 'Tset9'
        );
    
        insert pms_pjtevalsettle;
        
        User u3 = [SELECT Id FROM User WHERE Name = 'Org Admin'];
        /*User user = new User(
        	Alias = 'testUser'
            , Email = 'SysAdminTestuser@dkbmc.com'
            , EmailEncodingKey = 'UTF-8'
            , LastName = 'Testing'
            , LanguageLocaleKey = 'en_US'
            , LocaleSidKey = 'en_US'
            , EmployeeNumber = 'AC100000'
            , TimeZoneSidKey = 'Asia/Seoul'
            , ProfileId = [select id from Profile where Name='DK BMC System Admin'].Id
            , Username = 'SysAdminTestuser@dkbmc.com'
        );                   
        insert user;*/
        
        emp = new Employee__c(
        	Name = '홍길동'
            , Emp_No__c = '111'
            , Rank__c = '인턴'
            , Start__c = date.today()
            , User__c = u3.Id
        );
        insert emp;
        
        PMS_PjtPartner__c pp = new PMS_PjtPartner__c(
        	Name = '협력사'
        );
        insert pp;
        
        PMS_PjtPartnerEmp__c pEmp = new PMS_PjtPartnerEmp__c(
        	Name = '이사원'
            , PjtPartnerId__c = pp.Id
        );
        insert pEmp;
        
        pms_resource = new PMS_PjtResource__c(
        	Name = 'test1'
            , ResourceType__c = '직원'
            , EmployeeId__c = emp.Id
            , IsActive__c = true
            , PjtPartnerEmpId__c = pEmp.Id
        );
        insert pms_resource;
    
        pms_manpower = new PMS_PjtManpower__c(
        	ProjectId__c = pms_project2.Id
            , PjtResourceId__c = pms_resource.Id
            , JoinHQ__c = organization.Id
        );
        insert pms_manpower;
    }
    static testMethod void myUnitTest() {

        Test.startTest();
    
        PMS_ObjShareByProjectUpdateBatch batch = new PMS_ObjShareByProjectUpdateBatch();
        Database.executeBatch(batch, 200);
        
        SchedulableContext sc = null;
        PMS_ObjShareByProjectUpdateScheduler scheduler = new PMS_ObjShareByProjectUpdateScheduler();
        scheduler.execute(sc);

        Test.stopTest();
    }
}