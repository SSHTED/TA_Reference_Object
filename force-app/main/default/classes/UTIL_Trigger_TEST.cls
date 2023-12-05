/**
* @Class : UTIL_Trigger_TEST
*
* @Method : 
*   - myTest1()
*   - myTest2()
* 
* @Author : Yong-jin, Cha
* @Date : 2022-03-06
* @Version : 1.0
* @Modified : 
*  ---------------------------------------------
*  NO | Date       | Modifier      | Description
*  ---------------------------------------------
*  1. | 2022-03-06 | Yong-jin, Cha | 최초작성
*/
@isTest
private class UTIL_Trigger_TEST {

    static TriggerSetting__c ts;
    
    static testMethod void myTest1() {
        Test.startTest();
        
        UTIL_Trigger.getActiveSetting('AccountTrigger');

        Test.stopTest();
    }
    
    static testMethod void myTest2() {
        Test.startTest();
        
        ts = new TriggerSetting__c();
        ts.ALL_ACTIVE__c = true;
        ts.AFTER_DELETE__c = true;
        ts.AFTER_INSERT__c = true;
        ts.AFTER_UNDELETE__c = true;
        ts.AFTER_UPDATE__c = true;
        ts.BEFORE_DELETE__c = true;
        ts.BEFORE_INSERT__c = true;
        ts.BEFORE_UPDATE__c = true;
        ts.SetupOwnerId = System.userInfo.getOrganizationId();
        insert ts;
        
        UTIL_Trigger.getActiveSetting('AccountTrigger');       
        UTIL_Trigger.getActiveSetting('AccountTrigger2');

        Test.stopTest();
    }
}