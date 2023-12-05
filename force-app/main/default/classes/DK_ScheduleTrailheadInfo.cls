/**
* Desc : Trailhead Info Schedule
*
* @Author : Yong-Jin, Cha
* @Date : 2017. 4. 28.
* @Version : 1.0
*/
global class DK_ScheduleTrailheadInfo implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        List<User> uList = [select Id, Name, Trailhead_Badges__c, Trailhead_Points__c, Trailhead_Ranks__c, Trailhead_Trails__c, Trailhead_Profile__c 
                  from User 
                  where Trailhead_Profile__c != null and IsActive = true order by Name];
        
        for(User u : uList) {
        	DK_BatchTrailheadInfo.updateTrailheadInfo(u.Id);
        }
    }
}

/**
		DK_ScheduleTrailheadInfo sch = new DK_ScheduleTrailheadInfo();
        String sch1 = '0 0 12 * * ?';
        system.schedule('DK_ScheduleTrailheadInfo every day', sch1, sch);
/**/