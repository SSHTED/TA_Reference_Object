@isTest
private class TEST_LeadCopy {


static testmethod void test_trigger(){
   
    
  lead_custom__c lc = new lead_custom__c(
        Name='te2ttest',
        Company__c='DK',  
        rating__c='Hot',
        Status__c='Open - Not Contacted',
        LeadSource__c='Web',
        Description__c='test',
        Industry__c='Banking',
        AnnualRevenue__c=1000000,
        Website__c='www.test.com',
        Email__c='test@dkbmc.com',
        Phone__c='00-000-0000',
        Address__c='test',
        Title__c='ceo',
        NumberOfEmployees__c=1000
        );
  insert lc;

 Lead le = new Lead(
        FirstName='test',
        LastName='te2t',
        Company='DK',  
        rating='Hot',
        Status='Open - Not Contacted',
        LeadSource='Web',
        Description='test',
        Industry='Banking',
        AnnualRevenue=1000000,
        Website='www.test.com',
        Email='test@dkbmc.com',
        Phone='00-000-0000',
        Addr__c='test',
        Title='ceo',
        NumberOfEmployees=1000
        );
  insert le;
  
}

}