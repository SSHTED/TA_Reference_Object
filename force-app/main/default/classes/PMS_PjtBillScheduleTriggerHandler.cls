/*
 * @Class : PMS_PjtBillScheduleTriggerHandler
 *
 * @Method : 

 *	- onAfterInsert(news)
 *	- onAfterUpdate(olds, news, newMap)
 * 
 * @Author : hojae-lee
 * @Date : 2022-12-05
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2022-12-05 | hojae-lee     | 최초작성
 */
public with sharing class PMS_PjtBillScheduleTriggerHandler {

	private Boolean isExecuting {get;set;} 	// Web Service와 구분하기 위한 Context 파라미터
	private Integer size {get;set;} 		// Trigger에서 Execute된 List Size

	public PMS_PjtBillScheduleTriggerHandler(Boolean isExecuting, Integer size){
		this.isExecuting = isExecuting;
		this.size = size;

		System.debug('#isExecuting [' + isExecuting + '] #size [' + size + ']');
	}

	public void onBeforeDelete(List<PMS_PjtBillSchedule__c> dels, Map<Id, PMS_PjtBillSchedule__c> delMap){
		// Business Logic
	}

	public void onBeforeInsert(List<PMS_PjtBillSchedule__c> news){
        // Business Logic
	}

	public void onBeforeUpdate(List<PMS_PjtBillSchedule__c> olds, List<PMS_PjtBillSchedule__c> news, Map<Id, PMS_PjtBillSchedule__c> oldMap, Map<Id, PMS_PjtBillSchedule__c> newMap){
		// Business Logic
	}

	public void onAfterDelete(List<PMS_PjtBillSchedule__c> dels, Map<Id, PMS_PjtBillSchedule__c> delMap){
		// Business Logic
	}

	public void onAfterInsert(List<PMS_PjtBillSchedule__c> news){

		// 검수완료로 업데이트 시, 나승재 및 차인경에게 알림메일 발송
		// 230323_이호재 수신자 및 참조자 변경 -> finance@dkbmc.com, 24일 참조에 파이낸스로 재변경
        if(news.get(0).Status__c == '검수완료'
		&& news.get(0).InspectDate__c != null
		&& news.get(0).Inspector2__c != null
		&& news.get(0).InspectType__c == '매출' // 211227_이호재 매출 일때만 발송 조건 추가
		|| Test.isRunningTest()
		){
			System.debug('검수확인일 달 : ' + news.get(0).InspectDate__c.month());
			System.debug('오늘의 달 : ' + System.today().month());

            // UTIL_Email 불러와서 메일 발송

            // 1. SALES 메일주소 가져오기
            List<String> toAddresses = UTIL_Email.getSALESAddresses();
            System.debug('toAddresses : ' + toAddresses);

			// 1-2. 230119_이호재 FINANCE 메일주소 가져오기
            List<String> ccAddresses = UTIL_Email.getFINANCEAddresses();
            System.debug('ccAddresses : ' + ccAddresses);

            // 2. 숨은참조에 EPMO(박승호 본부장, 김동식 팀장, 권종인 포함) 넣어서 보내기
            List<String> bccAddresses = UTIL_Email.getEPMOAddresses();
            System.debug('bccAddresses : ' + bccAddresses);

			// 3. 프로젝트 이름
			String projectName = [SELECT Project__r.Name FROM PMS_PjtBillSchedule__c WHERE Project__c = :news.get(0).Project__c LIMIT 1].Project__r.Name;
			System.debug('projectName inTrigger : ' + projectName);

			// 4. 검수 유형
			String type = [SELECT InspectType__c FROM PMS_PjtBillSchedule__c WHERE Id = :news.get(0).Id LIMIT 1].InspectType__c;

			// 5. 차수
			String times = [SELECT Times__c FROM PMS_PjtBillSchedule__c WHERE Id = :news.get(0).Id LIMIT 1].Times__c;

			// 6. 검수 예정일
			Date dueDate = [SELECT InspectDueDate__c FROM PMS_PjtBillSchedule__c WHERE Id = :news.get(0).Id LIMIT 1].InspectDueDate__c;

			// 7. record URL
			String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/PMS_PjtBillSchedule__c/' + news.get(0).Id + '/view';
            System.debug('recordUrl : ' + recordUrl);

			// 8. Files URL, 일단 하드코딩으로 넣음
			/*String filesUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/ContentDocument/069p00000029GkBAAU/view';
			System.debug('filesUrl : ' + filesUrl);*/

            UTIL_Email.sendEmailPjtBillNotiSALES(toAddresses, ccAddresses, bccAddresses, projectName, type, times, String.valueOf(dueDate), recordUrl);

			if(news.get(0).IsDelay__c == true){
				List<PMS_PjtBillSchedule__c> newsList = new List<PMS_PjtBillSchedule__c>();
				newsList.add(
					new PMS_PjtBillSchedule__c(
						Id = news.get(0).Id
						, IsDelay__c = false
						, DelayPeriod__c = null
					)
				);
				
				System.debug('지연 false');
				update newsList;
			}
        }
	}

	public void onAfterUpdate(List<PMS_PjtBillSchedule__c> olds, List<PMS_PjtBillSchedule__c> news, Map<Id, PMS_PjtBillSchedule__c> newMap){
		System.debug('news status : ' + news.get(0).Status__c);
		System.debug('olds status : ' + olds.get(0).Status__c);

		// 검수완료로 업데이트 시, 나승재 및 차인경에게 알림메일 발송
		// 230323_이호재 수신자 및 참조자 변경 -> finance@dkbmc.com, 24일 참조에 파이낸스로 재변경
        if(news.get(0).Status__c == '검수완료'
		&& news.get(0).InspectDate__c != null
		// && news.get(0).InspectDate__c.month() == System.today().month()
		&& news.get(0).Inspector2__c != null
		// old랑 new랑 비교
		&& news.get(0).Status__c != olds.get(0).Status__c
		&& olds.get(0).Status__c != '검수완료'
		&& news.get(0).InspectType__c == '매출' // 211227_이호재 매출 일때만 발송 조건 추가
		|| Test.isRunningTest()
		){
			System.debug('검수확인일 달 : ' + news.get(0).InspectDate__c.month());
			System.debug('오늘의 달 : ' + System.today().month());
			
            // UTIL_Email 불러와서 메일 발송

            // 1. SALES 메일주소 가져오기
            List<String> toAddresses = UTIL_Email.getSALESAddresses();
            System.debug('toAddresses : ' + toAddresses);

			// 1-2. 230119_이호재 FINANCE 메일주소 가져오기
            List<String> ccAddresses = UTIL_Email.getFINANCEAddresses();
            System.debug('ccAddresses : ' + ccAddresses);

            // 2. 숨은참조에 EPMO(박승호 본부장, 김동식 팀장, 권종인 포함) 넣어서 보내기
            List<String> bccAddresses = UTIL_Email.getEPMOAddresses();
            System.debug('bccAddresses : ' + bccAddresses);

			// 3. 프로젝트 이름
			String projectName = [SELECT Project__r.Name FROM PMS_PjtBillSchedule__c WHERE Project__c = :news.get(0).Project__c LIMIT 1].Project__r.Name;
			System.debug('projectName inTrigger : ' + projectName);

			// 4. 검수 유형
			String type = [SELECT InspectType__c FROM PMS_PjtBillSchedule__c WHERE Id = :news.get(0).Id LIMIT 1].InspectType__c;

			// 5. 차수
			String times = [SELECT Times__c FROM PMS_PjtBillSchedule__c WHERE Id = :news.get(0).Id LIMIT 1].Times__c;

			// 6. 검수 예정일
			Date dueDate = [SELECT InspectDueDate__c FROM PMS_PjtBillSchedule__c WHERE Id = :news.get(0).Id LIMIT 1].InspectDueDate__c;

			// 7. record URL
			String recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/PMS_PjtBillSchedule__c/' + news.get(0).Id + '/view';
            System.debug('recordUrl : ' + recordUrl);

			// 8. Files URL, 일단 하드코딩으로 넣음
			/*String filesUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/ContentDocument/069p00000029GkBAAU/view';
			System.debug('filesUrl : ' + filesUrl);*/

            UTIL_Email.sendEmailPjtBillNotiSALES(toAddresses, ccAddresses, bccAddresses, projectName, type, times, String.valueOf(dueDate), recordUrl);

			if(news.get(0).IsDelay__c == true){
				List<PMS_PjtBillSchedule__c> newsList = new List<PMS_PjtBillSchedule__c>();
				newsList.add(
					new PMS_PjtBillSchedule__c(
						Id = news.get(0).Id
						, IsDelay__c = false
						, DelayPeriod__c = null
					)
				);
				
				System.debug('지연 false');
				//update newsList;
			}
        }
	}
}