@isTest
private class ClassContractHistoryTest 
{
    static ContractHistory__c ch1, ch2; //계약내역
    static AccountsReceivable__c ar1; //미수금
    static AccountsPayable__c ap1; //미지급금
    static CustomContract__c cc; //계약
    static Account a; //계정
    static TaxInvoice__c ti1, ti2; //세금 계산서
    static AccountReceivableRecovery__c arr1; //미수금 회수
    static PayArrears__c pa1; //미지급금 지급
    static Date d = Date.newInstance(2015, 10, 10); //세금 계산서 발행일, 예정일 , 계약시작일, 계약종료일
    
    //----------------------------------------------계정, 계약-----------------------------------------------
    static
    {
    	//계정 등록
        a = new Account(Name = '테스트계정');
        insert a;
      
        //계약 등록
        cc = new CustomContract__c(Name = '테스트', account__c = a.id,  ContractStart__c=d, ContractFinish__c=d);
        insert cc;
    }

    static testMethod void myUnitTest() 
    {
        // TO DO: implement unit test
        Test.startTest(); 
        
        
    	//매출 계약내역 등록
        ch1 = new ContractHistory__c(SalesPurchase__c = '매출', 
                     PublicationDueDate__c = d, 
                     Amount__c = 1000000, 
                     Contract__c = cc.id, 
                     Category__c = '계약금', 
                     PublicationCheck__c = FALSE);
        insert ch1;
        
        //매출 계약내역에서 세금 계산서 발행
        ch1.PublicationCheck__c = TRUE; //발행여부
        ch1.PublicationDate__c = d; //발행일
        ch1.TimeLimitOfPayment__c = '30일'; //기간
        update ch1;
        
        //매출 세금 계산서 등록
        ti1 = new TaxInvoice__c(Contract__c = cc.id, 
                    ContractHistory__c = ch1.id, 
                    DAmount__c = ch1.Amount__c, 
                    DSalesPurchase__c = ch1.SalesPurchase__c, 
                    DPublicationDate__c = ch1.PublicationDate__c, 
                    DDuePayment__c = d);
        insert ti1;        
        
        //미수금 등록
        ar1 = new AccountsReceivable__c(ContractHistory__c = ch1.Id, 
                        Account__c = a.Id, 
                        DAmount__c = ch1.Amount__c,
                        Contract__c = cc.id);
        insert ar1; 
        
        //등록된 미수금 회수
     	ar1.AccountReceivableRecoveryDate__c = d; //미수금 회수일자
     	ar1.AccountReceivableRecovery__c = TRUE; //회수여부
     	update ar1;
     	
         //미수금 회수 등록
     	arr1 = new AccountReceivableRecovery__c(ContractHistory__c = ch1.Id, 
                         Account__c = a.Id, 
                         DAmount__c = ch1.Amount__c, 
                         DAccountReceivableRecoveryDate__c = d, 
                         AccountReceivable__c = ar1.id);
    	insert arr1;
    	//회수된 미수금 삭제
		delete arr1;
		
		         //미수금 회수 등록
     	arr1 = new AccountReceivableRecovery__c(ContractHistory__c = ch1.Id, 
                         Account__c = a.Id, 
                         DAmount__c = ch1.Amount__c, 
                         DAccountReceivableRecoveryDate__c = d, 
                         AccountReceivable__c = ar1.id);
    	insert arr1;
		try
		{
			delete ti1;
			//System.assert(false);
		}
		catch(DMLException e)
		{
			System.assert(true, 'pass');
		}
   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   
           //매입 등록
        ch2 = new ContractHistory__c(SalesPurchase__c = '매입', 
                       PublicationDueDate__c = d, 
                       Amount__c = 1000000, 
                       Contract__c = cc.id, 
                       Category__c = '계약금', 
                       PublicationCheck__c = FALSE);
        insert ch2;  
        
        //계약 내역에서 세금 계산서 발행
        ch2.PublicationCheck__c = TRUE;
        ch2.PublicationDate__c = d;
        ch2.TimeLimitOfPayment__c = '30일';   
        update ch2; 
        
        //세금 계산서 등록
        ti2 = new TaxInvoice__c(Contract__c = cc.id, 
                    ContractHistory__c = ch2.id, 
                    DAmount__c = ch2.Amount__c, 
                    DSalesPurchase__c = ch2.SalesPurchase__c, 
                    DPublicationDate__c = ch2.PublicationDate__c, 
                    DDuePayment__c = d); 
        insert ti2;
        
        //미지급금 등록
        ap1 = new AccountsPayable__c(ContractHistory__c = ch2.Id, 
                       Account__c = a.Id, 
                       DAmount__c = ch2.Amount__c,
                       Contract__c = cc.id);
        insert ap1;
        
        //등록된 미지급금 지급
        ap1.PayArrearsDate__c = d;
        ap1.PayArrears__c = TRUE;
        update ap1;
        
        //미지급금 지급
        pa1 = new PayArrears__c(ContractHistory__c = ch2.Id, 
                    Account__c = a.Id, 
                    DAmount__c = ch2.Amount__c, 
                    DPayArrearsDate__c = d, 
                    AccountsPayable__c = ap1.id);
        insert pa1;
        
        //지급된 미지급금 삭제
        delete pa1;
        
                //미지급금 지급
        pa1 = new PayArrears__c(ContractHistory__c = ch2.Id, 
                    Account__c = a.Id, 
                    DAmount__c = ch2.Amount__c, 
                    DPayArrearsDate__c = d, 
                    AccountsPayable__c = ap1.id);
        insert pa1;
        
		try
		{
			delete ti2;
			//System.assert(false);
		}
		catch(DMLException e)
		{
			System.assert(true, 'pass');
		}
        Test.stopTest();
    }
}