@isTest
private class INF_Connector_Org_Register_TEST {

    static testMethod void myUnitTest() {
        
        Test.startTest();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        //String reqBody      = JSON.serialize(param);
        String reqBody = '{"Id":"00D5j00000CLOQfEAP","InstanceName":"AP27","IsSandbox":false,"Name":"DKBMC CX Support","OrganizationType":"Developer Edition","UiSkin":"Theme3","Country":"KR","DefaultLocaleSidKey":"ko","LanguageLocaleKey":"ko","PrimaryContact":"차용진 팀장","SignupCountryIsoCode":"KR","TimeZoneSidKey":"Asia/Seoul"}';
        req.requestBody = Blob.valueOf(reqBody);

        req.requestURI = '/services/apexrest/org-register/00D5j00000CLOQfEAP'; //Request URL
        req.httpMethod = 'POST';        

        RestContext.request = req;
        RestContext.response= res;
        
        INF_Connector_Org_Register.doPost();
        
        Test.stopTest();
    }
}