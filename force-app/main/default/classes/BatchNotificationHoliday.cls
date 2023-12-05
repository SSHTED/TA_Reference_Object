/**
* Desc : BatchNotificationHoliday
*        1. 오늘, 내일 휴가자 이사회에 알림
*
* @Author : Yong-Jin, Cha
* @Date : 2017. 8. 29.
* @Version : 1.0
* @Modify :
*/
global class BatchNotificationHoliday implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts
{
	global String query {set;get;}
    
    global database.querylocator start(Database.BatchableContext BC){
		system.debug('# Start Batch Process');
        
        system.debug('# query : ' + query);
                
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        system.debug('# Execute Batch Process');
        
        String target = 'Council';	// 이사회
        String bodys = '';
        
        for(Object o : scope) {
            Event e = (Event) o;
            bodys += '**이름 :** ' + e.Owner.Name + '\n';
            bodys += '**관련항목 :** ' + e.What.Name + '\n';
            bodys += '**비고 :** ' + e.Description + '\n\n';
        }
        
        try {
            if(System.Label.JANDI_COUNCIL_TRIGGER_USE == 'Y') {
                if(!Test.isRunningTest()) {
                    /*
                    NotificationToJANDI.send_batch('#b64b32'
                                             , '[금일 **('+System.today().format()+')** 휴가자 목록입니다.]('+System.Label.JANDI_INSTANCE_URL+'/00U/c?cType=2)'
                                             , 'On holiday', bodys, '', target);
					*/
                    // 2019.11.18 Office Teams로 알람 이관
                    OfficeTeamsConnector.send_batch(target, '#b64b32', '금일 ('+System.today().format()+') 휴가자 목록입니다.', bodys, '00U/c?cType=2');
                }
            }
        } catch (Exception ex) {
            System.debug('# Exception # ' + ex);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        system.debug('# Finish Batch Process');
    }
}