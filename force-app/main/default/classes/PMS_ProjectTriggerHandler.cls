public with sharing class PMS_ProjectTriggerHandler {

	private Boolean isExecuting {get;set;} 	// Web Service와 구분하기 위한 Context 파라미터
	private Integer size {get;set;} 		// Trigger에서 Execute된 List Size

	public PMS_ProjectTriggerHandler(Boolean isExecuting, Integer size){
		this.isExecuting = isExecuting;
		this.size = size;

		System.debug('#isExecuting [' + isExecuting + '] #size [' + size + ']');
	}

	public void onBeforeDelete(List<sObject> dels, Map<Id, sObject> delMap){
		// Business Logic
	}

	public void onBeforeInsert(List<PMS_Project__c> news){
        if(this.size == 1) {
            if(news.get(0).ProjectManagerId__c != null) {
                List<PMS_PjtResource__c> prList = [select EmployeeId__r.User__c from PMS_PjtResource__c where Id = :news.get(0).ProjectManagerId__c];
                if(prList.size() == 1) {
                    if(prList.get(0).EmployeeId__r.User__c != null) {
                        news.get(0).OwnerId = prList.get(0).EmployeeId__r.User__c;
                    }
                }
            }
        }

		System.debug('size ? ' + news.size());
        if(news.size() == 1){ // 230206_이호재 AutoNumber 기능 추가

            String thisYear = String.valueOf(System.today().year());
            String cutThisYear = 'PJT-' + thisYear + '-%';
            System.debug('올해는 ? ' + cutThisYear);

            // List로 변환해서 사이즈 1이면 그대로 로직, 없으면 디폴트로 하나넣어주기
            List<PMS_Project__c> pCodeList = [SELECT Id, ProjectCode2__c
											  FROM PMS_Project__c
											  WHERE ProjectCode2__c != null
											  AND ProjectCode2__c LIKE :cutThisYear
											  ORDER BY ProjectCode2__c DESC
											  LIMIT 1];
            System.debug('pCodeList는 ? ' + pCodeList);
            System.debug('pCodeList size는 ? ' + pCodeList.size());
            
            // O-22-0011 PJT-2023-0001
            if(pCodeList == null || pCodeList.size() == 0){
                System.debug('new !');
                news.get(0).ProjectCode2__c = 'PJT-' + thisYear + '-0001';
            }else if(pCodeList != null || pCodeList.size() == 1){
                System.debug('old !');
                String cCode;
                for(PMS_Project__c p : pCodeList){
                    cCode = String.valueOf(p.ProjectCode2__c);
                }
                System.debug('pCode는 ? ' + cCode);

                Integer subCode = Integer.valueOf(cCode.substring(9));
                System.debug('subCode ? ' + subCode);
                String plusOneCode = String.valueOf(subCode + 1);
                System.debug('plusOneCode ? ' + plusOneCode);

                String lpadedCode = plusOneCode.leftPad(4, '0');
                System.debug('lpadedCode ? ' + lpadedCode);
                news.get(0).ProjectCode2__c = 'PJT-' + thisYear + '-' + lpadedCode;
            }
        }
	}

	public void onBeforeUpdate(List<PMS_Project__c> olds, List<PMS_Project__c> news, Map<Id, PMS_Project__c> oldMap, Map<Id, PMS_Project__c> newMap){
        if(this.size == 1){
            if(news.get(0).Status__c == 'Completed' && oldMap.get(news.get(0).Id).Status__c != news.get(0).Status__c){
            	news.get(0).PerformedStage__c = '완료';
            }
        }
	}

	public void onAfterDelete(List<sObject> dels, Map<Id, sObject> delMap){
		// Business Logic
	}

	public void onAfterInsert(List<PMS_Project__c> news){
		if(this.size == 1){ // 221227_이호재 신규 프로젝트 생성 시 알림 메일 발송
			String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/PMS_Project__c/' + news.get(0).Id + '/view';
			System.debug('recordUrl : ' + recordUrl);

			if(news.get(0).ProjectManagerId__c != null){
				String projectName = [SELECT Name FROM PMS_Project__c WHERE Id = :news.get(0).Id LIMIT 1].Name;
				System.debug('projectName : ' + projectName);
				String projectCode = [SELECT ProjectCode2__c FROM PMS_Project__c WHERE Id = :news.get(0).Id LIMIT 1].ProjectCode2__c;
				System.debug('projectCode : ' + projectCode);
				Date ContractStartDate = [SELECT ContractStartDate__c FROM PMS_Project__c WHERE Id = :news.get(0).Id LIMIT 1].ContractStartDate__c;
                Date ContractEndDate = [SELECT ContractEndDate__c FROM PMS_Project__c WHERE Id = :news.get(0).Id LIMIT 1].ContractEndDate__c;
                String projectManager = [SELECT ProjectManagerId__r.name FROM PMS_Project__c WHERE Id = :news.get(0).Id LIMIT 1].ProjectManagerId__r.name;
                

				List<String> toAddresses = new List<String>();

				PMS_Project__c pjt = [SELECT ProjectManagerId__r.FM_Email__c FROM PMS_Project__c WHERE Id = :news.get(0).Id LIMIT 1];

				if(pjt.ProjectManagerId__r.FM_Email__c != null) {
					toAddresses.add(pjt.ProjectManagerId__r.FM_Email__c); // PM
					// 2023.11.30 안종민 : 받는 사람 PM + 오퍼레이션팀( 나대영 부장님 ) 추가
					toAddresses.add(UTIL_Email.getOPERATIONAddress()[0]);
				}
				System.debug('toAddresses : ' + toAddresses);

				// 230116_이호재 참조에 HR팀 추가
				List<String> ccAddresses = UTIL_Email.getHRAddresses();
				System.debug('ccAddresses : ' + ccAddresses);
				
				// 숨은참조에 EPMO(박승호 본부장, 김동식 팀장, 권종인 포함) 넣어서 보내기
				List<String> bccAddresses = UTIL_Email.getEPMOAddresses();
				System.debug('bccAddresses : ' + bccAddresses);

				UTIL_Email.sendEmailProjectNoti(toAddresses, ccAddresses, bccAddresses, projectName, projectCode,ContractStartDate,ContractEndDate,projectManager,recordUrl);
			}
		}
	}

	public void onAfterUpdate(List<PMS_Project__c> olds, List<PMS_Project__c> news, Map<Id, PMS_Project__c> oldMap, Map<Id, PMS_Project__c> newMap){
		if(this.size == 1){ // 221227_이호재 신규 프로젝트 생성 시 알림 메일 발송
			String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/PMS_Project__c/' + news.get(0).Id + '/view';
			System.debug('recordUrl : ' + recordUrl);

			// Project 업데이트 시 PM 변경 및, PM 추가 시 알림 메일 발송
			if(news.get(0).ProjectManagerId__c != null && olds.get(0).ProjectManagerId__c != news.get(0).ProjectManagerId__c){
				String projectName = [SELECT Name FROM PMS_Project__c WHERE Id = :news.get(0).Id LIMIT 1].Name;

				String projectCode = [SELECT ProjectCode2__c FROM PMS_Project__c WHERE Id = :news.get(0).Id LIMIT 1].ProjectCode2__c;
				Date ContractStartDate = [SELECT ContractStartDate__c FROM PMS_Project__c WHERE Id = :news.get(0).Id LIMIT 1].ContractStartDate__c;
                Date ContractEndDate = [SELECT ContractEndDate__c FROM PMS_Project__c WHERE Id = :news.get(0).Id LIMIT 1].ContractEndDate__c;
                String projectManager = [SELECT ProjectManagerId__r.name FROM PMS_Project__c WHERE Id = :news.get(0).Id LIMIT 1].ProjectManagerId__r.name;

				List<String> toAddresses = new List<String>();

				PMS_Project__c pjt = [SELECT ProjectManagerId__r.FM_Email__c FROM PMS_Project__c WHERE Id = :news.get(0).Id LIMIT 1];

				if(pjt.ProjectManagerId__r.FM_Email__c != null) {
					toAddresses.add(pjt.ProjectManagerId__r.FM_Email__c); // PM
					// 2023.11.30 안종민 : 받는 사람 PM + 오퍼레이션팀( 나대영 부장님 ) 추가
					toAddresses.add(UTIL_Email.getOPERATIONAddress()[0]);
				}

				// 230116_이호재 참조에 HR팀 추가
				List<String> ccAddresses = UTIL_Email.getHRAddresses();
				System.debug('ccAddresses : ' + ccAddresses);
				
				// 숨은참조에 EPMO(박승호 본부장, 김동식 팀장, 권종인 포함) 넣어서 보내기
				List<String> bccAddresses = UTIL_Email.getEPMOAddresses();
				System.debug('bccAddresses : ' + bccAddresses);

				UTIL_Email.sendEmailProjectNoti(toAddresses, ccAddresses, bccAddresses, projectName, projectCode,ContractStartDate,ContractEndDate,projectManager,recordUrl);
			}
            //프로젝트 종료시 알림
            if(news.get(0).Status__c == 'Completed' && olds.get(0).Status__c != 'Completed'){
				recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/PMS_Project__c/' + news.get(0).Id + '/view';
				System.debug('recordUrl : ' + recordUrl);
                
				String projectName = [SELECT Name FROM PMS_Project__c WHERE Id = :news.get(0).Id LIMIT 1].Name;

				Date ContractStartDate = [SELECT ContractStartDate__c FROM PMS_Project__c WHERE Id = :news.get(0).Id LIMIT 1].ContractStartDate__c;
                
                Date ContractEndDate = [SELECT ContractEndDate__c FROM PMS_Project__c WHERE Id = :news.get(0).Id LIMIT 1].ContractEndDate__c;
                
                Date KickoffDate = [SELECT KickoffDate__c FROM PMS_Project__c WHERE Id = :news.get(0).Id LIMIT 1].KickoffDate__c;
                
                Date DeadlineDate = [SELECT DeadlineDate__c FROM PMS_Project__c WHERE Id = :news.get(0).Id LIMIT 1].DeadlineDate__c;

				List<String> toAddresses = new List<String>();

			    toAddresses = UTIL_Email.getHRAddresses();
				System.debug('toAddress '+toAddresses);				

			
				List<String> ccAddresses = UTIL_Email.getEPMOAddresses();
				System.debug('ccAddresses : ' + ccAddresses);
				
				// 숨은참조에 EPMO(박승호 본부장, 김동식 팀장, 권종인 포함) 넣어서 보내기
				List<String> bccAddresses = null;
				System.debug('bccAddresses : ' + bccAddresses);

				UTIL_Email.sendEmailProjectCompleteNoti(toAddresses, ccAddresses, bccAddresses, projectName, ContractStartDate, ContractEndDate, KickoffDate ,DeadlineDate ,recordUrl);
			}
            System.debug('ActualCostPercentage__c'+news.get(0).ActualCostPercentage__c);
			
			//231107_안종민 프로젝트 예산 대비 사용 비율을 80%보다 100%를 먼저 체크하도록 수정
            //프로젝트 예산 대비 사용 비율 100% 이상
            if(news.get(0).ActualCostPercentage__c >= 100 && news.get(0).ActualCostPercentage100Check__c == false && (news.get(0).Status__c =='Planning' || news.get(0).Status__c =='Active') )  {
                recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/PMS_Project__c/' + news.get(0).Id + '/view';
				System.debug('recordUrl : ' + recordUrl);
                
                String projectName = [SELECT Name FROM PMS_Project__c WHERE Id =:news.get(0).Id LIMIT 1].Name;
                
                List<String> toAddresses = new List<String>();
                
                PMS_Project__c pjt = [SELECT id, ProjectManagerId__r.FM_Email__c , ActualCostPercentage__c , ActualCostPercentage100Check__c , ContractStartDate__c , ContractEndDate__c, HQId__r.name  FROM PMS_Project__c WHERE Id = :news.get(0).Id LIMIT 1];
                Employee__c DevisionDirector = [select id ,name,Position__c,FM_HQ__c, Email__c  from Employee__c  where User__r.IsActive = true and Position__c = '본부장' and FM_HQ__c =:pjt.HQId__r.name  limit 1];
                
                if(pjt.ProjectManagerId__r.FM_Email__c != null) {
					toAddresses.add(pjt.ProjectManagerId__r.FM_Email__c);
                    toAddresses.add(DevisionDirector.Email__c);
				}
                
                List<String> ccAddresses = UTIL_Email.getEPMOAddresses();
                pjt.ActualCostPercentage100Check__c = true;
                update pjt;
                UTIL_Email.sendEmailOnBudgetStatus_high(toAddresses , ccAddresses , null , projectName , pjt.ActualCostPercentage__c ,pjt.ContractStartDate__c, pjt.ContractEndDate__c ,recordUrl);
                                
			//프로젝트 예산 대비 사용 비율 80% 이상
            } else if(news.get(0).ActualCostPercentage__c >= 80 && news.get(0).ActualCostPercentageCheck__c == false && (news.get(0).Status__c =='Planning' || news.get(0).Status__c =='Active') )  {
                recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/PMS_Project__c/' + news.get(0).Id + '/view';
				System.debug('recordUrl : ' + recordUrl);
                
                String projectName = [SELECT Name FROM PMS_Project__c WHERE Id =:news.get(0).Id LIMIT 1].Name;
                
                List<String> toAddresses = new List<String>();
                
                PMS_Project__c pjt = [SELECT id, ProjectManagerId__r.FM_Email__c , ActualCostPercentage__c , ActualCostPercentageCheck__c , ContractStartDate__c , ContractEndDate__c  FROM PMS_Project__c WHERE Id = :news.get(0).Id LIMIT 1];
                
                if(pjt.ProjectManagerId__r.FM_Email__c != null) {
					toAddresses.add(pjt.ProjectManagerId__r.FM_Email__c);
				}
                
                List<String> ccAddresses = UTIL_Email.getEPMOAddresses();
                pjt.ActualCostPercentageCheck__c = true;
                update pjt;
                UTIL_Email.sendEmailOnBudgetStatus(toAddresses , ccAddresses , null , projectName , pjt.ActualCostPercentage__c ,pjt.ContractStartDate__c, pjt.ContractEndDate__c ,recordUrl);
                                
            }        
            
            
            //프로젝트 종료여부 확인 알람 메일
            if(news.get(0).PMS_ProjectCompleteCheck__c == true){
                
                User user = [select id,name,email,UserRole.name from user where name ='김정윤' AND UserRole.Name = 'CSM 팀' limit 1];
                
				recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/PMS_Project__c/' + news.get(0).Id + '/view';
                
				String projectName = [SELECT Name FROM PMS_Project__c WHERE Id = :news.get(0).Id LIMIT 1].Name;

				Date ContractStartDate = [SELECT ContractStartDate__c FROM PMS_Project__c WHERE Id = :news.get(0).Id LIMIT 1].ContractStartDate__c;
                
                Date ContractEndDate = [SELECT ContractEndDate__c FROM PMS_Project__c WHERE Id = :news.get(0).Id LIMIT 1].ContractEndDate__c;
                
                String projectManager = [SELECT ProjectManagerId__r.name FROM PMS_Project__c WHERE Id = :news.get(0).Id LIMIT 1].ProjectManagerId__r.name;

				List<String> toAddresses = new List<String>();

                PMS_Project__c pjt = [SELECT ProjectManagerId__r.FM_Email__c , PMS_ProjectCompleteCheck__c , HQId__r.name FROM PMS_Project__c WHERE Id = :news.get(0).Id LIMIT 1];
                
                if(pjt.ProjectManagerId__r.FM_Email__c != null) {
					toAddresses.add(pjt.ProjectManagerId__r.FM_Email__c);
				}
                
                if(pjt.HQId__r.name == 'CX본부'){
                    toAddresses.add(user.email);
                }
                
                pjt.PMS_ProjectCompleteCheck__c = false;
                update pjt;     
                    
				System.debug('toAddress '+toAddresses);				

			
				List<String> ccAddresses = UTIL_Email.getEPMOAddresses();
				System.debug('ccAddresses : ' + ccAddresses);
				
			
				List<String> bccAddresses = null;
				System.debug('bccAddresses : ' + bccAddresses);      
                
                UTIL_Email.sendEmailProjectEndNoti(toAddresses , ccAddresses , bccAddresses , projectName ,ContractStartDate , ContractEndDate , ProjectManager,recordUrl);
            }     
		}
	}
}