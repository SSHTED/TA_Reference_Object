@isTest
private class Milestone1_ShareToGrp_Controller_Test {
	static User user;
	static CollaborationGroup cg;
	static CollaborationGroupMember cgm;
	static Milestone1_Project__c project;
	static Milestone1_Milestone__c milestone;
	static Milestone1_Task__c task;

	static{
		Profile p1 = [SELECT id FROM Profile WHERE Name='System Admin'];
		user = new User(Alias = 'testadm', Email='SysAdminTestuser@team.dkbmc.com.dev',
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', EmployeeNumber='AC100000', ProfileId = p1.id,
                                TimeZoneSidKey='Asia/Seoul', UserName='SysAdminTestuser@team.dkbmc.com.dev');
		insert user;

		cg = new CollaborationGroup(Name = 'test for feed test', OwnerId = user.id, CollaborationType = 'Public', IsArchived = false);
		insert cg;

		cgm = new CollaborationGroupMember(CollaborationGroupId = cg.id);

		project = new Milestone1_Project__c(Name = 'test project');
		insert project;

		milestone = new Milestone1_Milestone__c(Name = 'tet milestone', Project__c = project.id, Complete__c = true);
		insert milestone;

		task = new Milestone1_Task__c(Name = 'Feed Test', Description__c = 'Test', selectedGroupId__c = cgm.CollaborationGroupId, 
									Project_Milestone__c = milestone.id, Complete__c = true);
		insert task;
	}

	static testMethod void myTest() {
		PageReference pref=Page.Milestone1_New_Task;
		Test.setCurrentPageReference(pref);
		ApexPages.StandardController sc= new ApexPages.StandardController(task);

		Test.startTest();
		system.runAs(user){
			pref.getParameters().put('id', task.id);
			Milestone1_ShareToGrp_Controller sgc = new Milestone1_ShareToGrp_Controller(sc);
			sgc.grpChk = true;
			sgc.loadGrpList();
			sgc.saveAndNew();
		}
		Test.stopTest();
	}
}