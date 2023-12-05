public with sharing class LeadConvertController {
    
    private Id leadId;
    public Account myA              {get;set;}
    public Opportunity__c myB          {get;set;}
    public Contact myC              {get;set;}
         
    public Lead_custom__c myL       {get;set;}

 
    public LeadConvertController(){
        
        leadId  = (String) ApexPages.currentPage().getParameters().get('id');
          
          
           myL = [SELECT
           ID
           , Name
           , OwnerId
           , status__c
           , industry__c
           , Phone__c
           , Title__c
           , Address__c 
           , Company__c
           , Fax__c
           , Disabled__c
           , Description__c
           , Website__c
           , AnnualRevenue__c
           , leadsource__c
           FROM Lead_custom__c WHERE Id = :leadId];
           
           
            myA = new Account();
            myA.Name = myL.Company__c;
            myA.OwnerId = myL.OwnerId;
            myA.Fax = myL.fax__c;
            myA.industry = myL.industry__c;
            myA.Website = myL.Website__c;
            myA.AnnualRevenue = myL.AnnualRevenue__c;
            myA.BillingCity = myL.Address__c;
            myA.Description = myL.Description__c;
            
            myB = new Opportunity__c();
            myB.Account__c = myA.id;
            myB.Name = myL.Name + '기회';
            myB.OwnerId=myL.OwnerId;
            myB.StageName__c = '초기접촉';
            myB.CloseDate__c = date.Today()+ 10;
            myB.leadsource__c = myL.leadsource__c;
               
                    
            myC = new Contact();
            myC.LastName = myL.Name;
            myC.Phone = myL.Phone__c;
            myC.Title = myL.Title__c;
            
            
     }
    
             
     public void saveAcc() {
        
            if(myL.disabled__c == false){
            insert myA;
            myB.Account__c = myA.Id;
            insert myB;
            
 
            myC.accountId = myA.Id;
            insert myC;
            delete myL;
            
            }else{
        
            insert myA;
 
            myC.accountId = myA.Id;
            insert myC;
            
            delete myL;
            }
        }
  
}