@isTest
public class LeadToCampains_TEST {

    static Lead l;

    testMethod static void LeadRegist(){

            l = new Lead(LastName='test',Company='dkbmc',Visit_BizBlog__c=false,Visit_HomePage__c=false,Visit_IndustryDemo__c=false);
            insert l;

            l.LastName = 'test2';
            l.Company = 'dkbmc2';
			l.Visit_BizBlog__c = true;            
            l.Visit_HomePage__c = true;
            l.Visit_IndustryDemo__c = true;
            
            update l;            

    }
    
}