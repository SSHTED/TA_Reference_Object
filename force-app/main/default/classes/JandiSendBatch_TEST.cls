/*
* @Desc : JandiSendBatch_TEST
* @Author : Ha-eun, Lee
* @Date : 2019-09-17
* @Version : 1.0
* 
* @Method :
* 
* 
* @Modified : 
*   ---------------------------------------------
*   NO | Date       | Modifier      | Description 
*   ---------------------------------------------
*   1. | 2019-09-17 | Ha-Eun, Lee   | 최초작성
*/

@isTest
public class JandiSendBatch_TEST {
    
    static JandiQueue__c jq;
    
    static {
        jq = new JandiQueue__c (
        body_Link_Text__c = 'test'
        , body_Link_Url__c = 'test'
        , body_Text__c = 'test'
        , IsSent__c = false);
    }
    
    static testmethod void myUnitTest() {
        Test.startTest();
        
        JandiSendBatch batch = new JandiSendBatch();
        Database.executeBatch(batch , 1);
        
        SchedulableContext sc = null;
        JandiSendScheduler scheduler = new JandiSendScheduler();
        scheduler.execute(sc);
        
        Test.stopTest();
    }

}