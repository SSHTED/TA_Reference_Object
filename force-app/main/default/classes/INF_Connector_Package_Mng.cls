/**
 * @Class : INF_Connector_Package_Mng
 *
 * @Method : 
 *	- @HttpPost doPost()
 *	- StringToDatetime(dt)
 *	- StringToDate(dt)
 * 
 * @Author : Yong-Jin, Cha
 * @Date : 2023-11-28
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2023-11-28 | Yong-Jin, Cha | 최초작성
 */
@RestResource(urlmapping = '/package/*')
global without sharing class INF_Connector_Package_Mng {

    @HttpPost
    global static PostResultWrap doPost() {

        PostResultWrap result = new PostResultWrap();

        RestRequest request = RestContext.request;
        
        String reqURI = request.requestURI;
        String packageNP = reqURI.replace('/package/', '');
        packageNP = packageNP.substring(0, packageNP.lastIndexOf('/'));
        String action = reqURI.substring(reqURI.lastIndexOf('/')+1);

        System.debug('# reqURI : ' + reqURI);
        System.debug('# packageNP : ' + packageNP);
        System.debug('# action : ' + action);

        /* */
        for(String key : request.headers.keySet()) {
            System.debug(key + ' : ' + request.headers.get(key));
        }
        /* */

        String param = RestContext.request.requestBody.toString();

        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(param);

        for(String key : m.keySet()) {
            System.debug(key + ' : ' + JSON.serialize(m.get(key)));
        }

        String customerOrgId = null;
        String packageManagementId = null;
        String packageManagementName = null;

        String orgId = String.valueOf(m.get('Id'));
        String orgName = String.valueOf(m.get('Name'));

        if('install' == action) {   // 설치시
    
            Customer_Org__c customer_org = new Customer_Org__c (
                Org_Id__c = orgId
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
                , Instance_Url__c = String.valueOf(m.get('Street')) // Street 정보에 Instance URL 담아서 넘겨 줌
                , NamespacePrefix__c = m.get('NamespacePrefix') == null ? null : String.valueOf(m.get('NamespacePrefix'))
                , OwnerId = System.Label.INF_CONNECTOR_ORG_REGISTER_OWNER
            );

            upsert customer_org Org_Id__c;

            customerOrgId = customer_org.Id;
        } else {
            customerOrgId = [select Id from Customer_Org__c where Org_Id__c = : orgId].get(0).Id;
        }

        List<PackageManagement__c> pmList = [select Id, Name from PackageManagement__c where Namespace_Prefix__c = :packageNP];
        if(pmList.size() > 0) {
            packageManagementId = pmList.get(0).Id;
            packageManagementName = pmList.get(0).Name;
        }

        if('install' == action) {   // 설치시
            ORG_InstalledApp__c installedApp = new ORG_InstalledApp__c (
                Name = packageManagementName + ' / ' + orgName
                , Customer_OrgId__c = customerOrgId
                , ExternalKey__c = customerOrgId + '_' + packageManagementId
                , FirstInstalledDate__c = System.today()
                , IsActive__c = true
                , PackageManagementId__c = packageManagementId
            );

            upsert installedApp ExternalKey__c;
        } else if('upgrade' == action) {    // 업그레이드시
            ORG_InstalledApp__c installedApp = new ORG_InstalledApp__c (
                ExternalKey__c = customerOrgId + '_' + packageManagementId
                , LastUpgradedDate__c = System.today()
            );

            upsert installedApp ExternalKey__c;
        } else if('unInstall' == action) {  // 제거시
            ORG_InstalledApp__c installedApp = new ORG_InstalledApp__c (
                ExternalKey__c = customerOrgId + '_' + packageManagementId
                , DeletedDate__c = System.today()
                , IsActive__c = false
            );

            upsert installedApp ExternalKey__c;
        }

        result.RequestCode = '200';
        result.Message = 'OK';
        
        return result;
    }

    @httpGet
    global static GetResultWrap doGet() {

        String methodName = 'doGet';

        GetResultWrap result = new GetResultWrap();
        
        RestRequest request = RestContext.request;
        
        String reqURI = request.requestURI;
        String packageNP = reqURI.replace('/package/', '');
        packageNP = packageNP.substring(0, packageNP.lastIndexOf('/'));
        String action = reqURI.substring(reqURI.lastIndexOf('/')+1);

        System.debug('# reqURI : ' + reqURI);
        System.debug('# packageNP : ' + packageNP);
        System.debug('# action : ' + action);

        /* */
        for(String key : request.headers.keySet()) {
            System.debug(key + ' : ' + request.headers.get(key));
        }
        /* */
        
        Map<String, String> paramMap = request.params;

        String orgId = paramMap.get('orgId');

        Boolean isActiveVal = false;
        
        if('checkActive' == action) {

            String customerOrgId = null;
            String packageManagementId = null;
            String exKey = '';
            
            List<Customer_Org__c> coList = [select Id from Customer_Org__c where Org_Id__c = :orgId];
            if(coList.size() > 0) {
                customerOrgId = coList.get(0).Id;
            }
            List<PackageManagement__c> pmList = [select Id, Name from PackageManagement__c where Namespace_Prefix__c = :packageNP];
            if(pmList.size() > 0) {
                packageManagementId = pmList.get(0).Id;
            }

            exKey = customerOrgId + '_' + packageManagementId;

            System.debug('## exKey : ' + exKey);

            List<ORG_InstalledApp__c> iaList = [select Id, IsActive__c, ExpirationDate__c from ORG_InstalledApp__c where ExternalKey__c = :exKey];
            if(iaList.size() > 0) {
                ORG_InstalledApp__c ia = iaList.get(0);
                if(ia.IsActive__c == false) {
                    isActiveVal = false;
                } else if(ia.ExpirationDate__c != null && ia.ExpirationDate__c < System.today()) {
                    isActiveVal = false;
                } else {
                    isActiveVal = true;
                }
            }
        }
        
        result.IsActive = isActiveVal;        
        result.RequestCode = '200';
        result.Message = 'OK';
        
        return result;
    }

    global class GetResultWrap {
        global String RequestCode;
        global String Message;
        global Boolean IsActive;
    }

    global class PostResultWrap {
        global String RequestCode;
        global String Message;
    }
}