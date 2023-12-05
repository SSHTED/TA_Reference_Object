public class TeamStatusMonthNewCloneBatch implements Database.Batchable<Sobject> , Database.Stateful{
    
    String TARGET_YYYY;
    String TARGET_MM;
    String DELIM = '-';
    String TARGET_YM='';
    String THIS_YEAR;
    Map<String , SObject> PjtManpowerMonthMapping = new Map<String , SObject>();
    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('---------- START ----------');
        Date thisMonth = System.today();
		TARGET_YYYY = String.valueOf(thisMonth.year());
		TARGET_MM = String.valueOf(thisMonth.month()-1).leftPad(2,'0');
        THIS_YEAR = String.valueOf(thisMonth.month()).leftPad(2,'0');
		TARGET_YM= TARGET_YYYY+DELIM+TARGET_MM;
        
        
        return Database.getQueryLocator([SELECT Id ,
                                         Project__c , //계약명
                                         PjtManpower__c , //프로젝트 투입 인력
                                         PjtManpower__r.PjtResourceId__c,  //프로젝트 자원
                                         PjtManpower__r.PjtResourceId__r.EmployeeId__c , // 직원
                                         Project__r.Customer_Org__c , //고객지원 ORG
                                         ManpowerMM__c ,  //공수
                                         FM_TeamStatusYM__c,   //해당 월
                                         Project__r.DirectCustomer__c, // 고객사 계약 주체
                                         PjtManpower__r.JoinHQ__c  // 참여본부
                                         FROM PMS_PjtManpowerMonth__c
                                         WHERE ManpowerMM__c!= NULL
                                         AND FM_TeamStatusYM__c=: TARGET_YM
                                         AND (Project__r.ProjectType__c ='SM' or Project__r.ProjectType__c ='Internal')
                                         AND PjtManpower__r.PjtResourceId__r.EmployeeId__c != NULL
                                         AND PjtManpower__r.JoinHQ__r.name = 'CX본부'
                                        ]);
        
    }
    
    public void execute(Database.BatchableContext BC, List<PMS_PjtManpowerMonth__c> scope){
        System.debug('---------- EXECUTE ----------');
        
        List<SObject> objInsertList = new List<SObject>();
        
        for(PMS_PjtManpowerMonth__c pjtManMonth : scope){
            TeamStatusMonthly__c newTeamStatusMonthly = new TeamStatusMonthly__c();
            newTeamStatusMonthly.TSM_Name__c = pjtManMonth.PjtManpower__r.PjtResourceId__r.EmployeeId__c;
            newTeamStatusMonthly.Account__c = pjtManMonth.Project__r.DirectCustomer__c;
            newTeamStatusMonthly.Month__c = String.valueof(TARGET_MM);
            newTeamStatusMonthly.PMS_PjtManpower__c = pjtManMonth.PjtManpower__c;
            newTeamStatusMonthly.PMS_PjtResource__c = pjtManMonth.PjtManpower__r.PjtResourceId__c;
            newTeamStatusMonthly.Customer_Org__c = pjtManMonth.Project__r.Customer_Org__c;
            newTeamStatusMonthly.ProjectName__c = pjtManMonth.Project__c;
            newTeamStatusMonthly.RecognizedMM__c = pjtManMonth.ManpowerMM__c;
            
            if(!PjtManpowerMonthMapping.containsKey(pjtManMonth.PjtManpower__c)){
                PjtManpowerMonthMapping.put(pjtManMonth.PjtManpower__c , pjtManMonth);
                
                objInsertList.add(newTeamStatusMonthly);                
            }

            
		            
        }
        
        if(objInsertList.size() > 0){
            Database.SaveResult[]  insertList = Database.insert(objInsertList , false);
            SavePoint sp = Database.setSavepoint();
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
        System.debug('---------- FINISH ----------');
    }

}