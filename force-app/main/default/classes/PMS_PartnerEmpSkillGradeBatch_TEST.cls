@isTest
public with sharing class PMS_PartnerEmpSkillGradeBatch_TEST{
    static PMS_PjtPartner__c ppt;
    static PMS_PjtPartnerEmp__c pmp1;
    static PMS_PjtPartnerEmp__c pmp2;
    static PMS_PjtPartnerEmp__c pmp3;
    static PMS_PjtResource__c res1;
    static PMS_PjtResource__c res2;
    static PMS_PjtResource__c res3;
    static PMS_PjtCareer__c car;
    static PMS_PjtCareer__c car11;
    static PMS_PjtCareer__c car2;
    static Organization__c org;
    static PMS_Project__c pjt;
    static PMS_PjtManpower__c pm;
    static PMS_LastEduBackground__c eb;
    static PMS_LastEduBackground__c eb2;
    static PMS_Certificate__c cer;
    static PMS_Certificate__c cer2;
    static PMS_Certificate__c cer3;
    
    static{
        ppt = new PMS_PjtPartner__c(
        	Name = 'testPartner'
            , PartnerType__c = '파트너'
        );
        insert ppt;
        
        pmp1 = new PMS_PjtPartnerEmp__c(
            Name = 'pmp1'
            , PjtPartnerId__c = ppt.Id
        );
        insert pmp1;
        
        pmp2 = new PMS_PjtPartnerEmp__c(
            Name = 'pmp2'
            , PjtPartnerId__c = ppt.Id
        );
        insert pmp2;
        
        pmp3 = new PMS_PjtPartnerEmp__c(
            Name = 'pmp3'
            , PjtPartnerId__c = ppt.Id
        );
        insert pmp3;
        
        res1 = new PMS_PjtResource__c(
        	IsActive__c = true
            , ResourceType__c = '협력사 인력'
            , PjtPartnerEmpId__c = pmp1.Id
        );
        insert res1;
        
        res2 = new PMS_PjtResource__c(
        	IsActive__c = true
            , ResourceType__c = '협력사 인력'
            , PjtPartnerEmpId__c = pmp2.Id
        );
        insert res2;
        System.debug('res1 ? ' + res1);
        System.debug('res2 ? ' + res2);
        
        res3 = new PMS_PjtResource__c(
        	IsActive__c = true
            , ResourceType__c = '협력사 인력'
            , PjtPartnerEmpId__c = pmp3.Id
        );
        insert res3;
        
        car = new PMS_PjtCareer__c(
            BusinessType__c = 'IT일반'
            , InputStartDate__c = Date.newInstance(2020, 01, 01)
            , InputEndDate__c = Date.newInstance(2020, 10, 01)
            , PjtResourceId__c = res1.Id
            , PjtPartnerEmpId__c = pmp1.Id
        );
        insert car;
        System.debug('car ? ' + car);
        System.debug('car.FM_InputPeriod_Days__c ? ' + car.FM_InputPeriod_Days__c);
        car11 = [SELECT FM_InputPeriod_Days__c FROM PMS_PjtCareer__c WHERE Id = :car.Id][0];
        System.debug('car11 ? ' + car11.FM_InputPeriod_Days__c);
        
        car2 = new PMS_PjtCareer__c(
            BusinessType__c = 'Salesforce'
            , InputStartDate__c = Date.newInstance(2018, 01, 01)
            , InputEndDate__c = Date.newInstance(2018, 02, 01)
            , PjtResourceId__c = res2.Id
            , PjtPartnerEmpId__c = pmp2.Id
        );
        insert car2;
        
        org = new Organization__c(
            IsActive__c = true
            , IsResourceActive__c = true
            , Level__c = '1'
            , Name = 'testOrg'
        );
        insert org;
        
        pjt = new PMS_Project__c(
            IsOnTime__c = true
            , Name = 'testProject'
        );
        insert pjt;
        
        pm = new PMS_PjtManpower__c(
            InputStartDate__c = Date.newInstance(2021, 01, 01)
            , InputEndDate__c = Date.newInstance(2021, 10, 01)
            , ContractPlanStartDate__c = Date.newInstance(2021, 01, 01)
            , ContractPlanEndDate__c = Date.newInstance(2021, 10, 01)
            , PjtResourceId__c = res1.Id
            , JoinHQ__c = org.Id
            , ProjectId__c = pjt.Id
        );
        insert pm;
        
        System.debug('pm.PmPeriods__c ? ' + pm.PmPeriods__c);
        
        eb = new PMS_LastEduBackground__c(
            DegreeType__c = '석사'
            , GraduationType__c = '졸업'
            , PjtResourceId__c = res1.Id
            , PjtPartnerEmpId__c = pmp1.Id
        );
        insert eb;
        
        eb2 = new PMS_LastEduBackground__c(
            DegreeType__c = '박사'
            , GraduationType__c = '졸업'
            , PjtResourceId__c = res2.Id
            , PjtPartnerEmpId__c = pmp2.Id
        );
        insert eb2;
        
        cer = new PMS_Certificate__c(
            CertificateName__c = '정보처리기사'
            , CertificateType__c = '국가기술자격'
            , ExpirationDate__c = null
            , HoldPlanType__c = '보유'
            , PjtResourceId__c = res1.Id
            , PjtPartnerEmpId__c = pmp1.Id
        );
        insert cer;
        
        cer2 = new PMS_Certificate__c(
            CertificateName__c = '정보처리산업기사'
            , CertificateType__c = '국가기술자격'
            , ExpirationDate__c = null
            , HoldPlanType__c = '보유'
            , PjtResourceId__c = res2.Id
            , PjtPartnerEmpId__c = pmp2.Id
        );
        insert cer2;
        
        cer3 = new PMS_Certificate__c(
            CertificateName__c = '정보관리기술사'
            , CertificateType__c = '국가기술자격'
            , ExpirationDate__c = null
            , HoldPlanType__c = '보유'
            , PjtResourceId__c = res3.Id
            , PjtPartnerEmpId__c = pmp3.Id
        );
        insert cer3;
        
        List<PMS_PjtCareer__c> cList = [SELECT Id, FM_InputPeriod_Days__c FROM PMS_PjtCareer__c WHERE PjtResourceId__c =: res1.Id];
        System.debug('car cList ? ' + cList);

        /*String v1 = '{"CarrerYear__c ":",1,2,", "DegreeType__c ":"석사", "Label ":"초급", "Rank__c ":"1", "DeveloperName ":"Master_Beginner"}';
        PMS_PartnerEmpSkillGradeBatch.customMetadata  = (List<MT_Skill_Grade__mdt>) JSON.deserialize( v1, List<MT_Skill_Grade__mdt>.class);*/
    }
    static testMethod void myUnitTest(){
        Test.startTest();
        
        // List<PMS_PjtCareer__c> cList2 = [SELECT Id, FM_InputPeriod_Days__c FROM PMS_PjtCareer__c WHERE PjtResourceId__c =: res1.Id];
        // System.debug('car cList2 ? ' + cList2);
        
        // car.recalculateFormulas();
        
        PMS_PartnerEmpSkillGradeBatch batch = new PMS_PartnerEmpSkillGradeBatch();
        Database.executeBatch(batch, 200);

        PMS_PartnerEmpSkillGradeBatch batch2 = new PMS_PartnerEmpSkillGradeBatch(res1.Id);
        Database.executeBatch(batch2, 200);
        
        SchedulableContext sc = null;
        PMS_PartnerEmpSkillGradeScheduler scheduler = new PMS_PartnerEmpSkillGradeScheduler();
        scheduler.execute(sc);
        Test.stopTest();
    }
}