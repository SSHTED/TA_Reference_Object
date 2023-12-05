@isTest
public class ResumeSearchTest {
	static User user;
    static Resume__c re;
    static String action;
    static String name;
    static String email;
    
    static testMethod void testDoPost(){
    
   	 	RestRequest req = new RestRequest();
    	RestResponse res = new RestResponse();
        
        Datetime date1st = Datetime.newInstance(2017, 1, 19 , 12, 30, 0);
        Datetime date2nd = Datetime.newInstance(2017, 1, 19 , 12, 30, 0);
        
		re = new Resume__c(Name='Tester', OwnerId='00528000000IBiCAAW', Condition__c='1차면접대상',
                           Email__c='email@naver.com', InterviewDate1st__c=date1st, InterviewDate2nd__c=date2nd);      
        insert re;
    
        req.requestURI = '/services/apexrest/resumeSearch/';
        req.addParameter('action', 'resultConfirm');
        req.addParameter('name', 'tester');
        req.addParameter('email', 'email@naver.com');
        
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
       
        Test.startTest();
        //Map<String, String> rs = ResumeSearch.doPost('resultConfirm', 'tester', 'email@naver.com');
		Map<String, String> rs2 = ResumeSearch.doPost('searchCondition', 'tester', 'email@naver.com');        
        Test.stopTest();
    }
}