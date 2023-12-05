@isTest
public class PMS_PartnerCareerUpdateBatch_TEST {

    static PMS_PjtPartner__c pms_pjtpartner;
	static PMS_PjtPartnerEmp__c pms_pjtpartneremp;
    static PMS_PjtResource__c pms_pjtresource;
    static PMS_PjtCareer__c pms_pjtcareer;
    
    static {
        
        pms_pjtpartner = new PMS_PjtPartner__c (
            BankBookInfo__c = 'Tset1'
            , BusinessRegistration__c = 'Tset5'
            , ContractEndDate__c = date.today()
            , ContractStartDate__c = date.today()
            , ContractStatus__c = '계약예정'
            , Description__c = 'Tset4'
            , EmpNumber__c = 3
            , MainPhone__c = '01000000000'
            , ManagerEmail__c = 'Test1@test.com'
            , ManagerName__c = 'Tset1'
            , ManagerPhone__c = '01000000000'
            , ManagerPosition__c = 'Tset9'
            , Name = '협력사'
            , OwnerId = System.UserInfo.getUserId()
            , PartnerType__c = '파트너'
            , RepresentativeEmail__c = 'Test6@test.com'
            , RepresentativeName__c = 'Tset4'
            , RepresentativePhone__c = '01000000000'
        );
    
        insert pms_pjtpartner;
    
        pms_pjtpartneremp = new PMS_PjtPartnerEmp__c (
            CompanyEmail__c = 'Test5@test.com'
            , Description__c = 'Tset2'
            , FingerprintClearDate__c = date.today()
            , FingerprintRegiDate__c = date.today()
            , Gender__c = '남'
            , IsAllowNAC__c = true
            , IsFingerprint__c = true
            , MainTask__c = 'Tset9'
            , ManagementEndDate__c = null
            , ManagementStartDate__c = date.today().addMonths(-10)
            , MS365License__c = 'Tset2'
            , Name = '홍길동'
            , OfficeDevice__c = 'Tset6'
            , Phone__c = '01000000000'
            , PjtPartnerId__c = pms_pjtpartner.Id
            , Position__c = 'Tset8'
            , Rank__c = 'Tset7'
            , SFGrade__c = '초급'
            , TechGrade__c = '초급'
        );
    
        insert pms_pjtpartneremp;
    
        pms_pjtresource = new PMS_PjtResource__c (
            ActualCnt__c = 5
            , ActualType__c = 'Tset2'
            , EmpBeforeCareer__c = 3
            , EmpBeforeSfCareer__c = 10
            , IsActive__c = true
            , IsActual__c = true
            , IsActual_Bill__c = true
            , IsActual_NonBill__c = true
            , IsActual_Training__c = true
            , Name = '홍길동'
            , OwnerId = System.UserInfo.getUserId()
            , PartnerBeforeCareer__c = 5
            , PartnerBeforeSfCareer__c = 1
            , PjtPartnerEmpId__c = pms_pjtpartneremp.Id
            , ResourceType__c = '협력사 인력'
        );
    
        insert pms_pjtresource;
        
        pms_pjtcareer = new PMS_PjtCareer__c (
            Agency__c = 'Tset1'
            , AppliedProduct_Solution__c = 'Tset4'
            , BusinessType__c = 'Salesforce'
            , Buyer__c = 'Tset3'
            , ChargeTask__c = 'Tset3'
            , PjtPartnerEmpId__c = pms_pjtpartneremp.Id
            , InputEndDate__c = date.today()
            , InputStartDate__c = date.today().addMonths(-20)
            , JoinDate__c = date.today()
            , JoinProjectInfo__c = 'Tset1'
            , JoinProjectName__c = 'Tset8'
            , RoleType__c = 'Tset7'
            , PjtResourceId__c = [select Id from PMS_PjtResource__c where PjtPartnerEmpId__c = :pms_pjtpartneremp.Id].get(0).Id
        );
    
        insert pms_pjtcareer;
    }
    
    static testMethod void myUnitTest() {

        Test.startTest();
    
        PMS_PartnerCareerUpdateBatch batch = new PMS_PartnerCareerUpdateBatch();
        Database.executeBatch(batch, 200);
        
        SchedulableContext sc = null;
        PMS_PartnerCareerUpdateScheduler scheduler = new PMS_PartnerCareerUpdateScheduler();
        scheduler.execute(sc);

        Test.stopTest();
    }
}