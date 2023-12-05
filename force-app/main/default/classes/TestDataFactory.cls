@isTest
public class TestDataFactory {

    public static Profile getProfile(String P_name) { 

        List<Profile> pfList = [SELECT Id FROM Profile WHERE Name= :P_name limit 1];                  
        
        if(pfList.size() > 0) {
            return pfList.get(0);
        } 
        
        return null;
    }
    
    public static User createUser(Profile pf) {
        
        User user = new User(Alias = 'testUser'
                            , Email='SysAdminTestuser@earth.org'
                            , EmailEncodingKey='UTF-8'
                            , LastName='Testing'
                            , LanguageLocaleKey='en_US'
                            , LocaleSidKey='en_US'
                            , EmployeeNumber='AC100000'
                            , ProfileId = pf.Id
                            , TimeZoneSidKey='Asia/Seoul'
                            , UserName='SysAdminTestuser@earth.org'
                            , IsHoliday_Target__c = true);
                                
        insert user;
        
        return user;
    }
    
}