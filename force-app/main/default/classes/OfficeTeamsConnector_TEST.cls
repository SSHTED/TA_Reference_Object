/*
* @Desc : OfficeTeamsConnector_TEST
* @Author : Ha-eun Lee
* @Date : 2019-11-08
* @Version : 1.0
* 
* @Method :
*  
* 
* @Modified : 
*   ---------------------------------------------
*   NO | Date       | Modifier      | Description 
*   ---------------------------------------------
*   1. | 2019-11-08 | Ha-eun Lee    | 최초작성
*   2. | 2019-11-08 | Yeseul.Jin    | 
*/
@isTest
public class OfficeTeamsConnector_TEST {
    
    
    testMethod static void myTest() {
        
        CollaborationGroup cg = new CollaborationGroup(
            Name = 'My Group',
            CollaborationType = 'Private'
        );
    
        insert cg;
        
        FeedItem f = new FeedItem();
    	f.Body = 'Test Body';
    	f.parentID = cg.Id;
    	insert f;
        
        FeedComment fc = new FeedComment();
        fc.CommentBody = 'Test Comment';
        fc.FeedItemId = f.Id;
        insert fc;        
        
        Test.startTest();
        
        OfficeTeamsConnector.send('Chatter', '#585858', 'Test 작성', f.Body , f.Id);
    	OfficeTeamsConnector.send('Chatter', '#585858', 'Test 작성', fc.CommentBody , fc.Id);
        
        OfficeTeamsConnector.send_batch('Chatter', '#585858', 'Test 작성', f.Body , f.Id);
    	OfficeTeamsConnector.send_batch('Chatter', '#585858', 'Test 작성', fc.CommentBody , fc.Id);
        
        OfficeTeamsConnector.saveOfficeTeamsQueue('Chatter', '#ffffff', 'title', 'text', cg.Id);
        
        Test.stopTest();
    }
}