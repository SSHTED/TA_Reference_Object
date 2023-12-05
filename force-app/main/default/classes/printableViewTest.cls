@isTest
private class printableViewTest {
    static Resolution_To_Spend__c spend;
    static ProcessInstance p;
    static ProcessInstanceHistory ph;
    static List<ProcessInstance> pList;
    static String recordId;
    
    static {
        spend = new Resolution_To_Spend__c(Title__c = 'test', expenditureType__c='송금', Total__c=100, PaymentStatus__c=true,CheckImp__c = true, ownerId=userInfo.getUserId(),
                                           Project__c='프로젝트명', Details__c='야', Payment_Account__c='111-222-333',
                                           Approval_Opinion__c='없음', DocStatus__c='승인완료');
        insert spend; // test 지출결의 생성
        system.debug(spend.ownerId);
        
        List<ProcessDefinition> processList = [select Id, Name, DeveloperName from ProcessDefinition];
        for(ProcessDefinition p : processList){
            system.debug(p);
        }
        system.debug(userInfo.getUserId());
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(spend.id);
        req1.setSubmitterId(userInfo.getUserId());
        req1.setNextApproverIds(new List<Id>{userInfo.getUserId()});
        req1.setSkipEntryCriteria(true);
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        
        Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setNextApproverIds(new List<Id>{userInfo.getUserId()});
        req2.setWorkitemId(result.getNewWorkitemIds().get(0));
        Approval.ProcessResult result2 =  Approval.process(req2);
        
        Approval.ProcessWorkitemRequest req3 = new Approval.ProcessWorkitemRequest();
        req3.setComments('Approving request.');
        req3.setAction('Approve');
        req3.setWorkitemId(result2.getNewWorkitemIds().get(0));
        Approval.ProcessResult result3 =  Approval.process(req3);

       // pList.add(ph);
    }
	@isTest
    static void test(){
        ProcessInstance p = new ProcessInstance();
       
        Test.startTest();
        System.debug('start-----------------------');
        List<ProcessInstance> processList = [SELECT Id, Status, CreatedDate, TargetObjectId,
                                             (SELECT Actor.Name, ProcessNode.Name FROM StepsAndWorkitems ORDER BY ProcessNode.Name) 
                                             FROM ProcessInstance WHERE TargetObjectId =: spend.Id  ORDER BY CreatedDate DESC LIMIT 1];
        ApexPages.currentPage().getParameters().put('id',spend.Id);
        ApexPages.StandardController sc = new ApexPages.StandardController(spend);
       	printableViewController pvc = new printableViewController(sc);
        pvc.getProcess();
        System.debug('stop-----------------------');
        Test.Stoptest();
    }
}