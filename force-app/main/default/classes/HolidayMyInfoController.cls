public with sharing class HolidayMyInfoController{
    public Holiday__c h {get;set;}
    public list<HolidayAction__c> haLst{get;set;}
    public list<HolidayHistoryClass> hldHstClsLst {get;set;}
    public string usrId {get;set;}
    public boolean isNormalTab {get;set;}
    
    public HolidayMyInfoController(){
        isNormalTab = true;
        if(ApexPages.currentPage().getParameters().get('sfdc.userId') == null) {
            usrId = UserInfo.getUserId();
        } else {
            usrId = ApexPages.currentPage().getParameters().get('sfdc.userId');
        }

        if(ApexPages.currentPage().getParameters().get('isNormalTab')==null)
            isNormalTab = false;
        h = [SELECT Id,Holiday_Calculated__c,Holiday_GivenHolidays__c,Holiday_IsAnnualleave__c,Holiday_JoinDate__c,
                  Holiday_LastActivity__c,Holiday_NoticeLevel__c,Holiday_PeriodEnd__c,Holiday_Remain__c,Holiday_Uncountable__c,Holiday_RemainAlternative__c,Holiday_Unpaid__c,Holiday_UseDays__c,
                  Holiday_User__c, Holiday_User__r.Name, Holiday_WorkingYears__c, Holiday_GivenUseDays__c, Holiday_TotalRemain__c,Holiday_GivenRemain__c
             		, Holiday_IsNewLawApply__c, Holiday_IsNewLaw2Apply__c, Holiday_Last_Remaining1__c
             FROM Holiday__c WHERE Holiday_User__c = :usrId limit 1];
        string hldId = h.Id;
        haLst = [SELECT HolidayAction_Days__c, HolidayAction_Type__c, Name,HolidayAction_IsConfirm__c,CreatedDate 
                   FROM HolidayAction__c
                  WHERE HolidayAction_Parent__c = :hldId ORDER BY CreatedDate DESC ];
                    
        list<Holiday__History> hldHstLst  = [SELECT CreatedBy.Name,CreatedDate,Field,Id,NewValue,OldValue FROM Holiday__History WHERE ParentId = :hldId  ORDER BY CreatedDate DESC Limit 100];
        String type='Holiday__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType holidaySchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = holidaySchema.getDescribe().fields.getMap();
        hldHstClsLst = new list<HolidayHistoryClass>();
        for(Holiday__History hldHstr : hldHstLst  ){
            HolidayHistoryClass hldHstCls = new HolidayHistoryClass();
            hldHstCls.createdDate = hldHstr.CreatedDate;
            hldHstCls.user = hldHstr .CreatedBy.Name;
            system.debug(hldHstr.OldValue);
            system.debug(hldHstr.NewValue);
            hldHstCls.actStrOldValue = string.valueOf(hldHstr.OldValue);
            hldHstCls.actStrNewValue = string.valueOf(hldHstr.NewValue);
            hldHstCls.isNumeric = true;
            try{
                hldHstCls.actStrOldDecimal = Decimal.valueOf(hldHstCls.actStrOldValue );
                hldHstCls.actStrNewDecimal = Decimal.valueOf(hldHstCls.actStrNewValue);
            }catch(Exception e){
                hldHstCls.isNumeric = false;
            }
            hldHstCls.language = UserInfo.getLanguage() ;
            if(hldHstCls.language == 'ko'){                
                if(hldHstr .Field == 'created'){
                    hldHstCls.actStrVerb1 = 'Created.';
                }
                else {
                    hldHstCls.actStrNoun = fieldMap.get(hldHstr .Field).getDescribe().getLabel() ;
                    hldHstCls.actStrNounPosition = '을(를) ';
                    if(hldHstr .OldValue != null){
                        hldHstCls.actStrOldPosition = '에서 ';
                    }
                    hldHstCls.actStrNewPosition = '(으)로 ';
                    hldHstCls.actStrVerb2 = '변경했습니다.';
                }
            }
            else{
                if(hldHstr .Field == 'created'){
                    hldHstCls.actStrVerb1 = 'Created.';
                }
                else {
                    hldHstCls.actStrNoun = fieldMap.get(hldHstr .Field).getDescribe().getLabel() ;
                    hldHstCls.actStrNoun = fieldMap.get(hldHstr .Field).getDescribe().getLabel() ;
                    hldHstCls.actStrNounPosition = '';
                    if(hldHstr .OldValue != null){
                        hldHstCls.actStrOldPosition= ' from ';
                    }
                    hldHstCls.actStrNewPosition= 'to ';
                    hldHstCls.actStrVerb2 = 'Changed ';
                }
            }
            hldHstCls.history = hldHstr ;
            hldHstClsLst.add(hldHstCls);
        }
    }
    
    public PageReference Action(){
        return new PageReference('/apex/HolidayActionRegister?retId='+ usrId);
    }
    
    public class HolidayHistoryClass{
        public datetime createdDate {get;set;}
        public string user{get;set;}
        public boolean isNumeric{get;set;}
        public string language{get;set;}
        public string actStrVerb1{get;set;}
        public string actStrNoun{get;set;}
        public string actStrNounPosition{get;set;}
        public string actStrVerb2{get;set;}
        public string actStrOldPosition{get;set;}
        public string actStrNewPosition{get;set;}
        public string actStrOldValue{get;set;}
        public string actStrNewValue{get;set;}
        public decimal actStrOldDecimal{get;set;}
        public decimal actStrNewDecimal{get;set;}
        public Holiday__History history {get;set;}
    }
}