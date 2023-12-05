global class PMS_PjtBillSchedulePurIterator Implements Iterator<AggregateResult>{

    global String pur = '매입';
    global String dkbmc = 'DK BMC';
    global String rain = 'Rainlight Soft';

    AggregateResult [] results {get;set;} 
    Integer index {get;set;}
    
    global PMS_PjtBillSchedulePurIterator(String query){
        index = 0;
        /*String query = ' SELECT  '
                    //+ ' 	Id '
                    //+ ' 	, Name '
                    //+ ' 	, InspectDueDate__c '
                    //+ ' 	, Project__c '
                    //+ ' 	, Project__r.Name '
                    + ' 	 Project__r.ProjectManagerId__c '
                    //+ ' 	, Project__r.ProjectManagerId__r.FM_Email__c '
                    //+ ' 	, PMS_PjtPartner__c '
                    //+ ' 	, PMS_PjtPartner__r.Name '
                    //+ ' 	, Times__c '
                    //+ ' 	, InspectType__c '
                    + ' FROM '
                    + ' 	PMS_PjtBillSchedule__c '
                    + ' WHERE '
                    + ' 	InspectDueDate__c = THIS_MONTH '
                    + ' 	AND InspectType__c = :pur '
                    + ' 	AND PMS_PjtPartner__r.Name != :dkbmc '
                    + ' 	AND PMS_PjtPartner__r.Name != :rain '
                    + ' GROUP BY Project__r.ProjectManagerId__c ';
                    //+ ' ORDER BY Name ';*/
        results = Database.query(query); 
    } 
    
    global boolean hasNext(){ 
        return results !=null && !results.isEmpty() && index < results.size(); 
    } 
    
    global AggregateResult next(){ 
        return results[index++]; 
    } 
}