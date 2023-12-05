@isTest(SeeAllData=true)
public class BCRaffle_TEST {
    static testmethod void Airpot() {        
        for (integer i = 0 ; i < 4 ; i++){
            String randomNumber = String.valueof((Math.random() * 100));        
            insert new Lead(LastName=randomNumber ,Company=randomNumber,Email= randomNumber+'@dkbmc.com',Visit_BizBlog__c=true,Visit_HomePage__c=true,Visit_IndustryDemo__c=true);                   
        }
        
        
        BCRaffle Raffle = new BCRaffle();
        Raffle.Airpot();
    }
    static testmethod void TwoSome() {
        List <Lead> l_list = new List<Lead>();
        for (integer i = 0 ; i < 21 ; i++){
            String randomNumber = String.valueof((Math.random() * 100));
            l_list.add(new Lead(LastName = randomNumber, Company = randomNumber,Email= randomNumber+'@dkbmc.com' ,Visit_BizBlog__c=true,Visit_HomePage__c=true,Visit_IndustryDemo__c=true));                          
        }
        insert l_list;
        
        BCRaffle Raffle = new BCRaffle();
        Raffle.TwoSome();
    }
    static testmethod void Airpot2() {        
        
        String randomNumber = String.valueof((Math.random() * 100));        
        insert new Lead(LastName=randomNumber ,Company=randomNumber,Email= randomNumber+'@dkbmc.com',Visit_BizBlog__c=true,Visit_HomePage__c=true,Visit_IndustryDemo__c=true);                   
        
        BCRaffle Raffle = new BCRaffle();
        Raffle.Airpot();
    }
    static testmethod void TwoSome2() {
        List <Lead> l_list = new List<Lead>();
        
        String randomNumber = String.valueof((Math.random() * 100));
        l_list.add(new Lead(LastName = randomNumber, Company = randomNumber,Email= randomNumber+'@dkbmc.com' ,Visit_BizBlog__c=true,Visit_HomePage__c=true,Visit_IndustryDemo__c=true));                          
        
        insert l_list;
        
        BCRaffle Raffle = new BCRaffle();
        Raffle.TwoSome();
    }
    
    
}