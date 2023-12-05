@isTest
public with sharing class HR_OrgMemberUpdateBatch_TEST {
    
    static Organization__c organization;
    static Employee__c employee;

    static {
        organization = new Organization__c (
            Code__c = 'Tset5'
            , DisplayOrder__c = 7
            , IsActive__c = true
            , IsResourceActive__c = true
            , Level__c = '1'
            , Name = 'CS2팀'
            , Note__c = 'Tset2'
            , OwnerId = System.UserInfo.getUserId()
            , WS_ChargerEmail__c = 'Test6@test.com'
            , WS_LeaderEmail__c = 'Test4@test.com'
            , WS_TeamId__c = 'cs2'
            , WS_TeamName__c = 'CS2팀'
            , WS_TeamNums__c = 5
            , WS_TeamParentId__c = '25807'
        );

        insert organization;

        employee = new Employee__c (
            Address__c = 'Tset1'
            , AdmitDate__c = 4
            , AdmitPosition__c = '인턴'
            , Affiliation_company__c = 'DK BMC'
            , Birthday__c = date.today()
            , Description__c = 'Tset7'
            , Email__c = 'yj.cha@dkbmc.com'
            , Emergency__c = '01000000000'
            , Emp_No__c = 'Tset2'
            , Engname__c = 'Tset1'
            , FAX__c = '01000000000'
            , FM__c = '남'
            , HQ__c = '임원실'
            , Leave__c = date.today()
            , LeaveReason__c = 'Tset4'
            , Mail_No__c = 'Tset6'
            , MobilePhone__c = '01000000000'
            , Name = 'Tset2'
            , Office_Phone__c = '01000000000'
            , OrganizationId__c = organization.Id
            , OwnerId = System.UserInfo.getUserId()
            , PersonalEmail__c = 'Test6@test.com'
            , Position__c = '파트장'
            , Position_start__c = date.today()
            , Probation__c = 4
            , ProbationEnd__c = date.today()
            , Rank__c = '인턴'
            , Rank_Start__c = date.today()
            , Re_entering__c = 'Yes'
            , rehabilitation__c = date.today()
            , RejectReason__c = 'Tset4'
            , ResignReason__c = 'Tset1'
            , SFGrade__c = '초급'
            , Start__c = date.today()
            , Team__c = '경영관리팀'
            , TechGrade__c = '초급'
            , Type__c = '신입'
            , WS_ActiveStatus__c = 'WORKING'
            , WS_Email__c = 'yj.cha@dkbmc.com'
            , WS_EventDesc__c = 'Tset6'
            , WS_Name__c = 'Tset2'
            , WS_OnDutyStatus__c = 'BEFORE'
            , WS_Position__c = 'Tset1'
            , WS_TeamId__c = '25807'
        );

        insert employee;
    }

    static testMethod void myUnitTest() {

        Test.startTest();
    
        HR_OrgMemberUpdateBatch batch = new HR_OrgMemberUpdateBatch();
        Database.executeBatch(batch , 200);

        SchedulableContext sc = null;
        HR_OrgMemberUpdateScheduler scheduler = new HR_OrgMemberUpdateScheduler();
        scheduler.execute(sc);
    
        Test.stopTest();
    }
}