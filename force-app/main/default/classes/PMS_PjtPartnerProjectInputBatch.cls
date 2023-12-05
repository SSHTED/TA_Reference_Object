/*
PMS_PjtPartnerProjectInputBatch batch = new PMS_PjtPartnerProjectInputBatch();
Database.executeBatch(batch, 1);
*/
public class PMS_PjtPartnerProjectInputBatch implements Database.Batchable<SObject> , Database.Stateful{
    
    List<String> OrgListName = new List<String>();
    Map<String, List<String>> ProjectOrgMapping = new Map<String, List<String>>();
    Map<String, String> ProjectOrgIdMapping = new Map<String, String>();
    Map<String, String> ProjectMangerMapping = new Map<String, String>();
    
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        
        
        System.debug('----- START -----');
        
        return Database.getQueryLocator([
            SELECT id , ProjectId__c , ProjectId__r.ProjectManagerId__c , PjtResourceId__r.ResourceType__c , PjtResourceId__r.PjtPartnerEmpId__r.PjtPartnerId__r.name , PlannedBillableMM__c,FM_PartnerName__c   
            FROM PMS_PjtManpower__c 
            WHERE PjtResourceId__r.ResourceType__c = '협력사 인력' and (CreatedDate =yesterday  or LastModifiedDate  = yesterday) order by ProjectId__c asc
            
            
        ]);
        
    }
    
    public void execute(Database.BatchableContext BC , List<PMS_PjtManpower__c> PjtManpowerList){
        
        PMS_PjtPartnerInputProject__c PjtPartnerInputProject = new PMS_PjtPartnerInputProject__c();
        List<PMS_PjtPartnerInputProject__c> PjtPartnerList = new List<PMS_PjtPartnerInputProject__c>();
        List<PMS_PjtPartnerInputProject__c> PjtPartnerUpdateList = new List<PMS_PjtPartnerInputProject__c>();
        
        Map<String,PMS_PjtPartnerInputProject__c> PjtPartnerUpdateMap = new Map<String,PMS_PjtPartnerInputProject__c>();
        Map<String,PMS_PjtPartnerInputProject__c> PjtPartnerInputMap = new Map<String,PMS_PjtPartnerInputProject__c>();
        
        
        
        for(PMS_PjtManpower__c pjt_manpower : PjtManpowerList){
            System.debug('pjt_manpower '+pjt_manpower);
            List<String> projectPartnerNameList = new List<String>();
            projectPartnerNameList.add(pjt_manpower.FM_PartnerName__c);
            ProjectOrgMapping.put(pjt_manpower.ProjectId__c , projectPartnerNameList);
            
            ProjectOrgIdMapping.put(pjt_manpower.PjtResourceId__r.PjtPartnerEmpId__r.PjtPartnerId__r.name , pjt_manpower.PjtResourceId__r.PjtPartnerEmpId__r.PjtPartnerId__c);
            ProjectMangerMapping.put(pjt_manpower.ProjectId__c , pjt_manpower.ProjectId__r.ProjectManagerId__c );
            // projectPartnerNameList.clear();
        }
        System.debug('ProjectOrgMapping '+ProjectOrgMapping);
        for(String ProjectId : ProjectOrgMapping.keySet()){
            System.debug('projectId '+ProjectId);
            List<AggregateResult> ProjectInputCountList;
            List<AggregateResult> PlannedBillMMList;
            List<AggregateResult> ProjectDate;
            
            for(String orgName : ProjectOrgMapping.get(ProjectId)){
                System.debug('orgName '+orgName);
                ProjectInputCountList = [SELECT count(FM_PartnerName__c) cntOrgName FROM PMS_PjtManpower__c where FM_PartnerName__c = :orgName and ProjectId__c =: ProjectId and InputStartDate__c != null];
                PlannedBillMMList = [SELECT sum(ActualInputMM__c) sumTotalMM FROM PMS_PjtManpower__c where ProjectId__c=: ProjectId and FM_PartnerName__c = :orgName];
                ProjectDate = [SELECT min(InputStartDate__c) startDate , max(InputEndDate__c) endDate FROM PMS_PjtManpower__c where FM_PartnerName__c = :orgName and ProjectId__c=: ProjectId];
                
                PMS_PjtPartnerInputProject__c pjtPartner = new 	PMS_PjtPartnerInputProject__c();
                
                pjtPartner.ProjectId__c = ProjectId;
                pjtPartner.ProjectInputMM__c = (Decimal)PlannedBillMMList[0].get('sumTotalMM') ;
                pjtPartner.ProjectPersonnel__c = ((Decimal)ProjectInputCountList[0].get('cntOrgName')==0) ? null : (Decimal)ProjectInputCountList[0].get('cntOrgName');
                pjtPartner.PjtPartnerId__c = ProjectOrgIdMapping.get(orgName);
                pjtPartner.ProjectPM__c = ProjectMangerMapping.get(ProjectId);
                pjtPartner.ProjectStartDate__c = (Date)ProjectDate[0].get('startDate');
                pjtPartner.ProjectEndDate__c = (Date)ProjectDate[0].get('endDate');
                List<PMS_PjtPartnerInputProject__c> pjtPartnerDuplicateList= [select id , ProjectId__c , PjtPartnerId__c , ProjectInputMM__c , ProjectPersonnel__c , ProjectStartDate__c, ProjectEndDate__c 
                                                                              from PMS_PjtPartnerInputProject__c where ProjectId__c=:ProjectId  and PjtPartnerId__c =: pjtPartner.PjtPartnerId__c limit 1];
                
                if(pjtPartnerDuplicateList.size() > 0) {            
                    for(PMS_PjtPartnerInputProject__c pms : pjtPartnerDuplicateList){
                        PMS_PjtPartnerInputProject__c p = new PMS_PjtPartnerInputProject__c();
                        p.Id = pms.Id;
                        p.ProjectInputMM__c = pjtPartner.ProjectInputMM__c;
                        p.ProjectPersonnel__c = pjtPartner.ProjectPersonnel__c;
                        p.ProjectStartDate__c = pjtPartner.ProjectStartDate__c;
                        p.ProjectEndDate__c = pjtPartner.ProjectEndDate__c;
                        PjtPartnerUpdateList.add(p);
                    }
                    PjtPartnerUpdateMap.putAll(PjtPartnerUpdateList);
                }else {
                    if(!PjtPartnerUpdateMap.containsKey(pjtPartner.PjtPartnerId__c+'_'+pjtPartner.ProjectId__c)) {
                        PjtPartnerUpdateMap.put(pjtPartner.PjtPartnerId__c+'_'+pjtPartner.ProjectId__c , pjtPartner);
                        
                    }
                }
                
            }
            
            
        }
        try{
            
            upsert PjtPartnerUpdateMap.values();
            

            PjtPartnerUpdateList.clear();  
        }catch(Exception e){
            System.debug('Exception '+e);
        }
        
        
    }
    
    public void finish(Database.BatchableContext BC) {
        System.debug('----- FINISH -----');
    }
}