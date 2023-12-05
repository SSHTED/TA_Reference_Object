/**
 * @Class : CX_CustomerOrgAssignController
 *
 * @Method : 
 *	- @AuraEnabled getSearchFilters()
 *	-  getCustomerOrgList(isAllOption, AllOptionLabel)
 *	-  getUserList(isAllOption, AllOptionLabel)
 *	- @AuraEnabled getAssignViewList(orderType, orgId, userId)
 *	- @AuraEnabled getAssignEditList(orgId, userId)
 *	- @AuraEnabled saveData(orgId, userId, idArray)
 * 
 * @Author : Yong-Jin, Cha
 * @Date : 2023-11-23
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2023-11-23 | Yong-Jin, Cha | 최초작성
 */
global without sharing class CX_CustomerOrgAssignController {
    
    @AuraEnabled(cacheable=true)
    global static Map<String, Object> getSearchFilters() {
        
        Map<String, Object> resultMap = new Map<String, Object>();

        resultMap.put('isSandbox', UTIL_BatchLog.getOrganizationInfo().IsSandbox);
        resultMap.put('orgList', getCustomerOrgList(true, '전체'));
        resultMap.put('userList', getUserList(true, '전체'));

        //System.debug(resultMap);
        
        return resultMap;
    }

    global static List<CX_OmniChannelController.comboBox> getCustomerOrgList(Boolean isAllOption, String AllOptionLabel) {

        List<CX_OmniChannelController.comboBox> options = new List<CX_OmniChannelController.comboBox>();
        
        if(isAllOption) options.add(new CX_OmniChannelController.comboBox(AllOptionLabel, ''));

        String SOQL = ' select  '
                    + ' 	Id '
                    + ' 	, Name '
                    + ' from '
                    + ' 	Customer_Org__c '
                    + ' where '
			        + '     IsActive__c = true';
		
        String ORDS = ' order by  Name ';

        for (Customer_Org__c item : Database.query(SOQL + ORDS)) {
            options.add(new CX_OmniChannelController.comboBox(item.Name, item.Id)); 
        }
        
        return options;
    }

    global static List<CX_OmniChannelController.comboBox> getUserList(Boolean isAllOption, String AllOptionLabel) {

        List<CX_OmniChannelController.comboBox> options = new List<CX_OmniChannelController.comboBox>();
        
        if(isAllOption) options.add(new CX_OmniChannelController.comboBox(AllOptionLabel, ''));

        Set<String> hqSet = new Set<String> {'CX본부', 'COO'};

        String SOQL = ' select  '
                    + ' 	Id '
                    + ' 	, Name '
                    + ' 	, Title '
                    + ' from '
                    + ' 	User '
                    + ' where '
			        + '     IsActive = true'
                    + ' and Department in :hqSet ';
		
        String ORDS = ' order by  Name ';

        for (User item : Database.query(SOQL + ORDS)) {
            options.add(new CX_OmniChannelController.comboBox(item.Name + ' ' + item.Title, item.Id)); 
        }
        
        return options;
    }

    @AuraEnabled
    global static Map<String, Object> getAssignViewList(String orderType, String orgId, String userId) {
        
        Map<String, Object> resultMap = new Map<String, Object>();
                
        List<mapViewHeaderWrapper> mappingHeaders = new List<mapViewHeaderWrapper>();

        if(orderType == 'org') {
            mappingHeaders.add(new mapViewHeaderWrapper('고객지원 ORG', true));
            mappingHeaders.add(new mapViewHeaderWrapper('운영리더', true));
            mappingHeaders.add(new mapViewHeaderWrapper('담당자', true));       
        } else {
            mappingHeaders.add(new mapViewHeaderWrapper('담당자', true));
            mappingHeaders.add(new mapViewHeaderWrapper('고객지원 ORG', true));
            mappingHeaders.add(new mapViewHeaderWrapper('운영리더', true));            
        }
        mappingHeaders.add(new mapViewHeaderWrapper('', false));

        List<mapViewDataWrapper> mappingDatas = new List<mapViewDataWrapper>();
        
        String SOQL = ' select  '
                    + ' 	PersonInChargeId__c '
            		+ '		, PersonInChargeId__r.Name '
                    + '		, PersonInChargeId__r.Title '
                    + ' 	, Id '
                    + ' 	, Name '
					+ ' 	, CustomerOrgId__c '
					+ ' 	, CustomerOrgId__r.Name '
                    + '     , CustomerOrgId__r.OperationLeaderId__r.Name '
                    + '     , CustomerOrgId__r.OperationLeaderId__r.Title '
                    + ' from '
                    + ' 	Customer_Org_Assign__c '
                    + ' where Id != null ';
        
        if(String.isNotBlank(orgId)) {
			SOQL += ' and CustomerOrgId__c = :orgId ';
        }
        if(String.isNotBlank(userId)) {
			SOQL += ' and PersonInChargeId__c = :userId ';
        }

        if(orderType == 'org') {
            SOQL += ' order by CustomerOrgId__r.Name, PersonInChargeId__r.Name ';
        } else {
            SOQL += ' order by PersonInChargeId__r.Name, CustomerOrgId__r.Name ';     
        }
        
        Integer idx = 0;

        List<mapViewDataWrapper> mappingList = new List<mapViewDataWrapper>();
        
        for(Customer_Org_Assign__c mp : Database.query(SOQL)) {

            String val1 = '';
            String val2 = '';
            String val3 = '';

            if(orderType == 'org') {
                val1 = mp.CustomerOrgId__r.Name;
                val2 = mp.CustomerOrgId__r.OperationLeaderId__r.Name + ' ' + mp.CustomerOrgId__r.OperationLeaderId__r.Title;
                val3 = mp.PersonInChargeId__r.Name + ' ' + mp.PersonInChargeId__r.Title;
            } else {
                val1 = mp.PersonInChargeId__r.Name + ' ' + mp.PersonInChargeId__r.Title;
                val2 = mp.CustomerOrgId__r.Name;
                val3 = mp.CustomerOrgId__r.OperationLeaderId__r.Name + ' ' + mp.CustomerOrgId__r.OperationLeaderId__r.Title;
            }

            mappingDatas.add(
                new mapViewDataWrapper(
                    mp.Id
                    , ++idx
                    , true
                    , val1
                    , val2
                    , val3
                    , ''
                    , true
                    , true
                    , true
                    , false
                )
            );
        }
     
        resultMap.put('mappingHeaders', mappingHeaders);
        resultMap.put('mappingDatas', mappingDatas);

        return resultMap;
    }
    

    @AuraEnabled
    global static Map<String, Object> getAssignEditList(String orgId, String userId) {
        
        Map<String, Object> resultMap = new Map<String, Object>();
        
        String SOQL = ' select '
                    + ' 	PersonInChargeId__c '
                    + ' 	, PersonInChargeId__r.Name '
                    + ' 	, CustomerOrgId__c '
                    + ' 	, CustomerOrgId__r.Name '
                    + '     , Ex_Key__c '
                    + ' from '
                    + ' 	Customer_Org_Assign__c ';

		List<Customer_Org_Assign__c> mappingList = Database.query(SOQL);
        Map<String, Boolean> mappingMap = new Map<String, Boolean>();
        
        for(Customer_Org_Assign__c mp : mappingList) {
			mappingMap.put(mp.CustomerOrgId__c + '_' + mp.PersonInChargeId__c, true);
        }

        Set<String> hqSet = new Set<String> {'CX본부', 'COO'};
        
        String SQL1 = ' select  '
                    + ' 	Id '
                    + ' 	, Name '
                    + ' from '
                    + ' 	User '
                    + ' where '
                    + ' 	IsActive = true '
                    + ' and Department in :hqSet ';
        
        if(String.isNotBlank(userId)) {
            SQL1 += ' and Id = :userId ';
        }
        
        SQL1 += ' order by Name ';

		List<User> columnList = Database.query(SQL1);        
        
        String SQL2 = ' select  '
                    + ' 	Id '
                    + ' 	, Name '
                    + ' from '
                    + ' 	Customer_Org__c '
                    + ' where '
                    + ' 	IsActive__c = true ';

        if(String.isNotBlank(orgId)) {
            SQL2 += ' and Id = :orgId ';
        }

        SQL2 += ' order by Name ';

		List<Customer_Org__c> rowList = Database.query(SQL2);
        
        resultMap.put('columnLabelList', columnList);
        
        List<mapRowsWrapper> mapRowList = new List<mapRowsWrapper>();
        
        for(Customer_Org__c row : rowList) {
            List<mapColumnsWrapper> mcList = new List<mapColumnsWrapper>();
            
            for(User col : columnList) {
                mcList.add(new mapColumnsWrapper(row.Id, col.Id, mappingMap.get(row.Id + '_' + col.Id)));
            }
			mapRowList.add(new mapRowsWrapper(row.Id, row.Name, true, mcList));
        }

        resultMap.put('mappingList', mapRowList);
        
        return resultMap;
    }
    
    @AuraEnabled
    global static Map<String, Object> saveData(String orgId, String userId, String idArray) {
        
        Map<String, Object> resultMap = new Map<String, Object>();

        // 체크된 데이터 저장
        List<Object> ids = (List<Object>)JSON.deserializeUntyped(idArray);
        
        try {
            // 기존 건 삭제
            String SOQL = ' select '
                        + ' 	Id '
                        + '     , PersonInChargeId__c '
                        + ' 	, PersonInChargeId__r.Name '
                        + ' 	, CustomerOrgId__c '
                        + ' 	, CustomerOrgId__r.Name '
                        + '     , Ex_Key__c '
                        + ' from '
                        + ' 	Customer_Org_Assign__c '
                        + ' where '
                        + '     Id != null ';
        
            if(String.isNotBlank(orgId)) {
                SOQL += ' and CustomerOrgId__c = :orgId ';
            }

            if(String.isNotBlank(userId)) {
                SOQL += ' and PersonInChargeId__c = :userId ';
            }

            //String ORDS = ' and Ex_Key__c not in :ids ';

            List<Customer_Org_Assign__c> coaList = Database.query(SOQL);

            delete coaList;
    
            List<CX_OmniChannelController.comboBox> orgList = getCustomerOrgList(false, '');
            List<CX_OmniChannelController.comboBox> userList = getUserList(false, '');

            Map<String, String> coaMap = new Map<String, String>();

            for(CX_OmniChannelController.comboBox o : orgList) {
                for(CX_OmniChannelController.comboBox u : userList) {
                    coaMap.put(o.value + '_' + u.value, o.label + '_' + u.label);
                }
            }

            List<Customer_Org_Assign__c> mappingList = new List<Customer_Org_Assign__c>();
            
            for(Object o : ids) {
                Map<String, Object> item = (Map<String, Object>)o;
                String key = String.valueOf(item.get('key'));
                String dKey = key.substring(0, key.indexOf('_'));
                String sKey = key.substring(key.indexOf('_')+1);
                
                //System.debug(key + ' | ' + dKey + ' | ' + sKey);         
                mappingList.add(new Customer_Org_Assign__c(CustomerOrgId__c = dKey, PersonInChargeId__c = sKey, Ex_Key__c = key, Name = coaMap.get(key)));
            }
            
            upsert mappingList Ex_Key__c;

       		resultMap.put('result', true);
            resultMap.put('msg', '성공');
        } catch(Exception e) {
			resultMap.put('result', false);
            resultMap.put('msg', e.getMessage());
            System.debug(e);
        }
        
        return resultMap;
    } 

    global class mapViewHeaderWrapper {
        @AuraEnabled global String label {get;set;} 
        @AuraEnabled global Boolean isShow {get;set;}
        
        global mapViewHeaderWrapper(String label, Boolean isShow) {
            this.label = label;
            this.isShow = isShow;
        }
    }

    global class mapViewDataWrapper {

        @AuraEnabled global String key {get;set;}
        @AuraEnabled global Integer idx {get;set;}
        @AuraEnabled global Boolean isCheck {get;set;}
        @AuraEnabled global String label_01 {get;set;}
        @AuraEnabled global String label_02 {get;set;}
        @AuraEnabled global String label_03 {get;set;}
        @AuraEnabled global String label_04 {get;set;}
        @AuraEnabled global Boolean isShow_01 {get;set;}
        @AuraEnabled global Boolean isShow_02 {get;set;}
        @AuraEnabled global Boolean isShow_03 {get;set;}
        @AuraEnabled global Boolean isShow_04 {get;set;}
        
        global mapViewDataWrapper(String key, Integer idx, Boolean isCheck
                            , String label_01, String label_02, String label_03, String label_04
                            , Boolean isShow_01, Boolean isShow_02, Boolean isShow_03, Boolean isShow_04) {
            this.key = key;
            this.idx = idx;
            this.isCheck = isCheck;
            this.label_01 = label_01;
            this.label_02 = label_02;
            this.label_03 = label_03;
            this.label_04 = label_04;
            this.isShow_01 = isShow_01;
            this.isShow_02 = isShow_02;
            this.isShow_03 = isShow_03;
            this.isShow_04 = isShow_04;
        }
    }

    global class mapColumnsWrapper {
        @AuraEnabled global String key {get;set;}        
        @AuraEnabled global String rowId {get;set;}
        @AuraEnabled global String colId {get;set;} 
        @AuraEnabled global Boolean value {get;set;}
        
        global mapColumnsWrapper(String rowId, String colId, Boolean value) {
            this.key = rowId + '_' + colId;            
            this.rowId = rowId;
            this.colId = colId;
            this.value = value == null ? false : value;
        }
    } 

    global class mapRowsWrapper {
        @AuraEnabled global String key {get;set;}
        @AuraEnabled global String label1 {get;set;}
        @AuraEnabled global String label2 {get;set;} 
        @AuraEnabled global String label3 {get;set;} 
        @AuraEnabled global String label4 {get;set;} 
        @AuraEnabled global Boolean isShow1 {get;set;}
        @AuraEnabled global Boolean isShow2 {get;set;} 
        @AuraEnabled global Boolean isShow3 {get;set;} 
        @AuraEnabled global Boolean isShow4 {get;set;} 
        @AuraEnabled global List<mapColumnsWrapper> columns {get;set;}
        
        global mapRowsWrapper(String key, String label1, Boolean isShow1, List<mapColumnsWrapper> columns) {
            this.key = key;
            this.label1 = label1;
            this.isShow1 = isShow1;
            this.columns = columns;
        }

        global mapRowsWrapper(String key, String label1, String label2, String label3, String label4
                                , Boolean isShow1, Boolean isShow2, Boolean isShow3, Boolean isShow4
                                , List<mapColumnsWrapper> columns) {
            this.key = key;
            this.label1 = label1;
            this.label2 = label2;
            this.label3 = label3;
            this.label4 = label4;
            this.isShow1 = isShow1;
            this.isShow2 = isShow2;
            this.isShow3 = isShow3;
            this.isShow4 = isShow4;
            this.columns = columns;
        }
    } 
}