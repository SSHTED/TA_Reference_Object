@isTest
private class SystemAdminDashboardController_TEST {

    static testMethod void myUnitTest() {

        String targetId = '';
		String featureType = 'SFContentUser';
        
        Test.startTest();
    
    	SystemAdminDashboardController.getData();
        SystemAdminDashboardController.getUserListByUserLicenseId(targetId);
		SystemAdminDashboardController.getUserListByPermissionSetLicenseId(targetId);
		SystemAdminDashboardController.getUserListByActiveFeatureLicenseId(featureType);
    
        Test.stopTest();
    }
        
}