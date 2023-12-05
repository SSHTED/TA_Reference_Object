public with sharing class StatusChangeController {

    ApexPages.StandardsetController setCon;

    public StatusChangeController(ApexPages.StandardsetController controller) {
        setCon = controller;
    } 

    public integer getMySelectedSize() {
        return setCon.getSelected().size();
    } 
    public integer getMyRecordsSize() {
        return setCon.getRecords().size();
    }
}