@isTest

public class ITAM_propertyMainController_Test {
@testSetup
    static void setup(){
        User user1 = new User();
        user1.Username ='ITAMemail@test.com';
        user1.LastName = 'ITAMLastTestName';
        user1.Email = 'testemail@test.com';
        user1.alias = 'itams';
        user1.TimeZoneSidKey = 'America/New_York';
        user1.LocaleSidKey = 'en_US';
        user1.EmailEncodingKey = 'ISO-8859-1';
        user1.ProfileId = [select id from Profile where Name='System Administrator'].Id;
        user1.LanguageLocaleKey = 'en_US';
        insert user1;
        
    }
    
    @isTest
    static void procChildCont(){
        User uid = [SELECT id FROM User WHERE UserName='ITAMemail@test.com'];
        
        RecordType rt = [select id,Name from RecordType where SobjectType='property_request__c' and Name='교체' Limit 1];
        
        Test.startTest();
        system.runAs(uid){
            ITAM_propertyMainController.getRecordType(rt.Id);
        }
        Test.stopTest();
        
    }
}