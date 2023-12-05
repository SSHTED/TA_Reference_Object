//사용공수 합산 배치
public class TeamStatusMMBatch implements Database.Batchable<SObject> , Database.Stateful {
     
    
    public TeamStatusMMBatch(){

    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
		System.debug('----- start -----');    
        
        String SOQL = 'SELECT '
            		+'		Id'
            		+',		TSM_Name__r.name'
            		+',		Account__c'
            		+',		Customer_Org__c'
            		+',		ProjectName__c'
            		+',		Support_USE_MM__c'
            		+',		FM_ContractStartDate__c'
            		+',		FM_ContractEndDate__c'
            		+',		D_day__c'
            		+ ' FROM '
            		+'		TeamStatusMM__c '
            		+ ' WHERE '
            		+ 'D_day__c >=0';
        System.debug('soql'+SOQL);
        return Database.getQueryLocator(SOQL);
    }
    
    public void execute(Database.BatchableContext BC, List<TeamStatusMM__c> teamStatusList){
        System.debug('----- execute -----');
           
        List<TeamStatusMM__c> teamupdateList = new List<TeamStatusMM__c>();
        List<AggregateResult> AggregateResultList = new List<AggregateResult>();
        Decimal WorkingDays;
        WorkingDays = Decimal.valueOf(System.Label.WorkingDays);
        
        
        for(TeamStatusMM__c team : teamStatusList){
            
             List<AggregateResult> OrguserMdbindList= [select count(id) id ,sum(Actual_MM__c) sumMd, sum(Actual_Work_MM__c) workMd  from Support_Manager__c where Customer_Org__c=:team.Customer_Org__c and FM_Person_In_Charge__c =:team.TSM_Name__r.name and Request_Date__c >= :team.FM_ContractStartDate__c and Request_Date__c <= :team.FM_ContractEndDate__c]; 
            
            if(OrguserMdbindList.size() >0){
        
                team.SR_ProcessingCount__c = (Decimal)OrguserMdbindList[0]?.get('id');
                team.UseMD__c  = (Decimal)OrguserMdbindList[0]?.get('sumMd');
                team.WorkMD__c = (Decimal)OrguserMdbindList[0]?.get('workMd');
	            if(team.UseMD__c != null) team.Support_USE_MM__c = team.UseMD__c / WorkingDays;
                if(team.WorkMD__c != null) team.Support_USE_Work_MM__c = team.WorkMD__c / WorkingDays;
                teamupdateList.add(team);
            }        
        }
        
        
        if(teamupdateList.size() > 0){
            System.debug('teamupdateList size > 0 ');
            update teamupdateList;
        }
    
        
    }
    
    public void finish(Database.BatchableContext BC){
        System.debug('----- finish -----');
    }



}