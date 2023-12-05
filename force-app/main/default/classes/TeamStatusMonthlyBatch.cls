public class TeamStatusMonthlyBatch implements Database.Batchable<SObject> , Database.Stateful{
    
    String TARGET_YYYY;
    String TARGET_MM;
    String DELIM = '-';
    String TARGET_YM='';
    Set<String> ExcludeOrgSet = new Set<String>();
    List<String> ExcludeOrgList = new List<String>();
    
    public TeamStatusMonthlyBatch(){
        
        String TARGET_YYYY;
        String TARGET_MM;
        String DELIM = '-';
        String TARGET_YM='';        
        Date thisMonth = System.today();
        TARGET_YYYY = String.valueOf(thisMonth.year());
        TARGET_MM = String.valueOf(thisMonth.month()-1).leftPad(2,'0');
        TARGET_YM= TARGET_YYYY+DELIM+TARGET_MM;      
        List<OutSupportManager__c> OutSupportManagerOrgList = [SELECT Customer_Org__c  FROM OutSupportManager__c where FM_YearMonth__c=:TARGET_YM  and Customer_Org__r.name !='CJ제일제당'];
        
        for(OutSupportManager__c o : OutSupportManagerOrgList){
            ExcludeOrgSet.add(o.Customer_Org__c);
            ExcludeOrgList.addAll(ExcludeOrgSet);
        }

    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('---------- start ----------');
        
        Date thisMonth = System.today();
        TARGET_YYYY = String.valueOf(thisMonth.year());
        TARGET_MM = String.valueOf(thisMonth.month()-1).leftPad(2,'0');
        TARGET_YM= TARGET_YYYY+DELIM+TARGET_MM;
        System.debug('TARGET_YM  '+TARGET_YM);
        String SOQL = 'SELECT '
            +'		Id'
            +',		TSM_Name__r.name'
            +',		Account__c'
            +',		Customer_Org__c'
            +',		ProjectName__c'
            +',		Support_USE_Monthly__c'
            +',		Support_USE_Work_MM__c'
            +',		FM_ContractStartDate__c'
            +',		FM_ContractEndDate__c'
            +',		UseMonthly_MD__c'
            +',		WorkMonthly_MD__c'
            +',		FM_TeamStatusYM__c'
            +',		D_day__c'
            +',		KoreanAir_Check__c'
            +',		PMS_PjtManpower__c'
            +',		PMS_PjtResource__c'
            + ' FROM '
            +'		TeamStatusMonthly__c '
            + ' WHERE '
            + ' Customer_Org__c  NOT IN : ExcludeOrgList'
            + ' AND '
            + 'FM_TeamStatusYM__c = \''+TARGET_YM+'\'';
        
        System.debug('soql '+SOQL); 
        return Database.getQueryLocator(SOQL);
    }
    
    public void execute(Database.BatchableContext BC , List<TeamStatusMonthly__c> TeamStatusMonthlyList){
        System.debug('---------- execute ----------'+TARGET_YM);
        
        List<TeamStatusMonthly__c> teamupdateList = new List<TeamStatusMonthly__c>();
        List<AggregateResult> AggregateResultList = new List<AggregateResult>();
        Decimal WorkingDays;
        Decimal WorkingDays_KoreanAir;
        
        WorkingDays = Decimal.valueOf(System.Label.WorkingDays);
        WorkingDays_KoreanAir = Decimal.valueOf(System.Label.WorkingDays_KoreanAir);
        
        for(TeamStatusMonthly__c team : TeamStatusMonthlyList){
            
            List<PMS_PjtManpowerMonth__c> ManpowerList = [select Id , PjtManpower__c , Project__c , FM_TeamStatusYM__c , ManpowerMM__c 
                                                          from PMS_PjtManpowerMonth__c
                                                          where PjtManpower__c =: team.PMS_PjtManpower__c 
                                                          and Project__c =: team.ProjectName__c 
                                                          and FM_TeamStatusYM__c=: team.FM_TeamStatusYM__c
                                                          and ManpowerMM__c != null
                                                          limit 1];
            
            List<AggregateResult> OrguserMdbindList= 
                [select count(id) id ,sum(Actual_MM__c) sumMd, sum(Actual_Work_MM__c) workMd , sum(Expected_MM__c) ExpectedMd
                 from Support_Manager__c 
                 where Customer_Org__c=:team.Customer_Org__c 
                 and FM_Person_In_Charge__c =:team.TSM_Name__r.name 
                 and FM_YearMonth__c =:team.FM_TeamStatusYM__c
                 and State__c ='완료'
                 
                ]; 
            System.debug('team '+team);
            System.debug('OrguserMdbindList '+OrguserMdbindList);
            if(OrguserMdbindList.size() >0){
                
                team.SR_ProcessingCount__c = (Decimal)OrguserMdbindList[0]?.get('id');
                team.UseMonthly_MD__c  = (Decimal)OrguserMdbindList[0]?.get('sumMd');
                team.WorkMonthly_MD__c = (Decimal)OrguserMdbindList[0]?.get('workMd');
                team.Support_Expected_MM__c = (Decimal)OrguserMdbindList[0]?.get('ExpectedMd');
                if(ManpowerList.size() > 0 )team.PlannedMonthTotalInputMM__c = (Decimal)ManpowerList[0]?.get('ManpowerMM__c');
                if(team.UseMonthly_MD__c != null && team.KoreanAir_Check__c == false) team.Support_USE_Monthly__c = team.UseMonthly_MD__c / WorkingDays;
                if(team.WorkMonthly_MD__c != null && team.KoreanAir_Check__c == false) team.Support_USE_Work_MM__c = team.WorkMonthly_MD__c / WorkingDays;
                if(team.Support_Expected_MM__c != null && team.KoreanAir_Check__c == false) team.Support_Expected_MM__c = team.Support_Expected_MM__c / WorkingDays;
                
                teamupdateList.add(team);
            }        
        }
        
        
        if(teamupdateList.size() > 0){
            System.debug('TeamStatusMonthlyBatch size > 0 ');
            update teamupdateList;
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        System.debug('---------- finish ----------');
        
    }
}