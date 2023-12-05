@isTest
public class SupportSiteController_TEST {
    static Support_Manager_Queues__c smq;
    static Support_Manager__c sm;
    static Support_Assign_Rule__c saf;
    static Contact con;
    static Event e;
    static ContentVersion cv;
    static Profile profile;
    static User u;
    static Customer_Org__c corg;
    static {
        
        profile = [SELECT ID FROM Profile LIMIT 1];
        u = new User(
            LastName='LastName'
            , ProfileId = profile.Id
            , Alias = 'Alias'
            , Email = 'Email@dkbmc.com'
            , Username = 'Email@dkbmc.com'
            , EmployeeNumber = '000012'
            , TimeZoneSidKey = 'Africa/Cairo'
            , LocaleSidKey = 'ar'
            , EmailEncodingKey = 'UTF-8'
            , LanguageLocaleKey = 'en_US'
        );
        insert u;
        corg = new Customer_Org__c(Name = '회사', Team__c = 'CS1');
        insert corg;
        smq = new Support_Manager_Queues__c(Name='test'
                                            , Request_Content__c = 'content'
                                            , Request_Date__c = System.now()
                                            , Requester_Email__c = u.Email
                                            , Customer_Org__c = corg.Id
                                           );
        insert smq;   
        
        con = new Contact(LastName='네임', Email = u.Email);
        insert con;
        saf = new Support_Assign_Rule__c(Name='test'
                                         , Person_In_Charge__c = u.Id
                                         , Sub_Person_In_Charge__c = u.Id
                                         , domain__c='dkbmc.com'); 
        insert saf;
        e = new Event(ActivityDateTime = Datetime.now(), DurationInMinutes = 3, ActivityDate= Date.today() , Subject='On holiday' ,OwnerId = saf.Person_In_Charge__c);
        cv = new ContentVersion(title='dddd.txt', PathOnClient='test', VersionData = Blob.valueOf('Unit Test Attachment Body'));

        insert e;     
        insert cv;
        
        sm = new Support_Manager__c(Name='test', Support_Manager_Queues__c = smq.Id, Requester_Email__c = smq.Requester_Email__c, Person_In_Charge__c = u.Id);
        insert sm;
    }
    testMethod static void myTest() {
        
        Test.startTest();
        String jsonFile = '{"data" : "Y29udHJvbGxlciANCg0Kc3RhbmRlcmRjb250cm9sbGVyIMGmsPjH2MHYsMUNCg0KZXh0ZW5zaW9uIL26xdm02bXlIL/cv6EgtPUgx8q/5MfRIMTBxq630bevIL+ssOENCg0KcmVjb3JkU2V0VmFyIA0KDQp0YWJTdHlsZSC8s8Gkv6G8rSB0YWJzt84gtem+7rChvK0gwaTH2MH4sMUgwaS/6z8/PyANCg0Kc2lkZUJhciDFrLehvcS/obytIL+3v6Egu+fAzLXlILjetLq4piDHpb3Dx8+zxCC+yMfPs8QNCg0KxuTAzMH2uu23sCC/tb+qwPu/6w0KxL+44LXlufbGsCCx17PJILn2xrAgDQoNCsbQs84gsde4rrXlIMDatb/AuLfOILvnwMzB7iDBtsD9tcoNCg0Kvte8x7ytxvfGrg0KDQq+xr/0x7K4tcWpIMfYtOcgxuTAzMH2t84gsKO02Q0KDQo8YXBleDpzbGRzLz4gtvPAzMautNcgtfDA2sDOvcO9usXbwLsguvHB1r7zxve9ur+hIMDUx/TB1rTCsM0NCg0KPGFwZXg6ZW5oYW5jZQ0KDQo8YXBleDpyZXBlYXQ+IGZvcrmusLDAuiC53bq5ua4NCg0KDQovLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8NCm5hbWW4uCDBtsi4tcew7Q0KxuTAzMKhIMfPsO0NCg0Kvu7Eq7/uxq63zg0KDQrIrbjpv6EgNbCzuLggu9G4rrDtILOquNPB+CDG5MDMwqHAuLfODQovLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8="'
            + ',"path":"Test.txt"}';
        String jsonData = '{"Customer" : "TEST"'
            + ',"Emergency" : "하"'
            + ',"RequestContent" : "Test"'
            + ',"RequestType" : "단순문의"'
            + ',"Requester" : "Test"'
            + ',"RequesterEmail" : "Test@test.com"'
            + ',"RequesterPhone" : "010-0000-0000"'
            + ',"Title":"Test"'
            + ',"File":[{"data" : "Y29udHJvbGxlciANCg0Kc3RhbmRlcmRjb250cm9sbGVyIMGmsPjH2MHYsMUNCg0KZXh0ZW5zaW9uIL26xdm02bXlIL/cv6EgtPUgx8q/5MfRIMTBxq630bevIL+ssOENCg0KcmVjb3JkU2V0VmFyIA0KDQp0YWJTdHlsZSC8s8Gkv6G8rSB0YWJzt84gtem+7rChvK0gwaTH2MH4sMUgwaS/6z8/PyANCg0Kc2lkZUJhciDFrLehvcS/obytIL+3v6Egu+fAzLXlILjetLq4piDHpb3Dx8+zxCC+yMfPs8QNCg0KxuTAzMH2uu23sCC/tb+qwPu/6w0KxL+44LXlufbGsCCx17PJILn2xrAgDQoNCsbQs84gsde4rrXlIMDatb/AuLfOILvnwMzB7iDBtsD9tcoNCg0Kvte8x7ytxvfGrg0KDQq+xr/0x7K4tcWpIMfYtOcgxuTAzMH2t84gsKO02Q0KDQo8YXBleDpzbGRzLz4gtvPAzMautNcgtfDA2sDOvcO9usXbwLsguvHB1r7zxve9ur+hIMDUx/TB1rTCsM0NCg0KPGFwZXg6ZW5oYW5jZQ0KDQo8YXBleDpyZXBlYXQ+IGZvcrmusLDAuiC53bq5ua4NCg0KDQovLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8NCm5hbWW4uCDBtsi4tcew7Q0KxuTAzMKhIMfPsO0NCg0Kvu7Eq7/uxq63zg0KDQrIrbjpv6EgNbCzuLggu9G4rrDtILOquNPB+CDG5MDMwqHAuLfODQovLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8vLy8="'
            + ',"path":"Test.txt"}]}';
        SupportSiteController.getFAQ();
        SupportSiteController.insertContentDocument(smq.Id, jsonFile);
        SupportSiteController.insertRequestQ(jsonData);
        
        ContentVersion testContent = [SELECT id, ContentDocumentId FROM ContentVersion where Id = :cv.Id];
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = smq.Id;
        contentlink.ShareType = 'V';
        contentlink.ContentDocumentId = testContent.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;
        
        Test.stopTest();
    }
    
}