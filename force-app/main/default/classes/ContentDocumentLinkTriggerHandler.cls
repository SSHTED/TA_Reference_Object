public with sharing class ContentDocumentLinkTriggerHandler {

	private Boolean isExecuting {get;set;} 	// Web Service와 구분하기 위한 Context 파라미터
	private Integer size {get;set;} 		// Trigger에서 Execute된 List Size

	public ContentDocumentLinkTriggerHandler(Boolean isExecuting, Integer size){
		this.isExecuting = isExecuting;
		this.size = size;

		System.debug('#isExecuting [' + isExecuting + '] #size [' + size + ']');
	}

	public void onBeforeDelete(List<ContentDocumentLink> dels, Map<Id, ContentDocumentLink> delMap){
		// Business Logic
		System.debug('dels 1 ? ' + dels);
	}

	/*public void onBeforeInsert(List<ContentDocumentLink> news){
		// Business Logic
	}*/

	public void onBeforeUpdate(List<ContentDocumentLink> olds, List<ContentDocumentLink> news, Map<Id, ContentDocumentLink> oldMap, Map<Id, ContentDocumentLink> newMap){
		// Business Logic
	}

	public void onAfterDelete(List<ContentDocumentLink> dels, Map<Id, ContentDocumentLink> delMap){
		System.debug('dels 2 ? ' + dels);

		// 221227_이호재 Quotes 첨부파일 유무 확인 필드 업데이트 기능
		// 지우면 사이즈 확인해서 파일 전부 없으면, false에다가 멘트 삭제
		Set<Id> cdIdSet = new Set<Id>();

		for(ContentDocumentLink cdl : dels){
			String sObjName = cdl.LinkedEntityId.getSObjectType().getDescribe().getName();
			System.debug('오브젝트 이름은 0 ? ' + sObjName);

            if(sObjName == 'Quote'){
                cdIdSet.add(cdl.LinkedEntityId);
            }
			System.debug('cdIdSet 0 : ' + cdIdSet);
		}

		if(cdIdSet.size() > 0){
            List<Quote> QuoteList = [SELECT Id, ValidationField__c, ValidationMessage__c
										, (SELECT Id, ContentDocumentId FROM AttachedContentDocuments)
									 FROM Quote
									 WHERE Id IN :cdIdSet
									 AND ValidationField__c = true];

			System.debug('size 는 ? ' + QuoteList.get(0).AttachedContentDocuments.size());

			if(QuoteList.get(0).AttachedContentDocuments.size() == 0){
				for(Quote q : QuoteList){
					q.ValidationField__c = false;
					q.ValidationMessage__c = '첨부파일이 없습니다.';
				}
				update QuoteList;
			}

			/*List<Id> cIdList = new List<Id>();
			for(Quote q : QuoteList){
				System.debug('섭쿼리 과연 1 ? ' + q.AttachedContentDocuments);
				for(AttachedContentDocument a : q.AttachedContentDocuments){
					System.debug('섭쿼리 안은 과연 2 ? ' + a);
					cIdList.add(a.ContentDocumentId);
				}
			}
			System.debug('cIdList 과연 3 ? ' + cIdList);

			if(cIdList.size() == 0 || cIdList == null){
				for(Quote q : QuoteList){
					q.ValidationField__c = false;
					q.ValidationMessage__c = '첨부파일이 없습니다!';
				}
				update QuoteList;
			}*/
        }
	}

	public void onAfterInsert(List<ContentDocumentLink> news){
		Set<Id> cdIdSet = new Set<Id>();

		for(ContentDocumentLink cdl : news){
			String sObjName = cdl.LinkedEntityId.getSObjectType().getDescribe().getName();
			System.debug('오브젝트 이름은 1 ? ' + sObjName);

            if(sObjName == 'Quote'){
                cdIdSet.add(cdl.LinkedEntityId);
            }
			System.debug('cdIdSet 1 : ' + cdIdSet);
		}

		if(cdIdSet.size() > 0){
            List<Quote> QuoteList = [SELECT Id, ValidationField__c, ValidationMessage__c
									 FROM Quote
									 WHERE Id IN :cdIdSet
									 AND ValidationField__c = false];

            for(Quote q : QuoteList){
                q.ValidationField__c = true;
				q.ValidationMessage__c = null;
            }
            update QuoteList;
        }
	}

	public void onAfterUpdate(List<ContentDocumentLink> olds, List<ContentDocumentLink> news, Map<Id, ContentDocumentLink> newMap){
		Set<Id> cdIdSet = new Set<Id>();

		for(ContentDocumentLink cdl : news){
			String sObjName = cdl.LinkedEntityId.getSObjectType().getDescribe().getName();
			System.debug('오브젝트 이름은 2 ? ' + sObjName);

            if(sObjName == 'Quote'){
                cdIdSet.add(cdl.LinkedEntityId);
            }
			System.debug('cdIdSet 2 : ' + cdIdSet);
		}

		if(cdIdSet.size() > 0){
            List<Quote> QuoteList = [SELECT Id, ValidationField__c, ValidationMessage__c
									 FROM Quote
									 WHERE Id IN :cdIdSet
									 AND ValidationField__c = false];

            for(Quote q : QuoteList){
                q.ValidationField__c = true;
				q.ValidationMessage__c = '첨부파일 X';
            }
            update QuoteList;
        }
	}
}