/**
* Desc : ScheduleNotificationHoliday
*        1. 
*
* @Author : Yong-Jin, Cha
* @Date : 2017. 8. 29.
* @Version : 1.0
* @Modify :
*/
global class ScheduleNotificationHoliday implements Schedulable {
    global void execute(SchedulableContext SC) {
        
        BatchNotificationHoliday batch = new BatchNotificationHoliday();
        batch.query = 'SELECT ActivityDate, Description, OwnerId, Subject, WhatId, Owner.Name, What.Name FROM Event WHERE ActivityDate = today AND Subject = \'On holiday\'';
        Database.executeBatch(batch, 200);
    }
}
/**
	ScheduleNotificationHoliday schClass = new ScheduleNotificationHoliday();
    String schName = '휴가자 이사회 알림 Schedule - every AM 09:00';
	String schTime = '0 0 9 * * ?';
	system.schedule(schName, schTime, schClass);
/**/