@isTest
public class lwcLookupTestClass {
  static User user;
    static{
        user = new User( LastName='bb', FirstName='cc');
    }
    @isTest static void fetchProductTest(){
          Test.startTest();
        LwcLookupController.findRecords('bb','user');
                Test.stopTest();
    }
}