/**
 * @Class : DK_WorkTimeHistoryController
 *
 * @Method : 
 *	- @AuraEnabled getWorkingTimeInfo()
 *	- @AuraEnabled checkWorkingStartTime()
 *	- @AuraEnabled checkWorkingFinishTime()
 * 
 * @Author : Yong-Jin, Cha
 * @Date : 2022-05-16
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2022-05-16 | Yong-Jin, Cha | 최초작성
 */
global class DK_WorkTimeHistoryController {

    @AuraEnabled
    global static Map<String, Object> getWorkingTimeInfo() {
        
        Map<String, Object> resultMap = new Map<String, Object>();
        
        DateTime nowTime = System.now();
        String dateStr = nowTime.format('yyyy-MM-dd') ;
        String uId = System.UserInfo.getUserId();
        String uName = System.UserInfo.getName();
        String key = uId + '_' + dateStr;
        
        List<DK_WorkTimeHistory__c> WTH_List = [
            select
            	Id
            	, Name
            	, OwnerId
            	, Owner.Name
                , IsWorkingFinish__c
                , IsWorkingStart__c
                , WorkingFinishIP__c
                , WorkingFinishTime__c
                , FM_WorkingPeriod__c
                , WorkingStartIP__c
                , WorkingStartTime__c
            	, FM_WelcomeMessage__c
				, FM_Status__c
            	, WorkingNote__c
            	, WorkingLocation__c
            from
                DK_WorkTimeHistory__c
            where
            	ExternalKey__c = :key
            and OwnerId = :uId
        ];
        
        if(WTH_List.size() == 1) {
			resultMap.put('info', WTH_List.get(0));
        } else {
            resultMap.put('info', new Map<String, Object>{
                                    'IsWorkingStart__c' => false
                                    , 'IsWorkingFinish__c' => false
                                    , 'FM_WelcomeMessage__c' => System.Label.MSG_WELCOME_001
                                    , 'FM_Status__c' => '출근전'
                                    , 'Owner' => new Map<String, String> {
                                    	'Name' => uName
                                    }
            					});
        }

        System.debug(resultMap);
        
        List<comboBox> location = new List<comboBox>();
        for(Schema.PicklistEntry pi : Schema.SObjectType.DK_WorkTimeHistory__c.fields.WorkingLocation__c.PicklistValues) {
            location.add(new comboBox(pi.getLabel(), pi.getValue()));
        }
        
        resultMap.put('location', location);
        
        return resultMap;
    }
    
    @AuraEnabled
    global static Map<String, Object> checkWorkingStartTime(String workingLocation) {
        
        Map<String, Object> resultMap = new Map<String, Object>();
        
        try {
        
            DateTime nowTime = System.now();
            String dateStr = nowTime.format('yyyy-MM-dd') ;
            String uId = System.UserInfo.getUserId();
            
            DK_WorkTimeHistory__c WTH = new DK_WorkTimeHistory__c();
            
            WTH.IsWorkingStart__c = true;
            WTH.WorkingStartIP__c = getSourceIp();
            WTH.WorkingStartTime__c = nowTime;
            WTH.ExternalKey__c = uId + '_' + dateStr;
            WTH.WorkingLocation__c = workingLocation;
            
            upsert WTH ExternalKey__c;
            
            resultMap.put('result', true);
            resultMap.put('info', getWorkingTimeInfo());
        } catch(Exception e) {
			resultMap.put('result', false);
            System.debug(e);
        }
        
        System.debug(resultMap);
        
        return resultMap;
    }
    
    @AuraEnabled
    global static Map<String, Object> checkWorkingFinishTime(String workingNote) {
        
        Map<String, Object> resultMap = new Map<String, Object>();
        
        try {
        
            DateTime nowTime = System.now();
            String dateStr = nowTime.format('yyyy-MM-dd') ;
            String uId = System.UserInfo.getUserId();
            
            DK_WorkTimeHistory__c WTH = new DK_WorkTimeHistory__c();
            
            WTH.IsWorkingFinish__c = true;
            WTH.WorkingFinishIP__c = getSourceIp();
            WTH.WorkingFinishTime__c = nowTime;
            WTH.ExternalKey__c = uId + '_' + dateStr;
            WTH.WorkingNote__c = workingNote;            
            
            upsert WTH ExternalKey__c;
            
            resultMap.put('result', true);
            resultMap.put('info', getWorkingTimeInfo());
        } catch(Exception e) {
			resultMap.put('result', false);
            System.debug(e);
        }
        
        System.debug(resultMap);
        
        return resultMap;
    }
    
    private static String getSourceIp() {
        return Test.isRunningTest() ? '0.0.0.0' : Auth.SessionManagement.getCurrentSession().get('SourceIp');
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