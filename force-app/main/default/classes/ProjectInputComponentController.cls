public with sharing class ProjectInputComponentController {
	public Id objId {get; set;}
	public Id empId {get; set;}
	public String objType {get; set;}
	public String paQuery {get; set;}
	public Id selectedProjectId {get; set;}
	public List<Project_Assigned_Period__c> progressPaList;	//진행 중인 프로젝트
	public List<Project_Assigned_Period__c> expectedPaList;	//예정된 프로젝트

	public ProjectInputComponentController() {
		objId = Id.valueOf(ApexPages.currentPage().getParameters().get('id'));
		System.debug(objId);
		objType = Id.valueOf(objId).getSObjectType().getDescribe().getName();
		System.debug(objType);

		paQuery = 'SELECT '
				+ '		Id '
				+ '		, Project__c '
				+ '		, Project__r.Name '
				+ '		, Employee__c '
				+ '		, ProjectRole__c '
				+ '		, Billingtype__c '
				+ '		, ContractedMM__c '
				+ '		, TotalMM__c '
				+ '		, StartDate__c '
				+ '		, PlanedEndDate__c '
				+ '		, ActualEndDate__c '
				+ '		, Grade__c '
				+ '		, EngageType__c '
				+ '		, WorkingType__c '
				+ 'FROM '
				+ '		Project_Assigned_Period__c '
				+ 'WHERE ';
		
		if (objType == 'Employee__c') {
			paQuery += 'Employee__c = :objId ';
		} else if (objType == 'WorkTime__c') {
			empId = [SELECT Id, Employee__c FROM WorkTime__c WHERE Id = :objId Limit 1].Employee__c;
			paQuery += 'Employee__c = :empId ';
		}
	}

	public PageReference moveToProjectDetail() {
		PageReference pref = new PageReference('/' + selectedProjectId);
		pref.setRedirect(true);
		return pref;
	}

	public List<Project_Assigned_Period__c> getProgressPaList() {
		String progressPaQuery = paQuery 
			+ '		AND StartDate__c <= TODAY '
			+ '		AND (ActualEndDate__c = null OR ActualEndDate__c >= TODAY) ';

		List<Project_Assigned_Period__c> resultList = Database.query(progressPaQuery);
		return resultList;
	}

	public List<Project_Assigned_Period__c> getExpectedPaList() {
		String expectedPaQuery = paQuery 
			+ '		AND StartDate__c > TODAY ';

		List<Project_Assigned_Period__c> resultList = Database.query(expectedPaQuery);
		return resultList;
	}
}