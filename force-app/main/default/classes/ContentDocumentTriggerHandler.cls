/**
 * @Class : ContentDocumentTriggerHandler
 *
 * @Method : onBeforeDelete
 * 
 * @Author : hojae-lee
 * @Date : 2022-12-16
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2022-12-16 | hojae-lee     | 최초작성
 */
public with sharing class ContentDocumentTriggerHandler {

	private Boolean isExecuting {get;set;} 	// Web Service와 구분하기 위한 Context 파라미터
	private Integer size {get;set;} 		// Trigger에서 Execute된 List Size
    private Set<Id> cdSet = new Set<Id>();

	public ContentDocumentTriggerHandler(Boolean isExecuting, Integer size){
		this.isExecuting = isExecuting;
		this.size = size;

		System.debug('#isExecuting [' + isExecuting + '] #size [' + size + ']');
	}

	public void onBeforeDelete(List<ContentDocument> dels, Map<Id, ContentDocument> delMap){

		for(ContentDocument cd : dels){
			String sObjName = cd.Id.getSObjectType().getDescribe().getName();
			System.debug('오브젝트 이름은 0 ? ' + sObjName);

            if(sObjName == 'ContentDocument'){
                cdSet.add(cd.Id);
            }
			System.debug('cdSet 0 : ' + cdSet);

            if(cdSet.size() > 0){
                List<Quote> QuoteList02 = [SELECT Id, (SELECT Id, LinkedEntityId FROM AttachedContentDocuments WHERE ContentDocumentId IN :cdSet)
                                          , (SELECT Id FROM ContentDocumentLinks WHERE ContentDocumentId IN :cdSet)
                                          FROM Quote];

                for(Quote q : QuoteList02){
                    for(ContentDocumentLink c : q.ContentDocumentLinks){
                        System.debug('삭제되는 c는 ? ' + c);
                        delete c;
                    }
                }
            }
		}
	}
}