/*
* @Desc : SupportManagerAfterTrigger_TEST
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
public class SupportManagerAfterTrigger_TEST {
    
    static Account acc;
    static Customer_Org__c org;
    
    static {
        acc = new Account(
            Name = 'Test');
        
        insert acc;
        
        org = new Customer_Org__c(
            Org_Id__c = '1234567'
            , Customer__c = acc.Id );
        
        insert org;
    }    
    
    testMethod static void myTest() {
        Test.startTest();
        
        Support_Manager_Queues__c smq = new Support_Manager_Queues__c(
            Name='문의'
            , Request_Type__c = '단순문의'
            , Request_Content__c = '내용'
            , Requester__c = System.UserInfo.getUserId()
            , Requester_Email__c = 'test@test.com'
            , Customer_Org__c = org.Id
            , Channel__c = 'Site');
        insert smq;
        
        Support_Manager__c sm = new Support_Manager__c(
            Name= smq.Name
            , Request_Type__c = smq.Request_Type__c
            , Request_Content__c = smq.Request_Content__c
            , Requester__c = smq.Requester__c
            , Requester_Email__c = smq.Requester_Email__c
            , Channel__c = smq.Channel__c
            , Support_Manager_Queues__c = smq.Id
            , Customer_Org__c = org.Id
            , State__c = '담당자 할당');
        insert sm;
        
        sm.Processing_Content__c = 'Test';
        sm.State__c = '완료';
        update sm;
        
        Test.stopTest();
    }
    
}