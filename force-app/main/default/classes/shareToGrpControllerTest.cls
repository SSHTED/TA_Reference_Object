@isTest
private class shareToGrpControllerTest {
	//필요한 오브젝트 선언
	static User user;
	static CollaborationGroup cg;
	static CollaborationGroupMember cgm;
	static Task task;
	
	static{
		//사용할 유저 설정
		Profile p1 = [SELECT id FROM Profile WHERE Name='System Admin'];
		user = new User(Alias = 'testadm', Email='SysAdminTestuser@team.dkbmc.com.dev',
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                LocaleSidKey='en_US', EmployeeNumber='AC100000', ProfileId = p1.id,
                                TimeZoneSidKey='Asia/Seoul', UserName='SysAdminTestuser@team.dkbmc.com.dev');
		insert user;

		//필요한 데이터 설정 : insert할 task데이터와 참조할 collaborationGroup 데이터
		cg = new CollaborationGroup(Name = 'test for feed test', OwnerId = user.id, CollaborationType = 'Public', IsArchived = false);
		insert cg;

		cgm = new CollaborationGroupMember(CollaborationGroupId = cg.id);

		task = new Task(OwnerId = user.id, Subject = 'Feed Test', Description = 'Test', selectedGroupId__c = cgm.CollaborationGroupId,
						Priority = 'Normal', Status = 'Not Started');
		insert task;	
	}

	static testMethod void myTest() {
		// 이 부분은 확인...???
		PageReference pref=Page.CreateTask;
		Test.setCurrentPageReference(pref);
		ApexPages.StandardController sc = new ApexPages.StandardController(task);

		Test.startTest();
		system.runAs(user){
			//작성..
			pref.getParameters().put('id', task.id);
			shareToGrpController sgc = new shareToGrpController(sc);
			sgc.grpChk = true;
			sgc.loadGrpList();
            sgc.saveAndNewTask();
            sgc.saveAndNewEvent();
		}
		Test.stopTest();
	}
}