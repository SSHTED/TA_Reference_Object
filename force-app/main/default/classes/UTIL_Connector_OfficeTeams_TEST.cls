/**
 * @Class : UTIL_Connector_OfficeTeams_TEST
 *
 * @Method : 
 *	- myUnitTest() : Unit 테스트
 * 
 * @Author : Yong-Jin, Cha
 * @Date : 2021-11-17
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2021-11-17 | Yong-Jin, Cha | 최초작성
 */
@isTest
private class UTIL_Connector_OfficeTeams_TEST {

    static testMethod void myUnitTest() {

        String developerName = 'Chatter';
        String title = '등록 알림';
        String text = '새로운 Account가 추가 되었습니다.';
        String clickText = '상세정보';
        String clickUrl = 'https://www.salesforce.com/kr/?ir=1';        
        String themeColor = 'FA58F4';
    
        Test.startTest();
    
    	UTIL_Connector_OfficeTeams.calloutSend(developerName, title, text);
        UTIL_Connector_OfficeTeams.calloutSend(developerName, title, text, clickText, clickUrl, themeColor);
        UTIL_Connector_OfficeTeams.unCalloutSend(developerName, title, text);
        UTIL_Connector_OfficeTeams.unCalloutSend(developerName, title, text, clickText, clickUrl, themeColor);
    
        Test.stopTest();
    }
}