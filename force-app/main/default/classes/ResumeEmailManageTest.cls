@isTest
public class ResumeEmailManageTest {
    static User user;
    static User user3;
    static Resume__c re;
    static String name;
    static String email;
    static String condition;
    static String jobGroup;
    static String interviewDate1st;
    static String interviewDate2nd;
    static String action;
    static EmailTemplate et;

    static testMethod void PageReferenceTest(){
        Test.startTest();
        // MIXED_DML_OPERATION 관련해서 User를 달리 넣어줬습니다.
        // 또한 DML 역시 test 안에 직접 넣고 사용했습니다.
        System.runAs(new User(Id=UserInfo.getUserId())){
            Profile p1 = [SELECT Id FROM Profile WHERE Name='Profile : DK BMC'];
            
            user= new User(Alias='test', Email='SysAdminTestuser@earth.org',
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', EmployeeNumber='AC100000', ProfileId=p1.id,
                           TimeZoneSidKey='Asia/Seoul', UserName='SysAdminTestuser@earth.org');
            
            insert user;
            
            re = new Resume__c(Name='Tester', OwnerId='00528000000IBiCAAW', Condition__c='1차면접대상',
                               Email__c='email@naver.com', JobGroup__c='개발자');
            insert re;
            
            et = new EmailTemplate(Body='BodyTestData' , DeveloperName='ResumeEmailTemp' , FolderId=user.Id,
                                   Encoding='ks_c_5601-1987', HtmlValue='<div>testData</div>', Name='ResumeTem', 
                                   OwnerId=user.Id , Subject='subject testdata', TemplateType='custom');
            insert et;
                
            name = 'dkbmc';
            email = 'email@naver.com';
            condition = '1차면접대상';
            jobGroup = '개발자';
            interviewDate1st = '2017/01/09 20:08:00';
            interviewDate2nd = '2017/01/10 20:08:00';
            action = 'post';
            
            ResumeEmailManage em = new ResumeEmailManage();
            em.postEmail(name, email, condition, jobGroup, interviewDate1st, interviewDate2nd, action);
            em.postEmail(name, email, '2차면접대상', jobGroup, interviewDate1st, interviewDate2nd, action);
            em.postEmail(name, email, '최종합격', jobGroup, interviewDate1st, interviewDate2nd, action);
            em.postEmail(name, email, '불합격', jobGroup, interviewDate1st, interviewDate2nd, action);
            em.postEmail(name, email, '지원취소', jobGroup, interviewDate1st, interviewDate2nd, action);
            em.postEmail(name, email, '1차면접대상', jobGroup, interviewDate1st, interviewDate2nd, 'resultConfirm');
            em.postEmail(name, email, '2차면접대상', jobGroup, interviewDate1st, interviewDate2nd, 'resultConfirm');
        }
        Test.stopTest();
    }
}