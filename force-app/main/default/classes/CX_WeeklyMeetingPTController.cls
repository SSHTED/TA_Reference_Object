global without sharing class CX_WeeklyMeetingPTController {

    global String thisWeekOfMonth { get; set; }

	global CX_WeeklyMeetingPTController() {
        //2023년 5월 2주차
        Datetime n = System.now().addDays(-7);
		thisWeekOfMonth = n.format('YYYY') + '년 ' + n.format('M') + '월 ' + n.format('W') + '주차';
	}

    @RemoteAction
    global static List<CX_WeeklyMeeting__c> getList() 
    {        
        return [
            select
            	Id
            	, Name
            	, CS_Team__c
                , LastWeekWork__c
                , MeetingDate__c
                , Opportunities_Requests__c
                , Risk_Issue__c
                , ThisWeekWorkPlan__c
            from
                CX_WeeklyMeeting__c
            where
                MeetingDate__c = THIS_WEEK
            order by
                MeetingDate__c, CS_Team__c
       	];
    }
}