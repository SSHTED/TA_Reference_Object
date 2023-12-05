public with sharing class ClassContractHistory 
{
    public List<ContractHistory__c> chlist {get; set;}  //계약내역
    public Set<ContractHistory__c> chset {get; set;}  //계약내역 중복제거
    public List<ContractHistory__c> chbound {get; set;}  //계약내역 리스트 
    public List<AccountsReceivable__c> arlist {get; set;} //미수금
    public Set<AccountsReceivable__c> arset {get;set;} //미수금 중복제거
    public List<AccountsReceivable__c> arbound {get;set;} //미수금 리스트    
    public List<AccountsPayable__c> aplist {get; set;} //미지급금
    public Set<AccountsPayable__c> apset {get;set;} //미지급금 중복제거
    public List<AccountsPayable__c> apbound {get;set;} //미지급금 리스트      
    public String cpid {get;set;} //현재 페이지 Id값
    
    //생성자 
    public ClassContractHistory()  
    {
        //현재 페이지 Id값 변수
        cpid = ApexPages.currentPage().getParameters().get('cpid'); 
        //세금 계산서가 발행되지 않은 계약내역
        chlist = [SELECT Id, PublicationCheck__c, PublicationDate__c, TimeLimitOfPayment__c, Amount__c, VAT__c, SalesPurchase__c, Category__c, Contract__c
                  FROM ContractHistory__c
                  WHERE PublicationCheck__c = FALSE and Contract__c = :cpid ORDER BY CreatedDate ASC];          
        //세금 계산서가 발행되지 않은 계약내역 중복제거
        chset = new Set<ContractHistory__c>();        
        //세금 계산서가 발행되지 않은 계약내역 리스트
        chbound = new List<ContractHistory__c>();        
        //미수금 회수가 되지 않은 미수금
        arlist = [SELECT Id, AccountReceivableRecoveryDate__c, DDuePayment__c, DCategory__c, DVAT__c, AccountReceivableRecovery__c, DPublicationDate__c, Contract__c
                  FROM AccountsReceivable__c
                  WHERE AccountReceivableRecovery__c = FALSE and (Account__c = :cpid Or ContractHistory__c = :cpid)ORDER BY PublicationDate__c ASC];        
        //미수금 회수가 되지 않은 미수금 중복제거
        arset = new Set<AccountsReceivable__c>();        
        //미수금 회수가 되지 않은 미수금 리스트
        arbound = new List<AccountsReceivable__c>();                        
        //미지급금 지급 되지 않은 미지급금
        aplist = [SELECT Id, PayArrearsDate__c, DDuePayment__c, DCategory__c, DVAT__c, PayArrears__c, DPublicationDate__c, Contract__c
                  FROM AccountsPayable__c
                  WHERE PayArrears__c = FALSE and (Account__c = :cpid or ContractHistory__c = :cpid)ORDER BY PublicationDate__c ASC];        
        //미지급금 지급 되지 않은 미지급금 중복제거
        apset = new Set<AccountsPayable__c>();        
        //미지급금 지급 되지 않은 미지급금 리스트
        apbound = new List<AccountsPayable__c>();   
    }   
    //발행하기
    public PageReference Publication() 
    {  
        PageReference reference = new PageReference('/' + cpid); 
        for(ContractHistory__c ch : chlist)
        {
            //선택란에 체크하였을 때
            if(ch.PublicationCheck__c == TRUE)
            {
                //세금 계산서 발행일과 지급기한이 입력되었을 때
                if(ch.PublicationDate__c != null && ch.TimeLimitOfPayment__c != null)
                {
                    chset.add(ch);                   
                }                 
                //세금 계산서 발행일이 비어있을 때
                else if(ch.PublicationDate__c == null && ch.TimeLimitOfPayment__c != null)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'[' + ch.Category__c + ']' + '의 ' + '[세금 계산서 발행일]란이 비어있습니다.'));
                    return null;
                }                
                //지급기한이 비어있을 때
                else if(ch.PublicationDate__c != null && ch.TimeLimitOfPayment__c == null)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'[' + ch.Category__c + ']' + '의 ' + '[지급기한]란이 비어있습니다.'));
                    return null;
                }               
                //세금 계산서 발행일과 지급기한이 비어있을 때
                else if(ch.PublicationDate__c == null && ch.TimeLimitOfPayment__c == null)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'[' + ch.Category__c + ']' + '의 ' + '[지급기한]과 [세금 계산서 발행일]란이 비어있습니다.'));
                    return null;
                }
            } 
        }
        //중복되는 값 제거
        chbound.addAll(chset);
        update chbound;
        return reference;
    }
    //회수하기
    public PageReference Recovery() 
    {  
        PageReference reference = new PageReference('/' + cpid); 
        for(AccountsReceivable__c ar : arlist)
        {
            //선택란에 체크하였을 때
            if(ar.AccountReceivableRecovery__c == TRUE)
            {
                //회수일자가 입력되었을 때
                if(ar.AccountReceivableRecoveryDate__c != null)
                {
                    arset.add(ar);
                }                
                //회수일자가 비어있을 때
                else if(ar.AccountReceivableRecoveryDate__c == null)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'[' + ar.DCategory__c + ']' + '의 ' + '[미수금 회수 일자]란이 비어있습니다.'));
                    return null;
                }
            }          
        }
        //중복되는 값 제거
        arbound.addAll(arset);
        update arbound;
        return reference;                       
    }   
    //지급하기
    public PageReference Arrears() 
    {  
        PageReference reference = new PageReference('/' + cpid); 
        for(AccountsPayable__c ap : aplist)
        {
            //선택란에 체크하였을 때
            if(ap.PayArrears__c == TRUE)
            {
                //지급일자가 입력되었을 때
                if(ap.PayArrearsDate__c != null)
                {
                    apset.add(ap);
                }
                //지급일자가 비어있을 때
                else if(ap.PayArrearsDate__c == null)
                {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'[' + ap.Category__c + ']' + '의 ' + '[미지급금 회수 일자]란이 비어있습니다.'));
                    return null;                    
                }
            }
        }
        //중복되는 값 제거
        apbound.addAll(apset);
        update apbound;
        return reference;                       
    }   
    //이전으로
    public PageReference Cancel() 
    {
        PageReference reference = new PageReference('/' + cpid);
        return reference;
    }    
}