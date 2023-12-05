/**
 * Desc : DK_CodeConventionsPT_TEST
 *
 * @Method : 
 *   - myUnitTest() : test 실행
 *
 * @Author : Yong-Jin, Cha
 * @Date : 2018. 01. 25.
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description 
 *  ---------------------------------------------
 *  1. | 2018-01-25 | Yong-Jin, Cha | 최초작성
 */
@isTest
public class DK_CodeConventionsPT_TEST
{
    static CodeConventions__c cc;
    static CodeConventionsDetail__c ccDetail;
    
    static
    {
        cc = new CodeConventions__c(Name = 'apex', IsActive__c = true, DisplayOrder__c = 0);
        insert cc;
        
        ccDetail = new CodeConventionsDetail__c(Name = 'apex 1', IsActive__c = true, DisplayOrder__c = 0, CodeFormat__c = 'css', CodeConventionsId__c = cc.Id);
        insert ccDetail;
    }

    static testMethod void myUnitTest()
    {
        Test.startTest();
                
        DK_CodeConventionsPTController.getList();

        Test.stopTest();
    }
}