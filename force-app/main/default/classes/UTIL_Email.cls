/**
 * @Class : UTIL_Email
 *
 * @Method : 
 * 
 * @Author : Yong-jin, Cha
 * @Date : 2022-03-21
 * @Version : 1.01
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2022-03-21 | Yong-jin, Cha | 최초작성
 *  2. | 2022-12-20 | hojae-lee     | 메소드 추가
 */
global with sharing class UTIL_Email {

    global static void sendEmailHtmlText(List<String> toAddresses, List<String> ccAddresses, String subject, String textBody, Id whatId)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(toAddresses);        
        mail.setSubject(subject);
        mail.setHtmlBody(textBody);
        
        if(ccAddresses != null) {
            mail.setCcAddresses(ccAddresses);
        }
        
        if(whatId != null) {
            mail.saveAsActivity = true;
            mail.setWhatId(whatId);
        }
        
        if(!Test.isRunningTest()) Messaging.sendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }

    // 220928_이호재 숨은참조 및 보내는 사람 변경해서 보내는 메소드
    global static void sendEmailHtmlText02(List<String> toAddresses, List<String> bccAddresses, String subject, String textBody)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'dkbmc_epmo@dkbmc.com'];
        
        mail.setSubject(subject);
        if (owea.size() > 0) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        mail.setToAddresses(toAddresses);
        mail.setHtmlBody(textBody);
        
        if(bccAddresses != null){
            mail.setBccAddresses(bccAddresses);
        }
        
        if(!Test.isRunningTest()) Messaging.sendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }

    // 220928_이호재 리스트로 한 번에 보내는 메소드
    global static void sendEmailHtmlText03(List<String> toAddresses, List<String> bccAddresses, String subject, String textBody)
    {
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'dkbmc_epmo@dkbmc.com'];
        
        mail.setSubject(subject);
        if (owea.size() > 0) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        mail.setToAddresses(toAddresses);
        mail.setHtmlBody(textBody);
        
        if(bccAddresses != null){
            mail.setBccAddresses(bccAddresses);
        }
        mailList.add(mail);
        System.debug('mailList : ' + mailList);
        
        if(!Test.isRunningTest()) Messaging.sendEmailResult [] r = Messaging.sendEmail(mailList);
    }

    // 230116_이호재 숨은참조, 참조 포함 및 보내는 사람 변경해서 보내는 메소드
    global static void sendEmailHtmlText04(List<String> toAddresses, List<String> ccAddresses, List<String> bccAddresses, String subject, String textBody)
    {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'dkbmc_epmo@dkbmc.com'];
        
        mail.setSubject(subject);
        if (owea.size() > 0) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        mail.setToAddresses(toAddresses);
        mail.setHtmlBody(textBody);

        if(ccAddresses != null){
            mail.setCcAddresses(ccAddresses);
        }
        
        if(bccAddresses != null){
            mail.setBccAddresses(bccAddresses);
        }
        
        if(!Test.isRunningTest()) Messaging.sendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }
    
    global static void sendEmailPMONoti(List<String> toAddresses
                                        ,List<String> ccAdresses
                                         , String typeName
                                         , String createdByName
                                         , String name
                                         , String recordUrl
                                        )
    {
        EmailTemplate et = [select HtmlValue, Subject from EmailTemplate where DeveloperName = 'PMS_PMO_NOTI_TEMPLATE' limit 1];
        
        String subject = et.Subject;
        String textBody = et.HtmlValue;
        
        subject = subject.replace('{!TYPE}', typeName);
        textBody = textBody.replace('{!TYPE}', typeName);     
        textBody = textBody.replace('{!CREATED_BY_NAME}', createdByName);
        textBody = textBody.replace('{!NAME}', name);
        textBody = textBody.replace('{!RECORD_URL}', recordUrl);
        
        sendEmailHtmlText(toAddresses, ccAdresses, subject, textBody, null);
    }

    global static void sendEmailPmsNoti(List<String> toAddresses
                                        , List<String> ccAddresses
                                        , String typeName
                                        , String projectName
                                        , String createdByName
                                        , String name
                                        , String recordUrl
                                        , Id whatId
                                        ){
        EmailTemplate et = [select HtmlValue, Subject from EmailTemplate where DeveloperName = 'PMS_BASE_NOTI_TEMPLATE' limit 1];
        
        String subject = et.Subject;
        String textBody = et.HtmlValue;
        
        subject = subject.replace('{!TYPE}', typeName);
        
        textBody = textBody.replace('{!TYPE}', typeName);
        if(projectName != null) {
            textBody = textBody.replace('{!PROJECT_NAME}', projectName);
        } else {
            textBody = textBody.replace('{!PROJECT_VIEW}', 'display:none');
        }        
        textBody = textBody.replace('{!CREATED_BY_NAME}', createdByName);
        textBody = textBody.replace('{!NAME}', name);
        textBody = textBody.replace('{!RECORD_URL}', recordUrl);
        
        sendEmailHtmlText(toAddresses, ccAddresses, subject, textBody, whatId);
    }

    // 220928_이호재 Project 생성 알림 추가
    global static void sendEmailProjectNoti(List<String> toAddresses
                                            , List<String> ccAddresses
                                            , List<String> bccAddresses
                                            , String projectName
                                            , String projectCode
                                            , Date ContractStartDate
                                            , Date ContractEndDate
                                            , String projectManager
                                            , String recordUrl){

        EmailTemplate et = [SELECT HtmlValue, subject FROM EmailTemplate WHERE DeveloperName = 'PMS_PROJECT_NOTI_TEMPLATE'];

        String subject = et.subject;
        String textBody = et.HtmlValue;
        textBody = textBody.replace('{!PROJECT_CODE}', projectCode);
        textBody = textBody.replace('{!PROJECT_NAME2}', projectName);
        textBody = textBody.replace('{!projectManager}', projectManager);                                        
        textBody = textBody.replace('{!ContractStartDate}', String.valueOf(ContractStartDate));
        textBody = textBody.replace('{!ContractEndDate}', String.valueOf(ContractEndDate));                                                
        textBody = textBody.replace('{!RECORD_URL}', recordUrl);

        sendEmailHtmlText04(toAddresses, ccAddresses, bccAddresses, subject, textBody);
    }
    //기성훈 Project 종료 알림 추가
    global static void sendEmailProjectCompleteNoti(List<String> toAddresses
                                            , List<String> ccAddresses
                                            , List<String> bccAddresses
                                            , String projectName
                                            , Date ContractStartDate
                                            , Date ContractEndDate
                                            , Date KickoffDate
                                            , Date DeadlineDate
                                            , String recordUrl){

        EmailTemplate et = [SELECT HtmlValue, subject FROM EmailTemplate WHERE DeveloperName = 'PMS_PROJECT_COMPLETE_NOTI_TEMPLATE'];

        String subject = et.subject;
        String textBody = et.HtmlValue;
                                                
        textBody = textBody.replace('{!PROJECT_NAME2}', projectName);
        textBody = textBody.replace('{!ContractStartDate}', String.valueOf(ContractStartDate));
        textBody = textBody.replace('{!ContractEndDate}', String.valueOf(ContractEndDate));
        textBody = textBody.replace('{!KickoffDate}', String.ValueOf(KickoffDate));
        textBody = textBody.replace('{!DeadlineDate}', String.ValueOf(DeadlineDate));                                                
        textBody = textBody.replace('{!RECORD_URL}', recordUrl);

        sendEmailHtmlText04(toAddresses, ccAddresses, bccAddresses, subject, textBody);
    }
    
    global static void sendEmailProjectEndNoti(List<String> toAddresses
                                            , List<String> ccAddresses
                                            , List<String> bccAddresses
                                            , String projectName
                                            , Date ContractStartDate
                                            , Date ContractEndDate
                                            , String ProjectManager
                                            , String recordUrl){
        
        EmailTemplate et = [SELECT HtmlValue, subject FROM EmailTemplate WHERE DeveloperName = 'PMS_PROJECT_END_NOTI_TEMPLATE'];

        String subject = et.subject;
        String textBody = et.HtmlValue;
                                                
        textBody = textBody.replace('{!PROJECT_NAME2}', projectName);
        textBody = textBody.replace('{!projectManager}', projectManager); 
        textBody = textBody.replace('{!ContractStartDate}', String.valueOf(ContractStartDate));
        textBody = textBody.replace('{!ContractEndDate}', String.valueOf(ContractEndDate));                                              
        textBody = textBody.replace('{!RECORD_URL}', recordUrl);

        sendEmailHtmlText04(toAddresses, ccAddresses, bccAddresses, subject, textBody);                                                
                                                
                                                
        
    }
    
    //기성훈 프로젝트 예산 집행 현황 알림 
    global static void sendEmailOnBudgetStatus(List<String> toAddresses
                                              ,List<String> ccAddresses
                                              ,List<String> bccAddresses
                                              ,String projectName
                                              ,Decimal ActualCostPercentage
                                             , Date ContractStartDate
                                             , Date ContractEndDate                                                
                                             , String recordUrl)
    {
                                                  
        EmailTemplate et = [SELECT HtmlValue, subject FROM EmailTemplate WHERE DeveloperName = 'PMS_Project_Use_Control'];
        
        String subject = et.subject;
        String textBody = et.HtmlValue;
        
        textBody = textBody.replace('{!PROJECT_NAME2}', projectName);
        textBody = textBody.replace('{!COST}', String.valueOf(ActualCostPercentage));
        textBody = textBody.replace('{!ContractStartDate}', String.valueOf(ContractStartDate));
        textBody = textBody.replace('{!ContractEndDate}', String.valueOf(ContractEndDate));         
        textBody = textBody.replace('{!RECORD_URL}', recordUrl);
        
        sendEmailHtmlText04(toAddresses, ccAddresses, bccAddresses, subject, textBody);
      
    }
    
        //기성훈 프로젝트 예산 집행 현황 알림 
    global static void sendEmailOnBudgetStatus_high(List<String> toAddresses
                                              ,List<String> ccAddresses
                                              ,List<String> bccAddresses
                                              ,String projectName
                                              ,Decimal ActualCostPercentage
                                             , Date ContractStartDate
                                             , Date ContractEndDate                                                
                                             , String recordUrl)
    {
                                                  
        EmailTemplate et = [SELECT HtmlValue, subject FROM EmailTemplate WHERE DeveloperName = 'PMS_Project_Use_Control_110'];
        
        String subject = et.subject;
        String textBody = et.HtmlValue;
        
        textBody = textBody.replace('{!PROJECT_NAME2}', projectName);
        textBody = textBody.replace('{!COST}', String.valueOf(ActualCostPercentage));
        textBody = textBody.replace('{!ContractStartDate}', String.valueOf(ContractStartDate));
        textBody = textBody.replace('{!ContractEndDate}', String.valueOf(ContractEndDate));         
        textBody = textBody.replace('{!RECORD_URL}', recordUrl);
        
        sendEmailHtmlText04(toAddresses, ccAddresses, bccAddresses, subject, textBody);
      
    }
    
    

    // 220928_이호재 Project 검수예정 알림 추가(매출)
    global static void sendEmailPjtBillNoti(List<String> toAddresses
                                            , List<String> bccAddresses
                                            , String projectName
                                            , String times
                                            , String dueDate
                                            , String recordUrl){

        EmailTemplate et = [SELECT HtmlValue, subject FROM EmailTemplate WHERE DeveloperName = 'PMS_PJTBILL_NOTI_TEMPLATE'];

        String subject = et.subject;
        String textBody = et.HtmlValue;

        textBody = textBody.replace('{!DUE_DATE}', dueDate);
        textBody = textBody.replace('{!TIMES}', times);
        textBody = textBody.replace('{!PROJECT_NAME2}', projectName);
        textBody = textBody.replace('{!RECORD_URL}', recordUrl);

        sendEmailHtmlText02(toAddresses, bccAddresses, subject, textBody);
    }

    // 221020_이호재_수정 Project 매입 검수확인 알림(투입인력 매입 발행 확인여부 체크 요청) 추가
    global static void sendEmailPurchasePjtBillNoti(List<String> toAddresses
                                                    , List<String> bccAddresses
                                                    , List<String> purchaseName
                                                    , List<String> timeList
                                                    , List<String> dueDate
                                                    , String recordUrl){

        EmailTemplate et = [SELECT HtmlValue, subject FROM EmailTemplate WHERE DeveloperName = 'PMS_PURCHASE_PJTBILL_NOTI_TEMPLATE'];
        
        Set<String> eSet = new Set<String>();
        for(String e : toAddresses){
            eSet.add(e);
        }
        List<String> eList = new List<String>(eSet);
        System.debug('eList : ' + eList);
        String htmlBody = '';
        htmlBody = '<table border = "1" style = "margin:auto; padding:7px; border-collapse:collapse; text-align:center; font-size:17px; color:#555"><!--caption>Request Summary Data</caption--><tr><th>회사명(매입)</th>';
        String subject = et.subject;
        String textBody = et.HtmlValue;
        /*List<String> newList = new List<String>();
        newList.add(purchaseName);*/

        for(String p : purchaseName){
            htmlBody += '<td>' + p + '</td>';
        }
        htmlBody += '</tr><tr><th>' + '검수 차수' + '</th>';
        for(String t : timeList){
            htmlBody += '<td>' + t + '</td>';
        }
        htmlBody += '</tr><tr><th>' + '검수 예정일' + '</th>';
        for(String d : dueDate){
            htmlBody += '<td>' + d + '</td>';
        }

        htmlBody += '</tr></table>';
        textBody = textBody.replace('{!TABLE}', htmlBody);
        
        textBody = textBody.replace('{!RECORD_URL}', recordUrl);
        System.debug('textBody : ' + textBody);
        sendEmailHtmlText03(toAddresses, bccAddresses, subject, textBody);
    }

    // 221206_이호재 검수일정에서 검수완료 일 시 세금계산서 발행 알림 메일, 나승재 및 차인경에게 알림메일 발송, 추가 이남주
    // 230323_이호재 참조자(이남주) 제거, 수신자(차인경, 나승재) 제거 후 finance@dkbmc.com 로 수신자 변경
    global static void sendEmailPjtBillNotiSALES(List<String> toAddresses
                                                 , List<String> ccAddresses
                                                 , List<String> bccAddresses
                                                 , String projectName
                                                 , String type
                                                 , String times
                                                 , String dueDate
                                                 , String recordUrl
                                                 // , String filesUrl
                                                 ){

        EmailTemplate et = [SELECT HtmlValue, subject FROM EmailTemplate WHERE DeveloperName = 'PMS_PJTBILL_NOTI_SALES_TEMPLATE'];
        String subject = et.subject;
        String textBody = et.HtmlValue;

        System.debug('projectName : ' + projectName);
        textBody = textBody.replace('{!PROJECT_NAME2}', projectName);
        textBody = textBody.replace('{!TYPE}', type);
        textBody = textBody.replace('{!TYPE}', dueDate);
        textBody = textBody.replace('{!TIMES}', times);
        textBody = textBody.replace('{!DUE_DATE}', dueDate);
        textBody = textBody.replace('{!RECORD_URL}', recordUrl);
        // textBody = textBody.replace('{!FILES_URL}', filesUrl);

        // 발송
        sendEmailHtmlText04(toAddresses, ccAddresses, bccAddresses, subject, textBody);
    }

    // 221206_이호재 영업기획팀 나승재 및 차인경 메일 주소
    global static List<String> getSALESAddresses() {
        /*{"seungjae.na@dkbmc.com":"나승재"
        , "inkyung.cha@dkbmc.com":"차인경"}*/
        List<String> addresses = new List<String>();
        
        Map<String, Object> HRmap = (Map<String, Object>) JSON.deserializeUntyped(System.Label.PMS_SALES_EMAILS);
        Set<String> addEmails = HRmap.keyset();
        for(String email_addr : addEmails) {
            addresses.add(email_addr);
        }
        
        return addresses;
    }

    // 230116_이호재 HR 이예슬, 박선주, 양이슬, 박정현 메일 주소
    global static List<String> getHRAddresses() {

        List<String> addresses = new List<String>();
        
        Map<String, Object> HRmap = (Map<String, Object>) JSON.deserializeUntyped(System.Label.PMS_HR_EMAILS);
        Set<String> addEmails = HRmap.keyset();
        for(String email_addr : addEmails) {
            addresses.add(email_addr);
        }
        
        return addresses;
    }

    // 230119_이호재 FINANCE 이남주 메일 주소
    global static List<String> getFINANCEAddresses() {

        List<String> addresses = new List<String>();
        
        Map<String, Object> HRmap = (Map<String, Object>) JSON.deserializeUntyped(System.Label.PMS_FINANCE_EMAILS);
        Set<String> addEmails = HRmap.keyset();
        for(String email_addr : addEmails) {
            addresses.add(email_addr);
        }
        
        return addresses;
    }
    
    global static List<String> getPMS_ToAddresses(String ProjectId) {
        return getPMS_ToAddresses(ProjectId, null);
    }
    
    global static List<String> getPMS_ToAddresses(String ProjectId, String activatorId) {
        List<String> toAddresses = new List<String>();
        
        PMS_Project__c pjt = [
            select 
                HQId__r.Name
                , Id
                , Name
                , ProjectManagerId__r.FM_Email__c
                , ProjectManagerId__r.FM_HQ__c
            from
                PMS_Project__c
            where
                Id = :ProjectId
            limit 1
        ];
        
        // 본부장
        Set<String> HQSet = new Set<String>();
        HQSet.add(pjt.HQId__r.Name);
        HQSet.add(pjt.ProjectManagerId__r.FM_HQ__c);
        
        List<Employee__c> empList = [
            select
                Email__c
            from
                Employee__c
            where
                FM_HQ__c in :HQSet
            and Position__c = '본부장'
        ];
        
        for(Employee__c e : empList) {
            toAddresses.add(e.Email__c);
        }
        
        // PM
        if(pjt.ProjectManagerId__r.FM_Email__c != null) {
            toAddresses.add(pjt.ProjectManagerId__r.FM_Email__c);
        }
        
        // 조치자
        List<Employee__c> li = [select Email__c from Employee__c where Id = :activatorId];
        if(li.size() > 0) {
            toAddresses.add(li.get(0).Email__c);
        }
        
        if(Test.isRunningTest())    toAddresses.add(System.UserInfo.getUserEmail());
        
        return toAddresses;
    }
    
    global static List<String> getEPMOAddresses() {
        /*{"jongin.kwon@dkbmc.com":"권종인"
        , "dongsik.kim@dkbmc.com":"김동식"
        , "이메일:"박승호"}*/
        List<String> addresses = new List<String>();
        
        Map<String, Object> EPMOmap = (Map<String, Object>) JSON.deserializeUntyped(System.Label.PMS_EPMO_TO_EMAILS);
        Set<String> addEmails = EPMOmap.keyset();
        for(String email_addr : addEmails) {
            addresses.add(email_addr);
        }
        
        return addresses;
    }
    
    global static List<String> getCXHQAddresses() {
        List<String> addresses = new List<String>();
        
        Map<String, Object> MEmap = (Map<String, Object>) JSON.deserializeUntyped(System.Label.PMS_CC_EMAILS);
        Set<String> addEmails = MEmap.keyset();
        for(String email_addr : addEmails) {
            addresses.add(email_addr);
        }
        
        return addresses;
    }
    
    global static List<String> getCCAddresses() {
        List<String> addresses = new List<String>();
        
        Map<String, Object> MEmap = (Map<String, Object>) JSON.deserializeUntyped(System.Label.PMS_CC_EMAILS);
        Set<String> addEmails = MEmap.keyset();
        for(String email_addr : addEmails) {
            addresses.add(email_addr);
        }
        
        return addresses;
    }
    
    global static List<String> getSC_SUPPORTAddress(){
        List<String> addresses = new List<String>();
        
        Map<String,Object> MEmap = (Map<String,Object>)JSON.deserializeUntyped(System.Label.PMS_SC_SUPPORT_EMAIL);
        Set<String> addEmails = MEmap.keyset();
        for(String email_addr : addEmails){
            addresses.add(email_addr);
        }
        
        return addresses;
    }

    // 2023.11.30 안종민 : OPERATION팀 get address 추가
    global static List<String> getOPERATIONAddress(){
        List<String> addresses = new List<String>();
        
        Map<String,Object> MEmap = (Map<String,Object>)JSON.deserializeUntyped(System.Label.PMS_OPERATION_EMAILS);
        Set<String> addEmails = MEmap.keyset();
        for(String email_addr : addEmails){
            addresses.add(email_addr);
        }
        
        return addresses;
    }
    
    global static List<String> getPMOAddresses() {
        List<String> addresses = new List<String>();
        
        List<PermissionSetAssignment> li = [
            select 
                AssigneeId
                , ExpirationDate
                , Id
                , IsActive
                , PermissionSetGroupId
                , PermissionSetId
                , Assignee.Name
                , Assignee.Email
                , PermissionSet.Name
            from
                PermissionSetAssignment
            where 
                PermissionSetId in (
                            select 
                                Id
                            from
                                PermissionSet
                            where 
                                Name in ('PMS_PERM_HQ', 'PMS_PERM_PMO')
                )
            and IsActive = true
            and (PermissionSet.Name = 'PMS_PERM_PMO' or Assignee.Name = '김동식')
        ];
        
        for(PermissionSetAssignment psa : li) {
            addresses.add(psa.Assignee.Email);
        }
        
        return addresses;
    }
}