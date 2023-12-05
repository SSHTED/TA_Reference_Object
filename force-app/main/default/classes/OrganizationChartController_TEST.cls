@isTest
public class OrganizationChartController_TEST {

    static Organization__c organization;

    static {
        organization = new Organization__c (
            Code__c = 'Tset9'
            , DisplayOrder__c = 8
            , IsActive__c = true
            , Level__c = '1'
            , Name = 'Tset4'
            , Note__c = 'Tset3'
        );
    
        insert organization;
    }
    static testMethod void myUnitTest() {

        Test.startTest();
    
        OrganizationChartController.getInit();
    
        Test.stopTest();
    }
}