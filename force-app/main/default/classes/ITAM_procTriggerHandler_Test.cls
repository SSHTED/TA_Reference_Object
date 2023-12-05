@isTest
private class ITAM_procTriggerHandler_Test {
    
    static TriggerSetting__c ts;
    static User user;
    static User user1;
    static User Auser;
    
    static Employee__c emp;
    static Employee__c emp2;
    static property__c prop;
    static property__c prop2;
    
    static property__c addPro1;
    static property__c addPro2;
    
    static property__c chanPro1;
    static property__c chanPro2;
    
    static property__c rePro1;
    static property__c rePro2;
    
    static property__c ucPro1;
    static property__c ucPro2;
    
    static RecordType rt;
    static property_request__c pr;
    static property_request__c pr2;
    static property_process__c Propr;
    static property_process__c addPropr;
    static property_process__c returnProp;
    static property_process__c changeProp;
    static property_process__c userChangeProp;
    
    static property__c cancelProp;    
    static property_request__c cancelReq;
    static property_request__c cancelReq2;
    static property_process__c cancelProc;
    static property_process__c cancelProc2;
    
    static {
        Auser = new User();
        Auser.Username ='aITAMtestemail@test.com';
        Auser.LastName = 'aITAMLastTestName';
        Auser.Email = 'testemail@test.com';
        Auser.alias = 'itam';
        Auser.TimeZoneSidKey = 'America/New_York';
        Auser.LocaleSidKey = 'en_US';
        Auser.EmailEncodingKey = 'ISO-8859-1';
        Auser.ProfileId = [select id from Profile where Name='DK BMC System Admin'].Id;
        Auser.LanguageLocaleKey = 'en_US';
        insert Auser;
        
        
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
            
            user1 = new User();
            user1.Username ='ITAMemail@test.com';
            user1.LastName = 'ITAMLastTestName';
            user1.Email = 'testemail@test.com';
            user1.alias = 'itams';
            user1.TimeZoneSidKey = 'America/New_York';
            user1.LocaleSidKey = 'en_US';
            user1.EmailEncodingKey = 'ISO-8859-1';
            user1.ProfileId = [select id from Profile where Name='DK BMC System Admin'].Id;
            user1.LanguageLocaleKey = 'en_US';
            insert user1;
            
            emp = new Employee__c();
            emp.Name = 'TestEmp';
            emp.Emp_No__c = '1';
            emp.Rank__c = '사원';
            emp.Start__c = System.today();
            emp.User__c = user.Id;
            insert emp;
            
            emp2 = new Employee__c();
            emp2.Name = 'TestEmp2';
            emp2.Emp_No__c = '2';
            emp2.Rank__c = '사원';
            emp2.Start__c = System.today();
            emp2.User__c = user1.Id;
            insert emp2;
            
            prop = new property__c();
            prop.Name = 'testProp';
            prop.ProductName__c = 'testPropProductName';
            prop.ModelName__c = 'textPropModle';
            insert prop;
            
            prop2 = new property__c();
            prop2.Name = 'userChangeProp';
            prop2.ProductName__c = 'userChangePropProdName';
            prop2.ModelName__c = 'userChangePropModel';
            prop2.RealEmp__c =emp2.Id;
            insert prop2;
            
            
            //add용 Property 생성
            addPro1 = new Property__c();
            addPro1.Name = 'addPro1';
            addPro1.ProductName__c = 'addProProdName';
            addPro1.ModelName__c = 'addProModel';
            
            addPro2 = new Property__c();
            addPro2.Name ='addPro2';
            addPro2.ProductName__c = 'addPro2ProdName';
            addPro2.ModelName__c = 'aaProModel';
            
            
            insert addPro1;
            insert addPro2;
            
            
            rt = [select id,Name from RecordType where SobjectType='property_request__c' and Name='교체' Limit 1];
            
            pr = new property_request__c();
            pr.realEmp__c = emp2.id;
            pr.requestEmp__c = emp.id;
            pr.status__c= 'createRequest';
            pr.RecordTypeId = rt.id;
            pr.requestRemarks__c = 'test remarks';
            pr.IsResign__c = false;
            pr.returnAsstNum__c = prop.id;
            pr.asstNum__c = prop.id;
            pr.beforeEmp__c = emp.id;
            pr.afterEmp__c = emp2.id;
            pr.Type__c ='하드웨어';
            pr.requestPropType__c = 'OA';
            pr.requestPropType_2nd__c = 'MT';
            pr.Name='testPr';
            insert pr;
            
            pr2 = new property_request__c();
            pr2.realEmp__c = emp2.id;
            pr2.requestEmp__c = emp.id;
            pr2.status__c= 'createRequest';
            pr2.RecordTypeId = rt.id;
            pr2.requestRemarks__c = 'test remarks';
            pr2.IsResign__c = false;
            pr2.returnAsstNum__c = prop.id;
            pr2.asstNum__c = prop.id;
            pr2.beforeEmp__c = emp.id;
            pr2.afterEmp__c = emp2.id;
            pr2.Type__c ='하드웨어';
            pr2.requestPropType__c = 'OA';
            pr2.requestPropType_2nd__c = 'MT';
            pr2.Name='testPr2';
            insert pr2;
            
            Propr = new property_process__c();
            Propr.requestNum__c = pr.id;
            Propr.asstNum__c = prop.id;
            
            addPropr = new property_process__c();
            addPropr.requestNum__c = pr.id;
            addPropr.asstNum__c = prop.id;
            addPropr.realEmp__c = emp.id;
            
            userChangeProp = new property_process__c();
            userChangeProp.ownerChangeNum__c = prop2.Id;
            userChangeProp.realEmp__c = emp2.id;
            userChangeProp.afterEmp__c = emp.Id;
            
            returnProp = new property_process__c();
            returnProp.requestNum__c = pr.id;
            returnProp.realEmp__c = emp.Id;
            returnProp.returnAsstNum__c = prop2.Id;
            
            
            changeProp = new property_process__c();
            
            // hojun

            cancelProp = new property__c();
            cancelProp.Name = 'userChangeProp';
            cancelProp.ProductName__c = 'userChangePropProdName';
            cancelProp.RealEmp__c = emp2.Id;
            cancelProp.ModelName__c = 'userChangePropModel';
            cancelProp.GiveDate__c = System.today();
            insert cancelProp;
            
            Id recordTypeId = [select id from RecordType where SobjectType='property_request__c' and DeveloperName='ADD' Limit 1].Id;
            //Id recordTypeId3 = [select id from RecordType where SobjectType='property_request__c' and DeveloperName='Return' Limit 1].Id;
            
            cancelReq = new property_request__c();
            cancelReq.asstNum__c = cancelProp.Id;
            cancelReq.RecordTypeId = recordTypeId;
            cancelReq.Type__c ='하드웨어';
            cancelReq.requestPropType__c = 'OA';
            cancelReq.requestPropType_2nd__c = 'MT';
            cancelReq.realEmp__c = emp2.id;
            cancelReq.status__c = 'cancel'; 
            insert cancelReq;
            System.debug('seogbong CHECK1: '+ [SELECT FM_status__c, status__c FROM property_request__c WHERE id = :cancelReq.Id]);
            
            cancelReq2 = new property_request__c();
            cancelReq2.asstNum__c = cancelProp.Id;
            cancelReq2.RecordTypeId = recordTypeId;
            cancelReq2.Type__c ='하드웨어';
            cancelReq2.requestPropType__c = 'OA';
            cancelReq2.requestPropType_2nd__c = 'MT';
            cancelReq2.realEmp__c = emp2.id;
			cancelReq2.status__c = 'cancel';            
            insert cancelReq2;
			
            
            Id recordTypeId2 = [select id from RecordType where SobjectType='property_process__c' and DeveloperName='Add' Limit 1].Id;
            
            cancelProc = new property_process__c();
            cancelProc.requestNum__c = cancelReq.Id;
            cancelProc.asstNum__c =cancelProp.Id;
            cancelProc.realEmp__c = emp2.id;
            cancelProc.RecordTypeId = recordTypeId2;
            //cancelProc.deliveryProp__c = 'cancel';
            insert cancelProc;
            System.debug('seogbong CHECK2: '+ [SELECT FM_status__c, status__c FROM property_request__c WHERE id = :cancelReq.Id]);
            /*
            cancelProc2 = new property_process__c();
            cancelProc2.requestNum__c = cancelReq2.Id;
            cancelProc2.returnAsstNum__c =cancelProp.Id;
            cancelProc2.realEmp__c = emp2.id;
            cancelProc2.RecordTypeId = recordTypeId2;
            insert cancelProc2;
			*/
            
            //cancelProc.sortOutDate__c = System.today();
            //update cancelProc; 
            
        }
    }
    
    static testMethod void procChildCont1(){
        
        
        Test.startTest();
        //System.runAs([SELECT Id FROM USER WHERE Id =:UserInfo.getUserId()][0]){
        System.runAs([SELECT Id FROM USER WHERE Username =:'aITAMtestemail@test.com'][0]){
            //property_request__c pr = [SELECT id FROM property_request__c WHERE Name ='testPr'];
            insert Propr;
            
            Propr.sortOutDate__c = System.today();
            update Propr;
            insert addPropr;
            insert userChangeProp;
            insert returnProp;
            //Propr.asstNum__c = prop2.Id;
            //update Propr;
            
            //delete userChangeProp;
            Propr.asstNum__c = prop2.Id;
            update Propr;
            EmailTemplate procTemp = [SELECT HtmlValue, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'propertyWait' LIMIT 1];
            ITAM_AllEmailTemplated2.getEmailTemplateMaps2(addPropr, procTemp);
            ITAM_AllEmailTemplated2.getEmailTemplateMaps3(addPropr, procTemp);
            
            delete addPropr;
            delete UserChangeProp;
        }
        
        
        Test.stopTest();
        
    }
    
    /////t12
    
    static testMethod void reqCancel(){
        
        System.runAs([SELECT Id FROM USER WHERE Username =:'aITAMtestemail@test.com'][0]){
            
            Test.startTest();
            System.debug('reqCancel - property_request__c notUpdate:: ' + [SELECT Id, asstNum__c, RecordType.Name, Type__c, FM_status__c, status__c FROM property_request__c WHERE id = :cancelReq.Id]);
            System.debug('reqCancel - property_process__c notUpdate:: ' + [SELECT Id, asstNum__c, realEmp__c, RecordType.Name, FM_reqRecordType__c, procStatus__c, deliveryProp__c, sortOutDate__c FROM property_process__c WHERE Id = :cancelProc.Id]);
            List<property_process__c> olds = [SELECT Id, asstNum__c, returnAsstNum__c, realEmp__c, RecordType.Name, FM_reqRecordType__c, procStatus__c, deliveryProp__c, sortOutDate__c FROM property_process__c WHERE Id = :cancelProc.Id];
            List<property_process__c> news = olds.deepClone(true);
            Map<Id, property_process__c> newMap = new Map<Id, property_process__c>(olds);
            
            ITAM_procTriggerHandler procTrigger = new ITAM_procTriggerHandler(true, 1);
            procTrigger.onAfterUpdate(olds, news, newMap);
            
            System.debug('reqCancel - property_process__c:: ' + [SELECT Id, asstNum__c, returnAsstNum__c, FM_reqRecordType__c, procStatus__c, deliveryProp__c FROM property_process__c WHERE Id = :cancelProc.Id ]);
            System.debug('reqCancel - property_request__c:: ' + [SELECT Id, asstNum__c, RecordType.Name, Type__c, FM_status__c, status__c FROM property_request__c WHERE id = :cancelReq.Id]);
            System.debug('reqCancel - property__c:: ' + [SELECT Id, realEmp__c, GiveDate__c, isProcessDel__c FROM property__c WHERE Id =:cancelProp.Id]);
            
            System.debug('reqCancel - property_process__c:22222: ' + cancelProc);
            System.debug('reqCancel - property_request__c:22222: ' + cancelReq2);
            System.debug('reqCancel - property__c:22222: ' + cancelProp);
            
            Test.stopTest();
            
            
        } 
        
    }
    
    
}