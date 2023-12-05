/**
 * @Class : HR_OrgUpdateBatch
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
 */
public class HR_OrgUpdateBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

    public String BatchName = 'HR_OrgUpdateBatch';                      // 배치명
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
    public String SERVICE_API = System.Label.WS_ORG_TEAM_API;           // 조직도 팀 조회 API

    public Map<String, String> orgNameMap = new Map<String, String>();  // 조직 이름으로 맵 생성
    public Map<String, String> orgWSMap = new Map<String, String>();    // 조직 WS 아이드로 맵 생성

    Set<String> wsKeySet = new set<String>();                           // 활성 중인 조직 ID Set

    public HR_OrgUpdateBatch() {
        SERVICE_API = String.format(SERVICE_API, new String[]{API_KEY});

        // 조직
        List<Organization__c> orgList = [
            select 
                Id
                , Name
                , WS_TeamId__c
            from
                Organization__c
        ];
        
        for(Organization__c p : orgList) {
            orgNameMap.put(p.Name, p.Id);

            if(p.WS_TeamId__c != null) {
                orgWSMap.put(p.WS_TeamId__c, p.Id);
            }
        }
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC) {

        if('Y' == System.Label.BATCH_LOG_USE) {
            LogExternalKey = UTIL_BatchLog.startLog(BatchName, OrgInfo);
        }
        
        String SOQL = ' SELECT '
                    + ' 	Id '
                    + ' FROM '
                    + ' 	User '
            		+ '	limit 1 ';
        
        return Database.getQueryLocator(SOQL);
    }
    
    public void execute(Database.BatchableContext BC, List<User> scope) {

        Integer batchSize = scope.size();
        TotalBatches++;
        TotalRows += batchSize;
        
        try {

            Httprequest httpReq = new Httprequest();
            HttpResponse httpRes = new HttpResponse();
            Http http = new Http();
    
            String resBody = null;
    
            httpReq.setMethod('GET');
            httpReq.setEndpoint(ENDPOINT + SERVICE_API);                      
            httpReq.setTimeout(120000);                   
            httpReq.setHeader('Authorization', API_SECRET_KEY);
            httpReq.setHeader('Content-Type', 'application/json');
            httpReq.setHeader('Accept', 'application/json');
    
            if(!Test.isRunningTest()) {
                httpRes = http.send(httpReq);           
            } else {
                String blStr= '[{"team_id":27315,"team_name":"1팀","team_parent":27299,"team_nums":0,"team_leader_email":null,"team_charger_email":"sunju.park@dkbmc.com"},{"team_id":27316,"team_name":"2팀","team_parent":27299,"team_nums":0,"team_leader_email":null,"team_charger_email":"sunju.park@dkbmc.com"}]';
                Blob bl = Blob.valueof(blStr);
                httpRes.setBody(blStr);
                httpRes.setStatusCode(200);
            }
            resBody = httpRes.getBody();          
    
            System.debug('** resBody : ' + resBody);
            
            List<Object> dataList = (List<Object>)JSON.deserializeUntyped(resBody);

            List<Organization__c> updateWSList = new List<Organization__c>();
                        
            for(Object o : dataList) {
                Map<String, Object> item = (Map<String, Object>)o;

                String teamId = String.valueOf(item.get('team_id'));
                String teamName = String.valueOf(item.get('team_name'));
                String teamParent = String.valueOf(item.get('team_parent'));
                Decimal teamNums = Decimal.valueOf(String.valueOf(item.get('team_nums')));
                String teamChargerEmail = String.valueOf(item.get('team_charger_email'));
                String teamLeaderEmail = String.valueOf(item.get('team_leader_email'));

                System.debug('# team_id            : ' + teamId);
                System.debug('# team_name          : ' + teamName);
                System.debug('# team_parent        : ' + teamParent);
                System.debug('# team_nums          : ' + teamNums);
                System.debug('# team_leader_email  : ' + teamChargerEmail);
                System.debug('# team_charger_email : ' + teamLeaderEmail);
                System.debug('# ---------------------------------------------');

                if(orgWSMap.get(teamId) == null) {
                    if(orgNameMap.get(teamName) == null) {
                        Organization__c orgInfo = new Organization__c(
                            Name = teamName
                            , IsActive__c = true
                            , WS_TeamId__c = teamId
                            , WS_TeamName__c = teamName
                            , WS_TeamParentId__c = teamParent
                            , WS_TeamNums__c = teamNums
                            , WS_ChargerEmail__c = teamChargerEmail              
                            , WS_LeaderEmail__c = teamLeaderEmail
                        );
                        updateWSList.add(orgInfo);
                    } else {
                        String sfId = orgNameMap.get(teamName);
                        Organization__c orgInfo = new Organization__c(
                            Id = sfId
                            , Name = teamName
                            , IsActive__c = true
                            , WS_TeamId__c = teamId
                            , WS_TeamName__c = teamName
                            , WS_TeamParentId__c = teamParent
                            , WS_TeamNums__c = teamNums
                            , WS_ChargerEmail__c = teamChargerEmail            
                            , WS_LeaderEmail__c = teamLeaderEmail
                        );
                        updateWSList.add(orgInfo);
                    }
                } else {
                    String sfId2 = orgWSMap.get(teamId);
                    Organization__c orgInfo = new Organization__c(
                        Id = sfId2
                        , Name = teamName
                        , IsActive__c = true
                        , WS_TeamId__c = teamId
                        , WS_TeamName__c = teamName
                        , WS_TeamParentId__c = teamParent
                        , WS_TeamNums__c = teamNums
                        , WS_ChargerEmail__c = teamChargerEmail              
                        , WS_LeaderEmail__c = teamLeaderEmail
                    );
                    updateWSList.add(orgInfo);
                }
            }
            
            BatchesProcessed++;
            RowsProcessed += batchSize;

            System.debug(updateWSList);

            upsert updateWSList;

            for(Organization__c o : updateWSList) {
                wsKeySet.add(o.ID);
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

        List<Organization__c> InActiveOrgList = [select Id, IsActive__c from Organization__c where Id not in :wsKeySet];

        for(Organization__c org : InActiveOrgList) {
            org.IsActive__c = false;
        }

        update InActiveOrgList;

        Map<String, String> orgWSIdMap = new Map<String, String>();  // 부모조직ID로 맵 생성

        List<Organization__c> orgList = [select Id, WS_TeamId__c, WS_TeamParentId__c, ParentOrgId__c from Organization__c where WS_TeamId__c != null];

        for(Organization__c org : orgList) {
            orgWSIdMap.put(org.WS_TeamId__c, org.Id);
        }

        for(Organization__c org : orgList) {
            if(orgWSIdMap.get(org.WS_TeamParentId__c) != null && orgWSIdMap.get(org.WS_TeamParentId__c) != org.ParentOrgId__c) {
                org.ParentOrgId__c = orgWSIdMap.get(org.WS_TeamParentId__c);
            }
        }

        update orgList;
    }
}