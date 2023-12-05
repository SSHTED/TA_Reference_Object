@isTest
private class PMS_PjtBillScheduleTrigger_TEST {
	static PMS_PjtBillSchedule__c pms_pjtbillschedule;
	static TriggerSetting__c ts;
	static PMS_PjtBillSchedule__c pms_bill;
    static Organization__c organization;
    static PMS_Project__c pms_project;
    static PMS_PjtResource__c pms_resource;
    static Employee__c emp;

	static {
		ts = new TriggerSetting__c();
		ts.ALL_ACTIVE__c = true;
		ts.AFTER_DELETE__c = true;
		ts.AFTER_INSERT__c = true;
		ts.AFTER_UNDELETE__c = true;
		ts.AFTER_UPDATE__c = true;
		ts.BEFORE_DELETE__c = true;
		ts.BEFORE_INSERT__c = true;
		ts.BEFORE_UPDATE__c = true;
		ts.SetupOwnerId = System.userInfo.getOrganizationId();
		insert ts;

		/*System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
			pms_pjtbillschedule = new PMS_PjtBillSchedule__c(
                // Name = 'Name'
				Project__c = 
            );
			insert pms_pjtbillschedule;
		}*/

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
            , IsDelay__c = true
            , DelayPeriod__c = 0
            , Times__c = '1'
			, InspectDate__c = date.newInstance(2022, 12, 26)
			, InspectType__c = '매출'
        );
        insert pms_bill;
	}

    static testMethod void myTest1() {
        Test.startTest();

        System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
            // pms_pjtbillschedule.Name = 'Name modified';
        	update pms_bill;
        }

        Test.stopTest();
    }

    static testMethod void myTest2() {
        Test.startTest();

        delete pms_bill;

        Test.stopTest();
    }
}