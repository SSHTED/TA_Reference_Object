global class BatchCalculateProjectTime implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{
	
    global List<Milestone1_Project__c> mtpList;
    
    global List<Milestone1_Task__c> pTaskList;
    
    global Set<Id> TaskIds;
    global Map<String, Milestone1_Project__c> pjMap;
    global Map<String, String> pjIdsMap;
    global Map<String, List<Milestone1_Time__c>> timeListMap;
    global Map<String, Project_Assigned_Period__c> pspMap;
    global BatchCalculateProjectTime() {
        timeListMap = new Map<String, List<Milestone1_Time__c>>();
        
        pjIdsMap = new Map<String, String>();
        pjMap = new Map<String, Milestone1_Project__c>();
        TaskIds = new Set<Id>();
        mtpList = [SELECT Id, Status__c FROM Milestone1_Project__c WHERE Status__c != 'Inactive' AND Status__c != 'Completed'];       
        Set<Id> PjIds = new Set<Id>();
        for(Milestone1_Project__c mp : mtpList) {
            PjIds.add(mp.Id);
            pjMap.put(mp.Id, mp);
        }
        
        pTaskList = [SELECT Id, LookupProject__c FROM Milestone1_Task__c WHERE LookupProject__c IN :PjIds];
        for(Milestone1_Task__c pTask : pTaskList) {
            TaskIds.add(pTask.Id);
            pjIdsMap.put(pTask.Id, pTask.LookupProject__c);
        }
        
        pspMap = new Map<String, Project_Assigned_Period__c>();
        List<Project_Assigned_Period__c> papList = new List<Project_Assigned_Period__c>();
        papList = [SELECT Project__c, Time_M_M__c, EmpId__c FROM Project_Assigned_Period__c WHERE Project__c = :PjIds];
        for(Project_Assigned_Period__c pap : papList) {
            pspMap.put(pap.EmpId__c + pap.Project__c, pap);
        }
        
    }
 
    global database.querylocator start(Database.BatchableContext BC){

        String query = 'SELECT Project_Task__c, CreatedDate, Date__c, Employee__c, Hours__c, Id, Name, ProjectId__c FROM Milestone1_Time__c WHERE Project_Task__c IN :TaskIds';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Milestone1_Time__c> timeScope){
       system.debug(timeScope.size());
        if(timeScope.size() > 0) {
            for(Milestone1_Time__c times : timeScope) { 
                if(timeListMap.get(times.Employee__c + times.ProjectId__c) != null) {
                    List<Milestone1_Time__c> timeList = timeListMap.get(times.Employee__c + times.ProjectId__c);
                    timeList.add(times);
                    timeListMap.put(times.Employee__c + times.ProjectId__c, timeList);
                } else {
                    List<Milestone1_Time__c> timeList = new List<Milestone1_Time__c>();
                    timeList.add(times);
                    timeListMap.put(times.Employee__c + times.ProjectId__c, timeList);
                }
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        List<Project_Assigned_Period__c> updatePsp = new List<Project_Assigned_Period__c>();
        if(timeListMap.size() > 0) {
            
            for (String key : timeListMap.keySet()) {
                if(pspMap.get(key) != null) {
                    decimal Hours = 0;
                    List<Milestone1_Time__c> timeList = timeListMap.get(key);
                    for(Milestone1_Time__c times : timeLIst) {
                        Hours += times.Hours__c;
                    }
                    Project_Assigned_Period__c psp = pspMap.get(key);
                    psp.Time_M_M__c =+ Hours/172;
                    updatePsp.add(psp);
                }
            }
        }
        if(updatePsp.size() > 0) {
            update updatePsp;
        }
    }
}