@isTest
private class UTIL_Email_TEST {

    static PMS_Project__c pms_project;
    static PMS_PjtResource__c pms_resource;
    static Employee__c emp;
    static {
        pms_project = new PMS_Project__c (
            Name = 'project'
            , OwnerId = System.UserInfo.getUserId()
        );
    
        insert pms_project;
	}
    static {
                User u03 = [SELECT Id FROM User WHERE Name = '차용진' LIMIT 1];
            emp = new Employee__c(
            Name = '홍길동02'
            , Emp_No__c = '112'
            , Rank__c = '인턴'
            , Start__c = date.today()
            , User__c = u03.Id
        );
        insert emp;
    }    
    static {
        pms_resource = new PMS_PjtResource__c(
            Name = 'test1'
            , ResourceType__c = '직원'
            , EmployeeId__c = emp.Id
        );
        insert pms_resource;        
    }
    
    static testMethod void myUnitTest() {

        List<String> toAddresses = new List<String>{'yj.cha@dkbmc.com'};
        List<String> ccAddresses = new List<String>{'yj.cha@dkbmc.com'};
        List<String> bccAddresses = new List<String>{'yj.cha@dkbmc.com'};
        List<String> purchaseName = new List<String>{'매입'};
        List<String> timeList = new List<String>{'3'};
        List<String> dueDate02 = new List<String>{'2022-12-31'};
        String subject = '제목';
        String textBody = '내용';
        Id whatId = pms_project.Id;
        String typeName = '요청사항';
        String projectName = '프로젝트';
        String createdByName = '홍길동';
        String name = 'HQ-000111';
        String recordUrl = '';
        String ProjectId = pms_project.Id;
        String activatorId = '';
        String times = '';
        String dueDate = '';
        String projectCode = '';
        Date ContractStartDate = Date.newInstance(2023, 05, 11);
        Date ContractEndDate = Date.newInstance(2023, 05, 11);
		Date KickoffDate = Date.newInstance(2023, 05, 11);
        Date DeadlineDate = Date.newInstance(2023, 05, 11);
        Decimal ActualCostPercentage;
    
        Test.startTest();

        UTIL_Email.sendEmailHtmlText(toAddresses, ccAddresses, subject, textBody, whatId);
        UTIL_Email.sendEmailPmsNoti(toAddresses, ccAddresses, typeName, projectName, createdByName, name, recordUrl, whatId);
        UTIL_Email.getPMS_ToAddresses(ProjectId);
        UTIL_Email.getPMS_ToAddresses(ProjectId, activatorId);
        UTIL_Email.getSALESAddresses();
        UTIL_Email.getHRAddresses();
        UTIL_Email.getEPMOAddresses();
        UTIL_Email.getCXHQAddresses();
        UTIL_Email.getPMOAddresses();
        UTIL_Email.getFINANCEAddresses();
        UTIL_Email.getSC_SUPPORTAddress();
        UTIL_Email.getCCAddresses();
        UTIL_Email.getOPERATIONAddress();
        UTIL_Email.sendEmailProjectNoti(toAddresses, ccAddresses, bccAddresses, projectName, projectCode, ContractStartDate,ContractEndDate,pms_resource.Name,recordUrl);
        UTIL_Email.sendEmailProjectCompleteNoti(toAddresses, ccAddresses, bccAddresses, projectName, ContractStartDate, ContractEndDate,KickoffDate,DeadlineDate,recordUrl);
        UTIL_Email.sendEmailProjectEndNoti(toAddresses, ccAddresses, bccAddresses, projectName, ContractStartDate, ContractEndDate,pms_resource.Name,recordUrl);
        UTIL_Email.sendEmailPjtBillNoti(toAddresses, bccAddresses, projectName, times, dueDate, recordUrl);
        UTIL_Email.sendEmailHtmlText02(toAddresses, bccAddresses, subject, textBody);
        UTIL_Email.sendEmailHtmlText03(toAddresses, bccAddresses, subject, textBody);
        UTIL_Email.sendEmailPMONoti(toAddresses,ccAddresses ,typeName, createdByName, name, recordUrl);
        UTIL_Email.sendEmailPurchasePjtBillNoti(toAddresses, bccAddresses, purchaseName, timeList, dueDate02, recordUrl);
        //UTIL_Email.sendEmailOnBudgetStatus(toAddresses , ccAddresses , bccAddresses , projectName , ActualCostPercentage ,ContractStartDate, ContractEndDate ,recordUrl);
    
        Test.stopTest();
    }
}