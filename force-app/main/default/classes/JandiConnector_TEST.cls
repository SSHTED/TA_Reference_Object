/**
* Desc : JandiConnector_TEST
*
* @Method : 
*		- testMethod myUnitTest()
* 
* @Author : Yong-Jin, Cha
* @Date : 2019-08-11
* @Version : 1.0
* @Modified : 
*  ---------------------------------------------
*  NO | Date       | Modifier      | Description
*  ---------------------------------------------
*  1. | 2019-08-11 | Yong-Jin, Cha | 최초작성
*/
@isTest
public class JandiConnector_TEST {

    static {
        
    }
    
    static testMethod void myUnitTest() {

        String webhookName = 'test';
        String connectColor = '';
        String body_Link_Url = '';
        String body_Link_Text = '';
        String body_Text = '';
        String title = '';
        String description = '';
        String imageUrl = '';
        
        List<JandiConnector.ConnectInfoWarp> connectInfoList = new List<JandiConnector.ConnectInfoWarp>{new JandiConnector.ConnectInfoWarp(title, description, imageUrl)};

    	JandiConnector.ConnectInfoWarp connectInfo = new JandiConnector.ConnectInfoWarp(title, description, imageUrl);
    
        Test.startTest();
        
        JandiConnector.sendByTrigger(webhookName, connectColor, body_Link_Url, body_Link_Text, body_Text, title, description, imageUrl);
        JandiConnector.sendByBatch(webhookName, connectColor, body_Link_Url, body_Link_Text, body_Text, title, description, imageUrl);
        JandiConnector.sendByBatch(webhookName, connectColor, body_Link_Url, body_Link_Text, body_Text, connectInfoList);
        JandiConnector.sendByBatch (webhookName, connectColor, body_Link_Url, body_Link_Text, body_Text, connectInfo);
    	JandiConnector.saveJandiQueue(webhookName, connectColor, body_Link_Url, body_Link_Text, body_Text, title, description, imageUrl);
        
        Test.stopTest();
    }
}