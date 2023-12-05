/**
* Desc : Test Data Factory
*        1. 테스트 코드 작성 시 주요 Object 생성 
*
* @Author : Yong-Jin, Cha
* @Date : 2017. 7. 20.
* @Version : 1.0
* @Method : 
*   - getProfile() - Profile 가져오기
*   - createUserRole() - UserRole 생성
*   - createUser() - User 생성
*   - createUserByName() - User 생성 (UserName 지정)
*/
@isTest(SeeAllData=true)
public class DK_UTIL_TestDataFactory
{
    /**
    	Profile 가져오기
    */
    public static Profile getProfile(String P_name) { 

        Profile pf = [select Id from Profile where Name = :P_name limit 1];                  
        
        return pf;
    }
    
    /**
    	UserRole 생성
    */
    public static UserRole createUserRole(String roleName) {
        
        UserRole role = new UserRole(
        	Name = roleName
        );
                                
        insert role;
        
        return role;
    }
    
    /**
    	User 생성
    */
    public static User createUser(Profile pf) {
        
        User user = new User(
        	Alias = 'testUser'
            , Email='SysAdminTestuser@dkbmc.com'
            , EmailEncodingKey='UTF-8'
            , LastName='Testing'
            , LanguageLocaleKey='en_US'
            , LocaleSidKey='en_US'
            , EmployeeNumber='AC100000'
            , TimeZoneSidKey='Asia/Seoul'
            , UserName='SysAdminTestuser@samsung.com'
            , ProfileId = pf.Id
        );
                                
        insert user;
        
        return user;
    }
    
    /**
    	User 생성 (UserName 지정)
    */
    public static User createUserByName(Profile pf, String u_name) {
        
        User user = new User(
        	Alias = 'testUser'
            , Email = 'SysAdminTestuser@dkbmc.com'
            , EmailEncodingKey = 'UTF-8'
            , LastName = 'Testing'
            , LanguageLocaleKey = 'en_US'
            , LocaleSidKey = 'en_US'
            , EmployeeNumber = 'AC100000'
            , TimeZoneSidKey = 'Asia/Seoul'
            , ProfileId = pf.Id
            , UserName = u_name
        );
                                
        insert user;
        
        return user;
    }
}