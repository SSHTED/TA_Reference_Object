public class ResumeTaskManage {

    public void taskCreate(String resumeId, String condition, Date resumeCreatedDate){
	//public void taskCreate(String name, String email){
        
        // 유저 중에서 채용담당자를 검색합니다.
        List<User> userLst = [SELECT Id FROM User WHERE Recruit__c =true];
		System.debug(userLst);
        System.debug('userLst size : ' + userLst.size());
        System.debug('resumeId : ' + resumeId);
        System.debug('condition : ' + condition);
        System.debug('resumeCreatedDate : ' + resumeCreatedDate);

        // Task 생성을 위한 List 입니다.
        List<Task> taLst = new List<Task>();

        // 채용담당자의 Task를 생성합니다.
        for(integer i=0; i < userLst.size(); i++){
            Task ta = new Task(OwnerId = userLst[i].Id , Subject = '면접일자 정하기 : ' + condition , Status = 'Not Started', 
                                Priority = 'Normal', ActivityDate = resumeCreatedDate + 3 , WhatId = resumeId);
            taLst.add(ta);
            System.debug('Task OwnerId : ' + ta.OwnerId);
        }
		
        insert taLst;
		
    }    
}