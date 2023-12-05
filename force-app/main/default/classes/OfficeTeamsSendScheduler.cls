/*
* @Desc : OfficeTeamsSendScheduler
* @Author : Yeseul.Jin
* @Date : 2019-11-07
* @Version : 1.0
* 
* @Method :
*  
* 
* @Modified : 
* 	---------------------------------------------
* 	NO | Date       | Modifier      | Description 
* 	---------------------------------------------
* 	1. | 2019-11-07 | Yeseul.Jin    | 최초작성
*/ 
global class OfficeTeamsSendScheduler implements Schedulable {
    global void execute(SchedulableContext SC){        
        OfficeTeamsSendBatch batch = new OfficeTeamsSendBatch();
		database.executeBatch(batch, 1);
    }
}