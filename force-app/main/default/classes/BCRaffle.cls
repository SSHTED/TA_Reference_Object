public class BCRaffle {
    // Airpot
    public void Airpot(){
        String C_id_r = System.Label.Campaign_Id_Raffle;        
        if(Test.isRunningTest()){
            C_id_r = System.Label.Campaign_Id;
        }
        List <String> A_Id_list = new List<String>();
        List <CampaignMember> CM_List = [SELECT Id, LeadId, Email, FirstName, LastName, Gifts__C FROM CampaignMember where CampaignId=: C_id_r and ((Lead.Visit_BizBlog__c = true and Lead.Visit_HomePage__c = true and Lead.Visit_IndustryDemo__c = true ) or (Contact.Visit_BizBlog__c = true and Contact.Visit_HomePage__c = true and Contact.Visit_IndustryDemo__c = true)) and Gifts__C = null Order by CreatedDate desc];    
        Integer A_l_count = CM_List.size();
        Map <String,String> A_map = new map<String,String>();    
        Integer randomNumber = 0;
        Boolean Check = True;
        if (A_l_count > 3){
            while(Check){
                randomNumber = Integer.valueof((Math.random() * A_l_count));    
                A_map.put(CM_List[randomNumber].Id,'Airpot');        
                if (A_map.size() == 3){
                    Check = False;
                }    
            }
            A_Id_list.addAll(A_map.Keyset());    
        }
        else{    
            for (CampaignMember cm : CM_List){
                A_Id_list.add(cm.Id);
            }
        }
        
        
        List <CampaignMember> A_cm_list = [SELECT id, Gifts__C FROM CampaignMember where Id in :A_Id_list];    
        for (CampaignMember cm : A_cm_list){
            cm.Gifts__C = 'Airpot';
        }
        update A_cm_list;
    }
    // TwoSome
    public void TwoSome(){
        String C_id_r = System.Label.Campaign_Id_Raffle;
        if(Test.isRunningTest()){
            C_id_r = System.Label.Campaign_Id;
        }
        //Integer T_l_count = Integer.valueof([SELECT count(Id) FROM CampaignMember where CampaignId=: C_id_r and ((Lead.Visit_BizBlog__c = true and Lead.Visit_HomePage__c = true and Lead.Visit_IndustryDemo__c = true ) or (Contact.Visit_BizBlog__c = true and Contact.Visit_HomePage__c = true and Contact.Visit_IndustryDemo__c = true)) and Gifts__C = null][0].get('expr0')); 
        List<String> T_Id_list = new List<String>();
        List <CampaignMember> CM_List = [SELECT Id, LeadId, Email, FirstName, LastName, Gifts__C FROM CampaignMember where CampaignId=: C_id_r and ((Lead.Visit_BizBlog__c = true and Lead.Visit_HomePage__c = true and Lead.Visit_IndustryDemo__c = true ) or (Contact.Visit_BizBlog__c = true and Contact.Visit_HomePage__c = true and Contact.Visit_IndustryDemo__c = true)) and Gifts__C = null Order by CreatedDate desc];    
        Integer T_l_count = CM_List.size();
        Map <String,String> T_map = new map<String,String>();    
        Integer randomNumber = 0;
        Boolean Check = True;
        if (T_l_count > 20){
            while(Check){
                randomNumber = Integer.valueof((Math.random() * T_l_count));    
                T_map.put(CM_List[randomNumber].Id,'TwoSome');        
                if (T_map.size() == 20){
                    Check = False;
                }    
            }
            T_Id_list.addAll(T_map.Keyset());    
        }
        else{    
            for (CampaignMember cm : CM_List){
                T_Id_list.add(cm.Id);
            }
        }
        
        
        List <CampaignMember> T_l_list = [SELECT id, Gifts__C FROM CampaignMember where Id in :T_Id_list];    
        for (CampaignMember cm : T_l_list){
            cm.Gifts__C = 'TwoSome';
        }
        update T_l_list;
    }   
}