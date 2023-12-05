public class ITAM_reqRecordTypeController {
    
	@AuraEnabled 
    public static List<RecordType> getRecordType(String objApiName) {
        List<RecordType> lstRecordTypes = [SELECT Id, Name, DeveloperName FROM RecordType WHERE sObjectType=:objApiName AND IsActive=true ORDER BY DeveloperName ASC];

        return lstRecordTypes;
    }

}