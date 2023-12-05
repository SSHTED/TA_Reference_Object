/**
* Desc : SupportCustomerOrgInfoController
*
* @Method : 
* 
* @Author : Ha-Eun, Lee
* @Date : 2019-08-12
* @Version : 1.0
* @Modified : 
*  ---------------------------------------------
*  NO | Date       | Modifier      | Description
*  ---------------------------------------------
*  1. | 2019-08-12 | Ha-Eun, Lee   | 최초작성
*  2. | 2019-08-23 | Yong-Jin, Cha | Org 정보 Insert 에서 Upsert로 변경
*/

@RestResource(urlMapping='/org/*')
global class SupportCustomerOrgInfoController {
    
    @HttpPost
    global static ResultClass doPost() 
    {
        ResultClass rsCls = new ResultClass();
        RestRequest req = RestContext.request;
        
        System.debug('============================== REST PARAMETERS =================================');
        Map<String, Object> resMap = (map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
        for(String key : resMap.keyset()) {
            System.debug('# '+ key + ' : ' + resMap.get(key));
        }
        System.debug('============================== REST PARAMETERS =================================');
        
        InsertCustomerOrgInfo(resMap);
        
        rsCls.result = true;
        rsCls.requestURI = req.requestURI;
        rsCls.orgId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        return rsCls;
    }
    
    global static void InsertCustomerOrgInfo(Map<String, Object> resMap) {
        
        System.debug('resMap : ' + resMap);
        
        Customer_Org__c orgInfo;
        Map<String, Object> orgMap = (Map<String, Object>) resMap.get('orgInfo');
        orgInfo = new Customer_Org__c(Name = (String)orgMap.get('Name')
                                     , Org_Id__c = (String)orgMap.get('Id')
                                     , Instance_Name__c = (String)orgMap.get('InstanceName')
                                     , IsSandbox__c = (Boolean)orgMap.get('IsSandbox')
                                     , NamespacePrefix__c = (String)orgMap.get('NamespacePrefix')
                                     , OrganizationType__c = (String)orgMap.get('OrganizationType')
                                     , Country__c = (String)orgMap.get('Country')
                                     , DefaultLocaleSidKey__c = (String)orgMap.get('DefaultLocaleSidKey')
                                     , LanguageLocaleKey__c = (String)orgMap.get('LanguageLocaleKey')
                                     , PrimaryContact__c = (String)orgMap.get('PrimaryContact')
                                     , SignupCountryIsoCode__c = (String)orgMap.get('SignupCountryIsoCode')
                                     , TimeZoneSidKey__c = (String)orgMap.get('TimeZoneSidKey')
                                     , UiSkin__c = (String)orgMap.get('UiSkin')
                                     , Instance_Url__c = (String)resMap.get('instanceUrl'));
        
        if(!Test.isRunningTest())	upsert orgInfo Org_Id__c;
    }
 
    global class ResultClass {
        public Boolean result {get; set;}
        public String requestURI {get; set;}
        public String orgId {get; set;}
        public String errorMsg {get; set;}
        public String errorCode {get; set;}
    }	
}