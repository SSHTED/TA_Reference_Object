/**
* Desc : Trailhead Info Test
*
* @Author : Yong-Jin, Cha
* @Date : 2017. 3. 15.
* @Version : 1.0
*/
@isTest
public class DK_BatchTrailheadInfo_Test
{
    static User testuser;
    
    static {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' OR Name='System Admin' OR Name='시스템 관리자' LIMIT 1];
        testuser = new User(Alias = 'Opptest', Email='Opptest@earth.org',
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', EmployeeNumber='AC100000', ProfileId = p.Id, 
                            TimeZoneSidKey='Asia/Seoul', UserName='Opptest@earth.org', Trailhead_Profile__c ='0055000000626ltAAA');
        insert testuser;
        
        Trailhead_Badges__c Badges = new Trailhead_Badges__c(Name = 'test');
        insert Badges;
    }
    
    static testMethod void DK_BatchTrailheadInfo_Test()
    {
        /* Schedule */
        DK_ScheduleTrailheadInfo sch = new DK_ScheduleTrailheadInfo();
        String sch1 = '0 1 * * * ?';
        system.schedule('DK_ScheduleTrailheadInfo every day', sch1, sch);
        
        //DK_BatchTrailheadInfo.updateTrailheadInfo(testuser.Id);
        Http h = DK_BatchTrailheadInfo.buildHttp();
        DK_BatchTrailheadInfo.buildWebServiceRequest(testuser.Trailhead_Profile__c);
        
        HttpRequest req = DK_BatchTrailheadInfo.buildWebServiceRequest(testuser.Trailhead_Profile__c);
        
        HttpResponse res = DK_BatchTrailheadInfo.invokeWebService(h, req);

        DK_BatchTrailheadInfo.handleWebServiceResponse(res, testuser);

        
    }
}