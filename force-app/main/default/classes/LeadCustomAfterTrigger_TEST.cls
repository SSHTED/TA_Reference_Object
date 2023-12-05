/*
* @Desc : LeadCustomAfterTrigger_TEST
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
public class LeadCustomAfterTrigger_TEST {
    
    testMethod static void myTest() {
        
        Test.startTest(); 
        lead_custom__c lc = new lead_custom__c(Name='Test');
        insert lc;
        Test.stopTest();
    }
    
}