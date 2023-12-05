@isTest
public class LeadCopyTriggerTest {
    
    @isTest static void insertLead(){
        Lead leadToInsert = new Lead(LastName='Kim',Phone='010-6658-5656',Company='DKBMC');
        insert leadToInsert;
        
        lead_custom__c lc = [SELECT Id,Name,Phone__c FROM lead_custom__c ORDER BY CreatedDate DESC LIMIT 1];
        System.assertEquals(leadToInsert.Phone, lc.Phone__c);
        System.assertEquals(leadToInsert.LastName, lc.Name);
    }
    
    /*
    @isTest static void updateLead(){
        Lead leadToInsert = new Lead(LastName='Kim',Phone='010-6658-5656',Company='DKBMC',pi__comments__c='BEFORE');
        insert leadToInsert;
        
        Lead leadToUpdate = [SELECT Id, LastName, Phone, pi__comments__c FROM Lead LIMIT 1];
        
        leadToUpdate.pi__comments__c = 'changed !!';
        update leadToUpdate;
        
        lead_custom__c lc = [SELECT Id,Name,Phone__c,Pardot_Comments__c FROM lead_custom__c ORDER BY CreatedDate DESC LIMIT 1];
        System.assertEquals(leadToUpdate.pi__comments__c, lc.Pardot_Comments__c);
    }*/
}