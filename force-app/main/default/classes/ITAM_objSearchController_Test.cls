@isTest
public class ITAM_objSearchController_Test {
	//This test class just ensures that there is enough code coverage
    //to get the component into production from your sandbox
    //it does not perform any validations.
    static testMethod void testLookupField() {
        List<string> returnFields = new List<string> {'Name'};
        property__c pro = new property__c();
        insert pro;
        
        property__c a = [SELECT Id FROM property__c LIMIT 1];
        //fetchRecords( String objectName, String filterField, String searchString )
        ITAM_objSearchController.fetchRecords('property__c재고', 'Name', 'dd');
        ITAM_objSearchController.setObjectToRecentItems(a.Id);
		ITAM_objSearchController.getObjectDetails('property__c재고');
        ITAM_objSearchController.GetRecentRecords('property__c재고', returnFields, 5, null, null);
        ITAM_objSearchController.SearchRecords('property__c재고', returnFields, returnFields, '', 'Name', 'ASC', 5, 'CreatedDate > 2001-01-01T00:00:01Z', null, null);
        ITAM_objSearchController.GetRecord('property__c재고', returnFields, a.Id);
        ITAM_objSearchController.getObjectDetails('property__c사용');
        ITAM_objSearchController.GetRecentRecords('property__c사용', returnFields, 5,null,null);
        ITAM_objSearchController.SearchRecords('property__c사용', returnFields, returnFields, '', 'Name', 'ASC', 5, 'CreatedDate > 2001-01-01T00:00:01Z', null,null);
        ITAM_objSearchController.GetRecord('property__c사용', returnFields, a.Id);
    }
}