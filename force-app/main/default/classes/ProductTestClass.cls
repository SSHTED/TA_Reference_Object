@isTest
public class ProductTestClass {
    public static Price_Book_Entry__c a;
    static Product__c p, p2, p3;
    static Price_Book_Test__c b;
    static list<OpportunityProduct__c> oplist;
    static list<Product__c> plist;
    static set<Id> prdid;
    //select Price_Book_Test__r.id,id,Price_Book_Test__r.Name,UnitPrice__c,UseStandardPrice__c,IsActive__c,Price_Book_Test__r.IsStandard__c 
    //                 from Price_Book_Entry__c where  Product__r.id =: entryList
    static {
        b = new Price_Book_Test__c(Name='test Pricebook',IsStandard__c=false);
        insert b;
        p = new Product__c(depth_one__c='Salesforce License', Name='force.com UE Unlimted Application');
        insert p;
		//REQUIRED_FIELD_MISSING, Required fields are missing:
        // [UnitPrice__c, Price_Book_Test__c]: [UnitPrice__c, Price_Book_Test__c]
        a = new Price_Book_Entry__c(Product__c=p.Id,UnitPrice__c=100,Price_Book_Test__c=b.id);
        system.debug('a : '+ a);
        insert a;
	        
    }
    @isTest static void fetchProductTest(){
        
        Test.startTest();
        
        ProAddProductController.fetchProduct(p.Id);
        ProAddProductController.optionSel(p.Id);
        ProAddProductController.getpriceBookName(p.Id);
        ProAddProductController.deleteCustomBKEntry(a);
        
        Test.stopTest();
        
    }
}