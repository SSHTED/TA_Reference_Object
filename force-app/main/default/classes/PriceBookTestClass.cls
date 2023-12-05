@isTest
public class PriceBookTestClass {
    public static Price_Book_Entry__c a;
    static Product__c p, p2, p3;
    static Price_Book_Test__c b;
    static list<Price_Book_Entry__c> prblist;
    static list<Price_Book_Entry__c> prblist2;
    static list<Product__c> plist;
    static String searchKeyWord = 'test';
    static List<sObject> ExcludeitemsList =new List<Product__c>();
    static  String ObjectName = 'Price_Book_Entry__c';
    static {
        
        b = new Price_Book_Test__c(Name='test Pricebook',IsStandard__c=false);
        insert b;
        
        p = new Product__c(depth_one__c='Salesforce License', Name='force.com UE Unlimted Application');
        insert p;
       // REQUIRED_FIELD_MISSING, Required fields are missing: 
       // [UnitPrice__c, Price_Book_Test__c]: [UnitPrice__c, Price_Book_Test__c]
        a = new Price_Book_Entry__c(Product__c=p.Id,UnitPrice__c=100,Price_Book_Test__c=b.id);
        system.debug('a : '+ a);
        insert a;
        
        prblist = new list<Price_Book_Entry__c>();
        prblist.add(a); 
       // prblist2 = new list<
    }
    @isTest static void fetchProductTest(){
        // List<Price_Book_Entry__c> updatedList, String pRecordId,List<Price_Book_Entry__c> mydata)
        Test.startTest();
        TestProClass.fetchProduct1(b.Id, false);
        TestProClass.modalProduct(b.Id);
        TestProClass.nextScreenValue(prblist);
        TestProClass.standardBtnChk(b.Id);
        TestProClass.fetchLookUpValues(searchKeyWord ,ObjectName ,ExcludeitemsList ,b.Id);
        TestProClass.insertPriceProduct(prblist2,b.Id,prblist);
        TestProClass.deleteCustomBKEntry(a);
        // TestProClass.deleteCustomBKEntry(a);
        // TestProClass.deleteCustomBKEntry(a);
        
        Test.stopTest();
        
    }
    
     @isTest static  void insertData(){
     TestProClass.insertPriceProduct(prblist,b.Id,prblist);
         TestProClass.fetchProduct1(b.Id, true);
     }

}