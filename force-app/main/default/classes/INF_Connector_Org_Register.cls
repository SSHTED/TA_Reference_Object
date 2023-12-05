/**
 * @Class : INF_Connector_Org_Register
 *
 * @Method : 
 *	- @HttpPost doPost()
 *	- StringToDatetime(dt)
 *	- StringToDate(dt)
 * 
 * @Author : Yong-Jin, Cha
 * @Date : 2023-08-12
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2023-08-12 | Yong-Jin, Cha | 최초작성
 */
@RestResource(urlmapping = '/org-register/*')
global without sharing class INF_Connector_Org_Register {

    @HttpPost
    global static PostResultWrap doPost() {

        PostResultWrap result = new PostResultWrap();

        RestRequest request = RestContext.request;
        
        String reqURI = request.requestURI;
        String orgId = reqURI.substring(reqURI.lastIndexOf('/')+1);

        System.debug('# reqURI : ' + reqURI);
        System.debug('# orgId : ' + orgId);

        /**
        for(String key : request.headers.keySet()) {
            System.debug(key + ' : ' + request.headers.get(key));
        }
        /**/

        String param = RestContext.request.requestBody.toString();

        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(param);

        for(String key : m.keySet()) {
            System.debug(key + ' : ' + JSON.serialize(m.get(key)));
        }

        Customer_Org__c customer_org = new Customer_Org__c (
            Org_Id__c = String.valueOf(m.get('Id'))
            , Instance_Name__c = String.valueOf(m.get('InstanceName'))
            , IsSandbox__c = Boolean.valueOf(m.get('IsSandbox'))
            , Name = String.valueOf(m.get('Name'))
            , OrganizationType__c = String.valueOf(m.get('OrganizationType'))
            , UiSkin__c = String.valueOf(m.get('UiSkin'))
            , Country__c = String.valueOf(m.get('Country'))
            , DefaultLocaleSidKey__c = String.valueOf(m.get('DefaultLocaleSidKey'))
            , LanguageLocaleKey__c = String.valueOf(m.get('LanguageLocaleKey'))
            , PrimaryContact__c = String.valueOf(m.get('PrimaryContact'))
            , SignupCountryIsoCode__c = String.valueOf(m.get('SignupCountryIsoCode'))
            , TimeZoneSidKey__c = String.valueOf(m.get('TimeZoneSidKey'))
            //, Customer__c = 고객사
            //, Instance_Url__c = String.valueOf(m.get('Name'))
            //, NamespacePrefix__c = String.valueOf(m.get('NamespacePrefix'))
            //, Org__c = Org
            //, Team__c = 'CS1'
            , OwnerId = System.Label.INF_CONNECTOR_ORG_REGISTER_OWNER
        );

        upsert customer_org Org_Id__c;

        result.RequestCode = '200';
        result.Message = 'OK';
        
        return result;
    }

    global class PostResultWrap {
        global String RequestCode;
        global String Message;
    }
}