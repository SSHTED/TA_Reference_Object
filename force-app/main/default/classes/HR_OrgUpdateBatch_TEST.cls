@isTest
public with sharing class HR_OrgUpdateBatch_TEST {

    static Organization__c organization;

    static {
        organization = new Organization__c (
            Code__c = '1팀'
            , DisplayOrder__c = 2
            , IsActive__c = true
            , IsResourceActive__c = true
            , Level__c = '2'
            , Name = '1팀'
            , Note__c = 'Tset5'
            , OwnerId = System.UserInfo.getUserId()
            , WS_ChargerEmail__c = 'Test8@test.com'
            , WS_LeaderEmail__c = 'Test5@test.com'
            , WS_TeamId__c = '27315'
            , WS_TeamName__c = '1팀'
            , WS_TeamNums__c = 4
            , WS_TeamParentId__c = '27299'
        );

        insert organization;
    }

    static testMethod void myUnitTest() {

        Test.startTest();
    
        HR_OrgUpdateBatch batch = new HR_OrgUpdateBatch();
        Database.executeBatch(batch , 200);
    
        Test.stopTest();
    }

    static testMethod void myUnitTest2() {

        Test.startTest();

        SchedulableContext sc = null;
        HR_OrgUpdateScheduler scheduler = new HR_OrgUpdateScheduler();
        scheduler.execute(sc);
    
        Test.stopTest();
    }
}