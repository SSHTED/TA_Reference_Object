global class eLearningController {
	@AuraEnabled(cacheable=true)
    global static Object getTrainingChallengeList() {
        return [SELECT Id, Name, Education_Number__c, TrainingStep__c, Category__c, Field1__c, CreatedDate, Owner.Name FROM Education__c ORDER BY TrainingStep__c ASC];
    }

    @AuraEnabled(cacheable=true)
    global static Object getTrainingChallengeDetail(string recordId) {
        return [SELECT Id, Name, Related_data_and_Development_resources__c, Detailed_business_requirements__c, CreatedDate FROM Education__c WHERE Id =: recordId];
    }

    @AuraEnabled(cacheable=true)
    global static Object getNoticeList() {
        return [SELECT Id, Name, CreatedDate, Description__c FROM CommunityNotice__c ORDER BY CreatedDate DESC];
    }
    @AuraEnabled(cacheable=true)
    global static Object getNoticeListOne() {
        return [SELECT Id, Name, CreatedDate, Description__c FROM CommunityNotice__c ORDER BY CreatedDate DESC Limit 1];
    }

    @AuraEnabled(cacheable=true)
    global static Object getCategoryCompleteList(String category1, String category) {
        String UserId = UserInfo.getUserId();
        return [SELECT Id, Name, CreatedDate, CreatedById FROM CategoryComplete__c WHERE Category1__c =: category1 AND Category__c =: category AND CreatedById =: UserId];
    }

    @AuraEnabled(cacheable=true)
    global static Object getNoticeDetail(string recordId) {
        return [SELECT Id, Name, CreatedDate, Description__c FROM CommunityNotice__c WHERE Id =: recordId];
    }

    @AuraEnabled
    global static void setVideoComplete(String recordId) {
        VideoComplete__c Vc = New VideoComplete__c();
        String UserName = UserInfo.getUserName();
        Vc.eLearningContents__c = recordId;
        Vc.Name	= UserName;
        Vc.Status__c = '완료';
        insert Vc;
    }

    @AuraEnabled
    global static void setCategoryComplete(String category1, String category) {
        CategoryComplete__c CC = New CategoryComplete__c();
        CC.Name	= category;
        CC.Category1__c = category1;
        CC.Category__c = category;
        insert CC;
    }

    @AuraEnabled(cacheable=true)
    global static Object getVideoList(string category, String category1, String userId) {
        List<eLearningContents__c> learnings = [SELECT Id, Name, CreatedDate, Category__c, Description__c, Owner.Name, (SELECT Id, Name, Status__c, CreatedDateTime__c, CreatedDate FROM VideoComplete__r WHERE CreatedById =:userId) FROM eLearningContents__c WHERE Category__c =: category AND Category1__c =: category1 Order by CreatedDate ASC];
        Set<Id> learningsIds = (new Map<Id,eLearningContents__c>(learnings)).keySet();
        
        List<ContentDocumentLink> CDL_LIST = [select ContentDocumentId, LinkedEntityId from ContentDocumentLink where LinkedEntityId IN: learningsIds order by LinkedEntityId desc];
        
        map<string,string> contentsIds_map = new map<string,string>();

        for(ContentDocumentLink cd : CDL_LIST){
            contentsIds_map.put(cd.ContentDocumentId, cd.LinkedEntityId);
        }
        set<string> contentsIds = contentsIds_map.keySet();

        List<ContentVersion> CV_LIST = [select Id, Title, PathOnClient, FileExtension, Description, ContentSize, ContentDocumentId, CreatedDate from ContentVersion where ContentDocumentId IN: contentsIds ];
        map<string,List<ContentVersion>> cv_map = new map<string,List<ContentVersion>>();
        
        for(ContentVersion CV : CV_LIST){
            string learning_Id = contentsIds_map.get(CV.ContentDocumentId);
            List<ContentVersion> put_list = cv_map.get(learning_Id) != null ? cv_map.get(learning_Id) : new List<ContentVersion>();
            put_list.add(CV);
            cv_map.put(learning_Id,put_list);
        }

        List<map<string,object>> result = new List<map<string,object>>();

        for(eLearningContents__c learning : learnings){
            map<string,object> res_map = new map<string,object>{'data' => learning, 'contents' => cv_map.get(learning.Id)};
            result.add(res_map);   
        }
        return result;
    }

    @AuraEnabled(cacheable=true)
    global static Map<String, Object> getVideoDetailAndFiles(String recordId, String userId) {
        Map<String, Object> resultMap = new Map<String, Object>();

        List<ContentDocumentLink> CDL_LIST = [select ContentDocumentId from ContentDocumentLink where LinkedEntityId = :recordId];
        String CDL_IDS = '';
        Integer i = 0;
        for(ContentDocumentLink CDL : CDL_LIST) {
            if(i > 0) {
                CDL_IDS += ',';
            }
            CDL_IDS += '\'' + CDL.ContentDocumentId + '\'';
            i++;
        }

        String SQL = 'select Id, Title, PathOnClient, FileExtension, Description, ContentSize, ContentDocumentId, CreatedDate from ContentVersion ';
        if(!string.isBlank(CDL_IDS)) SQL += 'where ContentDocumentId in (' + CDL_IDS + ') ';
        String SQL1 = 'select Id, Name, CreatedDate, Category__c, Category1__c, Description__c, Owner.Name, videoURL__c, (SELECT Id, Name, Status__c FROM VideoComplete__r WHERE CreatedById= :userId) FROM eLearningContents__c Where Id= :recordId ';

        resultMap.put('fileData', Database.query(SQL));
        resultMap.put('data', Database.query(SQL1));

        return resultMap;
    }
    
    @AuraEnabled(cacheable=true)
    global static map<string,Map<String, String>> getPickList() {
        map<string,Map<String, String>> result = new map<string,Map<String, String>>();
			
        Schema.DescribeFieldResult field_description = eLearningContents__c.Category__c.getDescribe();
        
        Schema.DescribeFieldResult Controller_field_description = field_description.getController().getDescribe();
        List<Schema.PicklistEntry> pick_list = Controller_field_description.getPicklistValues();
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        
        for( Schema.PicklistEntry p : field_description.getPicklistValues() ){
            if(p.isActive()) {
                //result.put(p.getLabel(),p.getValue());
                List<String> base64chars = String.valueOf(   ((Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( p ) )).get( 'validFor' ) ).split( '' );
                
                //Except blank validFor 
                if (String.isNotBlank(String.valueOf(   ((Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( p ) )).get( 'validFor' ) )) 
                    && Math.mod(String.valueOf(   ((Map<String,Object>) JSON.deserializeUntyped( JSON.serialize( p ) )).get( 'validFor' ) ).length(), 2) == 0) {
                        for ( Integer index = 0; index < (pick_list != null ? pick_list.size() : 2); index++ ){
                            Object controlValue = (   pick_list == null ?   (Object) (index == 1) :   (Object) (pick_list[ index ].isActive() ? pick_list[ index ].getValue() : null) );
                            Integer bitIndex = index / 6, bitShift = 5 - Math.mod( index, 6 );
                            if  ( controlValue == null || (base64map.indexOf( base64chars[ bitIndex ] ) & (1 << bitShift)) == 0 ) continue;
                            if ( !result.containsKey( (string) controlValue ) ) {
                                result.put( (string) controlValue, new map<String, String>() );
                            }
                            result.get( (string) controlValue ).put( p.getLabel(), p.getValue() );
                        }
                    }
                
            }
        }
        return result;
    }
}