/**
 * @Class : CX_OmniChannelController
 *
 * @Method : 
 * 
 * @Author : Yong-Jin, Cha
 * @Date : 2023-10-25
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2023-10-25 | Yong-Jin, Cha | 최초작성
 */
global without sharing class CX_OmniChannelController {

    @AuraEnabled(cacheable=true)
    global static Map<String, Object> getInit() {

        Map<String, Object> resultMap = new Map<String, Object>();

        List<comboBox> statusPV = new List<comboBox>();
        for(Schema.PicklistEntry pi : Schema.SObjectType.User.fields.Processable_Status__c.PicklistValues) {
            statusPV.add(new comboBox(pi.getLabel(), pi.getValue()));
        }

        resultMap.put('statusPV', statusPV);

        return resultMap;
    }

    @AuraEnabled
    global static Map<String, Object> getEmployeeInfo() {

        Map<String, Object> resultMap = new Map<String, Object>();

        String uId = System.UserInfo.getUserId();

        List<Employee__c> li = [
            select
                Id
                , Name
                , Work_Time__c
                , toLabel(WS_OnDutyStatus__c)
                , toLabel(WS_ActiveStatus__c)
                , WS_EventDesc__c
                , WS_Position__c
                , OrganizationId__r.Name
                , User__c
                , User__r.Processable_Status__c
                , User__r.SmallPhotoUrl
            from
                Employee__c
            where
                User__c = :uId
            limit 1
        ];

        if(li.size() == 1) {
            Employee__c emp = li.get(0);
            resultMap.put('uId', uId);
            resultMap.put('empId', emp.Id);
            resultMap.put('empName', emp.Name);
            resultMap.put('empOrgName', emp.OrganizationId__r.Name);
            resultMap.put('empWorkTime', emp.Work_Time__c);
            resultMap.put('empWS_ActiveStatus', emp.WS_ActiveStatus__c);
            resultMap.put('empWS_OnDutyStatus', emp.WS_OnDutyStatus__c);
            resultMap.put('empWS_EventDesc', emp.WS_EventDesc__c);
            resultMap.put('empWS_Position', emp.WS_Position__c);
            resultMap.put('processableStatus', emp.User__r.Processable_Status__c);
            resultMap.put('photoUrl', emp.User__r.SmallPhotoUrl);
        }

        return resultMap;
    }

    @AuraEnabled
    global static Map<String, Object> getTasks() {

        Map<String, Object> resultMap = new Map<String, Object>();

        Set<String> exceptStatusSet = new Set<String> {'반려', '취소', '완료'};
        Set<String> completeStatusSet = new Set<String> {'완료'};

        String uId = System.UserInfo.getUserId();

        String SOQL = ' select  '
                    + '     Id '
                    + '     , Name '
                    + '     , Actual_Days__c '
                    + '     , Actual_MM__c '
                    + '     , Actual_Work_MM__c '
                    + '     , Calculated_MD__c '
                    + '     , Channel__c '
                    + '     , Close_Date__c '
                    + '     , Customer__c '
                    + '     , Customer_Category__c '
                    + '     , Customer_Org__c '
                    + '     , Detail_State__c '
                    + '     , Difficulty__c '
                    + '     , Email_Reply__c '
                    + '     , Emergency__c '
                    + '     , Estimated_duration__c '
                    + '     , ExceededDays__c '
                    + '     , Expected_MM__c '
                    + '     , Ext_SR_Key__c '
                    + '     , Flag__c '
                    + '     , FM_DelayCheck__c '
                    + '     , FM_Person_In_Charge__c '
                    + '     , FM_QATarget__c '
                    + '     , FM_Team__c '
                    + '     , FM_YearMonth__c '
                    + '     , ImplementType__c '
                    + '     , Importance__c '
                    + '     , Leader_Actual_Work_MD__c '
                    + '     , OperationLeader__c '
                    + '     , ORG_ID__c '
                    + '     , Parent_Support_Manager__c '
                    + '     , Person_In_Charge__c '
                    + '     , PMS_Project__c '
                    + '     , Priority__c '
                    + '     , Processing_Content__c '
                    + '     , Production_Apply__c '
                    + '     , Production_Apply_Date__c '
                    + '     , ProjectStatusCheck__c '
                    + '     , QA_Check__c '
                    + '     , Record_Id__c '
                    + '     , Related_Case__c '
                    + '     , Related_Sources__c '
                    + '     , Request_Content__c '
                    + '     , Request_Date__c '
                    + '     , Request_Deadline__c '
                    + '     , Request_No__c '
                    + '     , Request_Type__c '
                    + '     , Requester__c '
                    + '     , Requester_Email__c '
                    + '     , Requester_Phone__c '
                    + '     , Sandbox_Apply__c '
                    + '     , Sandbox_Apply_Date__c '
                    + '     , SR_No__c '
                    + '     , Start_Date__c '
                    + '     , State__c '
                    + '     , State_For_Email__c '
                    + '     , Sub_Request_Type__c '
                    + '     , UseMMCount__c '
                    + '     , FM_Customer_OrgName__c '
                    + '     , FM_OperationLeaderName__c '
                    + ' from '
                    + '     Support_Manager__c ';

        String ADD1 = ' where State__c not in :exceptStatusSet and OperationLeader__c = :uId ';     // 운영리더로 쿼리
        String ADD2 = ' where State__c not in :exceptStatusSet and Person_In_Charge__c = :uId ';    // 담당자로 쿼리
        String ADD3 = ' where State__c in :completeStatusSet and (OperationLeader__c = :uId OR Person_In_Charge__c = :uId) and (Expected_MM__c = null OR Actual_MM__c = null)';

        String ORDS = ' order by Request_Deadline__c nulls last, Request_Date__c desc';

        resultMap.put('Leaders', Database.query(SOQL + ADD1 + ORDS));
        resultMap.put('TaskOwners', Database.query(SOQL + ADD2 + ORDS));
        resultMap.put('NotInputMDs', Database.query(SOQL + ADD3 + ORDS));

        return resultMap;
    }

    @AuraEnabled
    global static Boolean saveProcessableStatus(String statusVal) {

        Boolean result = true;
        String uId = System.UserInfo.getUserId();

        try {
            User u = [select Id, Processable_Status__c from User where Id = :uId limit 1];
            u.Processable_Status__c = statusVal;
            update u;
        } catch(Exception e) {
            result = false;
            System.debug(e);
        }

        return result;       
    }

    

    global class comboBox {
        
        @AuraEnabled global String label {get;set;} 
        @AuraEnabled global String value {get;set;}

        global comboBox(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}