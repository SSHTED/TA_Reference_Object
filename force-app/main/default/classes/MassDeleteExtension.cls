public with sharing class MassDeleteExtension {

    ApexPages.StandardSetController setCon;
    public String error { get; set; }
    public PageReference originalUrl { get; set; }

    public MassDeleteExtension(ApexPages.StandardSetController controller) {
        setCon = controller;
    }

    public String getMySelectedSize() {
        return setCon.getSelected().size() + '';
    }
    
    public String getMyAllSize() {
        return [select count() from HR_PMS_ORG_Resource__c] + '';
    }
    
    public PageReference deleteRecords(){
        originalUrl = setCon.cancel();
        delete setCon.getSelected();
        return originalUrl;
    }
    
    public PageReference deleteAllRecords(){
        originalUrl = setCon.cancel();
        delete [select Id from HR_PMS_ORG_Resource__c];
        return originalUrl;
    }
}