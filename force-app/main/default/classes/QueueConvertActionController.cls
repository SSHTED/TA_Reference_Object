/*
* @Desc : QueueConvertActionController
* @Author : Yeseul.Jin
* @Date : 2019-09-02
* @Version : 1.0
* 
* @Method :
*  - 
* 
* @Modified : 
* 	---------------------------------------------
* 	NO | Date       | Modifier      | Description 
* 	---------------------------------------------
* 	1. | 2019-09-03 | Yeseul.Jin    | 최초작성
*/
public without sharing class QueueConvertActionController {
    
    @AuraEnabled
    public static Map<String, Object> getInfo(String recordId) {
        
        Map<String, Object> resultMap = new Map<String, Object>();
        
        resultMap.put('userInfo', getUserInfo());
        resultMap.put('personInCharge', getPersonInCharge(recordId));
        resultMap.put('csmList', getCSMList());
        resultMap.put('queuesDetail', getQueuesDetail(recordId));
        resultMap.put('emergencyPickList', getEmergencyPickList());
        resultMap.put('requestTypePickList', getRequestTypePickList());
        
        return resultMap;
    }
    
    private static Support_Manager_Queues__c getQueuesDetail(String recordId) {
        return [
            SELECT
            	Id
            	, Name
            	, Customer_Org__c
            	, Request_Content__c
            	, Record_Id__c
            	, Request_Date__c
            	, Channel__c
            	, Requester_Email__c
            	, Customer__c
            	, Requester__c
                , Emergency__c
            	, Request_Type__c
            	, Reception_Status__c
            	, ApprovalStatus__c
           	FROM
            	Support_Manager_Queues__c
            WHERE
            	Id = :recordId
            limit 1
        ];
    }
    
    private static User getUserInfo() {
        
        User u = [
            SELECT
            	Id
            	, Name
            	, Username
            	, UserRoleId
            	, UserRole.Name
            	, SupportManagerIsActive__c
           	FROM
            	User
            WHERE
            	Id = :System.UserInfo.getUserId()
        ];
        
        return u;
    }
   
    private static List<SelectOptions> getPersonInCharge(String recordId) {
        
        List<SelectOptions> opt = new List<SelectOptions>();
        
        List<Support_Assign_Rule__c> li = [
            SELECT 
            	Id
            	, Name
            	, Person_In_Charge__c
            	, Sub_Person_In_Charge__c
            	, Sub_Person_In_Charge2__c
            	, Sub_Person_In_Charge3__c
            	, Sub_Person_In_Charge4__c
            	, Person_In_Charge__r.Name
            	, Sub_Person_In_Charge__r.Name
            	, Sub_Person_In_Charge2__r.Name
            	, Sub_Person_In_Charge3__r.Name
            	, Sub_Person_In_Charge4__r.Name
            	, Person_In_Charge__r.Title
            	, Sub_Person_In_Charge__r.Title
            	, Sub_Person_In_Charge2__r.Title
            	, Sub_Person_In_Charge3__r.Title
            	, Sub_Person_In_Charge4__r.Title
            	, Customer_Org__c
            	, Customer_Org__r.Name
            FROM 
            	Support_Assign_Rule__c
            WHERE
            	Customer_Org__c in (select Customer_Org__c from Support_Manager_Queues__c where Id = :recordId)
            Order by 
            	Customer_Org__r.Name
            	, Person_In_Charge__r.Name
        ];
        
        if(li.size() == 1) {
            Support_Assign_Rule__c sar = li.get(0);
            opt.add(new SelectOptions(sar.Person_In_Charge__c, sar.Person_In_Charge__r.Name + ' ' + sar.Person_In_Charge__r.Title));
            if(sar.Sub_Person_In_Charge__c != null)		opt.add(new SelectOptions(sar.Sub_Person_In_Charge__c, sar.Sub_Person_In_Charge__r.Name + ' ' + sar.Sub_Person_In_Charge__r.Title));
            if(sar.Sub_Person_In_Charge2__c != null)	opt.add(new SelectOptions(sar.Sub_Person_In_Charge2__c, sar.Sub_Person_In_Charge2__r.Name + ' ' + sar.Sub_Person_In_Charge2__r.Title));
            if(sar.Sub_Person_In_Charge3__c != null)	opt.add(new SelectOptions(sar.Sub_Person_In_Charge3__c, sar.Sub_Person_In_Charge3__r.Name + ' ' + sar.Sub_Person_In_Charge3__r.Title));
            if(sar.Sub_Person_In_Charge4__c != null)	opt.add(new SelectOptions(sar.Sub_Person_In_Charge4__c, sar.Sub_Person_In_Charge4__r.Name + ' ' + sar.Sub_Person_In_Charge4__r.Title));
        }
        
        return opt;
    }
    
    private static List<SelectOptions> getCSMList() {
        
        List<SelectOptions> opt = new List<SelectOptions>();
        
        List<User> li = [
            SELECT
            	Id
            	, Name
            	, Username
            	, UserRoleId
            	, UserRole.Name
            	, Title
           	FROM
            	User
            WHERE
            	IsCSM__c = true
            and IsActive = true
            order by 
            	Name 
        ];
        
        if(li.size() > 0) {
            for(User u : li) {
				opt.add(new SelectOptions(u.Id, u.Name + ' ' + u.Title));
            }            
        }
        
        return opt;
    }
    
    private static List<SelectOptions> getEmergencyPickList() {

        List<SelectOptions> opt = new List<SelectOptions>();
        Schema.PicklistEntry[] pes = Schema.SObjectType.Support_Manager_Queues__c.fields.Emergency__c.PicklistValues;
        for(Schema.PicklistEntry pi : pes) {
            opt.add(new SelectOptions(pi.getValue(), pi.getLabel()));
        }     
        
        return opt;
    }
    
    private static List<SelectOptions> getRequestTypePickList() {

        List<SelectOptions> opt = new List<SelectOptions>();
        Schema.PicklistEntry[] pes = Schema.SObjectType.Support_Manager_Queues__c.fields.Request_Type__c.PicklistValues;
        for(Schema.PicklistEntry pi : pes) {
            opt.add(new SelectOptions(pi.getValue(), pi.getLabel()));
        }     
        
        return opt;
    }
    
    @AuraEnabled
    public static void UpdateSupportManagerQueues(String recordId, String chargeId, String requestType, String emergency) {
        try{
            Support_Manager_Queues__c queue = [
                SELECT
                	Id
                	, Name
                	, Customer_Org__c
                	, Request_Content__c
                	, Record_Id__c
                	, Request_Date__c
                	, Channel__c
                	, Requester_Email__c
                	, Customer__c
                	, Requester__c
                    , Emergency__c
                	, Request_Type__c
                	, Request_Deadline__c
                	, Request_Title__c
                FROM
                	Support_Manager_Queues__c
                WHERE
                	Id = :recordId
            ];
                       
            String orgName = [SELECT Id, Customer__r.Name FROM Customer_Org__c WHERE Id = :queue.Customer_Org__c].Customer__r.Name;
            
            Support_Manager__c smanager = new Support_Manager__c(
                Name = queue.Request_Title__c
                , Request_No__c = queue.Name
                , OwnerId = chargeId
                , Person_In_Charge__c = chargeId	// param
                , Customer__c = orgName
                , Request_Type__c = requestType		// param
                , Emergency__c = emergency	// param
                , Requester_Email__c = queue.Requester_Email__c
                , Customer_Org__c = queue.Customer_Org__c
                , Request_Content__c = queue.Request_Content__c
                , Record_Id__c = queue.Record_Id__c
                , Requester__c = queue.Requester__c
                , Request_Date__c = queue.Request_Date__c
                , Channel__c = queue.Channel__c
                , Support_Manager_Queues__c = queue.Id
                , Request_Deadline__c = queue.Request_Deadline__c
                , State__c = '담당자 할당'
            );
            
            insert smanager;
            saveAttachment(smanager.Id, queue.Id);
        }
        catch(Exception e) {
            e.setMessage('ERROR');
        }
    }
    
    private static void saveAttachment(ID smanagerId, ID queueId) {
        //Support_Manager_Queues__c로부터 저장된 첨부파일의 LinkedEntityId를 가져와 Support_Manager__c도 동일하게 Link
        List<ContentDocumentLink> cdId = [SELECT Id, ContentDocumentId
                                          FROM ContentDocumentLink
                                          WHERE LinkedEntityId = :queueId];
        
        List<ContentDocumentLink> cdlist = new List<ContentDocumentLink>();
        
        for(ContentDocumentLink cl : cdId) { 
            ContentDocumentLink cdlink = new ContentDocumentLink();
            cdlink.ContentDocumentId = cl.ContentDocumentId;
            cdlink.LinkedEntityId = smanagerId;
            cdlink.ShareType = 'V';
            cdlink.Visibility = 'AllUsers';
            cdlist.add(cdlink);
        }
        insert cdlist;
    }
    
    public class SelectOptions {
        @AuraEnabled public String value {set;get;}
        @AuraEnabled public String label {set;get;}
        
        public SelectOptions(String val, String lbl) {
            value = val;
            label = lbl;
        }
    }
}