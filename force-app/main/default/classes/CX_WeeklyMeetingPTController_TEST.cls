@isTest
public class CX_WeeklyMeetingPTController_TEST {

    static CX_WeeklyMeeting__c cx_weeklymeeting;

    static {
        cx_weeklymeeting = new CX_WeeklyMeeting__c (
            CS_Team__c = 'CS1'
            , LastWeekWork__c = 'Tset4'
            , MeetingDate__c = date.today()
            , Name = 'Tset5'
            , Opportunities_Requests__c = 'Tset9'
            , Risk_Issue__c = 'Tset10'
            , ThisWeekWorkPlan__c = 'Tset8'
        );

        insert cx_weeklymeeting;
    }

    static testMethod void myUnitTest() {

        Test.startTest();
    
        CX_WeeklyMeetingPTController con = new CX_WeeklyMeetingPTController();
        CX_WeeklyMeetingPTController.getList();
    
        Test.stopTest();
    }
}