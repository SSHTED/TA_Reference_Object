@isTest
public class contractRenewCloneControllerTest {

    public static CustomContract__c CC, cloneCC;
    static ContractProduct__c cp, upcp;
    
    static List<ContractProduct__c> conlist; // 기존 항목 리스트
    static List<ContractProduct__c> prds; // 수정 항목 리스트
    static List<Sobject> new_contracts;
    static string conId;
    static string id_Field;
    static string objName;
    static string listName;
    static Id Id;
    static Account acc;
    static string cont;
    static string keys;
    //static CustomContract__c cclist = [SELECT id FROM CustomContract__c];
    static {

        acc = new Account(Name = 'test');
        insert acc;
        
        CC = new CustomContract__c(Name = 'testContract', account__c=acc.id, Category__c='신규', contract_price__c='1', ContractStart__c=System.today(), ContractFinish__c=System.today()); // TEST 계약 이름의 계약 생성
        insert cc;
        System.debug('cc : '+cc);
        
        cloneCC = new CustomContract__c(Name = CC.Name, account__c=CC.account__c, Category__c=cc.Category__c, contract_price__c=cc.contract_price__c, 
                                        ContractStart__c=cc.ContractStart__c, ContractFinish__c=cc.ContractFinish__c); // TEST 계약 이름의 계약 생성
        insert cloneCC;
		System.debug('cloneCC : '+cloneCC);        
        
        cp = new ContractProduct__c(Vendor__c='Salesforce', InvoiceNumber__c='123', Invoice_Date__c=System.today(), InvoiceDueDate__c=System.today(),
                                     Contract__c=cc.Id, Name__c='test', Period_Month__c= 1, number__c=12, Unitprice__c='100', price__c='100');
        insert cp;
        System.debug('cp : '+cp);
        conlist = new list<ContractProduct__c>();      
        conlist.add(cp); 
        System.debug('conlist : '+conlist);
        
        upcp = new ContractProduct__c(Vendor__c=cp.Vendor__c , InvoiceNumber__c='9999', Invoice_Date__c=System.today(), InvoiceDueDate__c=System.today(),
                                       Contract__c=cloneCC.Id, Name__c=cc.Name , Period_Month__c= 1, number__c=12, Unitprice__c='100', price__c='100');
        insert upcp;
        System.debug('upcp : '+upcp);
        prds = [SELECT Id,vendor__c,invoicenumber__c,invoice_date__c,invoiceduedate__c,name__c,period_month__c,number__c,unitprice__c,price__c,purchase_unit_price__c,purchase_price__c FROM ContractProduct__c WHERE ID =: upcp.iD];
        //prds.add(upcp);
    }
    @isTest
    static void contractCloneTest1(){
        
        Test.startTest();
        //contractRenewCloneController crcc  = new contractRenewCloneController(); 
        
        conId = cc.Id;
        id_Field = 'Contract__c';
        objName = 'CustomContract__c';
        listName = 'upconList';
        
        //contractRenewCloneController.fetchConProduct(c.Id);
        contractRenewCloneController.fetchConProduct(CC.Id);            // 계약 Id
        contractRenewCloneController.setFields(objName);                // 
        contractRenewCloneController.madeQuery(CC.Id);              // 계약 Id
        contractRenewCloneController.madeQuery(CC.Id, id_Field, objName);   // 계약 Id
        contractRenewCloneController.madeQuery(prds, listName);         // 
        contractRenewCloneController.cloneAction(cloneCC.Id, json.serialize(prds));         // 계약 id, 수정값
                
        test.stopTest();
    }

}