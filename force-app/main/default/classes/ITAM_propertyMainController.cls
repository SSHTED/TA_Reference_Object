public class ITAM_propertyMainController {
    @AuraEnabled
    public static String getRecordType(String TypeId){
        
        return [SELECT ID,Name, DeveloperName FROM RecordType WHERE id=:TypeId].DeveloperName;
    }
}