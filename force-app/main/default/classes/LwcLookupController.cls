/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-28-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class LwcLookupController {  
    @AuraEnabled(cacheable=true)  
    public static List<sobject> findRecords(String searchKey, String objectName) {  
      string searchText = '\'' + String.escapeSingleQuotes(searchKey) + '%\'';  
      string query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText+' LIMIT 6';  
      return Database.query('SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE '+searchText+' LIMIT 6');  
    }  
  }