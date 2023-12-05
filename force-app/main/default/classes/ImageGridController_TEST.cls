/**
 * Desc : ImageGridController_TEST
 *        1. Image Grid Controller Test Code
 *
 * @Method : 
 *   - myUnitTest() : 
 *
 * @Author : Yong-Jin, Cha
 * @Date : 2019. 08. 01.
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description 
 *  ---------------------------------------------
 *  1. | 2019-08-01 | Yong-Jin, Cha | 최초작성
 */
@isTest
global class ImageGridController_TEST {

    public static Account a;
    public static ContentVersion content;
    public static ContentDocumentLink contentlink;
    
    static {
        // Account Create
        a = new Account(Name='Test Account');
        insert a;
        
        content = new ContentVersion(); 
        content.Title = 'Header_Picture1'; 
        content.PathOnClient = '/' + content.Title + '.jpg'; 
        content.VersionData = Blob.valueOf('Unit Test ContentVersion Body'); 
        content.origin = 'H';
        insert content;
        
        contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId = a.Id;
        contentlink.contentdocumentid = [select contentdocumentid from contentversion where id =: content.Id].contentdocumentid;
        contentlink.ShareType = 'V';
        insert contentlink;
    }
    
	static testMethod void myUnitTest()
    {
        Test.startTest();
        
        Id recordId = a.Id;
        String sortingField = 'Title';
        String sortDirection = 'asc';

        ImageGridController.getFileList(recordId, sortingField, sortDirection);

        Test.stopTest();
    }
    
}