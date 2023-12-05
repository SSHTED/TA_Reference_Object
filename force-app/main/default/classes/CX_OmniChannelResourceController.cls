/**
 * @Class : CX_OmniChannelResourceController
 *
 * @Method : 
 * 
 * @Author : Yong-Jin, Cha
 * @Date : 2023-11-12
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2023-11-12 | Yong-Jin, Cha | 최초작성
 */
global without sharing class CX_OmniChannelResourceController {

    @AuraEnabled(cacheable=true)
    global static Map<String, Object> getInit() {

        Map<String, Object> resultMap = new Map<String, Object>();

        String uId = System.UserInfo.getUserId();

        // CX등급
        List<CX_OmniChannelController.comboBox> cxGradePV = new List<CX_OmniChannelController.comboBox>();

        cxGradePV.add(new CX_OmniChannelController.comboBox('전체', ''));

        for(Schema.PicklistEntry pi : Schema.SObjectType.Employee__c.fields.CXGrade__c.PicklistValues) {
            cxGradePV.add(new CX_OmniChannelController.comboBox(pi.getLabel(), pi.getValue()));
        }

        resultMap.put('cxGradePV', cxGradePV);

        // 근무시간
        List<CX_OmniChannelController.comboBox> workTimePV = new List<CX_OmniChannelController.comboBox>();

        workTimePV.add(new CX_OmniChannelController.comboBox('전체', ''));

        for(Schema.PicklistEntry pi : Schema.SObjectType.Employee__c.fields.Work_Time__c.PicklistValues) {
            workTimePV.add(new CX_OmniChannelController.comboBox(pi.getLabel(), pi.getValue()));
        }

        resultMap.put('workTimePV', workTimePV);

        // 처리가능상태
        List<CX_OmniChannelController.comboBox> statusPV = new List<CX_OmniChannelController.comboBox>();

        statusPV.add(new CX_OmniChannelController.comboBox('전체', ''));

        for(Schema.PicklistEntry pi : Schema.SObjectType.User.fields.Processable_Status__c.PicklistValues) {
            statusPV.add(new CX_OmniChannelController.comboBox(pi.getLabel(), pi.getValue()));
        }

        resultMap.put('statusPV', statusPV);

        // 내 담당자
        List<CX_OmniChannelController.comboBox> picPV = new List<CX_OmniChannelController.comboBox>();

        List<User> uList = [
            select 
                Id
                , (select CustomerOrgId__r.Name from Customer_Org_Assign__r)
            from
                User
            where Id in (
                select
                    PersonInChargeId__c
                from
                    Customer_Org_Assign__c
                where
                    CustomerOrgId__r.OperationLeaderId__c = :uId
            )
        ];

        Map<String, String> userMap = new Map<String, String>();

        for(User u : uList) {
            Integer i = 0;
            String org = '(';
            for(Customer_Org_Assign__c coa : u.Customer_Org_Assign__r) {
                System.debug(coa.CustomerOrgId__r.Name);
                if(i != 0) org += ', ';
                org += coa.CustomerOrgId__r.Name;
                i++;
            }
            org += ')';
            userMap.put(u.Id, org);
        }

        Integer isSharedCount = [select count() from Customer_Org__c where IsShared__c = true and OperationLeaderId__c = :uId];
    
        if(isSharedCount > 0) {
            for(Employee__c emp : [select User__c from Employee__c where IsShared__c = true]) {
                userMap.put(emp.User__c, '(Shared)');
            }
        }

        List<Employee__c> empList = [
            select
                Id
                , Name
                , Rank__c
                , Position__c
                , User__c
                , IsShared__c
                , OrganizationId__r.Name
                , User__r.Processable_Status__c
                , CxGrade__c
            from
                Employee__c
            where
                Status__c = '재직'
            and User__c in :userMap.keyset()
            order by 
                IsShared__c
                , Name
        ];

        picPV.add(new CX_OmniChannelController.comboBox('선택', ''));

        for(Employee__c pi : empList) {
            String name = pi.Name + ' ' + pi.Rank__c + ' / ' + pi.User__r.Processable_Status__c + ' / ' + pi.CxGrade__c + ' / ' + userMap.get(pi.User__c);
            picPV.add(new CX_OmniChannelController.comboBox(name, pi.User__c));
        }

        resultMap.put('picPV', picPV);

        // 고객지원 ORG
        List<CX_OmniChannelController.comboBox> customerOrgPV = new List<CX_OmniChannelController.comboBox>();

        customerOrgPV.add(new CX_OmniChannelController.comboBox('전체', ''));

        for(Customer_Org__c pi : [select Id, Name from Customer_Org__c where IsActive__c = true order by Name]) {
            customerOrgPV.add(new CX_OmniChannelController.comboBox(pi.Name, pi.Id));
        }

        resultMap.put('customerOrgPV', customerOrgPV);

        // 고객지원 관리 상태
        List<CX_OmniChannelController.comboBox> supportStatePV = new List<CX_OmniChannelController.comboBox>();

        supportStatePV.add(new CX_OmniChannelController.comboBox('전체', ''));

        for(Schema.PicklistEntry pi : Schema.SObjectType.Support_Manager__c.fields.State__c.PicklistValues) {
            supportStatePV.add(new CX_OmniChannelController.comboBox(pi.getLabel(), pi.getValue()));
        }

        resultMap.put('supportStatePV', supportStatePV);

        return resultMap;
    }

    @AuraEnabled
    global static Map<String, Object> getResources(String type, String filters) {

        Map<String, Object> resultMap = new Map<String, Object>();

        List<resourceWrap> allResourceList = new List<resourceWrap>();
        List<resourceWrap> myResourceList = new List<resourceWrap>();        

        Set<String> exceptStatusSet = new Set<String> {'취소', '반려', '완료'};
        Set<String> hqSet = new Set<String> {'CX본부', 'COO'};
        String duty_status = '재직';

        String uId = System.UserInfo.getUserId();

        Map<String, Decimal> cntByOLMap = new Map<String, Decimal>();
        Map<String, Decimal> cntByPICMap = new Map<String, Decimal>();

        List<AggregateResult> arList1 = [
            select
                OperationLeader__c uId
                , MAX(OperationLeader__r.Name)
                , count(Id) cnt
            from
                Support_Manager__c
            where
                State__c not in :exceptStatusSet
            and OperationLeader__c != null
            group by
                OperationLeader__c
        ];

        for(AggregateResult ar : arList1) {
            cntByOLMap.put(String.valueOf(ar.get('uId')), Decimal.valueOf(String.valueOf(ar.get('cnt'))));
        }

        List<AggregateResult> arList2 = [
            select
                Person_In_Charge__c uId
                , MAX(Person_In_Charge__r.Name)
                , count(Id) cnt
            from
                Support_Manager__c
            where
                State__c not in :exceptStatusSet
            and Person_In_Charge__c != null
            group by
                Person_In_Charge__c
        ];

        for(AggregateResult ar : arList2) {
            cntByPICMap.put(String.valueOf(ar.get('uId')), Decimal.valueOf(String.valueOf(ar.get('cnt'))));
        }

        Map<String, Object> filtersMap = (Map<String, Object>)JSON.deserializeUntyped(filters);

        String name = nullToNullString(filtersMap.get('name'));
        String cxGrade = nullToNullString(filtersMap.get('cxGrade'));
        String workTime = nullToNullString(filtersMap.get('workTime'));
        String status = nullToNullString(filtersMap.get('status'));

        String SOQL = ' select '
                    + '     Id '
                    + '     , Name '
                    + '     , Work_Time__c '
                    + '     , toLabel(WS_OnDutyStatus__c) '
                    + '     , toLabel(WS_ActiveStatus__c) '
                    + '     , WS_EventDesc__c '
                    + '     , WS_Position__c '
                    + '     , OrganizationId__r.Name '
                    + '     , User__c '
                    + '     , User__r.Processable_Status__c '
                    + '     , User__r.SmallPhotoUrl '
                    + '     , CXGrade__c '
                    + '     , Rank__c '
                    + '     , Position__c '
                    + ' from '
                    + '     Employee__c '
                    + ' where '
                    + '     Status__c = :duty_status '
                    + ' and FM_HQ__c in :hqSet ';

        if(String.isNotEmpty(name)) {
            SOQL += ' and Name like \'%' + name +'%\'';
        }

        if(String.isNotEmpty(cxGrade)) {
            SOQL += ' and CXGrade__c = :cxGrade ';
        }

        if(String.isNotEmpty(workTime)) {
            SOQL += ' and Work_Time__c = :workTime ';
        }

        if(String.isNotEmpty(status)) {
            SOQL += ' and User__r.Processable_Status__c = :status ';
        }

        Set<String> userSet = new Set<String>();

        List<Customer_Org_Assign__c> coaList = [
            select
                PersonInChargeId__c
            from
                Customer_Org_Assign__c
            where
                CustomerOrgId__r.OperationLeaderId__c = :uId
        ];

        for(Customer_Org_Assign__c coa : coaList) {
            userSet.add(coa.PersonInChargeId__c);
        }

        Integer isSharedCount = [select count() from Customer_Org__c where IsShared__c = true and OperationLeaderId__c = :uId];
    
        if(isSharedCount > 0) {
            for(Employee__c emp : [select User__c from Employee__c where IsShared__c = true]) {
                userSet.add(emp.User__c);
            }
        }

        String SQL2 = ' and User__c in :userSet ';

        String ORDS = ' order by Name ';

        if(null == type || 'all' == type) {
            for(Employee__c emp : Database.query(SOQL + ORDS)) {
                allResourceList.add(new resourceWrap(emp, cntByOLMap.get(emp.User__c), cntByPICMap.get(emp.User__c)));
            }
    
            resultMap.put('allResourceList', allResourceList);
        }
        
        if(null == type || 'my' == type) {
            for(Employee__c emp : Database.query(SOQL + SQL2 + ORDS)) {
                myResourceList.add(new resourceWrap(emp, cntByOLMap.get(emp.User__c), cntByPICMap.get(emp.User__c)));
            }
    
            resultMap.put('myResourceList', myResourceList);
        }

        if(null == type) {
            resultMap.put('notAssignedList', getNotAssignedTasks(null, null, null));
        }

        return resultMap;
    }

    @AuraEnabled
    global static List<Support_Manager__c> getNotAssignedTasks(String title, String customerOrg, String supportState) {

        String uId = System.UserInfo.getUserId();
        
        Set<String> exceptStatusSet = new Set<String> {'취소','반려', '완료'};

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
                    + '     Support_Manager__c '
                    + ' where State__c not in :exceptStatusSet '
                    + ' and (OperationLeader__c = null or OperationLeader__c = :uId) '  // 운영리더 본인 또는 없을 경우 
                    + ' and Person_In_Charge__c = null ';     
        if(String.isNotEmpty(title)) {
            SOQL += ' and Name like \'%' + title +'%\'';
        }
        if(String.isNotEmpty(customerOrg)) {
            SOQL += ' and Customer_Org__c = :customerOrg ';
        }
        if(String.isNotEmpty(supportState)) {
            SOQL += ' and State__c = :supportState ';
        }

        String ORDS = ' order by Request_Deadline__c nulls last, Request_Date__c desc';

        return Database.query(SOQL + ORDS);
    }

    @AuraEnabled
    global static List<Support_Manager__c> getTasks(String uId, String type) {

        Set<String> exceptStatusSet = new Set<String> {'취소', '반려', '완료'};

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
                    + '     Support_Manager__c '
                    + ' where State__c not in :exceptStatusSet ';
        if('operationLeader' == type) {
            SOQL += ' and OperationLeader__c = :uId ';     // 운영리더로 쿼리
        } else {
            SOQL += ' and Person_In_Charge__c = :uId ';    // 담당자로 쿼리
        }

        String ORDS = ' order by Request_Deadline__c nulls last, Request_Date__c desc';

        return Database.query(SOQL + ORDS);
    }

    @AuraEnabled
    global static Boolean saveAssignPIC(String srIds, String picId) {

        Boolean result = true;
        Set<String> idSet = new Set<String>();

        List<Object> srIdList = (List<Object>)JSON.deserializeUntyped(srIds);

        for(Object o : srIdList) {
            Map<String, Object> item = (Map<String, Object>) o;
            idSet.add(String.valueOf(item.get('key')));
        }

        try {
            List<Support_Manager__c> smList = [select Id, Person_In_Charge__c from Support_Manager__c where Id in :idSet and Person_In_Charge__c = null];
            for(Support_Manager__c sm : smList) {
                sm.Person_In_Charge__c = picId;
            }
            update smList;
        } catch(Exception e) {
            result = false;
            System.debug(e);
        }

        return result;       
    }

    private static String nullToNullString(object o) {
        return o == null ? null : String.valueOf(o);
    }

    global class resourceWrap {
        
        @AuraEnabled global String userId {get;set;}
        @AuraEnabled global String empId {get;set;} 
        @AuraEnabled global String empName {get;set;}
        @AuraEnabled global String empPosition {get;set;}
        @AuraEnabled global String workTime {get;set;}
        @AuraEnabled global String processableStatus {get;set;}
        @AuraEnabled global String wsOnDutyStatus {get;set;}
        @AuraEnabled global String wsActiveStatus {get;set;}
        @AuraEnabled global String wsEventDesc {get;set;}
        @AuraEnabled global String cxGrade {get;set;}
        @AuraEnabled global String orgName {get;set;}

        @AuraEnabled global Decimal srCount_OL {get;set;}
        @AuraEnabled global Decimal srCount_PIC {get;set;}

        global resourceWrap(Employee__c emp, Decimal cnt_OL, Decimal cnt_PIC) {
            this.userId = emp.User__c;
            this.empId = emp.Id;
            this.empName = emp.Name;
            this.empPosition = 'ㅤ' + emp.Rank__c + (emp.Position__c == null || emp.Position__c == '팀원' ? '' : '(' + emp.Position__c + ')');
            this.workTime = emp.Work_Time__c;
            this.processableStatus = emp.User__r.Processable_Status__c;
            this.wsOnDutyStatus = emp.WS_OnDutyStatus__c;
            this.wsActiveStatus = emp.WS_ActiveStatus__c;
            this.wsEventDesc = emp.WS_EventDesc__c;
            this.cxGrade = emp.CXGrade__c;
            this.orgName = emp.OrganizationId__r.Name;

            this.srCount_OL = cnt_OL == null ? 0 : cnt_OL;
            this.srCount_PIC = cnt_PIC == null ? 0 : cnt_PIC;
        }
    }
}