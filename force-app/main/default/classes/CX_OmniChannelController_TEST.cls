@isTest
private class CX_OmniChannelController_TEST {

    static Organization__c organization1;
    static Organization__c organization2;
    static Employee__c employee;
    static Customer_Org__c customer_org;
    static PMS_Project__c pms_project;
    static Support_Manager__c support_manager;

    static {

        organization1 = new Organization__c (
            Code__c = 'Tset2'
            , DisplayOrder__c = 2
            , IsActive__c = true
            , IsResourceActive__c = true
            , Level__c = '2'
            , Name = 'CX본부'
            , Note__c = 'Tset5'
            , OwnerId = System.UserInfo.getUserId()
            , WS_ChargerEmail__c = 'Test8@test.com'
            , WS_LeaderEmail__c = 'Test5@test.com'
            , WS_TeamId__c = 'Tset6'
            , WS_TeamName__c = 'Tset2'
            , WS_TeamNums__c = 4
            , WS_TeamParentId__c = 'Tset4'
        );

        insert organization1;

        organization2 = new Organization__c (
            Code__c = 'TA팀'
            , DisplayOrder__c = 2
            , IsActive__c = true
            , IsResourceActive__c = true
            , Level__c = '4'
            , Name = 'TA팀'
            , Note__c = 'Tset5'
            , OwnerId = System.UserInfo.getUserId()
            , ParentOrgId__c = organization1.Id
            , WS_ChargerEmail__c = 'Test8@test.com'
            , WS_LeaderEmail__c = 'Test5@test.com'
            , WS_TeamId__c = 'Tset6ert'
            , WS_TeamName__c = 'Tset2'
            , WS_TeamNums__c = 3
            , WS_TeamParentId__c = 'Tset4'
        );

        insert organization2;

        employee = new Employee__c (
            Address__c = 'Tset4'
            , AdmitDate__c = 2
            , AdmitPosition__c = '인턴'
            , Affiliation_company__c = 'DK BMC'
            , Birthday__c = date.today()
            , CXGrade__c = '상'
            , Description__c = 'Tset4'
            , Email__c = 'Test7@test.com'
            , Emergency__c = '01000000000'
            , Emp_No__c = 'Tset1'
            , End__c = date.today()
            , Engname__c = 'Tset5'
            , FAX__c = '01000000000'
            , FM__c = '남'
            , HQ__c = '임원실'
            , Leave__c = date.today()
            , LeaveReason__c = 'Tset3'
            , Mail_No__c = 'Tset1'
            , MobilePhone__c = '01000000000'
            , Name = 'Tset6'
            , Office_Phone__c = '01000000000'
            , OrganizationId__c = organization2.Id
            , OwnerId = System.UserInfo.getUserId()
            , PersonalEmail__c = 'Test8@test.com'
            , Position__c = '파트장'
            , Position_start__c = date.today()
            , Probation__c = 2
            , ProbationEnd__c = date.today()
            , Rank__c = '인턴'
            , Rank_Start__c = date.today()
            , Re_entering__c = 'Yes'
            , rehabilitation__c = date.today()
            , RejectReason__c = 'Tset4'
            , ResignReason__c = 'Tset2'
            , SFGrade__c = '초급'
            , Start__c = date.today()
            , Team__c = '경영관리팀'
            , TechGrade__c = '초급'
            , Type__c = '신입'
            , User__c = System.UserInfo.getUserId()
            , Work_Time__c = '08:00 ~ 17:00'
            , WS_ActiveStatus__c = 'WORKING'
            , WS_Email__c = 'Tset10'
            , WS_EventDesc__c = 'Tset9'
            , WS_Name__c = 'Tset8'
            , WS_OnDutyStatus__c = 'BEFORE'
            , WS_Position__c = 'Tset8'
            , WS_TeamId__c = 'Tset4'
        );

        insert employee;
        
        customer_org = new Customer_Org__c (
            Name = '고객오그'
            , IsActive__c = true
            , IsSandbox__c = true
            , IsShared__c = true
            , OwnerId = System.UserInfo.getUserId()
        );

        insert customer_org;

        pms_project = new PMS_Project__c (
            ActualCostPercentage100Check__c = true
            , ActualCostPercentageCheck__c = true
            , IsOnTime__c = true
            , OwnerId = System.UserInfo.getUserId()
            , PMS_ProjectCompleteCheck__c = true
            , Customer_Org__c = customer_org.Id
            , ProjectType__c = 'SM'
            , Status__c = 'Active'
        );

        insert pms_project;

        support_manager = new Support_Manager__c (
            Actual_MM__c = 5
            , Actual_Work_MM__c = 8
            , AssignedDate__c = date.today()
            , Calculated_MD__c = 7
            , Channel__c = 'Customer Org'
            , Close_Date__c = date.today()
            , CompletionDate__c = date.today()
            , Customer__c = 'Tset10'
            , Customer_Category__c = 'Tset4'
            , Customer_Org__c = customer_org.Id
            //, Detail_State__c = '요건분석'
            , Difficulty__c = '최하'
            , Email_Reply__c = 'Tset1'
            , Emergency__c = '하'
            , Estimated_duration__c = 10
            , Expected_MM__c = 3
            , Ext_SR_Key__c = 'Tset10'
            , Flag__c = true
            , ImplementType__c = 'Configuration'
            , Importance__c = '낮음'
            , Leader_Actual_Work_MD__c = 6
            , Name = 'Tset1'
            , OperationLeader__c = System.UserInfo.getUserId()
            , OwnerId = System.UserInfo.getUserId()
            , Priority__c = '낮음'
            , Processing_Content__c = 'Tset9'
            , Production_Apply__c = true
            , Production_Apply_Date__c = date.today()
            , ProjectStatusCheck__c = true
            , QA_Check__c = true
            , Record_Id__c = 'Tset9'
            , Related_Sources__c = 'Tset1'
            , Request_Content__c = 'Tset1'
            , Request_Date__c = datetime.now()
            , Request_Deadline__c = date.today()
            , Request_No__c = 'Tset4'
            , Request_Type__c = '단순문의'
            , Requester__c = 'Tset8'
            , Requester_Email__c = 'Tset3'
            , Requester_Phone__c = '01000000000'
            , Sandbox_Apply__c = true
            , Sandbox_Apply_Date__c = date.today()
            , Start_Date__c = date.today()
            , State__c = '접수'
            , UseMMCount__c = 2
            , PMS_Project__c = pms_project.Id
        );
    
        insert support_manager;
    }

    static testMethod void myUnitTest() {

        String statusVal = '🟢 Available';
    
        Test.startTest();
    
        CX_OmniChannelController.getInit();
        CX_OmniChannelController.getEmployeeInfo();
        CX_OmniChannelController.getTasks();
        CX_OmniChannelController.saveProcessableStatus(statusVal);
    
        Test.stopTest();
    }
}