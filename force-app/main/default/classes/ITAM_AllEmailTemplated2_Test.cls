@isTest
public class ITAM_AllEmailTemplated2_Test {
    
    static TriggerSetting__c ts;
    
    static User user;
    
    static Employee__c emp;
    
    static RecordType rt;
    
    static property__c prop;
    
    static property_request__c req;
    
    static property_process__c Proc;
    
    static EmailTemplate procTemp;
    static EmailTemplate reqTemp;
    
    static {
        
        ts = new TriggerSetting__c();
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
        
        System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
            user = new User();
            user.Username ='ITAMtestemail@test.com';
            user.LastName = 'ITAMLastTestName';
            user.Email = 'testemail@test.com';
            user.alias = 'itam';
            user.TimeZoneSidKey = 'America/New_York';
            user.LocaleSidKey = 'en_US';
            user.EmailEncodingKey = 'ISO-8859-1';
            user.ProfileId = [select id from Profile where Name='DK BMC System Admin'].Id;
            user.LanguageLocaleKey = 'en_US';
            insert user;
            
            emp = new Employee__c();
            emp.Name = 'TestEmp';
            emp.Emp_No__c = '1';
            emp.Rank__c = '사원';
            emp.Start__c = System.today();
            emp.User__c = user.Id;
            insert emp;
            
            prop = new property__c();
            prop.Name = 'testProp';
            prop.ProductName__c = 'testPropProductName';
            prop.ModelName__c = 'textPropModel';
            prop.RealEmp__c = emp.Id;
            prop.ReceivingDate__c = System.today();
            insert prop;
            
            
            req = new property_request__c ();
            req.CreatedById = User.Id;
            req.CreatedDate = datetime.now();
            req.realEmp__c = emp.id;
            req.IsProcess__c = false;
            req.IsResign__c = false;
            req.LastModifiedById = User.Id;
            req.LastModifiedDate = datetime.now();
            req.OwnerId = System.UserInfo.getUserId();
            req.requestDate__c = date.today();		
            insert req;
            
            proc = new property_process__c ();
            proc.CreatedById = User.Id;
            proc.CreatedDate = datetime.now();
            proc.IsDiffQa__c = false;
            proc.IsResign__c = false;
            proc.LastModifiedById = User.Id;
            proc.LastModifiedDate = datetime.now();
            proc.OwnerId = System.UserInfo.getUserId();			
            insert proc;
            
        }           
    }
    
    static testMethod void myUnitTest1() {
        
        procTemp = null;
        
        Test.startTest();
        
        EmailTemplate procTemp = [SELECT HtmlValue, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'propertyWait' LIMIT 1];
        
        ITAM_AllEmailTemplated2.getEmailTemplateMaps2(Proc, procTemp);
        
        update proc;
        
        Test.stopTest();
    }
    
    static testMethod void myUnitTest2() {
        
        procTemp = null;
        
        Test.startTest();
        
        EmailTemplate procTemp = [SELECT HtmlValue, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'propertySuccess' LIMIT 1];
        
        ITAM_AllEmailTemplated2.getEmailTemplateMaps3(Proc, procTemp);
        
        update proc;
        
        Test.stopTest();
    }
    
    static testMethod void myUnitTest3() {
        
        reqTemp = null;
        
        Test.startTest();
        
        EmailTemplate reqTemp = [SELECT HtmlValue, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'property_return' LIMIT 1];
        
        ITAM_AllEmailTemplated2.getEmailTemplateMaps2T(Req, reqTemp);
        
        update req;
        
        Test.stopTest();
    }
    
}