/**
* Desc : BatchNotificationHoliday, ScheduleNotificationHoliday Test
*
* @Author : Yong-Jin, Cha
* @Date : 2017. 8. 29.
* @Version : 1.0
*/
@isTest
public class BatchNotificationHoliday_Test {
    
    static {
        // EventAfterTrigger Test
        Event e = new Event(Subject = 'On holiday'
                            , OwnerId = System.UserInfo.getUserId()
                            , StartDateTime = DateTime.now()
                            , EndDateTime = DateTime.now().addHours(1)
                            , Description = 'text'
                            , ShowAs = 'Free');
        insert e;
    }
	static testMethod void NotificationToJANDI_Test()
    {
        // Batch Test Code
   		BatchNotificationHoliday batch = new BatchNotificationHoliday();
        batch.query = 'SELECT ActivityDate, Description, OwnerId, Subject, WhatId, Owner.Name, What.Name FROM Event WHERE ActivityDate = today AND Subject = \'On holiday\'';
        Database.executeBatch(batch, 200);
        
        // Schedule Test Code
        ScheduleNotificationHoliday schClass = new ScheduleNotificationHoliday();
        String schName = '휴가자 이사회 알림 Schedule - every AM 09:00';
        String schTime = '0 0 9 * * ?';
        system.schedule(schName, schTime, schClass);
    }
}