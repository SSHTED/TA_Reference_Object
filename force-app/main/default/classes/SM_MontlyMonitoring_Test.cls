@isTest
public class SM_MontlyMonitoring_Test {
    static SM_MontlyMonitoring__c sm_montlymonitoring;
    static Customer_Org__c customer_org;
    
    @testSetup 
    static void setupTestData(){
        
        customer_org = new Customer_Org__c (
            OwnerId = System.UserInfo.getUserId(),
            name = 'test1'
        );
        insert customer_org;
        
        sm_montlymonitoring = new SM_MontlyMonitoring__c (
            Apex_Class_Characters__c = 'Tset2'
            , API_LIMIT__c = 'Tset8'
            , Customer_Org__c = customer_org.Id
            , Comment__c = 'Tset3'
            , Domain_Certificate__c = 'Tset1'
            , File_Download_Archive__c = 'Tset6'
            , Individual_Org_backups__c = 'Tset1'
            , Last_login_date__c = 'Tset1'
            , License__c = 'Tset5'
            , Month__c = '01'
            , Monthly_batch_schedule__c = 'Tset2'
            , Object_Count__c = 'Tset4'
            , OwnerId = System.UserInfo.getUserId()
            , Storage__c = 'Tset2'
            , Title__c = 'Tset8'
            , Trust_reflection_list__c = 'Tset2'
        );
        
        insert sm_montlymonitoring;
        
        
    }
    
    @isTest 
    static void testGetInit() {
        Test.startTest();
        Map<String, Object> result = SetupSearchController.getInit();
        Test.stopTest();
    }

}