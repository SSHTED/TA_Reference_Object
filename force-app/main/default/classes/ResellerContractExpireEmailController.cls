/**
* Desc : ResellerContractExpireEmailController
*
* @Method : 
*  - 
* @Author : Yong-Jin, Cha
* @Date : 2019-09-19
* @Version : 1.0
* @Modified : 
*  ---------------------------------------------
*  NO | Date       | Modifier      | Description
*  ---------------------------------------------
*  1. | 2019-09-19 | Yong-Jin, Cha | 최초작성
*/
public class ResellerContractExpireEmailController {

    @AuraEnabled
    public static Map<String,Object> getEmailPreview(String recordId) {

        Map<String, Object> result = new Map<String,Object>();

        Opportunity__c OP = getData(recordId);
        
        String templateName = 'DK_Contract_Expire';
        
		EmailTemplate ET = getEmailTemplate(templateName);
        
        String FromEmail = OP.Owner.Name + ' <' + OP.Owner.Email + '>';
        String ToEmail = OP.Main_Contact__r.Name + ' <' + OP.F_Mail__c + '>';
        String Subject = ET.Subject;
        String HtmlValue = ET.HtmlValue;

        result.put('FromEmail', FromEmail);
        result.put('ToEmail', ToEmail);
        result.put('Subject', Subject);
        result.put('HtmlValue', setHtmlValueFromData(HtmlValue, OP));

        return result;
    }
    
    @AuraEnabled
    public static Map<String,Object> sendEmail(String recordId) {

        Map<String, Object> result = new Map<String,Object>();

        Opportunity__c OP = getData(recordId);
        
        String templateName = 'DK_Contract_Expire';

		EmailTemplate ET = getEmailTemplate(templateName);
        
        String Subject = ET.Subject;
        String HtmlValue = ET.HtmlValue;
        
		HtmlValue = setHtmlValueFromData(HtmlValue, OP);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(new List<String> {OP.F_Mail__c});
        mail.setBccSender(false);
        mail.setSubject(Subject);
        mail.setHtmlBody(HtmlValue);
        mail.saveAsActivity = true;
        mail.setWhatId(OP.Id);
        
        
        if(!Test.isRunningTest())	Messaging.sendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        
        result.put('result', true);

        return result;
    }
    
