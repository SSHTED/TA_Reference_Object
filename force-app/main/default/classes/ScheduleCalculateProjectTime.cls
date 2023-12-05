/**
* Desc : ScheduleCalculateProjectTime
*        1. 
*
* @Author : JOOHA MOON
* @Date : 2020. 02. 14.
* @Version : 1.0
* @Modify :
*/
global class ScheduleCalculateProjectTime implements Schedulable {
    global void execute(SchedulableContext SC) {
        BatchCalculateProjectTime batch = new BatchCalculateProjectTime();
        Database.executeBatch(batch, 200);
    }
}