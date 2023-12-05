/**
 * @Class : INF_Connector_Org_Kmtc
 *
 * @Method : 
 *	- @HttpPost doPost()
 *	- StringToDatetime(dt)
 *	- StringToDate(dt)
 * 
 * @Author : Yong-Jin, Cha
 * @Date : 2023-07-10
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2023-07-10 | Yong-Jin, Cha | 최초작성
 */
@RestResource(urlmapping = '/org-kmtc/*')
global without sharing class INF_Connector_Org_Kmtc {
    
    @HttpPost
    global static PostResultWrap doPost() {

        PostResultWrap result = new PostResultWrap();

        RestRequest request = RestContext.request;
        
        String reqURI = request.requestURI;
        String uriType = reqURI.substring(reqURI.lastIndexOf('/')+1);

        System.debug('# reqURI : ' + reqURI);
        System.debug('# uriType : ' + uriType);

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

        Customer_Org__c customerOrg = [select Id, Customer__c from Customer_Org__c where Name = '고려해운' limit 1];

        List<PMS_Project__c> projectList = [
            select 
                Id
            from
                PMS_Project__c 
            where
                EndCustomer__c = :customerOrg.Customer__c
            and Status__c = 'Active'
            and ContractStartDate__c <= today
            and ContractEndDate__c >= today
            limit 1
        ];

        Id CustomerOrgId = customerOrg.Id;
        Id projectId = projectList.size() > 0 ? projectList.get(0).Id : null;

        String title = String.valueOf(m.get('title'));
        String rId = String.valueOf(m.get('rId'));
        String rNo = String.valueOf(m.get('rNo'));
        String requester = String.valueOf(m.get('requester'));

        String rType = convertRequirementType(String.valueOf(m.get('rType')));
        String importance = convertImportance(String.valueOf(m.get('importance')));
        String status = convertStatus(String.valueOf(m.get('status')));        
        
        Datetime reqDate = m.get('reqDate') == null || String.valueOf(m.get('reqDate')) == '' ? null : parseDatetime((String)m.get('reqDate'));
        Date deadline = m.get('deadline') == null || String.valueOf(m.get('deadline')) == '' ? null : parseDate((String)m.get('deadline'));

        Decimal expectedDays = m.get('expectedDays') == null || String.valueOf(m.get('expectedDays')) == '' ? null : Decimal.valueOf(m.get('expectedDays')+'');
        Decimal actualDays = m.get('actualDays') == null || String.valueOf(m.get('actualDays')) == '' ? null : Decimal.valueOf(m.get('actualDays')+'');

        Date startDate = m.get('startDate') == null || String.valueOf(m.get('startDate')) == '' ? null : parseDate((String)m.get('startDate'));
        Date endDate = m.get('endDate') == null || String.valueOf(m.get('endDate')) == '' ? null : parseDate((String)m.get('endDate'));

        Support_Manager__c sm = new Support_Manager__c(
            Name = title
            , Customer_Org__c = CustomerOrgId
            , PMS_Project__c = projectId
            , Request_Date__c = reqDate
            , Request_Deadline__c = deadline
            , Request_Content__c = '** 상세 내용은 고객사 Org에서 확인 **'
            , Processing_Content__c = '** 상세 내용은 고객사 Org에서 확인 **'
            , Requester__c = requester
            , Request_Type__c = rType
            , Customer__c = '고려해운'
            , State__c = status
            , Channel__c = 'Customer System'
            , Person_In_Charge__c = null
            , Request_No__c = rNo
            , Ext_SR_Key__c = rId
            , Expected_MM__c = expectedDays
            , Actual_MM__c = actualDays
            , Emergency__c = importance
            , Start_Date__c = startDate
            , Close_Date__c = endDate
            , OwnerId = System.Label.INF_CONNECTOR_ORG_KMTC_OWNER
        );

        upsert sm Ext_SR_Key__c;

        result.RequestCode = '200';
        result.Message = 'OK';
        
        return result;

    }

    // 2023-04-06T08:41:09.396+09:00
    // private static DateTime StringToDatetime(String dt) {

    //     if(dt == null || dt == 'null')  return null;

    //     String DateStr = dt.substring(0, 10);
        
    //     Integer year = Integer.valueOf(DateStr.substring(0, 4));
    //     Integer month = Integer.valueOf(DateStr.substring(5, 7));
    //     Integer day = Integer.valueOf(DateStr.substring(8, 10));

    //     String TimeStr = dt.substring(11, 19);

    //     Integer hour = Integer.valueOf(TimeStr.substring(0, 2));
    //     Integer minute = Integer.valueOf(TimeStr.substring(3, 5));
    //     Integer second = Integer.valueOf(TimeStr.substring(6, 8));

    //     return DateTime.newInstanceGMT(year, month, day, hour, minute, second).addHours(-9);
    // }

    // 20230711120000
    private static DateTime parseDatetime(String dt) {
        Integer year = Integer.valueOf(dt.substring(0, 4));
        Integer month = Integer.valueOf(dt.substring(4, 6));
        Integer day = Integer.valueOf(dt.substring(6, 8));

        String TimeStr = dt.substring(8, 14);

        Integer hour = Integer.valueOf(TimeStr.substring(0, 2));
        Integer minute = Integer.valueOf(TimeStr.substring(2, 4));
        Integer second = Integer.valueOf(TimeStr.substring(4, 6));

        return DateTime.newInstanceGMT(year, month, day, hour, minute, second).addHours(-9);
    } 

    // 20230714
    private static Date parseDate(String dt) {
        Integer y = Integer.valueOf(dt.substring(0, 4));
        Integer m = Integer.valueOf(dt.substring(4, 6));
        Integer d = Integer.valueOf(dt.substring(6, 8));        
        return date.newinstance(y, m, d);
    } 

    // 2023-07-14
    // private static Date StringToDate(String dt) {

    //     if(dt == null || dt == 'null')  return null;

    //     String DateStr = dt.substring(0, 10);
        
    //     Integer year = Integer.valueOf(DateStr.substring(0, 4));
    //     Integer month = Integer.valueOf(DateStr.substring(5, 7));
    //     Integer day = Integer.valueOf(DateStr.substring(8, 10));

    //     return Date.newInstance(year, month, day);
    // }
    
    private static String convertRequirementType(String rt) {
        String returnRT = '';

        if(rt == 'Simple inquiry')              returnRT = '단순문의';
        else if(rt == 'Change request')         returnRT = '변경요청';
        else if(rt == 'Expansion requirement')  returnRT = '확장요건';
        else if(rt == 'Disability request')     returnRT = '장애요청';
        else if(rt == 'Emergency disability')   returnRT = '긴급장애';

        return returnRT;
    }

    private static String convertImportance(String importance) {
        String returnImportance = '';

        if(importance == 'Very high')       returnImportance = '최상';
        else if(importance == 'High')       returnImportance = '상';
        else if(importance == 'Middle')     returnImportance = '중';
        else if(importance == 'Low')        returnImportance = '하';

        return returnImportance;
    }

    private static String convertStatus(String status) {
        String returnStatus = '';

        if(status == 'Receipt')                                 returnStatus = '접수';
        else if(status == 'Assign person in charge')            returnStatus = '담당자 할당';
        else if(status == 'In progress')                        returnStatus = '처리 중';
        else if(status == 'Development completed (Sandbox)')    returnStatus = '개발완료(Sandbox)';
        else if(status == 'User testing')                       returnStatus = '사용자 테스트';
        else if(status == 'Waiting for customer reply')         returnStatus = '사용자 테스트';
        else if(status == 'Hold')                               returnStatus = '반려';
        else if(status == 'Cancel')                             returnStatus = '반려';
        else if(status == 'Complete')                           returnStatus = '완료';

        return returnStatus;
    }

    global class PostResultWrap {
        global String RequestCode;
        global String Message;
    }
}