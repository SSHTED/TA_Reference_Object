global with sharing class ImageGridController {

    @AuraEnabled
    global static Map<String, Object> getFileList(String recordId, String sortingField, String sortDirection){
        
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
        
        String SQL = 'select Id, Title, PathOnClient, FileType, Description, ContentSize, ContentDocumentId, CreatedDate from ContentVersion where ContentDocumentId in (' + CDL_IDS + ') ';

        if(sortingField != '') {
            SQL += ' order by ' + sortingField + ' ' + sortDirection;
        }
        System.debug(SQL);

        resultMap.put('datas', Database.query(SQL));
        
        return resultMap;
    }
    
}