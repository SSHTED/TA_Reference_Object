@isTest
public with sharing class MassDeleteExtension_TEST {

	static testMethod void testDeleteRecords() {

        List<HR_PMS_ORG_Resource__c> objs = new List<HR_PMS_ORG_Resource__c>();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(objs);
        MassDeleteExtension extension = new MassDeleteExtension(sc);

        System.assertNotEquals(null, extension.deleteRecords());
        System.assertNotEquals(null, extension.deleteAllRecords());
    }

    static testMethod void testSelectedSize() {
        List<HR_PMS_ORG_Resource__c> objs = new List<HR_PMS_ORG_Resource__c>();
        objs.add(new HR_PMS_ORG_Resource__c(Name='1'));

        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(objs);
        sc.setSelected(objs);
        MassDeleteExtension extension = new MassDeleteExtension(sc);
		extension.getMyAllSize();
        //System.assertEquals('1', extension.getMyAllSize());
    }
}