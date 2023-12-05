@isTest(SeeAllData=true)
public class BCRaffleEmail_TEST {
    static testmethod void Airpot() {                         
        insert new Lead(LastName='test',Company='dkbmc',Visit_BizBlog__c=true,Visit_HomePage__c=true,Visit_IndustryDemo__c=true); 
        BCRaffle Raffle = new BCRaffle();
        Raffle.Airpot();        
        BCRaffleEmail e_mail = new BCRaffleEmail();
        e_mail.Airpot();
    }
    static testmethod void TwoSome() {
        insert new Lead(LastName='test',Company='dkbmc',Visit_BizBlog__c=true,Visit_HomePage__c=true,Visit_IndustryDemo__c=true);     
        BCRaffle Raffle = new BCRaffle();
        Raffle.TwoSome();  
        BCRaffleEmail e_mail = new BCRaffleEmail();
        e_mail.TwoSome();
    }
    static testmethod void Other() {     
        //insert new EmailTemplate(Name = 'BC Participation Other2',DeveloperName='E');
        insert new Lead(LastName='test',Company='dkbmc',Visit_BizBlog__c=true,Visit_HomePage__c=true,Visit_IndustryDemo__c=true);      		
        BCRaffleEmail e_mail = new BCRaffleEmail();
        e_mail.Other();
    }
    static testmethod void Other2() {
        BCRaffleEmail e_mail = new BCRaffleEmail();
        e_mail.a();
    }
}