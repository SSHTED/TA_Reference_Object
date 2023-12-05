/**
* Desc : Notification To JANDI Test
*
* @Author : Yong-Jin, Cha
* @Date : 2017. 3. 15.
* @Version : 1.0
*/
@isTest
public class NotificationToJANDI_Test
{
    static {
        // CollaborationGroup Create
        CollaborationGroup grp = new CollaborationGroup(Name='비공개그룹', CollaborationType ='Private');
        insert grp;
        
        // FeedItemAfterTrigger Test
        FeedItem feed = new FeedItem(Body = 'ddd', Title='ddd', ParentId = grp.Id);
        insert feed;
        
        // FeedCommentAfterTrigger Test
        FeedComment comment = new FeedComment(CommentBody = 'ddd', FeedItemId = feed.Id);
        insert comment;
        
        // EventAfterTrigger Test
        Event e = new Event(Subject = 'test'
                            , OwnerId = System.UserInfo.getUserId()
                            , StartDateTime = DateTime.now()
                            , EndDateTime = DateTime.now().addHours(1)
                            , Description = 'text'
                            , ShowAs = 'Free');
        insert e;
        
        e.Subject = 'test2';
        
        update e;
        
        delete e;
        
        // EmployeeExpenseAfterTrigger Test
        Employee_Expense__c expense = new Employee_Expense__c(OwnerId = System.UserInfo.getUserId()
                                                              , ExpenseDesc__C = 'ㄴㄴㄴ'
                                                              , ExpenseDate__C = Date.today()
                                                              , ExpenseAmount__c = 10000
                                                              , ExpenseNumberPeople__c = 1
                                                              , ExpenseType__C = '기타'
                                                             );
        
        insert expense;
        
        expense.IsDeadline__c = true;
        
        update expense;
        
        update expense;
        
        delete expense;
        
        Employee_Expense__c expense2 = new Employee_Expense__c(OwnerId = System.UserInfo.getUserId()
                                                              , ExpenseDesc__C = 'ㄴㄴㄴ'
                                                              , ExpenseDate__C = Date.today()
                                                              , ExpenseAmount__c = 30000
                                                              , ExpenseNumberPeople__c = 1
                                                              , ExpenseType__C = '기타'
                                                             );
        
        insert expense2;
        
        Employee_Expense__c expense3 = new Employee_Expense__c(OwnerId = System.UserInfo.getUserId()
                                                              , ExpenseDesc__C = 'ㄴㄴㄴ'
                                                              , ExpenseDate__C = Date.today()
                                                              , ExpenseAmount__c = 50000
                                                              , ExpenseNumberPeople__c = 1
                                                              , ExpenseType__C = '기타'
                                                             );
        
        insert expense3;
        
        Employee_Expense__c expense4 = new Employee_Expense__c(OwnerId = System.UserInfo.getUserId()
                                                              , ExpenseDesc__C = 'ㄴㄴㄴ'
                                                              , ExpenseDate__C = Date.today()
                                                              , ExpenseAmount__c = 100000
                                                              , ExpenseNumberPeople__c = 1
                                                              , ExpenseType__C = '기타'
                                                             );
        
        insert expense4;
        
        Employee_Expense__c expense5 = new Employee_Expense__c(OwnerId = System.UserInfo.getUserId()
                                                              , ExpenseDesc__C = 'ㄴㄴㄴ'
                                                              , ExpenseDate__C = Date.today()
                                                              , ExpenseAmount__c = 200000
                                                              , ExpenseNumberPeople__c = 1
                                                              , ExpenseType__C = '기타'
                                                             );
        
        insert expense5;
        
        DK_Notice__c notice = new DK_Notice__c(OwnerId = System.UserInfo.getUserId()
                                               , Name = '공지사항 제목'
                                               , Category__c = '교육'
                                               , Contents__c = '공지사항 내용'
                                               );
        insert notice;
        
    }
    
    static testMethod void NotificationToJANDI_Test()
    {
        String connectColor = '#fcfcfc';
        String body = 'test';
        String title = 'test';
        String description = 'text';
        String imageUrl = 'http://test.com';
        String target = 'Chatter';

        NotificationToJANDI.setValue(connectColor, body, title, description, imageUrl);

        Http h = NotificationToJANDI.buildHttp();

        HttpRequest req = NotificationToJANDI.buildWebServiceRequest(target);
        
        target = 'Event';
        req = NotificationToJANDI.buildWebServiceRequest(target);
        
        target = 'Expense';
        req = NotificationToJANDI.buildWebServiceRequest(target);

        HttpResponse res = new HttpResponse();//NotificationToJANDI.invokeWebService(h, req);

        NotificationToJANDI.handleWebServiceResponse(res);
        
        NotificationToJANDI.send(connectColor, body, title, description,'', 'Council');
        
        NotificationToJANDI.send_batch(connectColor, body, title, description,'', 'Council');
    }
}