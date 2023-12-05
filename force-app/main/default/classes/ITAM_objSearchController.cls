public class ITAM_objSearchController {
    @AuraEnabled 
    public static List<RecordsData> fetchRecords( String objectName, String filterField, String searchString ) {
        String objMode = '0';
        String IsObjectName = ObjectName;
        if (ObjectName == 'property__c재고'){
            IsObjectName = 'property__c';
            objMode = '1';
        }
        if (ObjectName == 'property__c사용'){
            IsObjectName = 'property__c';
            objMode = '2';
        }
        
        List<RecordsData> recordsDataList = new List<RecordsData>();
        try {
            String query = 'SELECT Id, ' + filterField+
                ' FROM '+IsObjectName+
                ' WHERE '+filterField+' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\'' + ' LIMIT 50000';
            
            for(SObject s : Database.query(query)){
                recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
            } 
        } catch(Exception err) {
            if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
        }
        return recordsDataList;
    }
    
    public class RecordsData{
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
    @AuraEnabled
    public static void setObjectToRecentItems(Id recordId) {
        if (!String.isBlank(recordId)) {
            Schema.SObjectType sObjectType = recordId.getSobjectType();
            String queryString = String.format('SELECT Id, Name FROM {0} WHERE Id =: recordId FOR VIEW', new List<Object>{sObjectType});
            Database.query(queryString);
        }
    }
    
    @AuraEnabled
    public static List<sObject> GetRecentRecords(String ObjectName, List<String> ReturnFields, Integer MaxResults, String recordId, String Type2) {
        //전석봉 추가
        //objMode - 1 : 재고, 2 : 사용
        String objMode = '0';
        String IsObjectName = ObjectName;
        String empRealId;
        if (ObjectName == 'property__c재고'){
            IsObjectName = 'property__c';
            objMode = '1';
        }
        if (ObjectName == 'property__c사용'){
            IsObjectName = 'property__c';
            objMode = '2';
        }
        /*
        if (recordId != null){
            System.debug('emp : '+ recordId);
            empRealId = [SELECT realEmp__c FROM property_request__c WHERE id =:recordID].realEmp__c;
            System.debug('전석봉emp 확인 : '+empRealId);
        }
        */
        List<Id> recentIds = new List<Id>();
        for(RecentlyViewed recent : [SELECT Id FROM RecentlyViewed WHERE Type = :IsObjectName ORDER BY LastViewedDate DESC LIMIT :MaxResults]) {
            recentIds.add(recent.Id);
        }
        
        
        String sQUERY = 'SELECT Id, ';
        
        if (ReturnFields != null && ReturnFields.Size() > 0) {
            sQuery += String.join(ReturnFields, ',');
        } else {
            sQuery += 'Name';   
        }
        
        sQuery += ' FROM ' + IsObjectName + ' WHERE Id IN :recentIds';
        
        //전석봉 추가
        String temp1 ;
        System.debug('objMode : '+ objMode);
        if(objMode == '1'){
            temp1 = '재%';
            sQuery +=' AND Condition__c Like :temp1';
        }
        if(objMode == '2'){
            temp1 = '사용%';
            sQuery +=' AND Condition__c Like :temp1';
        }
        System.debug('recordId: '+recordId);
        if(recordId != null){
            sQuery +=' AND RealEmp__c =:recordId';
        }
         System.debug('recordId: '+Type2);
        if(Type2 != null){
            sQuery +=' AND ProductType_2nd__c =:Type2';
        }
        System.debug('query: '+sQuery);
        
        List<sObject> searchResult = Database.query(sQuery);
        
        System.debug('result: '+searchResult);
        return searchResult;
    }
    
    @AuraEnabled
    public static List<sObject> SearchRecords(String ObjectName, List<String> ReturnFields, List<String> QueryFields, String SearchText, String SortColumn, String SortOrder, 
                                              Integer MaxResults, String Filter, String Type2, String recordId) {        
        //전석봉 추가
        //objMode - 1 : 재고, 2 : 사용
        String objMode = '0';
        String IsObjectName = ObjectName;
        if (ObjectName == 'property__c재고'){
            IsObjectName = 'property__c';
            objMode = '1';
        }
        if (ObjectName == 'property__c사용'){
            IsObjectName = 'property__c';
            objMode = '2';
        }
        
        //always put a limit on the results
        if (MaxResults == null || MaxResults == 0) {
            MaxResults = 5;
        }
        SearchText = '%' + SearchText + '%';
        
        List <sObject > returnList = new List < sObject > ();
        
        String sQuery =  'SELECT Id, ';
        
        if (ReturnFields != null && ReturnFields.Size() > 0) {
            sQuery += String.join(ReturnFields, ',');
        } else {
            sQuery += 'Name';   
        }

        sQuery += ' FROM ' + IsObjectName + ' WHERE ';

        //전석봉 추가
        String temp1;
        System.debug('objMode : '+ objMode);
        if(objMode == '1'){
            temp1 = '재%';
            sQuery +=' Condition__c Like :temp1';
            sQuery += ' AND';
        }
        if(objMode == '2'){
            temp1 = '사용%';
            sQuery +=' Condition__c Like :temp1';
            sQuery += ' AND';
        }
        if(Type2 != null){
        	String tmps = Type2;
            sQuery += ' ProductType_2nd__c =:Type2';
            sQuery += ' AND';
        }
        System.debug('recordId get Record: '+recordId);
        if(recordId != null){
            sQuery += ' RealEmp__c =:recordId';
            sQuery += ' AND';
            
        }
        
        if (QueryFields == null || QueryFields.isEmpty()) {
            sQuery += ' Name LIKE :SearchText ';
        } else {
            string likeField = '';
            for(string field : QueryFields) {
                likeField += ' OR ' + field + ' LIKE :SearchText ';    
            }
            sQuery += ' (' + likeField.removeStart(' OR ') + ') ';
        }
        /*
        if (Filter != null) {
            System.debug('필터 인');
            sQuery += ' AND (' + Filter + ')';
        }
		*/
        
        if(string.isNotBlank(SortColumn) && string.isNotBlank(SortOrder)) {
            sQuery += ' ORDER BY ' + SortColumn + ' ' + SortOrder;
        }
        
        sQuery += ' LIMIT ' + MaxResults;
        System.debug('SearchText'+SearchText);
        System.debug(sQuery);
        
        List <sObject> searchResult = Database.query(sQuery);
        System.debug('DML'+searchResult);
        return searchResult;
    }
    
    @AuraEnabled
    public static List<sObject> GetRecord(String ObjectName, List<String> ReturnFields, String selId) {
        //전석봉 추가
        String objMode = '0';
        String IsObjectName = ObjectName;
        if (ObjectName == 'property__c재고'){
            IsObjectName = 'property__c';
            objMode = '1';
        }
        if (ObjectName == 'property__c사용'){
            IsObjectName = 'property__c';
            objMode = '2';
        }
        
        String sQUERY = 'SELECT Id, ';
        
        if (ReturnFields != null && ReturnFields.Size() > 0) {
            sQuery += String.join(ReturnFields, ',');
        } else {
            sQuery += 'Name';   
        }
        
        sQuery += ' FROM ' + IsObjectName + ' WHERE Id = :selId';
        
        List<sObject> searchResult = Database.query(sQuery);
        
        return searchResult;
    }
    
    @AuraEnabled
    public static string findObjectIcon(String ObjectName) {
        //전석봉 추가
        String objMode = '0';
        String IsObjectName = ObjectName;
        if (ObjectName == 'property__c재고'){
            IsObjectName = 'property__c';
            objMode = '1';
        }
        if (ObjectName == 'property__c사용'){
            IsObjectName = 'property__c';
            objMode = '2';
        }
        
        String u;
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();
        
        for(Schema.DescribeTabSetResult describeTabSetResult : Schema.describeTabs()) {
            for(Schema.DescribeTabResult describeTabResult : describeTabSetResult.getTabs()) {
                if(describeTabResult.getSobjectName() == IsObjectName) { 
                    if( describeTabResult.isCustom() == true ) {
                        for (Schema.DescribeIconResult describeIcon : describeTabResult.getIcons()) {
                            if (describeIcon.getContentType() == 'image/svg+xml'){
                                return 'custom:' + describeIcon.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                            }
                        }
                    } else {
                        return 'standard:' + IsObjectName.toLowerCase();
                    }
                }
            }
        }
        
        return 'standard:default';
    }
    
    @AuraEnabled
    public static objectDetails getObjectDetails(String ObjectName) {    
        //전석봉 추가
        String objMode = '0';
        String IsObjectName = ObjectName;
        if (ObjectName == 'property__c재고'){
            IsObjectName = 'property__c';
            objMode = '1';
        }
        if (ObjectName == 'property__c사용'){
            IsObjectName = 'property__c';
            objMode = '2';
        }
        
        objectDetails details = new objectDetails();
        
        Schema.DescribeSObjectResult describeSobjectsResult = Schema.describeSObjects(new List<String>{IsObjectName})[0];
        
        details.label = describeSobjectsResult.getLabel();
        details.pluralLabel = describeSobjectsResult.getLabelPlural();
        
        details.iconName = findObjectIcon(IsObjectName);
        
        return details;
    }
    
    public class objectDetails {
        @AuraEnabled
        public string iconName;
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string pluralLabel;
    }
}