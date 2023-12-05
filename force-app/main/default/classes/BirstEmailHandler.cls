/**
 * Email services are automated processes that use Apex classes
 * to process the contents, headers, and attachments of inbound
 * email.
 */
global class BirstEmailHandler implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
          CustomerSupport__c bcs = new CustomerSupport__c();
          bcs.Title__c = email.subject;
          bcs.Description__c = email.plainTextBody;
          bcs.Email__c = email.fromAddress;
          bcs.SourcePath__c = '이메일';
          bcs.Name__c = '이메일 접수';
          bcs.Phone__c = '이메일 접수';
          bcs.ServiceType__c = 'Birst';
          
          insert bcs;
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();

        return result; 
    }
}