@isTest
private class TestCustomerSupport {
	
	static CustomerSupport__c cs;
	static CustomerSupportSolution__c sol;
	static JuncCustomerSupportSolution__c junc;
	static Milestone1_Project__c mp;
	static Account ac;
	static Contact ct;
	static CustomerSupportCharge__c cst;

	static testMethod void test() {
		ac = new Account();
		ac = new account(Name = 'DKBMC');

		insert ac;
		
		ct = new Contact();
		ct.lastname ='황';

		insert ct;

		mp = new Milestone1_Project__c();
		mp.RecordTypeId = '0120I0000011JKJ';
		mp.Name = '대한항공';
		mp.endcustomer__c = ac.id;
		mp.Status__c = 'Planning';

		insert mp;

		User user = new User(Alias = 'testUser'
                            , Email='SysAdminTestuser@earth.org'
                            , EmailEncodingKey='UTF-8'
                            , LastName='Testing'
                            , LanguageLocaleKey='en_US'
                            , LocaleSidKey='en_US'
                            , EmployeeNumber='AC100000'
                            , ProfileId = '00e28000000Wt7B'
                            , TimeZoneSidKey='Asia/Seoul'
                            , UserName='SysAdminTestuser@earth.org'
                            , IsHoliday_Target__c = true);
                                
        insert user;

		cst = new CustomerSupportCharge__c();
		cst.Contact__c = ct.id;
		cst.User__c = user.id;

		insert cst;

		

		cs = new CustomerSupport__c();		
		cs.SourcePath__c = '웹사이트';
		cs.Name__c = '고대근';
		cs.Phone__c = '010-2636-5411';
		cs.Email__c = 'daekeun.ko@dkbmc.com';
		cs.ServiceType__c = 'Salesforce.com';
		cs.Title__c = '테스트';
		cs.Description__c = '테스트확인';
		cs.Project__c = mp.id;
		cs.Contact__c = ct.id;
		insert cs;
		
		cs.status__c = '완료';
		
		update cs;


		
		sol = new CustomerSupportSolution__c();
		sol.SolutionSubject__c = '제목';
		sol.SolutionDetail__c = '내용';
		
		insert sol;
		
		
		junc = new JuncCustomerSupportSolution__c();
		junc.CustomerSupport__c = cs.Id;
		junc.CustomerSupportSolution__c = sol.Id;
		
		insert junc;
		
		sol.SolutionSubject__c = '제목변경';
		update sol;
		
		delete sol;
	}

}