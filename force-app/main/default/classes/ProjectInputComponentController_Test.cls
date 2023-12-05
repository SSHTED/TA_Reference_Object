@isTest
private class ProjectInputComponentController_Test {
	static Employee__c emp;
	static WorkTime__c wt;
	static Account ac;
	static Milestone1_Project__c proj;
	static ProjectResource__c prs;
	static Project_Assigned_Period__c pa;

	static {
		emp = new Employee__c(Emp_No__c = '180001', Name = 'test user', Rank__c = '사원', Start__c = Date.today());
		insert emp;

		wt = new WorkTime__c(Work_Time__c = '09:00 ~ 18:00', Employee__c = emp.Id);
		insert wt;

		ac = new Account(Name = 'test account');
		insert ac;

		proj = new Milestone1_Project__c(Name = 'test project', endcustomer__c = ac.Id, Status__c = 'Active');
		insert proj;

		prs = new ProjectResource__c(Type__c = 'DKBMC 직원', ResourceName__c = 'test user', Employee__c = emp.Id);
		insert prs;

		pa = new Project_Assigned_Period__c(Project__c = proj.Id, ProjectResource__c = prs.Id, Employee__c = emp.Id, 
						StartDate__c = Date.today(), PlanedEndDate__c = Date.today().addMonths(1));
		insert pa;
	}
	
	@isTest static void test_method_one() {
		PageReference pref = Page.ProjectInputList_Employee;
		Test.setCurrentPageReference(pref);
		pref.getParameters().put('id', emp.Id);

		ProjectInputComponentController picc = new ProjectInputComponentController();
		picc.selectedProjectId = proj.Id;
		picc.moveToProjectDetail();
		picc.getProgressPaList();
		picc.getExpectedPaList();
	}

	@isTest static void test_method_two() {
		PageReference pref = Page.ProjectInputList_WorkTime;
		Test.setCurrentPageReference(pref);
		pref.getParameters().put('id', wt.Id);

		ProjectInputComponentController picc = new ProjectInputComponentController();
		picc.getProgressPaList();
		picc.getExpectedPaList();
	}
}