global class ControllerEmailLead implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        
        lead_custom__c lead = new lead_custom__c();
        lead.Description__c = email.plainTextBody;
        lead.Email__c = email.fromAddress;
        lead.LeadSource__c = '컨설팅신청';
        
        insert lead;
        
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        return result;
    }
}