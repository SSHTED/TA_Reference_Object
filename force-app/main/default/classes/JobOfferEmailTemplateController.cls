/**
* Desc : JobOfferEmailTemplateController
*
* @Method : 
*  - 
* @Author : Yong-Jin, Cha
* @Date : 2019-08-29
* @Version : 1.0
* @Modified : 
*  ---------------------------------------------
*  NO | Date       | Modifier      | Description
*  ---------------------------------------------
*  1. | 2019-08-29 | Yong-Jin, Cha | 최초작성
*  2. | 2020-09-11 | Yong-Jin, Cha | 희망근무시작일* 필드 추가 및 반영 경영지원 메일 참조 추가
*  2. | 2021-03-15 | Yong-Jin, Cha | 희망근무시작일* 필드 추가 및 반영 경영지원 메일 참조 추가
*/
public class JobOfferEmailTemplateController {

    @AuraEnabled
    public static Map<String,Object> getEmailPreview(String recordId) {

        Map<String, Object> result = new Map<String,Object>();

        Job_Offer__c JO = getData(recordId);
        
        String templateName = 'DK_JOB_OFFER';
        
        if(JO.IsInterviewDropout__c) {
            templateName = 'DK_JOB_NO_OFFER';
        } else if(JO.IsOfferAccept__c) {
            templateName = 'DK_JOB_DOCS_INFO';
        }  
        
		EmailTemplate ET = getEmailTemplate(templateName);
        
        String FromEmail = JO.Owner.Name + ' <' + JO.Owner.Email + '>';
        String ToEmail = JO.Name + ' <' + JO.Email__c + '>';
        String Subject = ET.Subject;
        String HtmlValue = ET.HtmlValue;
        
        Subject = Subject.replace('{!Job_Offer__c.Name}', JO.Name);

        result.put('FromEmail', FromEmail);
        result.put('ToEmail', ToEmail);
        result.put('Subject', Subject);
        result.put('HtmlValue', setHtmlValueFromData(HtmlValue, JO));

        return result;
    }
    
