@isTest
private class Time_EmpInsert_Test {
	static Employee__c e;
	static Milestone1_Project__c mp;
	static Milestone1_Milestone__c mm;
	static Milestone1_Task__c mt;
	static Milestone1_Time__c mti;
	static Account ac;

	@isTest static void test_method_one() {
		Test.startTest();
		User user = new User(Alias = 'testUser'
                            , Email='SysAdminTestuser@earth.org'
                            , EmailEncodingKey='UTF-8'
                            , LastName='Testing'
                            , LanguageLocaleKey='en_US'
                            , LocaleSidKey='en_US'
                            , EmployeeNumber='140001'
                            , ProfileId = '00e28000000Wt7B'
                            , TimeZoneSidKey='Asia/Seoul'
                            , UserName='SysAdminTestuser@earth.org'
                            , IsHoliday_Target__c = true);
                                
        insert user;

		System.runAs(user) {
		e = new Employee__c (Emp_No__c = '140001',
		Name='황병훈',
		Rank__c='대리',
		Start__c=system.today());
		insert e;
		ac = new Account(Name = 'DKBMC');
		mp = new Milestone1_Project__c (RecordTypeId = '0120I0000011JKJ',
										 Name = '대한항공',
										 endcustomer__c = ac.id,
										 Status__c = 'Planning');
		insert mp;

		mm = new Milestone1_Milestone__c(Name = '대한항공 사전준비', Project__c = mp.id);
		insert mm;

		mt = new Milestone1_Task__c(Name= '대한항공 준비', Project_Milestone__c = mm.id);
		insert mt;

		mti = new Milestone1_Time__c(Project_Task__c = mt.id);
		insert mti;
		}

		Test.stopTest();
	}
	

	
}