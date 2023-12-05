@IsTest(SeeAllData=true)
public class FeedItemAfterTrigger_Test {

    static FeedItem feed;
    static List<User> user1;
   	static Profile pf; 
    static CollaborationGroup cGroup;
    static {
   
        user1 = [select Id, Name, UserRoleId,ManagerId  from User limit 3];
        
        feed = new FeedItem(Type ='TextPost',
                           Body='test',
                           Title='test',
                           Status='Published',
                           Revision=1,
                           ParentId=user1[0].Id 
                           );
        
        cGroup = new CollaborationGroup(
        	Name='TA1',
            CollaborationType = 'Private',
            CanHaveGuests = false,
            IsArchived = false,
            IsAutoArchiveDisabled = true
    );
        
        insert cGroup;
		
    }
    
    static testMethod void mymethod(){
		Test.startTest();
		insert feed;        
        Test.stopTest();
    }
}