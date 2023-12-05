public with sharing class shareToGrpController {
	public Boolean grpChk {get; set;}
	public List<CollaborationGroupMember> grpName {get; set;}
	public List<SelectOption> options {get; set;}
	public String currentUserId {get; set;}
	
	Task newTask = new Task();

	//생성자
	public shareToGrpController(ApexPages.StandardController stdController) {
		grpChk = false;
		currentUserId = UserInfo.getUserId();
		this.newTask = (Task)stdController.getRecord();
		newTask.OwnerId = currentUserId;
    }

	//////////////////////////////셀렉리스트에 그룹명 추가할 함수들/////////////////////////
	//사용자가 속해있는 채터 그룹을 가져와서 selectList에 option으로 추가///////////
	public void queryGrpName(){
		grpName=[SELECT CollaborationGroupId, CollaborationGroup.IsArchived, CollaborationGroup.Name FROM CollaborationGroupMember WHERE MemberId = :currentUserId]; //'00528000000ILDXAA4']; //
		System.debug(grpName);

		options = new List<SelectOption>();

		options.add(new SelectOption('','--선택해주세요.--'));
			
		if(grpName.size()==0){
			options.add(new SelectOption('','그룹이 없습니다.'));
		}else{
			Integer i=0;
			for(i=0;i<grpName.size();i++){
				if(grpName.get(i). CollaborationGroup.IsArchived==false){
					options.add(new SelectOption((grpName.get(i)).CollaborationGroupId, (grpName.get(i)).CollaborationGroup.Name));
				}
			}
		}
	}

	//체크박스 변경시 selectList에 채터 그룹 이름 가져오기
	public PageReference loadGrpList() {

		if(grpChk){
			queryGrpName();
		}

		return null;
	}
	//////////////////////////////////////////////////////////////////////////////////////


    /////////////////////////////버튼 클릭시 수행할 함수들///////////////////////////////////
	//저장 및 새 작업
	public PageReference saveAndNewTask() {
		PageReference newPage = New PageReference('/apex/CreateTask'); 
		System.debug(newPage);

		////newTask에 데이터 넣기....
		if (!Test.isRunningTest()) {
			try{
				Insert newTask;						
			}catch(Exception ex){
				newPage = null;
				ApexPages.addMessages(ex);
			}	
		}
		
		newPage.setRedirect(true);
		return newPage;		
	}

	//저장 및 새 이벤트
	public PageReference saveAndNewEvent() {		
		PageReference newPage = New PageReference('/00U/e');
		System.debug(newPage);		

		////newTask에 데이터 넣기....
		if (!Test.isRunningTest()) {
			try{
				Insert newTask;						
			}catch(Exception ex){
				newPage = null;
				ApexPages.addMessages(ex);
			}	
		}
		
		newPage.setRedirect(true);
		return newPage;
	}
	////////////////////////////////////////////////////////////////////////////////
}