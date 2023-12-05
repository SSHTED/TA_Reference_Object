/**
 * @description       : 
 * @author            : hojoon.park@dkbmc.com
 * @group             : 
 * @last modified on  : 06-21-2022
 * @last modified by  : hojoon.park@dkbmc.com
**/
public class ITAM_AllEmailTemplated2 {
    
    ////// 자산 신청 처리시 지급 대기상태 일때 사용자에게 이메일 전송되는 템플릿 ////// - START
    public static Map<String, String> getEmailTemplateMaps2(property_process__c Proc, EmailTemplate procTemp) {
        System.debug('------------------신청처리단계에서 자산지급대기상태일때 이메일전송------------------');

        String query = '';
        query += 'SELECT Id, deliveryProp__c ';
        query += 'FROM property_process__c WHERE Id = \''+Proc.id+'\' LIMIT 1';
        property_process__c p = Database.query(query);
           
        Map<String, String> StatusMap = new Map<String, String>();

        Schema.DescribeFieldResult Status = property_process__c.deliveryProp__c.getDescribe();
        List<Schema.PicklistEntry> StatusList = Status.getPicklistValues();
        for (Schema.PicklistEntry sta: StatusList) {
            StatusMap.put(String.ValueOf(sta.getValue()), String.ValueOf(sta.getLabel()));
        }

        // url
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + Proc.Id;
        Map<String, String> bodyMap = new Map<String, String>();        

        String body = String.valueOf(procTemp.HtmlValue).replace('\r\n', '');
        System.debug('body : ' + body);


        if(procTemp.DeveloperName == 'propertyWait') {

            body = body.replace('{status__c}', (StatusMap.get(Proc.deliveryProp__c) == null ? '' : StatusMap.get(Proc.deliveryProp__c)));
            body = body.replace('{LinkUrl}', (Proc.Id == null ? '' : baseUrl));
        
        }

        System.debug('body : ' + body);
        bodyMap.put('body', body);
        System.debug('bodyMap : '+ bodyMap);
        return bodyMap;
    }
    ////// 자산 신청 처리시 지급 대기상태 일때 사용자에게 이메일 전송되는 템플릿 ////// - END
    
    
    ////// 자산 신청 처리시 지급 완료상태 일때 사용자에게 이메일 전송되는 템플릿 ////// - START
    public static Map<String, String> getEmailTemplateMaps3(property_process__c Proc, EmailTemplate procTemp) {
        System.debug('------------------신청처리단계에서 자산지급완료상태일때 이메일전송------------------');

        String query = '';
        query += 'SELECT Id, deliveryProp__c ';
        query += 'FROM property_process__c WHERE Id = \''+Proc.id+'\' LIMIT 1';
        property_process__c p = Database.query(query);
           
        Map<String, String> StatusMap = new Map<String, String>();

        Schema.DescribeFieldResult Status = property_process__c.deliveryProp__c.getDescribe();
        List<Schema.PicklistEntry> StatusList = Status.getPicklistValues();
        for (Schema.PicklistEntry sta: StatusList) {
            StatusMap.put(String.ValueOf(sta.getValue()), String.ValueOf(sta.getLabel()));
        }

        // url
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + Proc.Id;
        Map<String, String> bodyMap = new Map<String, String>();        

        String body = String.valueOf(procTemp.HtmlValue).replace('\r\n', '');
        System.debug('body : ' + body);


        if(procTemp.DeveloperName == 'propertySuccess') {

            body = body.replace('{status__c}', (StatusMap.get(Proc.deliveryProp__c) == null ? '' : StatusMap.get(Proc.deliveryProp__c)));
            body = body.replace('{LinkUrl}', (Proc.Id == null ? '' : baseUrl));
        
        }

        System.debug('body : ' + body);
        bodyMap.put('body', body);
        System.debug('bodyMap : '+ bodyMap);
        return bodyMap;
    }
    ////// 자산 신청 처리시 지급 완료상태 일때 사용자에게 이메일 전송되는 템플릿 ////// - END
    

    
    ////// 자산 반납신청시 IT Service 에게 보내는 이메일 템플릿 ////// - START   
    public static Map<String, String> getEmailTemplateMaps2T(property_request__c Req, EmailTemplate reqTemp) {
        System.debug('------------------반납대기일때 메일전송------------------');

        String query = '';
        query += 'SELECT Id, status__c, realEmp__c ';
        query += 'FROM property_request__c WHERE Id = \''+Req.id+'\' LIMIT 1';
        property_request__c p = Database.query(query);
           
        Map<String, String> StatusMap = new Map<String, String>();

        Schema.DescribeFieldResult Status = property_request__c.status__c.getDescribe();
        List<Schema.PicklistEntry> StatusList = Status.getPicklistValues();
        for (Schema.PicklistEntry sta: StatusList) {
            StatusMap.put(String.ValueOf(sta.getValue()), String.ValueOf(sta.getLabel()));
        }
		
        String User = Req.realEmp__c;
        
        // url
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + Req.Id;
        Map<String, String> bodyMap = new Map<String, String>();        

        String body = String.valueOf(reqTemp.HtmlValue).replace('\r\n', '');
        System.debug('body : ' + body);

 
        if(reqTemp.DeveloperName == 'property_return') {
            //body = body.reqlace('{realEmp}', ());
            body = body.replace('{realEmp}', (User));
            body = body.replace('{status__c}', (StatusMap.get(Req.status__c) == null ? '' : StatusMap.get(Req.status__c)));
            body = body.replace('{LinkUrl}', (Req.Id == null ? '' : baseUrl));
        
        }

        System.debug('body : ' + body);
        bodyMap.put('body', body);
        System.debug('bodyMap : '+ bodyMap);
        return bodyMap;
    }
    ////// 자산 반납신청시 IT Service 에게 보내는 이메일 템플릿 ////// - END

}