@isTest
public class PMS_ObjShareUpdateBatch_TEST {

    static Employee__c employee;
    static PMS_LastEduBackground__c pms_lastedubackground;
    static PMS_Certificate__c pms_certificate;
    static PMS_PjtCareer__c pms_pjtcareer;
    static PMS_EduHistory__c pms_eduhistory;
    static PMS_ActionItem__c pms_actionitem;
    static PMS_PjtResource__c pms_pjtresource;
    static PMS_Psc_Risk__c pms_psc_risk;
    static PMS_Psc_Issue__c pms_psc_issue;

    static {
        
        Id pId = [SELECT Id, UserLicenseId FROM Profile WHERE Name like '%Admin%' LIMIT 1].Id;
        
        User u = new User(UserName='MaterialManagement@Test.com'
                     , LastName='Test'
                     , Email='MaterialManagement@Test.com'
                     , Alias='Test'
                     , TimeZoneSidKey='America/Los_Angeles'
                     , EmailEncodingKey='UTF-8'
                     , LanguageLocaleKey='en_US'
                     , LocaleSidKey='en_US'
                     , ProfileId = pId);
        
        insert u;
        
        employee = new Employee__c (
            Address__c = 'Tset7'
            , AdmitDate__c = 6
            , AdmitPosition__c = '인턴'
            , Affiliation_company__c = 'DK BMC'
            , Birthday__c = date.today()
            , CreatedDate = datetime.now()
            , Description__c = 'Tset7'
            , Email__c = 'Test2@test.com'
            , Emergency__c = '01000000000'
            , Emp_No__c = 'Tset5'
            //, End__c = date.today()
            , Engname__c = 'Tset6'
            , FAX__c = '01000000000'
            , FM__c = '남'
            , Leave__c = date.today()
            , LeaveReason__c = 'Tset8'
            , Mail_No__c = 'Tset1'
            , MobilePhone__c = '01000000000'
            , Name = 'Tset3'
            , Office_Phone__c = '01000000000'
            , PersonalEmail__c = 'Test5@test.com'
            , Position__c = '파트장'
            , Position_start__c = date.today()
            , Probation__c = 5
            , ProbationEnd__c = date.today()
            , Rank__c = '인턴'
            , Rank_Start__c = date.today()
            , Re_entering__c = 'Yes'
            , rehabilitation__c = date.today()
            , RejectReason__c = 'Tset4'
            , ResignReason__c = 'Tset1'
            , SFGrade__c = '초급'
            , Start__c = date.today().addMonths(-1)
            , TechGrade__c = '초급'
            , Type__c = '신입'
            , User__c = System.UserInfo.getUserId()
        );
    
        insert employee;
        
        pms_pjtresource = new PMS_PjtResource__c (
            ActualCnt__c = 5
            , ActualType__c = 'Tset3'
            , EmpBeforeCareer__c = 2
            , EmpBeforeSfCareer__c = 8
            , EmployeeId__c = employee.Id
            , IsActive__c = true
            , IsActual__c = true
            , IsActual_Bill__c = true
            , IsActual_NonBill__c = true
            , IsActual_Training__c = true
            , Name = 'Tset6'
            , OwnerId = System.UserInfo.getUserId()
            , PartnerBeforeCareer__c = 5
            , PartnerBeforeSfCareer__c = 3
            , ResourceType__c = '직원'
        );
    
        insert pms_pjtresource;
        
        pms_lastedubackground = new PMS_LastEduBackground__c (
            AdmissionDate__c = date.today()
            , ClassPeriod__c = 9
            , DegreeType__c = '고졸'
            , Description__c = 'Tset2'
            , EduType__c = '고등학교'
            , EmployeeId__c = employee.Id
            , PjtResourceId__c = [select Id from PMS_PjtResource__c where EmployeeId__c = :employee.Id].get(0).Id
            , GraduationDate__c = date.today()
            , GraduationType__c = '졸업'
            , MajorName__c = 'Tset5'
            , SchoolName__c = 'Tset5'
            , OwnerId = u.Id
        );
    
        insert pms_lastedubackground;
    
        pms_certificate = new PMS_Certificate__c (
            AcquisitionDate__c = date.today()
            , AcquisitionPlanMonth__c = 'Tset9'
            , CertificateName__c = '정보관리기술사'
            , CertificateType__c = '국가기술자격'
            , Description__c = 'Tset10'
            , EmployeeId__c = employee.Id
            , PjtResourceId__c = [select Id from PMS_PjtResource__c where EmployeeId__c = :employee.Id].get(0).Id
            , ExpirationDate__c = date.today()
            , HoldPlanType__c = '보유'
            , IssueDate__c = date.today()
            , IssuingAgency__c = 'Tset2'
            , ProgressStatus__c = '계획'
            , QualificationNo__c = 'Tset2'
            , RenewalType__c = '취득'
            , OwnerId = u.Id
        );
    
        insert pms_certificate;
    
        pms_pjtcareer = new PMS_PjtCareer__c (
            Agency__c = 'Tset1'
            , AppliedProduct_Solution__c = 'Tset4'
            , BusinessType__c = 'Salesforce'
            , Buyer__c = 'Tset3'
            , ChargeTask__c = 'Tset3'
            , EmployeeId__c = employee.Id
            , InputEndDate__c = date.today()
            , InputStartDate__c = date.today().addMonths(-10)
            , JoinDate__c = date.today()
            , JoinProjectInfo__c = 'Tset1'
            , JoinProjectName__c = 'Tset8'
            , RoleType__c = 'Tset7'
            , PjtResourceId__c = [select Id from PMS_PjtResource__c where EmployeeId__c = :employee.Id].get(0).Id
            , OwnerId = u.Id
        );
    
        insert pms_pjtcareer;
    
        pms_eduhistory = new PMS_EduHistory__c (
            CompletionType__c = '수료'
            , EduAgencyName__c = 'Tset3'
            , EducationCost__c = 6
            , EduCurriculumInfo__c = 'Tset8'
            , EduCurriculumName__c = 'Tset5'
            , EduEndDate__c = date.today()
            , EduPeriod__c = 5
            , EduStartDate__c = date.today()
            , EmployeeId__c = employee.Id
            , PjtResourceId__c = [select Id from PMS_PjtResource__c where EmployeeId__c = :employee.Id].get(0).Id
            , Note__c = 'Tset8'
            , OnOffType__c = 'On-Line'
            , Refund__c = 10
            , OwnerId = u.Id
        );
    
        insert pms_eduhistory;
        
        
        
        

        pms_psc_risk = new PMS_Psc_Risk__c (
            ActionDate__c = date.today()
            , ActionHistory__c = 'Tset8'
            , EmpActivatorId__c = employee.Id
            , DangerousContent__c = 'Tset2'
            , DueDate__c = date.today()
            , IdentifyDate__c = date.today()
            , Influence__c = '상'
            , OccurPossibililty__c = '상'
            , OwnerId = System.UserInfo.getUserId()
            //, ProjectId__c = 프로젝트
            //, PSCId__c = PSC
            , ResponsePlan__c = 'Tset4'
            , RiskType__c = '요건 범위'
            , Status__c = '신규'
        );
    
        insert pms_psc_risk;
    
        pms_psc_issue = new PMS_Psc_Issue__c (
            ActionDate__c = date.today()
            , ActionHistory__c = 'Tset4'
            , EmpActivatorId__c = employee.Id
            , DueDate__c = date.today()
            , IssueContents__c = 'Tset6'
            , IssueType__c = '요건 범위'
            , MitigationMeasures__c = 'Tset2'
            , OccurDate__c = date.today()
            , OwnerId = System.UserInfo.getUserId()
            //, ProjectId__c = 프로젝트
            //, PSCId__c = PSC
            , Status__c = '신규'
        );
    
        insert pms_psc_issue;
        
        pms_actionitem = new PMS_ActionItem__c (
            ActionDate__c = date.today()
            , ActionDetails__c = 'Tset3'
            , ActionStatus__c = '배정'
            , Activator__c = employee.Id
            , Description__c = 'Tset7'
            , DueDate__c = date.today()
            , IssueId__c = pms_psc_issue.Id
            , OwnerId = System.UserInfo.getUserId()
            //, ProjectId__c = 프로젝트
        );
    
        insert pms_actionitem;
        
    }
    static testMethod void myUnitTest() {

        Test.startTest();
    
        PMS_ObjShareUpdateBatch batch = new PMS_ObjShareUpdateBatch();
        Database.executeBatch(batch, 200);
        
        SchedulableContext sc = null;
        PMS_ObjShareUpdateScheduler scheduler = new PMS_ObjShareUpdateScheduler();
        scheduler.execute(sc);

        Test.stopTest();
    }
}