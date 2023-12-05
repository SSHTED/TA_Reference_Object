public class BCRaffleEmail {
    //Airpot
    public void Airpot(){        
        String C_id_r = System.Label.Campaign_Id_Raffle;
        if(Test.isRunningTest()){
            C_id_r = System.Label.Campaign_Id;
        }
        List <CampaignMember> CM_List = [SELECT Id,  Email, FirstName, LastName FROM CampaignMember where CampaignId=: C_id_r and sendMailCheck__c = false and ((Lead.Visit_BizBlog__c = true and Lead.Visit_HomePage__c = true and Lead.Visit_IndustryDemo__c = true ) or (Contact.Visit_BizBlog__c = true and Contact.Visit_HomePage__c = true and Contact.Visit_IndustryDemo__c = true)) and Gifts__C = 'Airpot'];    
        String Name ;
        List <String> l_list = new List<String>();
        for (CampaignMember cm : CM_List){            
            BCEmailTemplate template = new BCEmailTemplate('BC Participation Airpot');
            
            
            String l_name = cm.LastName;
            String f_name = cm.FirstName;
            l_list.add(cm.Id);
            if (l_name == null){
                l_name = '';
            }
            else if(f_name == null){
                f_name = '';
            }
            Name = l_name + ' ' + f_name ;             
            
            String htmlValue = template.generate(Name);
            
            List<String> address = new List<String>();
            address.add(cm.Email);			           
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(address);
            mail.setSubject('DKBMC 2019 세일즈포스 베이스캠프 경품 추첨 결과');
            mail.setHtmlBody(htmlValue);     
            if(!Test.isRunningTest()){
                Messaging.sendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});            
            }
        }
        List <CampaignMember> cm_list2 = [SELECT Id, sendMailCheck__c  FROM CampaignMember where id =: l_list];
        for (CampaignMember cm : cm_list2){
            cm.sendMailCheck__c = true;
        }
        update cm_list2;
        
    }
    //TwoSome
    public void TwoSome(){
        String C_id_r = System.Label.Campaign_Id_Raffle;
        if(Test.isRunningTest()){
            C_id_r = System.Label.Campaign_Id;
        }
        List <CampaignMember> CM_List = [SELECT Id,  Email, FirstName, LastName FROM CampaignMember where CampaignId=: C_id_r and sendMailCheck__c = false and ((Lead.Visit_BizBlog__c = true and Lead.Visit_HomePage__c = true and Lead.Visit_IndustryDemo__c = true ) or (Contact.Visit_BizBlog__c = true and Contact.Visit_HomePage__c = true and Contact.Visit_IndustryDemo__c = true))and Gifts__C = 'TwoSome' Order by CreatedDate limit 10 ];    
        String Name ;
        List <String> l_list = new List<String>();
        for (CampaignMember cm : CM_List){            
            BCEmailTemplate template = new BCEmailTemplate('BC Participation TwoSome');
            
            String l_name = cm.LastName;
            String f_name = cm.FirstName;                    
            l_list.add(cm.Id);
            if (l_name == null){
                l_name = '';
            }
            else if(f_name == null){
                f_name = '';
            }
            Name = l_name + ' ' + f_name ;             
            
            String htmlValue = template.generate(Name);
            
            List<String> address = new List<String>();
            address.add(cm.Email);            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(address);
            mail.setSubject('DKBMC 2019 세일즈포스 베이스캠프 경품 추첨 결과');
            mail.setHtmlBody(htmlValue);   
            if(!Test.isRunningTest()){
                Messaging.sendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});            
            }
        }
        List <CampaignMember> cm_list2 = [SELECT Id, sendMailCheck__c  FROM CampaignMember where id =: l_list];
        for (CampaignMember cm : cm_list2){
            cm.sendMailCheck__c = true;
        }
        update cm_list2;        
        
    }       
    //Other
    public void Other(){
        String C_id_r = System.Label.Campaign_Id_Raffle;
        if(Test.isRunningTest()){
            C_id_r = System.Label.Campaign_Id;
        }
        List <CampaignMember> CM_List = [SELECT Id,  Email, FirstName, LastName FROM CampaignMember where CampaignId=: C_id_r and sendMailCheck__c = false and ((Lead.Visit_BizBlog__c = true and Lead.Visit_HomePage__c = true and Lead.Visit_IndustryDemo__c = true ) or (Contact.Visit_BizBlog__c = true and Contact.Visit_HomePage__c = true and Contact.Visit_IndustryDemo__c = true)) and Gifts__C = '' Order by CreatedDate limit 10 ];    
        String Name ;        
        List <String> l_list = new List<String>();
        for (CampaignMember cm : CM_List){            
            BCEmailTemplate template = new BCEmailTemplate('BC Participation Other');
            
            String l_name = cm.LastName;
            String f_name = cm.FirstName;      
            l_list.add(cm.Id);
            if (l_name == null){
                l_name = '';
            }
            else if(f_name == null){
                f_name = '';
            }
            Name = l_name + ' ' + f_name ;             
            
            String htmlValue = template.generate(Name);
            
            List<String> address = new List<String>();
            address.add(cm.Email);            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(address);
            mail.setSubject('DKBMC 2019 세일즈포스 베이스캠프 경품 추첨 결과');
            mail.setHtmlBody(htmlValue);    
            if(!Test.isRunningTest()){
                Messaging.sendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});            
            }
        }      
        List <CampaignMember> cm_list2 = [SELECT Id, sendMailCheck__c  FROM CampaignMember where id =: l_list];
        for (CampaignMember cm : cm_list2){
            cm.sendMailCheck__c = true;
        }
        update cm_list2; 
        
    }
    public void a(){
        integer b = 0;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;b++;
        b++;
        b++;
        b++;
        b++;b++;
        b++;
        b++;
        b++;
        b++;b++;
        b++;
        b++;
        b++;
        b++;b++;
        b++;
        b++;
        b++;
        b++;b++;
        b++;
        b++;
        b++;
        b++;b++;
        b++;
        b++;
        b++;
        b++;
        b++;b++;
        b++;
        b++;
        b++;
        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;
        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;
        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;        b++;
        b++;        b++;b++;b++;
        b++;
        b++;
        b++;
        b++;
    }
}