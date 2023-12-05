public class TeamStatusMonthCloneBatch implements Database.Batchable<Sobject> , Database.Stateful{
     
    String TARGET_YYYY;
    String TARGET_MM;
    String DELIM = '-';
    String TARGET_YM='';
    String THIS_YEAR;
    public List<SObject> objInsertList = new List<SObject>();
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('----- Start -----');
        Date thisMonth = System.today();
		TARGET_YYYY = String.valueOf(thisMonth.year());
		TARGET_MM = String.valueOf(thisMonth.month()-1).leftPad(2,'0');
        THIS_YEAR = String.valueOf(thisMonth.month()).leftPad(2,'0');
		TARGET_YM= TARGET_YYYY+DELIM+TARGET_MM;
        
		               
        return Database.getQueryLocator([SELECT Id
                                         , TSM_Name__r.name
                                         , Account__c
                                         , Customer_Org__c
                                         , ProjectName__c
                                         , Support_USE_Monthly__c
                                         , Support_USE_Work_MM__c
                                         , UseMonthly_MD__c
                                         , UseMonthly_MM__c
                                         , WorkMonthly_MD__c
                                         , SolubleMonthly_MM__c
                                         , D_day__c
                                         , Month__c 
                                         , Note__c
                                         , SR_ProcessingCount__c
                                         , RecognizedMM__c
                                         , FM_PlannedTotalInputMM__c
                                         FROM TeamStatusMonthly__c  
                                         WHERE Month__c =:TARGET_MM]);
    }
    
    public void execute(Database.BatchableContext BC , List<TeamStatusMonthly__c> TeamStatusMonthlyList){
		System.debug('----- execute ----- ' + TeamStatusMonthlyList);
        SavePoint sp = Database.setSavepoint();
        
        for(TeamStatusMonthly__c team : TeamStatusMonthlyList){
             TeamStatusMonthly__c newTeamStatusMonthly = new TeamStatusMonthly__c();
             newTeamStatusMonthly.TSM_Name__c = team.TSM_Name__c;
             newTeamStatusMonthly.Account__c = team.Account__c;
             newTeamStatusMonthly.Month__c = String.valueof(THIS_YEAR);
             newTeamStatusMonthly.Customer_Org__c = team.Customer_Org__c;
             newTeamStatusMonthly.ProjectName__c = team.ProjectName__c;
             newTeamStatusMonthly.RecognizedMM__c = team.FM_PlannedTotalInputMM__c;
            objInsertList.add(newTeamStatusMonthly);
        }
        
        if(objInsertList.size() >0){
			Database.SaveResult[]  insertList = Database.insert(objInsertList , false);
            
            for(Database.SaveResult sr : insertList){
                if(!sr.isSuccess()){
                    for(Database.Error err: sr.getErrors()){
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    }
                    Database.rollback(sp);
                }
            }       
        }     
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('----- finish -----');
       
        
        
    }

}