    @AuraEnabled
    public static Map<String,Object> sendEmail(String recordId) {

        Map<String, Object> result = new Map<String,Object>();

        Job_Offer__c JO = getData(recordId);
        
        String templateName = 'DK_JOB_OFFER';
        
        if(JO.IsInterviewDropout__c) {
            templateName = 'DK_JOB_NO_OFFER';
        } else if(JO.IsOfferAccept__c) {
            templateName = 'DK_JOB_DOCS_INFO';
        }
        
		EmailTemplate ET = getEmailTemplate(templateName);
        
        String Subject = ET.Subject;
        String HtmlValue = ET.HtmlValue;
        
        Subject = Subject.replace('{!Job_Offer__c.Name}', JO.Name);
		HtmlValue = setHtmlValueFromData(HtmlValue, JO);
        
        List<String> BccAddresses = new List<String>();
        
        // Email Monitoring 여부
        try {
            // Monitoring 대상 Email 추가
            Map<String, Object> MEmap = (Map<String, Object>) JSON.deserializeUntyped(System.Label.JobOfferBccEmail);
            Set<String> addEmails = MEmap.keyset();
            for(String email_addr : addEmails) {
                BccAddresses.add(email_addr);
            }
        } catch(Exception e) {
            System.debug(e);
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(new List<String> {JO.Email__c});
        mail.setBccSender(false);
        if(BccAddresses.size() > 0 && templateName == 'DK_JOB_DOCS_INFO') {
            mail.setBccAddresses(BccAddresses);
        }
        mail.setSubject(Subject);
        mail.setHtmlBody(HtmlValue);
        mail.saveAsActivity = true;
        mail.setWhatId(JO.Id);
        
        if(!Test.isRunningTest())	Messaging.sendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        
        result.put('result', true);

        return result;
    }
    
    private static String setHtmlValueFromData(String HtmlValue, Job_Offer__c JO) {
		
        if(JO.IsInterviewDropout__c) {
            HtmlValue = HtmlValue.replace('{!Job_Offer__c.Name}', JO.Name);
        } else if(JO.IsOfferAccept__c) {
            HtmlValue = HtmlValue.replace('{!Job_Offer__c.IsEmploymentInsurance__c}', JO.IsEmploymentInsurance__c ? '' : 'display:none;');
        	HtmlValue = HtmlValue.replace('{!Job_Offer__c.IsFinalGraduationCertificate__c}', JO.IsFinalGraduationCertificate__c ? '' : 'display:none;');
            HtmlValue = HtmlValue.replace('{!Job_Offer__c.IsCareerCertificate__c}', JO.IsCareerCertificate__c ? '' : 'display:none;');
            HtmlValue = HtmlValue.replace('{!Job_Offer__c.IsCertificationCopy__c}', JO.IsCertificationCopy__c ? '' : 'display:none;');
            HtmlValue = HtmlValue.replace('{!Job_Offer__c.IsHealthCheckup__c}', JO.IsHealthCheckup__c ? '' : 'display:none;');
            
            HtmlValue = HtmlValue.replace('{!Job_Offer__c.IsTaxReceipt__c}', JO.IsTaxReceipt__c ? '' : 'display:none;');
            HtmlValue = HtmlValue.replace('{!Job_Offer__c.IsHealthCertificate__c}', JO.IsHealthCertificate__c ? '' : 'display:none;');
            HtmlValue = HtmlValue.replace('{!Job_Offer__c.EtcMemo__c}', JO.EtcMemo__c == null ? '' : JO.EtcMemo__c.replaceAll('\n', '<br/>'));
        } else {
			HtmlValue = HtmlValue.replace('{!Job_Offer__c.Name}', JO.Name);
        
            HtmlValue = HtmlValue.replace('{!Job_Offer__c.ReplyDeadline__c}', JO.ReplyDeadline__c == null ? '' : JO.ReplyDeadline__c);
            HtmlValue = HtmlValue.replace('{!Job_Offer__c.Department__c}', JO.Department__c == null ? '' : JO.Department__c);
            HtmlValue = HtmlValue.replace('{!Job_Offer__c.Title__c}', JO.Title__c == null ? '' : JO.Title__c);
            HtmlValue = HtmlValue.replace('{!Job_Offer__c.Salary__c}', JO.Salary__c == null ? '' : String.valueOf(JO.Salary__c));
            HtmlValue = HtmlValue.replace('{!Job_Offer__c.Incentive__c}', JO.Incentive__c == null ? '' : String.valueOf(JO.Incentive__c));
            HtmlValue = HtmlValue.replace('{!Job_Offer__c.IsIncentive__c}', JO.IsIncentive__c ? '' : 'display:none;');
            HtmlValue = HtmlValue.replace('{!Job_Offer__c.SelectiveWelfare__c}', JO.SelectiveWelfare__c == null ? '' : String.valueOf(JO.SelectiveWelfare__c));
            HtmlValue = HtmlValue.replace('{!Job_Offer__c.AdditionalBenefits__c}', JO.AdditionalBenefits__c == null ? '' : JO.AdditionalBenefits__c);
            if(JO.HopeStartDateText__c != null) {
                HtmlValue = HtmlValue.replace('{!Job_Offer__c.HopeStartDate__c}', JO.HopeStartDateText__c);
            } else {
                HtmlValue = HtmlValue.replace('{!Job_Offer__c.HopeStartDate__c}', JO.HopeStartDate__c == null ? '' : JO.HopeStartDate__c.format());
            }
            
        }
        
        return HtmlValue;
    }
    
    private static EmailTemplate getEmailTemplate(String templateName) {
        return [
            select 
                DeveloperName
                , Encoding
                , HtmlValue
                , Id
                , IsActive
                , Name
                , Subject
            from
            	EmailTemplate
            where 
            	IsActive = true
            and DeveloperName = :templateName
            limit 1
        ].get(0);
    }
    
    private static Job_Offer__c getData(String recordId) {
		return [
            select 
                AdditionalBenefits__c
                , Department__c
                , Email__c
                , HopeStartDate__c
            	, HopeStartDateText__c
                , IsEmploymentInsurance__c
                , IsFinalGraduationCertificate__c
                , IsIncentive__c
                , IsOfferAccept__c
            	, IsInterviewDropout__c
                , ReplyDeadline__c
                , Salary__c
                , SelectiveWelfare__c
                , Title__c
                , Name
            	, Id
            	, OwnerId
            	, Owner.Name
            	, Owner.Email
            	, IsCareerCertificate__c
            	, IsCertificationCopy__c
            	, IsHealthCheckup__c
            	, Incentive__c
                , IsTaxReceipt__c
                , IsHealthCertificate__c
                , EtcMemo__c
            from
                Job_Offer__c
            where
            	Id = :recordId
            limit 1
        ].get(0);
    }
}