/**
* Desc : DK_UserListController_TEST
*        1. 
*        2. 
*
* @Author : Yong-Jin, Cha
* @Date : 2017. 7. 20.
* @Version : 1.0
*/
@isTest
public class DK_UserListController_TEST
{
    static Profile P;
    static UserRole UR;
    static User u;
    static User u2;
    
    static
    {
        P = DK_UTIL_TestDataFactory.getProfile('System Administrator');
        UR = DK_UTIL_TestDataFactory.createUserRole('CEO');
        u = DK_UTIL_TestDataFactory.createUserByName(P, 'testuser1@test.kr');
        u2 = DK_UTIL_TestDataFactory.createUserByName(P, 'testuser2@test.kr');  
    }

    static testMethod void DK_UserListController_TEST()
    {
        Test.startTest();
        
        Set<String> listviewSet = new Set<String>();
        listviewSet.add('RecentlyViewedUsers');
        listviewSet.add('AllUsers');
        listviewSet.add('ActiveUsers');
        listviewSet.add('InactiveUsers');
        listviewSet.add('AdminUsers');
        
        Set<String> sortingFieldSet = new Set<String>();
        sortingFieldSet.add('Name');
        sortingFieldSet.add('ProfileId');
        sortingFieldSet.add('UserRoleId');
        sortingFieldSet.add('LastLoginDate');
            
        String sortingDirection = 'asc';
        String sortingDirection2 = 'desc';
        String filter_text = 'testuser1';
        String filter_Profile = P.Id;
        String filter_Role = UR.Id;
        String filter_LastLogin = 'TODAY';
        String password = 'password1234';
        String sendUserEmail = 'Y';
        
        Integer limit_size = 10;

        DK_UserListController.getFilterPickList();
        DK_UserListController.getListViews();
        
        DK_UserListController.doChangePassword(u2.Id, password);
        DK_UserListController.doResetPassword(u2.Id, sendUserEmail);
        
        for(String listviewId : listviewSet) {
            for(String sortingField : sortingFieldSet) {
                DK_UserListController.getData(sortingField, sortingDirection, listviewId, filter_text, filter_Profile, filter_Role, filter_LastLogin, limit_size);
                if(sortingField == 'LastLoginDate') {
                    DK_UserListController.getData(sortingField, sortingDirection2, listviewId, filter_text, filter_Profile, filter_Role, filter_LastLogin, limit_size);
                }
            }
        }

        Test.stopTest();
    }
}