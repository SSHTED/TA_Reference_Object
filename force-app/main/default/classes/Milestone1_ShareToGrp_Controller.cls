public class Milestone1_ShareToGrp_Controller {
	public Boolean grpChk {get; set;}
	public List<CollaborationGroupMember> grpName {get; set;}
	public List<SelectOption> options {get; set;}

	Milestone1_Task__c newTask = new Milestone1_Task__c();
	
    //생성자
    public Milestone1_ShareToGrp_Controller(ApexPages.StandardController stdController) {
		grpChk=false;
		this.newTask=(Milestone1_Task__c)stdController.getRecord();
    }

    //사용자가 속해있는 채터 그룹을 가져와서 selectList에 option으로 추가///////////
	public void queryGrpName(){
		String currentUserId = UserInfo.getUserId();
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

    //저장 후 새로 만들기    
    public PageReference saveAndNew(){
    	PageReference newPage = new PageReference('/apex/Milestone1_New_Task');

		if (!Test.isRunningTest()) {
			try{
				Insert newTask;						
				newPage.setRedirect(true);
			}catch(Exception ex){
				newPage = null;
				ApexPages.addMessages(ex);
			}	
		}		
		
		return newPage;    	
    }
}