public class OutSupportManagerBatch implements Database.Batchable<SObject> , Database.Stateful{
    
    String TARGET_YYYY;
    String TARGET_MM;
    String DELIM = '-';
    String TARGET_YM ='';
    
    /*public OutSupportManagerBatch(String mm){
this.TARGET_MM = mm;
}*/
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('---------- start ----------');
        
        Date thisMonth = System.today();
        TARGET_YYYY = String.valueOf(thisMonth.year());
        TARGET_MM = String.valueOf(thisMonth.month()-1).leftPad(2,'0');
        TARGET_YM = TARGET_YYYY + DELIM + TARGET_MM;
        
        return Database.getQueryLocator([
            
            SELECT Id , OSM_Name__c , Customer_Org__c ,ProjectName__c , BatchStatus__c  , KoreanAir_Check__c , Expected_MD__c
            FROM OutSupportManager__c
            WHERE FM_YearMonth__c =: TARGET_YM 
        ]);
    }
    
    
    public void execute(Database.BatchableContext BC , List<OutSupportManager__c> OutSupportManagerList){
        System.debug('---------- execute ----------' + TARGET_YM);
        
        Decimal WorkingDays;
        Decimal WorkingDays_KoreanAir;
        
        WorkingDays = Decimal.valueOf(System.Label.WorkingDays);
        WorkingDays_KoreanAir = Decimal.valueOf(System.Label.WorkingDays_KoreanAir);
        
        
        for(OutSupportManager__c OSM : OutSupportManagerList){
            
            List<TeamStatusMonthly__c> teamStatusContainList = [SELECT Id , TSM_Name__c , Customer_Org__c , ProjectName__c ,Support_Expected_MM__c ,Support_USE_Monthly__c , KoreanAir_Check__c ,PMS_PjtManpower__c , FM_TeamStatusYM__c
                                                                FROM TeamStatusMonthly__c 
                                                                WHERE  FM_TeamStatusYM__c =: TARGET_YM
                                                                AND TSM_Name__c =: OSM.OSM_Name__c
                                                                AND Customer_Org__c =: OSM.Customer_Org__c
                                                                AND ProjectName__c =: OSM.ProjectName__c LIMIT 1];
            
            if(teamStatusContainList.size() > 0){
                System.debug('teamStatusContainList[0] '+teamStatusContainList[0].Id);
                System.debug('OSM '+OSM.Id);
                
                List<PMS_PjtManpowerMonth__c> ManpowerList = [select Id , PjtManpower__c , Project__c , FM_TeamStatusYM__c , ManpowerMM__c 
                                                              from PMS_PjtManpowerMonth__c
                                                              where PjtManpower__c =: teamStatusContainList[0].PMS_PjtManpower__c 
                                                              and Project__c =: teamStatusContainList[0].ProjectName__c 
                                                              and FM_TeamStatusYM__c=: teamStatusContainList[0].FM_TeamStatusYM__c
                                                              and ManpowerMM__c != null
                                                              limit 1];
                
                List<AggregateResult> SumUseMDList = [SELECT count(id) id , sum(Expected_MD__c) ExpectedMD  
                                                      FROM OutSupportManager__c 
                                                      WHERE OSM_Name__c =: teamStatusContainList[0].TSM_Name__c 
                                                      AND Customer_Org__c =: teamStatusContainList[0].Customer_Org__c 
                                                      AND ProjectName__c =: teamStatusContainList[0].ProjectName__c 
                                                      AND Expected_MD__c != null
                                                      AND FM_YearMonth__c =: TARGET_YM ];
                
                
                if((Decimal)SumUseMDList[0]?.get('id') >= 0){
                    System.debug('SumUseMDList'+SumUseMDList);
                    if(ManpowerList.size() > 0 )teamStatusContainList[0].PlannedMonthTotalInputMM__c = (Decimal)ManpowerList[0]?.get('ManpowerMM__c');
                    //if(teamStatusContainList[0].KoreanAir_Check__c == false) teamStatusContainList[0].Support_USE_Monthly__c = (Decimal)SumUseMDList[0]?.get('UseMD') / WorkingDays;
                    if(teamStatusContainList[0].KoreanAir_Check__c == false) teamStatusContainList[0].Support_Expected_MM__c = (Decimal)SumUseMDList[0]?.get('ExpectedMD') / WorkingDays;
                    //if(teamStatusContainList[0].KoreanAir_Check__c == true)  teamStatusContainList[0].Support_USE_Monthly__c = (Decimal)SumUseMDList[0]?.get('UseMD') / WorkingDays_KoreanAir;
                    if(teamStatusContainList[0].KoreanAir_Check__c == true)  teamStatusContainList[0].Support_Expected_MM__c = (Decimal)SumUseMDList[0]?.get('ExpectedMD') / WorkingDays_KoreanAir;
                }  
                
                try {
                    if(teamStatusContainList[0].Support_Expected_MM__c != NULL){
                        //OSM.BatchStatus__c = true;
                        //update OSM;
                        update teamStatusContainList[0];
                    }
                }catch(Exception e) {
                    System.debug('Update Exception'+e);
                }
            }
            
            
            
        }  
    }
    
    public void finish(Database.BatchableContext BC) {
        System.debug('---------- finish ----------');
        
    }
    
}