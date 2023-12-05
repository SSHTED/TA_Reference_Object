/**
 * @description       : 
 * @author            : hojoon.park@dkbmc.com
 * @group             : 
 * @last modified on  : 07-26-2022
 * @last modified by  : hojoon.park@dkbmc.com
**/
// 이메일
public class AllEmailTemplated {


	///////////////////////
    /// 요청단계 이메일 ///
    ///////////////////////
        
    public static Map<String, String> getEmailTemplateMaps(property_request__c Prop, EmailTemplate propTemp) {
        System.debug('------------------Start VOC Email Send------------------');
        
        String query = ''; 
        query += 'SELECT Id, status__c, recordTypeId ';
        query += 'FROM property_request__c WHERE Id = \''+Prop.id+'\' LIMIT 1';
        property_request__c p = Database.query(query); 
        
        Map<String, String> StatusMap = new Map<String, String>();
        
        Schema.DescribeFieldResult Status = property_request__c.status__c.getDescribe();
        List<Schema.PicklistEntry> StatusList = Status.getPicklistValues();
        for (Schema.PicklistEntry sta: StatusList) {
            StatusMap.put(String.ValueOf(sta.getValue()), String.ValueOf(sta.getLabel()));
        }
        
        // url test
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + p.Id;
        
        Map<String, String> recordMap = new Map<String, String>();
        
        
        Map<String, String> bodyMap = new Map<String, String>();        
        
        List<RecordType> RtList = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'property_request__c'];
        Map<String,String> RtMap = new Map<String,String>();
        for(RecordType rt : RtList){
            RtMap.put(rt.Id,rt.Name);
        }
        
        String Title = RtMap.get(Prop.RecordTypeId);
        
        String subject = String.valueOf(propTemp.Subject);
        System.debug('subject : ' + subject);
        
        String SubjectName = '';
        
        SubjectName = '[자산요청 - ' + Title + '요청건에 대해 확인 후 승인 부탁드립니다.]';
        
        System.debug('SubjectName :: '+SubjectName);
        String body = String.valueOf(propTemp.HtmlValue).replace('\r\n', '');
        System.debug('body : ' + body);
        // url test
        String url = '<a href="' + System.URL.getSalesforceBaseUrl().toExternalForm()  + '/';
        
        if(propTemp.DeveloperName == 'propertyPaymentRequest') {
            
            // SubjectName이 없으면 빈칸 아니라면 작성된 SubjectName 
            subject = subject.replace('{SubjectName}', (SubjectName == '' ? '' : SubjectName));
            System.debug('DataStart');
            body = body.replace('{status__c}', (StatusMap.get(p.status__c) == null ? '' : StatusMap.get(p.status__c)));
            body = body.replace('{recordName}', (RtMap.get(p.RecordTypeId) == null ? '' : RtMap.get(p.RecordTypeId)));
            // url test
            body = body.replace('{LinkUrl}', (p.Id == null ? '' : baseUrl));
            
        }
        System.debug('body : ' + body);
        bodyMap.put('subject', subject);
        bodyMap.put('body', body);
        bodyMap.put('recordId' ,p.Id);
        System.debug('bodyMap : '+ bodyMap);
        return bodyMap;
    }
    
}