@isTest
public class PMS_PjtBillScheduleBatch_TEST {
    static PMS_PjtBillSchedule__c pms_bill;
    static Organization__c organization;
    static PMS_Project__c pms_project;
    static PMS_PjtResource__c pms_resource;
    static Employee__c emp;

    static{
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
        
        User u = [SELECT Id FROM User WHERE Name = '이호재' LIMIT 1];
        emp = new Employee__c(
            Name = '홍길동'
            , Emp_No__c = '111'
            , Rank__c = '인턴'
            , Start__c = date.today()
            , User__c = u.Id
            , Email__c = 'hojae.lee@dkbmc.com'
        );
        insert emp;
        
        pms_resource = new PMS_PjtResource__c(
            Name = 'test1'
            , ResourceType__c = '직원'
            , EmployeeId__c = emp.Id
        );
        insert pms_resource;

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
            , HQId__c = organization.Id
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
            , ProjectManagerId__c = pms_resource.Id
        );
        insert pms_project;

        pms_bill = new PMS_PjtBillSchedule__c(
            Project__c = pms_project.Id
            , InspectDueDate__c = date.newInstance(2009, 12, 26)
            , IsDelay__c = False
            , DelayPeriod__c = 0
            , Times__c = '1'
        );
        insert pms_bill;
    }
    static testMethod void myUnitTest() {

        Test.startTest();
    
        PMS_PjtBillScheduleBatch batch = new PMS_PjtBillScheduleBatch();
        Database.executeBatch(batch, 200);
        
        SchedulableContext sc = null;
        PMS_PjtBillScheduleScheduler scheduler = new PMS_PjtBillScheduleScheduler();
        scheduler.execute(sc);

        Test.stopTest();
    }
}