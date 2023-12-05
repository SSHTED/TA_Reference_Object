@isTest
private class CX_CustomerOrgAssignController_TEST {

    static Customer_Org__c customer_org;
    static Customer_Org_Assign__c customer_org_assign;

    static {
        customer_org = new Customer_Org__c (
            Country__c = 'Tset3'
            , DefaultLocaleSidKey__c = 'Tset4'
            , Instance_Name__c = 'Tset3'
            , Instance_Url__c = 'Tset1'
            , IsActive__c = true
            , IsSandbox__c = false
            , IsShared__c = false
            , LanguageLocaleKey__c = 'Tset7'
            , Name = 'Tset2'
            , NamespacePrefix__c = 'Tset3'
            , OperationLeaderId__c = System.UserInfo.getUserId()
            , Org_Id__c = 'Tset1'
            , OrganizationType__c = 'Enterprise Edition'
            , OwnerId = System.UserInfo.getUserId()
            , PrimaryContact__c = 'Tset6'
            , SignupCountryIsoCode__c = 'Tset7'
            , Team__c = 'CX1사업부'
            , TimeZoneSidKey__c = 'Tset10'
            , UiSkin__c = 'Tset10'
        );

        insert customer_org;

        customer_org_assign = new Customer_Org_Assign__c (
            CustomerOrgId__c = customer_org.Id
            , Ex_Key__c = customer_org.Id + '_' + System.UserInfo.getUserId()
            , Name = customer_org.Name + '_' + System.UserInfo.getName()
            , OwnerId = System.UserInfo.getUserId()
            , PersonInChargeId__c = System.UserInfo.getUserId()
        );

        insert customer_org_assign;
    }

    static testMethod void myUnitTest() {

        Boolean isAllOption = true;
        String AllOptionLabel = '전체';
        String orderType = 'org';
        String orgId = customer_org.Id;
        String userId = System.UserInfo.getUserId();
        String idArray = '["' + customer_org.Id + '_' + System.UserInfo.getUserId() + '"]';
    
        Test.startTest();
    
        CX_CustomerOrgAssignController.getSearchFilters();
        CX_CustomerOrgAssignController.getCustomerOrgList(isAllOption, AllOptionLabel);
        CX_CustomerOrgAssignController.getUserList(isAllOption, AllOptionLabel);
        CX_CustomerOrgAssignController.getAssignViewList(orderType, orgId, userId);
        CX_CustomerOrgAssignController.getAssignEditList(orgId, userId);
        CX_CustomerOrgAssignController.saveData(orgId, userId, idArray);
    
        Test.stopTest();
    }
}