/**
 * Desc : DPL_TEST
 *        1. DynamicPickList Test Code
 *
 * @Method : 
 *   - myUnitTest_01() : DPL_IconName Test
 *   - myUnitTest_02() : DPL_SortName Test
 *   - myUnitTest_03() : DPL_RelationshipName Test
 *   - myUnitTest_04() : DPL_TimeZoneName Test
 *
 * @Author : Yong-Jin, Cha
 * @Date : 2019. 02. 20.
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description 
 *  ---------------------------------------------
 *  1. | 2019-02-20 | Yong-Jin, Cha | 최초작성
 *  2. | 2019-03-25 | Yong-Jin, Cha | myUnitTest_03(), myUnitTest_04() 추가
 */
@isTest
public class DPL_TEST {

	static testMethod void myUnitTest_01()
    {
        Test.startTest();
        
        DPL_IconName DPL = new DPL_IconName();
        
        DPL.getDefaultValue();
        DPL.getValues();

        Test.stopTest();
    }
    
    static testMethod void myUnitTest_02()
    {
        Test.startTest();
        
        DPL_SortName DPL = new DPL_SortName();
        
        DPL.getDefaultValue();
        DPL.getValues();

        Test.stopTest();
    }
    
    static testMethod void myUnitTest_03()
    {
        Test.startTest();
        
        VisualEditor.DesignTimePageContext context;
        
        DPL_RelationshipName DPL = new DPL_RelationshipName(context);
        
        DPL.getDefaultValue();
        DPL.getValues();

        Test.stopTest();
    }
    
    static testMethod void myUnitTest_04()
    {
        Test.startTest();
        
        DPL_TimeZoneName DPL = new DPL_TimeZoneName();
        
        DPL.getDefaultValue();
        DPL.getValues();

        Test.stopTest();
    }
}