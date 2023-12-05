/**
* @Class : HR_OrgMemberUpdateBatch
*
* @Method : 

*  - start(BC)
*  - execute(BC, scope)
*  - finish(BC)
* 
* @Author : Yong-jin, Cha
* @Date : 2022-11-23
* @Version : 1.0
* @Modified : 
*  ---------------------------------------------
*  NO | Date       | Modifier      | Description
*  ---------------------------------------------
*  1. | 2022-11-23 | Yong-jin, Cha | 최초작성
* 
* @reference : https://wantedplus.notion.site/wantedplus/API-4dd6e82481f640f997e369e242c247e2
*/
public with sharing class HR_OrgMemberUpdateBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    
    public String BatchName = 'HR_OrgMemberUpdateBatch';                // 배치명
    public Organization OrgInfo = UTIL_BatchLog.getOrganizationInfo();  // 오그정보
    public String LogExternalKey = '';                                  // 로그고유키값
    public Integer TotalBatches = 0;                                    // 총 execute 건수
    public Integer BatchesProcessed = 0;                                // 실행된 execute 건수
    public Integer BatchesFailed = 0;                                   // 실패한 execute 건수
    public Integer TotalRows = 0;                                       // 총 처리 대상 데이터 건수
    public Integer RowsProcessed = 0;                                   // 처리된 데이터 건수
    public Integer RowsFailed = 0;                                      // 실패한 데이터 건수
    public String ResultMessage = '';                                   // 결과 내용(에러시)
    
    public String API_KEY = System.Label.WS_API_KEY;                    // 원티드스페이스 API 키
    public String API_SECRET_KEY = System.Label.WS_API_SECRET_KEY;      // 원티드스페이스 시크릿키
    public String ENDPOINT = System.Label.WS_ENDPOINT_URL;              // 원티드스페이스 Endpoint
    public String SERVICE_API = System.Label.WS_ORG_MEMBER_API;         // 조직도 멤버 조회 API
    
    public String CX_TEAM_ID = System.Label.WS_CX_TEAM_ID;              // 원티드스페이스 CX본부 조직 ID
    
    public Map<String, String> orgMap = new Map<String, String>();
    public Map<String, Employee__c> emailMap = new Map<String, Employee__c>();
    
    public HR_OrgMemberUpdateBatch() {
        // 조직
        List<Organization__c> orgList = [
            select 
                Id
                , Name
                , WS_TeamId__c
            from
                Organization__c
            where
                WS_TeamId__c != null
        ];
        //select id,name,Email__c from Employee__c  where Email__c != null
        List<Employee__c> empList = [
            select 
                id
                , name
                , Email__c 
            from 
                Employee__c
            where
                Email__c != null 
        ];
        
        for(Organization__c p : orgList) {
            orgMap.put(p.WS_TeamId__c, p.Id);
        }
        
        for(Employee__c emp : empList){
            emailMap.put(emp.Email__c , emp);
        }
        
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        
        if('Y' == System.Label.BATCH_LOG_USE) {
            LogExternalKey = UTIL_BatchLog.startLog(BatchName, OrgInfo);
        }
        
        String SOQL = ' select  '
                    + ' 	Code__c '
                    + ' 	, DisplayOrder__c '
                    + ' 	, Id '
                    + ' 	, IsActive__c '
                    + ' 	, IsResourceActive__c '
                    + ' 	, Level__c '
                    + ' 	, Name '
                    + ' 	, Note__c '
                    + ' 	, ParentOrgId__c '
                    + ' 	, WS_ChargerEmail__c '
                    + ' 	, WS_LeaderEmail__c '
                    + ' 	, WS_TeamId__c '
                    + ' 	, WS_TeamName__c '
                    + ' 	, WS_TeamNums__c '
                    + ' 	, WS_TeamParentId__c '
                    + ' from '
                    + ' 	Organization__c '
                    + ' where '
                    //+ '     WS_TeamId__c != null '
                    //+ ' and WS_TeamNums__c > 0 '
                    + '  (WS_TeamParentId__c = :CX_TEAM_ID OR WS_TeamId__c = :CX_TEAM_ID) '
                    + ' order by '
                    + '     Level__c';
        
        return Database.getQueryLocator(SOQL);
    }
    
    public void execute(Database.BatchableContext BC, List<Organization__c> scope) {
        
        Integer batchSize = scope.size();
        TotalBatches++;
        TotalRows += batchSize;
        
        try {
            for(Organization__c org : scope) {
                Httprequest httpReq = new Httprequest();
                HttpResponse httpRes = new HttpResponse();
                Http http = new Http();
                
                String resBody = null;
                
                String SERVICE_API2 = String.format(SERVICE_API, new String[]{API_KEY, org.WS_TeamId__c});
                
                httpReq.setMethod('GET');
                httpReq.setEndpoint(ENDPOINT + SERVICE_API2);                      
                httpReq.setTimeout(120000);                   
                httpReq.setHeader('Authorization', API_SECRET_KEY);
                httpReq.setHeader('Content-Type', 'application/json');
                httpReq.setHeader('Accept', 'application/json');
                
                if(!Test.isRunningTest()) {
                    httpRes = http.send(httpReq);           
                } else {
                    String blStr= '{"next":null,"previous":null,"count":1,"results":[{"email":"yj.cha@dkbmc.com","username":"차용진","position":"팀장","team_id":25809,"onduty_detail":{"events_txt":"","status":"WORKING"},"cmem_status":"WORKING"}]}';
                    Blob bl = Blob.valueof(blStr);
                    httpRes.setBody(blStr);
                    httpRes.setStatusCode(200);
                }
                resBody = httpRes.getBody();          
                
                System.debug('** resBody : ' + resBody);
                
                Object dataObj = (Object)JSON.deserializeUntyped(resBody);
                
                Map<String, Object> data = (Map<String, Object>) dataObj;
                
                List<Object> dataList = (List<Object>)data.get('results');
                
                List<Employee__c> empList = new List<Employee__c>();
                
                for(Object o : dataList) {
                    Map<String, Object> item = (Map<String, Object>)o;
                    
                    System.debug('# email : ' + item.get('email'));
                    System.debug('# username : ' + item.get('username'));
                    System.debug('# position : ' + item.get('position'));
                    System.debug('# team_id : ' + item.get('team_id'));
                    System.debug('# cmem_status : ' + item.get('cmem_status'));
                    System.debug('# onduty_detail : ' + item.get('onduty_detail'));
                    
                    Map<String, Object> detail = (Map<String, Object>) item.get('onduty_detail');
                    
                    System.debug('# status : ' + detail.get('status'));
                    System.debug('# events_txt : ' + detail.get('events_txt'));
                    
                    System.debug('#-------------------------- ');
                    
                    if(emailMap.containsKey(String.ValueOf(item.get('email')))){
                        
                        Employee__c emp = emailMap.get(String.ValueOf(item.get('email')));
                        emp.WS_Name__c = String.valueOf(item.get('username'));
                        emp.WS_Email__c = String.valueOf(item.get('email'));
                        emp.WS_Position__c = String.valueOf(item.get('position'));
                        emp.WS_TeamId__c = String.valueOf(item.get('team_id'));
                        emp.WS_ActiveStatus__c = String.valueOf(item.get('cmem_status'));
                        emp.WS_OnDutyStatus__c = String.valueOf(detail.get('status'));
                        emp.WS_EventDesc__c = String.valueOf(detail.get('events_txt'));
                        emp.Name = String.valueOf(item.get('username'));
                        emp.Email__c = String.valueOf(item.get('email'));                       
                        /*
                        Employee__c emp = new Employee__c(
                        WS_Name__c = String.valueOf(item.get('username'))
                        , WS_Email__c = String.valueOf(item.get('email'))
                        , WS_Position__c = String.valueOf(item.get('position'))
                        , WS_TeamId__c = String.valueOf(item.get('team_id'))
                        , WS_ActiveStatus__c = String.valueOf(item.get('cmem_status'))
                        , WS_OnDutyStatus__c = String.valueOf(detail.get('status'))
                        , WS_EventDesc__c = String.valueOf(detail.get('events_txt'))
                        , Name = String.valueOf(item.get('username'))
                        , Email__c = String.valueOf(item.get('email'))
                        //, Position__c = String.valueOf(item.get('position'))                        
                        );*/
                        
                        // if(orgMap.get(emp.WS_TeamId__c) != null) {
                        //     emp.OrganizationId__c = orgMap.get(emp.WS_TeamId__c);
                        // }
                        
                        empList.add(emp);
                        
                        System.debug('#-------------------------- ' + empList.size());
                    }
                }
                
                //upsert empList WS_Email__c;
                update empList;
                BatchesProcessed++;
                RowsProcessed += batchSize;
            }
            
        } catch(Exception e) {
            
            BatchesFailed++;
            RowsFailed += batchSize;
            ResultMessage += UTIL_BatchLog.getExceptionMessage(e, TotalBatches);
            
            throw e;
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        if('Y' == System.Label.BATCH_LOG_USE) {
            UTIL_BatchLog.finishLog(LogExternalKey, TotalBatches, BatchesProcessed, BatchesFailed, TotalRows, RowsProcessed, RowsFailed, ResultMessage);
        }
    }
}