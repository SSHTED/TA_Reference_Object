/*
* @Desc : SupportManagerQueuesTrigger_TEST
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
public class SupportManagerQueuesTrigger_TEST {
    
    static Account acc;
    static Customer_Org__c org;
    
    static {
        acc = new Account(
            Name = 'Test');
        
        insert acc;
        
        org = new Customer_Org__c(
            Org_Id__c = '1234567'
            , Customer__c = acc.Id
        	, Team__c = 'CS1');
        
        insert org;
    }    
    
    testMethod static void myTest() {
        Test.startTest();

        
        Support_Assign_Rule__c sar = new Support_Assign_Rule__c(
            Customer_Org__c = org.Id
            , Person_In_Charge__c = System.UserInfo.getUserId()
            , domain__c = 'test.com'
            , IsActive__c = true);
        
        insert sar;
        
        Support_Manager_Queues__c smq = new Support_Manager_Queues__c(
            Name='문의'
            , Request_Type__c = '단순문의'
            , Request_Content__c = '내용'
            , Requester__c = System.UserInfo.getUserId()
            , Requester_Email__c = 'test@test.com'
            , Customer_Org__c = org.Id
            , Channel__c = 'Site');
        insert smq;
        
        Test.stopTest();
    }
    
    
    testMethod static void myTest2() {
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
        
        Test.stopTest();
    }
    
}