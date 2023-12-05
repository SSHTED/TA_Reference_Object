/**
* Desc : SupportSiteController
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
*  1. | 2019-08-28 | Ye-Seul, Jin  | getFAQ 쿼리 수정
*/

global class SupportSiteController {
    
    @RemoteAction
    global static String insertRequestQ(String jsonData) {
        
        Map<String, Object> resMap = (map<String, Object>) JSON.deserializeUntyped(jsonData); 
        
        System.debug('resMap' + resMap);
        
        Support_Manager_Queues__c result = new Support_Manager_Queues__c();
        result = new Support_Manager_Queues__c (
            Channel__c = 'Site'
            , Name = (String)resMap.get('Title')
            , Request_Date__c = DateTime.now()
            , Requester__c = (String)resMap.get('Requester')
            , Requester_Email__c = (String)resMap.get('RequesterEmail')
            , Requester_Phone__c = (String)resMap.get('RequesterPhone')
            , Request_Type__c = (String)resMap.get('RequestType')
            , Emergency__c = (String)resMap.get('Emergency')
            , Request_Content__c = (String)resMap.get('RequestContent')
            , Customer__c = (String)resMap.get('Customer')
        );
        
        insert result;
        
        return result.id;
    }
    
    @RemoteAction
    global static String insertContentDocument(string id, string JsonFile) {
        
        system.debug('In');
        List<ContentVersion> verList = new List<ContentVersion>();
        set<id> verId = new set<id>();
        
        Map<String,Object> file = (Map<String,Object>) JSON.deserializeUntyped(JsonFile);
        
        ContentVersion ver = new ContentVersion();
        ver.versionData = EncodingUtil.base64Decode(string.valueOf(file.get('data')));
        ver.title = (string) file.get('path');
        ver.pathOnClient = (string) file.get('path');
        
        system.debug('id : '+id+', file : '+file);
        insert ver;
        
        ContentDocument cd = [SELECT Id, LatestPublishedVersionId 
                              FROM ContentDocument 
                              WHERE LatestPublishedVersionId =: ver.id];
        
        List<ContentDocumentLink> clList = new List<ContentDocumentLink>();
        
        ContentDocumentLink cl = new ContentDocumentLink();
        cl.LinkedEntityId = id;
        cl.ContentDocumentId = cd.Id;
        cl.ShareType = 'I';
        
        insert cl;
        
        
        
        // Queue에서 Support Manager로 바로 Insert 되었을 경우 queue와 동일하게 링크시켜준다.
        List<Support_Manager__c> smanager = [SELECT Id, Support_Manager_Queues__r.Id
                                       FROM Support_Manager__c 
                                       WHERE Support_Manager_Queues__r.Id = :id];
        if(smanager.size() != 0) {
            ContentDocumentLink cdlink = new ContentDocumentLink();
            cdlink.ContentDocumentId = cl.ContentDocumentId;
            cdlink.LinkedEntityId = smanager[0].Id;
            cdlink.ShareType = 'V';
            cdlink.Visibility = 'AllUsers';
            insert cdlink;
        }
        

        
        
        
        
        string result = 'Success';
        return result;
    }
    
    @RemoteAction
    public static List<Support_FAQ__c> getFAQ() {
        
        return [SELECT Name, Content__c , Sort_Order__c
                FROM Support_FAQ__c
                WHERE IsActive__c = true
                ORDER BY Sort_Order__c ASC NULLS LAST];
    }
    
}