@isTest
global class PMS_MonthlyInputStatusBatch_TEST{
    static Organization__c org;
    static PMS_PjtPartner__c par;
    static Employee__c emp;
    static PMS_PjtPartnerEmp__c pemp;
    static PMS_PjtResource__c res01;
    static PMS_PjtResource__c res02;
    static PMS_Project__c pjt;
    static PMS_PjtManpower__c pm01;
    static PMS_PjtManpower__c pm02;
    static PMS_PjtManpowerMonth__c pmm01;
    static PMS_PjtManpowerMonth__c pmm02;
    static PMS_PjtManpowerMonth__c pmm03;
    static PMS_PjtManpowerMonth__c pmm04;
    static PMS_PjtManpowerMonth__c pmm05;
    static PMS_PjtManpowerMonth__c pmm06;
    static PMS_PjtManpowerMonth__c pmm07;
    static PMS_PjtManpowerMonth__c pmm08;
    static PMS_PjtManpowerMonth__c pmm09;
    static PMS_PjtManpowerMonth__c pmm10;
    static PMS_PjtManpowerMonth__c pmm11;
    static PMS_PjtManpowerMonth__c pmm12;
    static PMS_MonthlyInputStatus__c pmis;

    static{
        org = new Organization__c(
            Code__c = 'CX HQ'
            , DisplayOrder__c = 9
            , IsActive__c = true
            , Level__c = '2'
            , Name = 'CX본부'
            , Note__c = 'Tset3'
            , OwnerId = System.UserInfo.getUserId()
        );
        insert org;

        par = new PMS_PjtPartner__c(
            Name = 'test협력사'
        );
        insert par;
        
        User u = [SELECT Id FROM User WHERE Name = '이호재' LIMIT 1];
        emp = new Employee__c(
            Name = '홍길동'
            , Emp_No__c = '111'
            , Rank__c = '인턴'
            , Start__c = date.today()
            , User__c = u.Id
            , Email__c = 'hojae.lee@dkbmc.com'
            , Affiliation_company__c = 'DK BMC'
            , OrganizationId__c = org.Id
        );
        insert emp;

        pemp = new PMS_PjtPartnerEmp__c(
            Name = '협력사직원'
            , PjtPartnerId__c = par.Id
        );
        insert pemp;
        
        res01 = new PMS_PjtResource__c(
            Name = 'test123'
            , ResourceType__c = '직원'
            , EmployeeId__c = emp.Id
            , IsActive__c = true
        );
        insert res01;

        res02 = new PMS_PjtResource__c(
            Name = 'test1'
            , ResourceType__c = '협력사 인력'
            , PjtPartnerEmpId__c = pemp.Id
            , IsActive__c = true
        );
        insert res02;

        pjt = new PMS_Project__c(
            Name = 'testPjt'
        );
        insert pjt;

        pm01 = new PMS_PjtManpower__c(
            PjtResourceId__c = res01.Id
            , ProjectId__c = pjt.Id
            , JoinHQ__c = org.Id
            , ContractPlanStartDate__c = Date.newInstance(2021, 01, 01)
            , ContractPlanEndDate__c = Date.newInstance(2023, 12, 31) // 21.01.01 - 23.12.31
            , BillingType__c = 'Billable'
            , PlannedBillableMM__c = 1
        );
        insert pm01;
        pm02 = new PMS_PjtManpower__c(
            PjtResourceId__c = res02.Id
            , ProjectId__c = pjt.Id
            , JoinHQ__c = org.Id
            , ContractPlanStartDate__c = Date.newInstance(2021, 01, 01)
            , ContractPlanEndDate__c = Date.newInstance(2023, 12, 31) // 21.01.01 - 23.12.31
            , BillingType__c = 'Training'
            , PlannedBillableMM__c = 1
        );
        insert pm02;

        pmm01 = new PMS_PjtManpowerMonth__c(
            PjtManpower__c = pm01.Id
            , Project__c = pjt.Id
            , BaseDate__c = Date.newInstance(2021, 01, 01)
            , Type__c = '계획'
            , ManpowerMM__c = 12
            , ExId__c = pm01.Id + String.valueOf(2021) + String.valueOf(1) + '계획' + 'Billable'
            , Billing__c = 'Billable'
            , IsAvailable__c = true
        );
        insert pmm01;
        pmm02 = new PMS_PjtManpowerMonth__c(
            PjtManpower__c = pm01.Id
            , Project__c = pjt.Id
            , BaseDate__c = Date.newInstance(2021, 01, 01)
            , Type__c = '계획'
            , ManpowerMM__c = 12
            , ExId__c = pm01.Id + String.valueOf(2021) + String.valueOf(1) + '계획' + 'Non-Billable'
            , Billing__c = 'Non-Billable'
            , IsAvailable__c = true
        );
        insert pmm02;
        /*pmm03 = new PMS_PjtManpowerMonth__c(
            PjtManpower__c = pm01.Id
            , Project__c = pjt.Id
            , BaseDate__c = Date.newInstance(2021, 01, 01)
            , Type__c = '계획'
            , ManpowerMM__c = 12
            , ExId__c = pm01.Id + String.valueOf(2021) + String.valueOf(1) + '계획' + 'Billable'
            , Billing__c = 'Billable'
            , IsAvailable__c = true
        );
        insert pmm03;*/

        pmm04 = new PMS_PjtManpowerMonth__c(
            PjtManpower__c = pm01.Id
            , Project__c = pjt.Id
            , BaseDate__c = Date.newInstance(2021, 01, 01)
            , Type__c = '실적'
            , ManpowerMM__c = 12
            , ExId__c = pm01.Id + String.valueOf(2021) + String.valueOf(1) + '실적' + 'Billable'
            , Billing__c = 'Billable'
            , IsAvailable__c = true
        );
        insert pmm04;
        pmm05 = new PMS_PjtManpowerMonth__c(
            PjtManpower__c = pm01.Id
            , Project__c = pjt.Id
            , BaseDate__c = Date.newInstance(2021, 01, 01)
            , Type__c = '실적'
            , ManpowerMM__c = 12
            , ExId__c = pm01.Id + String.valueOf(2021) + String.valueOf(1) + '실적' + 'Non-Billable'
            , Billing__c = 'Non-Billable'
            , IsAvailable__c = true
        );
        insert pmm05;
        /*pmm06 = new PMS_PjtManpowerMonth__c(
            PjtManpower__c = pm01.Id
            , Project__c = pjt.Id
            , BaseDate__c = Date.newInstance(2021, 01, 01)
            , Type__c = '실적'
            , ManpowerMM__c = 12
            , ExId__c = pm01.Id + String.valueOf(2021) + String.valueOf(1) + '실적' + 'Non-Billable'
            , Billing__c = 'Non-Billable'
            , IsAvailable__c = true
        );
        insert pmm06;*/

        pmm07 = new PMS_PjtManpowerMonth__c(
            PjtManpower__c = pm02.Id
            , Project__c = pjt.Id
            , BaseDate__c = Date.newInstance(2021, 01, 01)
            , Type__c = '계획'
            , ManpowerMM__c = 12
            , ExId__c = pm02.Id + String.valueOf(2021) + String.valueOf(1) + '계획' + 'Billable'
            , Billing__c = 'Billable'
            , IsAvailable__c = true
        );
        insert pmm07;
        pmm08 = new PMS_PjtManpowerMonth__c(
            PjtManpower__c = pm02.Id
            , Project__c = pjt.Id
            , BaseDate__c = Date.newInstance(2021, 01, 01)
            , Type__c = '계획'
            , ManpowerMM__c = 12
            , ExId__c = pm02.Id + String.valueOf(2021) + String.valueOf(1) + '계획' + 'Non-Billable'
            , Billing__c = 'Non-Billable'
            , IsAvailable__c = true
        );
        insert pmm08;
        /*pmm09 = new PMS_PjtManpowerMonth__c(
            PjtManpower__c = pm02.Id
            , Project__c = pjt.Id
            , BaseDate__c = Date.newInstance(2021, 01, 01)
            , Type__c = '계획'
            , ManpowerMM__c = 12
            , ExId__c = pm02.Id + String.valueOf(2021) + String.valueOf(1) + '계획' + 'Billable'
            , Billing__c = 'Billable'
            , IsAvailable__c = true
        );
        insert pmm09;*/

        pmm10 = new PMS_PjtManpowerMonth__c(
            PjtManpower__c = pm02.Id
            , Project__c = pjt.Id
            , BaseDate__c = Date.newInstance(2021, 01, 01)
            , Type__c = '실적'
            , ManpowerMM__c = 12
            , ExId__c = pm02.Id + String.valueOf(2021) + String.valueOf(1) + '실적' + 'Billable'
            , Billing__c = 'Billable'
            , IsAvailable__c = true
        );
        insert pmm10;
        pmm11 = new PMS_PjtManpowerMonth__c(
            PjtManpower__c = pm02.Id
            , Project__c = pjt.Id
            , BaseDate__c = Date.newInstance(2021, 01, 01)
            , Type__c = '실적'
            , ManpowerMM__c = 12
            , ExId__c = pm02.Id + String.valueOf(2021) + String.valueOf(1) + '실적' + 'Non-Billable'
            , Billing__c = 'Non-Billable'
            , IsAvailable__c = true
        );
        insert pmm11;
        /*pmm12 = new PMS_PjtManpowerMonth__c(
            PjtManpower__c = pm02.Id
            , Project__c = pjt.Id
            , BaseDate__c = Date.newInstance(2021, 01, 01)
            , Type__c = '실적'
            , ManpowerMM__c = 12
            , ExId__c = pm02.Id + String.valueOf(2021) + String.valueOf(1) + '실적' + 'Billable'
            , Billing__c = 'Billable'
            , IsAvailable__c = true
        );
        insert pmm12;*/
    }

    @isTest
    static void myUnitTest01(){
        Test.startTest();
        PMS_MonthlyInputStatusBatch batch = new PMS_MonthlyInputStatusBatch();
        Database.executeBatch(batch, 200);
        
        SchedulableContext sc = null;
        PMS_MonthlyInputStatusBatchScheduler scheduler = new PMS_MonthlyInputStatusBatchScheduler();
        scheduler.execute(sc);
        Test.stopTest();
    }
}