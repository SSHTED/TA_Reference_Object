@isTest
public class ResumeTaskManageTest {
    static User user;
    static Task ta;
    static Resume__c re;
    static Resume__c re2;

    static testMethod void PageReferenceTest(){
        Profile p1 = [SELECT Id FROM Profile WHERE Name='Profile : DK BMC'];

        user= new User(Alias='test', Email='SysAdminTestuser@earth.org',
                      EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                      LocaleSidKey='en_US', EmployeeNumber='AC100000', ProfileId=p1.id, IsActive = true , 
                      TimeZoneSidKey='Asia/Seoul', UserName='SysAdminTestuser@earth.org', Recruit__c = true);

        DateTime date1st = dateTime.now();
        DateTime date2nd = dateTime.now();

        re = new Resume__c(Name='Tester', OwnerId='00528000000IBiCAAW', Condition__c='1차면접대상', JobGroup__c='개발자',
                           Email__c='email@naver.com', InterviewDate1st__c=date1st, InterviewDate2nd__c=date2nd);
		re2 = new Resume__c(Name='Tester2', OwnerId='00528000000IBiCAAW', Condition__c='서류접수', JobGroup__c='개발자',
                           Email__c='email2@naver.com', InterviewDate1st__c=date1st, InterviewDate2nd__c=date2nd);
            
        ta = new Task(OwnerId = '00528000000IBiCAAW' , Subject = '면접일자 정하기 : ' + '1차면접대상' , Status = 'Not Started', 
                                Priority = 'Normal', ActivityDate = Date.today());
		
        List<Resume__c> reLst = new List<Resume__c>();
        reLst.add(re);
        reLst.add(re2);
        insert reLst;
        insert ta;
    
        Test.startTest();
        SYstem.runAs(user){
            ResumeTaskManage tm = new ResumeTaskManage();
            tm.taskCreate(re.Id, '1차면접대상', Date.today());
        }
        Test.stoptest();
    }
}