/**
* Desc : SupportRestOutboundController
*
* @Method : 
*  - 
* @Author : Ha-Eun, Lee
* @Date : 2019-08-20
* @Version : 1.0
* @Modified : 
*  ---------------------------------------------
*  NO | Date       | Modifier      | Description
*  ---------------------------------------------
*  1. | 2019-08-20 | Ha-Eun, Lee   | 최초작성
*  2. | 2019-08-28 | Yong-Jin, Cha | 날짜 관련 파리미터 수정 (보내는쪽과 받는 쪽의 Locale 이 다를 경우 포멧에서 발생하는 오류 수정)
*  3. | 2019-09-02 | Ha-Eun, Lee   | Support Manager Person In charge 를 Owner로 변경
*  4. | 2019-09-05 | Ha-Eun, Lee   | JWT 방식 등록
*/

global class SupportRestOutboundController {
	
    @Future(callout=true)
    global static void oauth2Token(String rId) {

        Support_Manager__c result = [SELECT Id, Customer_Org__c FROM Support_Manager__c WHERE Id = :rId LIMIT 1];
        
        String orgId = result.Customer_Org__c;
        
        Customer_Org__c orgInfo = [SELECT Id, Org__r.UserName__c , Org__r.Password__c FROM Customer_Org__c WHERE Id = :orgId LIMIT 1];

        String httpResBody = null;     
        String username = orgInfo.Org__r.UserName__c;
        String password = orgInfo.Org__r.Password__c;
        String clientId = Label.client_id;
        String clientSecret = Label.client_secret;
  
        Httprequest httpReq = new Httprequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();
        
        httpReq.setMethod('POST');          
        httpReq.setEndpoint('https://login.salesforce.com/services/oauth2/token'
                            + '?grant_type=password' 
                            + '&username=' + username 
                            + '&password=' + password 
                            + '&client_id=' + clientId 
                            + '&client_secret=' + clientSecret);                       
        httpReq.setTimeout(120000);                    

        if(!Test.isRunningTest()) httpRes = http.send(httpReq);  

		httpResBody = httpRes.getBody();
        System.debug('httpResBody : ' + httpResBody);
  
        sendResult(httpResBody , rId);
    }
    
    global static void sendResult(String httpResBody, String DKRecordId) {
        
        Map<String, Object> resMap = new Map<String, Object>();
        
        if(!Test.isRunningTest()) resMap = (map<String, Object>) JSON.deserializeUntyped(httpResBody);
        
        System.debug('resMap : ' + resMap);
        
        Support_Manager__c data = [
            SELECT 
                Id
                , Name
                , Actual_Days__c
                , Close_Date__c
                , Start_Date__c
                , Customer_Category__c
                , State__c
                , Detail_State__c
                , Emergency__c
                , Owner.Name
                , Processing_Content__c
                , Sandbox_Apply__c
                , Sandbox_Apply_Date__c
                , Production_Apply__c
                , Production_Apply_Date__c
                , Record_Id__c
            	, CreatedDate
            	, Expected_MM__c
            	, Actual_MM__c
			FROM 
            	Support_Manager__c 
            WHERE 
            	Id = :DKRecordId
        ];
        
        String resBody = null;
        String recordId = data.Record_Id__c;
        String instanceUrl = (String)resMap.get('instance_url') ;
        String accessToken = (String)resMap.get('access_token') ;
  
        System.debug('data : ' + data);
        
        //String StartDate = data.Start_Date__c != null ? data.Start_Date__c.format() : null;
        //String CloseDate = data.Close_Date__c != null ? data.Close_Date__c.format() : null;
        //String SandboxApplyDate = data.Sandbox_Apply_Date__c != null ? data.Sandbox_Apply_Date__c.format() : null;
        //String ProductionApplyDate = data.Production_Apply_Date__c != null ? data.Production_Apply_Date__c.format() : null;
        
        String StartDate = data.Start_Date__c == null ? null : formatDate(data.Start_Date__c);
        String CloseDate = data.Close_Date__c == null ? null : formatDate(data.Close_Date__c);
        String SandboxApplyDate = data.Sandbox_Apply_Date__c == null ? null : formatDate(data.Sandbox_Apply_Date__c);
        String ProductionApplyDate = data.Production_Apply_Date__c == null ? null : formatDate(data.Production_Apply_Date__c);
        
        RequestWapper request = new RequestWapper();
        
        request.Id = data.Id;
        request.Name = data.Name;
        request.ProcessingContent = data.Processing_Content__c;
        request.State = data.State__c;
        request.DetailState = data.Detail_State__c;
        request.StartDate = StartDate;
        request.CloseDate  = CloseDate;
        request.SandboxApply = data.Sandbox_Apply__c;
        request.SandboxApplyDate = SandboxApplyDate;
        request.ProductionApply = data.Production_Apply__c;
        request.ProductionApplyDate = ProductionApplyDate;
        request.PersonInCharge = data.Owner.Name;
        request.ReceptionDateLong = data.CreatedDate.getTime();
        request.ExpectedMD = data.Expected_MM__c;
        request.ActualMD = data.Actual_MM__c;
        
        System.debug('request : ' + request);
        

        Httprequest httpReq = new Httprequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();
        
        httpReq.setMethod('POST');          
        httpReq.setEndpoint(instanceUrl + '/services/apexrest/DK_SUPPORT/result/' + recordId);                     
        httpReq.setTimeout(120000);                    
        httpReq.setHeader('Authorization', 'Bearer ' + accessToken);
        httpReq.setHeader('Content-Type', 'application/json'); 
        httpReq.setBody(JSON.serialize(request));
        if(!Test.isRunningTest()) httpRes = http.send(httpReq);            
        
        
        resBody = httpRes.getBody();
        
        System.debug(resBody);
    }
 
    
    ////////////////////////////////////JWT 방식 시작/////////////////////////////////////////////////////////////////////////////////////////
    /*@Future(callout=true)
    global static void oauth2Token2(String rId) {

        Support_Manager__c result = [SELECT Id, Customer_Org__c FROM Support_Manager__c WHERE Id = :rId LIMIT 1];
        String orgId = result.Customer_Org__c;
        Customer_Org__c orgInfo = [SELECT Id, Org__r.UserName__c , Instance_Url__c FROM Customer_Org__c WHERE Id = :orgId LIMIT 1];

        String iss =  Label.Consumer_Key;
        String aud = 'https://login.salesforce.com';
		String sub = orgInfo.Org__r.UserName__c;

        Jwt.Configuration config = new Jwt.Configuration();
        config.jwtUsername = sub;
        config.jwtSigningCertificateName = 'support_manager';
        config.jwtHostname = 'login.salesforce.com';
        config.jwtConnectedAppConsumerKey = iss;
        
        System.debug('config : ' + config);
        
        String accessToken = new Jwt(config).requestAccessToken();
        
        System.debug('accessToken : ' + accessToken);

        String instanceUrl = orgInfo.Instance_Url__c;
        
		sendJWTResult(instanceUrl , accessToken , rId);        

    } 

    
    global static void sendJWTResult(String instanceUrl, String accessToken , String DKRecordId) {
        
        Map<String, Object> resMap = new Map<String, Object>();

        System.debug('resMap : ' + resMap);
        
        Support_Manager__c data = [
            SELECT 
                Id
                , Name
                , Actual_Days__c
                , Close_Date__c
                , Start_Date__c
                , Customer_Category__c
                , State__c
                , Detail_State__c
                , Emergency__c
                , Owner.Name
                , Processing_Content__c
                , Sandbox_Apply__c
                , Sandbox_Apply_Date__c
                , Production_Apply__c
                , Production_Apply_Date__c
                , Record_Id__c
			FROM 
            	Support_Manager__c 
            WHERE 
            	Id = :DKRecordId
        ];
        
        String resBody = null;
        String recordId = data.Record_Id__c;
  
        System.debug('data : ' + data);
        
        String StartDate = data.Start_Date__c == null ? null : formatDate(data.Start_Date__c);
        String CloseDate = data.Close_Date__c == null ? null : formatDate(data.Close_Date__c);
        String SandboxApplyDate = data.Sandbox_Apply_Date__c == null ? null : formatDate(data.Sandbox_Apply_Date__c);
        String ProductionApplyDate = data.Production_Apply_Date__c == null ? null : formatDate(data.Production_Apply_Date__c);
        
        RequestWapper request = new RequestWapper();
        
        request.Id = data.Id;
        request.Name = data.Name;
        request.ProcessingContent = data.Processing_Content__c;
        request.State = data.State__c;
        request.DetailState = data.Detail_State__c;
        request.StartDate = StartDate;
        request.CloseDate  = CloseDate;
        request.SandboxApply = data.Sandbox_Apply__c;
        request.SandboxApplyDate = SandboxApplyDate;
        request.ProductionApply = data.Production_Apply__c;
        request.ProductionApplyDate = ProductionApplyDate;
        request.PersonInCharge = data.Owner.Name;
        
        System.debug('request : ' + request);
        

        Httprequest httpReq = new Httprequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();
        
        httpReq.setMethod('POST');          
        httpReq.setEndpoint(instanceUrl + '/services/apexrest/DK_SUPPORT/result/' + recordId);                     
        httpReq.setTimeout(120000);                    
        httpReq.setHeader('Authorization', 'Bearer ' + accessToken);
        httpReq.setHeader('Content-Type', 'application/json'); 
        httpReq.setBody(JSON.serialize(request));
        if(!Test.isRunningTest()) httpRes = http.send(httpReq);            
        
        
        resBody = httpRes.getBody();
        
        System.debug(resBody);
    }
    */
    ////////////////////////////////////JWT 방식 끝/////////////////////////////////////////////////////////////////////////////////////////
     
    
    private static String formatDate(Date dt) {
        return dt.year() + '' + (dt.month()+'').leftPad(2, '0') + '' + (dt.day()+'').leftPad(2, '0');
    }    
    
    public class RequestWapper
    {
        public String Id { get; set; }
        public String Name { get; set; }
        public String ProcessingContent { get; set; }
        public String RecordId { get; set; }
        public String PersonInCharge { get; set; }
        public String State { get; set; }
        public String DetailState { get; set; }
        public String StartDate { get; set; }
        public String CloseDate { get; set; }
        public Boolean SandboxApply { get; set; }
        public Boolean ProductionApply { get; set; }
        public String SandboxApplyDate { get; set; }
        public String ProductionApplyDate { get; set; }
        public Long ReceptionDateLong { get; set; }
        public Decimal ExpectedMD { get; set; }
        public Decimal ActualMD { get; set; }
    }
}