/**
* @Class : UTIL_Trigger - Trigger 관련된 Util Class
*
* @Method : 
*   - getActiveSetting(triggerName)
* 
* @Author : Yong-jin, Cha
* @Date : 2022-03-06
* @Version : 1.0
* @Modified : 
*  ---------------------------------------------
*  NO | Date       | Modifier      | Description
*  ---------------------------------------------
*  1. | 2022-03-06 | Yong-jin, Cha | 최초작성
*/
public class UTIL_Trigger {
    
    public static ActiveSetting getActiveSetting(String triggerName) {
        
        List<MT_Trigger_Active__mdt> TAList = [
            select
                BEFORE_INSERT__c
                , BEFORE_UPDATE__c
                , BEFORE_DELETE__c
                , AFTER_INSERT__c
                , AFTER_UPDATE__c
                , AFTER_DELETE__c
                , AFTER_UNDELETE__c
            from
                MT_Trigger_Active__mdt
            where
                DeveloperName = :triggerName
            limit 1
        ];
        
        if(TAList.size() == 0) {
            return new ActiveSetting(null);
        }
        
        return new ActiveSetting(TAList.get(0));
    }
    
    public class ActiveSetting {
        public Boolean isBeforeInsert {get;set;}
        public Boolean isBeforeUpdate {get;set;}
        public Boolean isBeforeDelete {get;set;}
        public Boolean isAfterInsert {get;set;}
        public Boolean isAfterUpdate {get;set;}
        public Boolean isAfterDelete {get;set;}
        public Boolean isAfterUndelete {get;set;}
        
        public ActiveSetting(MT_Trigger_Active__mdt TA){
            
            TriggerSetting__c TS = TriggerSetting__c.getInstance();
            
            //System.debug(TS);
            
            if(TS.ALL_ACTIVE__c) {
                if(TA == null) {
                    this.isBeforeInsert = TS.BEFORE_INSERT__c;
                    this.isBeforeUpdate = TS.BEFORE_UPDATE__c;
                    this.isBeforeDelete = TS.BEFORE_DELETE__c;
                    this.isAfterInsert = TS.AFTER_INSERT__c;
                    this.isAfterUpdate = TS.AFTER_UPDATE__c;
                    this.isAfterDelete = TS.AFTER_DELETE__c;
                    this.isAfterUndelete = TS.AFTER_UNDELETE__c;                    
                } else {
                    this.isBeforeInsert = TS.BEFORE_INSERT__c && TA.BEFORE_INSERT__c;
                    this.isBeforeUpdate = TS.BEFORE_UPDATE__c && TA.BEFORE_UPDATE__c;
                    this.isBeforeDelete = TS.BEFORE_DELETE__c && TA.BEFORE_DELETE__c;
                    this.isAfterInsert = TS.AFTER_INSERT__c && TA.AFTER_INSERT__c;
                    this.isAfterUpdate = TS.AFTER_UPDATE__c && TA.AFTER_UPDATE__c;
                    this.isAfterDelete = TS.AFTER_DELETE__c && TA.AFTER_DELETE__c;
                    this.isAfterUndelete = TS.AFTER_UNDELETE__c && TA.AFTER_UNDELETE__c;
                }
            } else {
                this.isBeforeInsert = false;
                this.isBeforeUpdate = false;
                this.isBeforeDelete = false;
                this.isAfterInsert = false;
                this.isAfterUpdate = false;
                this.isAfterDelete = false;
                this.isAfterUndelete = false;
            }
        }
    }
}