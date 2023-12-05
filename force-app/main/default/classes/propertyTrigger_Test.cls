/**
 * @description       : 
 * @author            : hojoon.park@dkbmc.com
 * @group             : 
 * @last modified on  : 06-21-2022
 * @last modified by  : hojoon.park@dkbmc.com
**/
@isTest
public class propertyTrigger_Test {
    static Id HARDWAREID = [SELECT Id FROM RecordType WHERE SobjectType = 'property__c' AND Name = '하드웨어' LIMIT 1].Id;
    static Id SOFTWAREID = [SELECT Id FROM RecordType WHERE SobjectType = 'property__c' AND Name = '소프트웨어' LIMIT 1].Id;
    static List<Schema.PicklistEntry> pdt1PickListVal = property__c.ProductType__c.getDescribe().getPicklistValues(); 
    static List<Schema.PicklistEntry> pdt2PickListVal = property__c.ProductType_2nd__c.getDescribe().getPicklistValues();
	static List<Schema.PicklistEntry> typePickListVal = property__c.largeType__c.getDescribe().getPicklistValues(); 

	@TestSetup
    static void makeData(){
        
        TriggerSetting__c ts = new TriggerSetting__c();
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
        
        Employee__c emp = new Employee__c(
        	Start__c = Date.today().addDays(-10)
            , Name = '나능야 퉁퉁이'
            , Emp_No__c = 'test_001100'
            , Rank__c = Employee__c.Rank__c.getDescribe().getPicklistValues()[0].getValue()
        );
        insert emp;
        
        property__c prop1 = new property__c(
            RecordTypeId = HARDWAREID
        	, ProductType__c = pdt1PickListVal[0].getValue()
            , ProductType_2nd__c = pdt2PickListVal[13].getValue()
            , largeType__c = typePickListVal[0].getValue()
            , ReceivingDate__c = Date.newInstance(2022, 6, 1)
            , RealEmp__c = emp.Id
        );
        insert prop1;
                
        property__c prop2 = new property__c(
            RecordTypeId = HARDWAREID
        	, ProductType__c = pdt1PickListVal[0].getValue()
            , ProductType_2nd__c = pdt2PickListVal[13].getValue()
            , largeType__c = typePickListVal[0].getValue()
            , ReceivingDate__c = Date.newInstance(2022, 6, 1)
            , RealEmp__c = emp.Id
        );
        insert prop2;
                
        property__c prop3 = new property__c(
            RecordTypeId = HARDWAREID
        	, ProductType__c = pdt1PickListVal[0].getValue()
            , ProductType_2nd__c = pdt2PickListVal[13].getValue()
            , largeType__c = typePickListVal[0].getValue()
            , ReceivingDate__c = Date.newInstance(2022, 6, 3)
            , RealEmp__c = emp.Id
        );
        insert prop3;
                
        property__c prop4 = new property__c(
            RecordTypeId = HARDWAREID
        	, ProductType__c = pdt1PickListVal[0].getValue()
            , ProductType_2nd__c = pdt2PickListVal[13].getValue()
            , largeType__c = typePickListVal[0].getValue()
            , ReceivingDate__c = Date.newInstance(2022, 1, 1)
            , RealEmp__c = emp.Id
        );
        insert prop4;
        
        property__c prop5 = new property__c(
            RecordTypeId = SOFTWAREID
        	, ProductType__c = pdt1PickListVal[5].getValue()
            , ProductType_2nd__c = pdt2PickListVal[6].getValue()
            , largeType__c = typePickListVal[1].getValue()
            , ReceivingDate__c = Date.newInstance(2022, 4, 1)
            , RealEmp__c = emp.Id
        );
        insert prop5;
        
        List<property__c> checkList = [SELECT Id, Name, ProductType__c, ProductType_2nd__c, OrderBy__c FROM property__c];
        System.debug('checkList ::: ' + checkList);
    }
    
    @isTest
    public static void propInsertTest(){
        System.debug('TEST ____ INSERT START !!@@');
        List<Employee__c> empList = [SELECT Id FROM Employee__c LIMIT 1];
        Test.startTest();
        
        property__c prop = new property__c(
            RecordTypeId = HARDWAREID
        	, ProductType__c = pdt1PickListVal[0].getValue()
            , ProductType_2nd__c = pdt2PickListVal[13].getValue()
            , largeType__c = typePickListVal[0].getValue()
            , ReceivingDate__c = Date.newInstance(2022, 6, 1)
            , RealEmp__c = empList[0].Id
        );
        insert prop;
        
        Test.stopTest();
        property__c afProp = [SELECT Id, OrderBy__c FROM property__c WHERE Id =:prop.Id];
        System.debug('afProp :: ' + afProp);
        System.assertEquals('04', afProp.OrderBy__c);
        
    }
    
    @isTest
    public static void propUpdateTest(){
        System.debug('TEST ____ UPDATE START !!@@');
        List<property__c> propList = [SELECT Id, ReceivingDate__c, ProductType__c, ProductType_2nd__c, OrderBy__c FROM property__c WHERE YearMonthF__c = '2206' LIMIT 100];
        
        Test.startTest();
        
        property__c testProp = new property__c();
        for(property__c p : propList){
            if(testProp.Id == null){
                p.RecordTypeId = HARDWAREID;
            	p.ProductType__c = pdt1PickListVal[3].getValue();
                p.ProductType_2nd__c = pdt2PickListVal[16].getValue();
                p.ReceivingDate__c = Date.newInstance(2022, 1, 31);
                testProp = p;
            } else {
                p.RecordTypeId = SOFTWAREID;
        		p.ProductType__c = pdt1PickListVal[5].getValue();
            	p.ProductType_2nd__c = pdt2PickListVal[6].getValue();
            	p.largeType__c = typePickListVal[1].getValue();
            	p.ReceivingDate__c = Date.newInstance(2022, 4, 11);
                
            }
        }
        
        update propList;
        
        Test.stopTest();
		// Expected: <a href="/a0mp0000007SdxSAAS" target="_self">NK-220101</a>, 
		// Actual: <a href="/a0mp0000007SdxS" target="_self">NK-220101</a>
		
        property__c afProp = [SELECT Id, Name, OrderBy__c FROM property__c WHERE Id =:testProp.Id];
        System.debug('afProp :: ' + afProp);
        //String convertId = String.valueOf(afProp.Id).substring(0, 15);
        System.assertEquals(testProp.ProductType_2nd__c + '-220101', afProp.Name);
        
        List<property__c> checkList = [SELECT Id, Name, ReceivingDate__c, ProductType__c, ProductType_2nd__c, OrderBy__c FROM property__c];
        System.debug('checkList :: ' + checkList);
    }
    
}