    private static String setHtmlValueFromData(String HtmlValue, Opportunity__c OP) {
		
        DateTime TD = System.now();
        
        HtmlValue = HtmlValue.replace('{!Opportunity__c.Id}', String.valueOf(TD.year()) + String.valueOf(TD.month()).leftPad(2, '0') + String.valueOf(TD.day()).leftPad(2, '0') 
                                      + '-' + String.valueOf(TD.hour()).leftPad(2, '0')  + String.valueOf(TD.minute()).leftPad(2, '0'));
        HtmlValue = HtmlValue.replace('{!Opportunity__c.F_dept__c}', OP.F_dept__c == null ? '' : OP.F_dept__c);
        HtmlValue = HtmlValue.replace('{!Opportunity__c.Main_Contact__c}', OP.Main_Contact__r.Name == null ? '' : OP.Main_Contact__r.Name);
        HtmlValue = HtmlValue.replace('{!Opportunity__c.F_Position__c}', OP.F_Position__c == null ? '' : OP.F_Position__c);
        HtmlValue = HtmlValue.replace('{!Opportunity__c.F_Address__c}', OP.F_Address__c == null ? '' : OP.F_Address__c);        
        HtmlValue = HtmlValue.replace('{!Opportunity__c.FirstEndDate__c}', OP.FirstEndDate__c == null ? '' : OP.FirstEndDate__c.format());
        HtmlValue = HtmlValue.replace('{!Opportunity__c.OwnerFullName}', OP.Owner.Name == null ? '' : OP.Owner.Name);
        HtmlValue = HtmlValue.replace('{!Opportunity__c.OwnerTitle}', OP.Owner.Title == null ? '' : OP.Owner.Title);
        HtmlValue = HtmlValue.replace('{!Opportunity__c.OwnerPhone}', OP.Owner.Phone == null ? '' : OP.Owner.Phone);
        HtmlValue = HtmlValue.replace('{!Opportunity__c.OwnerEmail}', OP.Owner.Email == null ? '' : OP.Owner.Email);
        HtmlValue = HtmlValue.replace('{today}', String.valueOf(TD.year()) + '년 ' + String.valueOf(TD.month()) + '월 ' + String.valueOf(TD.day()) + '일');
        
        String gridValue = '';
        
        for(ResellerOpportunityProduct__c rop : OP.Opportunity__r) {
            gridValue += '<tr>';
            gridValue += '   <td style="border:1px solid #333;height:24px;padding-left:5px;text-align:center">' + rop.Product__r.Name + ' (' + rop.Qty__c + '개)</td>';
            gridValue += '   <td style="border:1px solid #333;height:24px;padding-left:5px;text-align:center">' + (rop.StartDate__c == null ? '' : rop.StartDate__c.format()) + '</td>';
            gridValue += '   <td style="border:1px solid #333;height:24px;padding-left:5px;text-align:center">' + (rop.EndDate__c == null ? '' : rop.EndDate__c.format()) + '</td>';
            gridValue += '   <td style="border:1px solid #333;height:24px;padding-left:5px;text-align:center">' + rop.Period__c + '개월</td>';
            gridValue += ' </tr>';
        }
        
        HtmlValue = HtmlValue.replace('<tr><td colspan="4"></td></tr>', gridValue);
        
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
    
    private static Opportunity__c getData(String recordId) {
		return [
            select 
                Account__c
                //, Amount__c
                , CloseDate__c
                , Customer_Scheduled_Date__c
                , Description__c
                , EBU__c
                , ExpectedRevenue__c
                , ExpectedTotalRevenue__c
                , F_dept__c
                , F_Mail__c
                , F_Mobile__c
                , F_Olddate__c
                , F_ParentOppty__c
                , F_Partner__c
                , F_PartnerPerson__c
                , F_phone__c
                , F_Position__c
                , Field1__c
            	, F_Address__c
                , FirstEndDate__c
                , FirstStartDate__c
                , Fld_SalesDiv__c
                , GrandDealerPrice__c
                , GrandProfit__c
                , GrandProfitRate__c
                , GrandSellingPrice__c
                , LeadSource__c
                , Main_Contact__c
            	, Main_Contact__r.Name
                , OpportunityType__c
                , Probability__c
                , Resource_MM__c
                , Resource_Prepared_Date__c
                , Role_Off_Date__c
                , Sales_Estimated_Date__c
            	, Field2__c 
                , SED_Month__c
                , SFDC_Reps__c
                , StageName__c
                , TotalOpportunityQuantity__c
                , Type__c
                , WinType__c
                , OwnerId
                , Owner.Name
            	, Owner.Email
            	, Owner.Phone
            	, Owner.Title
                , Name
                , RecordTypeId
                , Id
            	, RecordType.Name
            	, (select 
                   		Id
                   		, Name
                   		, ApprovalStatus__c
                        , CurrencyCode__c
                        , CurrencySymbol__c
                        , DealerPrice__c
                        , Discount__c
                        , EndDate__c
                        , ListPrice__c
                        , Margin__c
                        , OppAccountName__c
                        , Opportunity__c
                        , Period__c
                        , Product__c
                   		, Product__r.Name
                        , Profit__c
                        , ProfitRate__c
                        , Qty__c
                        , SellingPrice__c
                        , StartDate__c
                        , TotalDealerPrice__c
                        , TotalSellingPrice__c
                   from
                   		Opportunity__r)
            from
                Opportunity__c
            where
            	Id = :recordId
            limit 1
        ].get(0);
    }
    
}