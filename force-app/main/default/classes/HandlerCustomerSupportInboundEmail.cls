global class HandlerCustomerSupportInboundEmail implements Messaging.InboundEmailHandler {
      global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
          
          CustomerSupport__c cs = new CustomerSupport__c();
          cs.Title__c = email.subject;
          cs.Description__c = email.plainTextBody;
          cs.Email__c = email.fromAddress;
          cs.SourcePath__c = '이메일';
          cs.Name__c = '이메일 접수';
          cs.Phone__c = '이메일 접수';
          
          insert cs;
          
          Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
          return result;
      }
  }