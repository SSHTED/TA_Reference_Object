public class ClassOrder 	
{
    public List<CustomContract__c> mastercc; //마스터계약
    public CustomContract__c cc; //세부계약
    public List<Order__c> olist {get;set;} //마스터계약에 연결된 주문리스트
    public List<Order__c> oldolist {get;set;} //마스터계약에 연결된 주문리스트 중에 선택된 세부주문
    public List<Order__c> orderlist {get;set;} //현재페이지에 등록된 주문   
    public List<ContractProduct__c> Infocplist {get;set;} //마스터계약에 연결된 주문리스트 중에 선택된 주문 계약제품리스트 정보
    public List<ContractProduct__c> oldcplist {get;set;} //마스터계약에 연결된 주문리스트 중에 선택된 주문 계약제품리스트 
    public List<ContractProduct__c> cucplist {get;set;} //현재페이지에 있는 계약제품리스트
    public String cpid {get;set;} //현재 페이지 아이디(계약페이지)
    public String productview {get;set;} //제품보기
    public String selectedorder {get;set;} //선택된 주문아이디
    public String deselectedorder {get;set;} //해제된 주문아이디
    
    //생성자
    public ClassOrder()
    {  
        //현재페이지 아이디
        cpid = Apexpages.currentPage().getParameters().get('cid'); 
        
        //현재페이지와 같은 계약 레코드
        cc = [SELECT Id, Name, parent__c 
              FROM CustomContract__c 
              WHERE Id = :cpid]; 
        
        //현재페이지와 같은 마스터계약 레코드 
        mastercc = [SELECT Id 
                    FROM CustomContract__c 
                    WHERE Id = :cc.parent__c];    
        
        //현재페이지의 마스터계약이 있다면
        if(mastercc.size() > 0)
        {
            //마스터계약에 연결된 주문리스트 가져오기
            olist = [SELECT Id, Name, Contract__c
                     FROM Order__c 
                     WHERE Contract__c = :mastercc[0].Id];
            
            for(Order__c o : olist)
            {
                oldcplist = [SELECT Id, product__c, productprice__c, supplyPrice__c, number__c, Order__c, OriginalPrice__c  
                    		FROM ContractProduct__c 
                    		WHERE Order__c = :o.Id];
            }
        }
        //마스터계약이 없다면 
        else if(mastercc.size() == 0){}
        
        //현재페이지에 등록된 주문
        orderlist = [SELECT Id, Name, Contract__c 
                     FROM Order__c 
                     WHERE Contract__c =:cpid];
        
        oldolist = new List<Order__c>(); //마스터계약에 연결된 주문리스트 중에 선택된 세부주문
        Infocplist = new List<ContractProduct__c>(); //마스터계약에 연결된 주문리스트 중에 선택된 주문 계약제품리스트
        
        //현재페이지 계약제품리스트
        cucplist = [SELECT Id, product__c, productprice__c, supplyPrice__c, number__c, Order__c, OriginalPrice__c  
                    FROM ContractProduct__c 
                    WHERE Contract__c = :cpid];
        
        selectedorder = this.selectedorder; //주문 선택
        deselectedorder = this.deselectedorder; //주문 해제
        productview = this.productview; //제품 정보
    }
    
    //주문리스트에 담긴 제품정보
    public void ProductList()
    {
        //마스터계약에 연결된 주문리스트에서
        for(Order__c o : olist)
        {
            //선택된 주문이 있다면
            if(o.id == productview)
            {
                //주문에 해당되는 계약제품리스트를 보여주기
                Infocplist = [SELECT Id, product__c, productprice__c, supplyPrice__c, number__c, OriginalPrice__c, Order__c    
                              FROM ContractProduct__c 
                              WHERE Order__c = :productview];
                System.debug(productview); 
                System.debug(Infocplist);
            }
        }
    }
    
    //주문 선택
    public void SelectOrder()
    {
        integer num = 0;
        
        //마스터계약에 연결된 주문리스트
        for(Order__c o : olist)
        {
            //선택된 주문
            for(Order__c oldo : oldolist)
            {
                //중복되는 주문이 있다면
                if(o.Id == selectedorder && o.Id == oldo.Id)
                {
                    apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'이전에 선택된 주문내역 입니다.'));
                    return;  
                }
                //주문이 있었다면
                else if(oldolist.size() > 0)
                {
                    apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'하나의 주문내역만 선택하세요'));
                    return;                    
                }
            }
            //선택된 주문이 있다면
            if(o.Id == selectedorder)
            {
                //선택된 주문리스트에 추가
                oldolist.add(o);
                break;
                System.debug(productview); 
                System.debug(oldolist);
            }
            num++;
        }    
        System.debug(oldolist);
        System.debug(oldolist.size());
    }
    
    //주문 선택해제
    public void DeselectOrder()
    {
        integer num = 0;
        
        //선택된 주문에서
        for(Order__c oldo : oldolist)
        {
            //선택 해제되었다면
            if(oldo.id == deselectedorder)
            {
                break;
                System.debug(productview);   
            }
            num++;
        }
        System.debug(oldolist);
        
        //주문제거
        oldolist.remove(num);  
        System.debug(oldolist); 
    }
    
    //저장
    public PageReference Save()
    {
        PageReference reference = new PageReference('/' + cpid); 
        
        //현재 페이지에 주문이 없다면
        if(orderlist.size() == 0 && oldolist.size() > 0)
        {	    
            Order__c o = new Order__c();
            o.Contract__c = cpid;
            insert o;
            
            for(Order__c olod : oldolist)
            {
                oldcplist = [SELECT Id, product__c, productprice__c, supplyPrice__c, number__c, Order__c, OriginalPrice__c  
                             FROM ContractProduct__c 
                             WHERE Order__c = :olod.Id]; 
                
                System.debug(olist); 
                for(ContractProduct__c oldc : oldcplist)
                {
                    ContractProduct__c addoldc = new ContractProduct__c();
                    addoldc.product__c = oldc.product__c;
                    addoldc.supplyPrice__c = oldc.supplyPrice__c;
                    addoldc.number__c = oldc.number__c;
                    addoldc.Order__c = o.Id;
                    addoldc.OriginalPrice__c = oldc.OriginalPrice__c; 
                    addoldc.Contract__c = cpid;
                    insert addoldc;
                }    
            }
        }
        //현재페이지에 이전에 등록된 주문이 있다면
        //oldolist
        else if(orderlist.size() > 0 && oldolist.size() > 0)
        {
            delete cucplist;
      		for(Order__c olod : oldolist)
            {
                oldcplist = [SELECT Id, product__c, productprice__c, supplyPrice__c, number__c, Order__c, OriginalPrice__c  
                             FROM ContractProduct__c 
                             WHERE Order__c = :olod.Id]; 
                
                System.debug(olist); 
                for(ContractProduct__c oldc : oldcplist)
                {
                    ContractProduct__c addoldc = new ContractProduct__c();  
                    addoldc.product__c = oldc.product__c;
                    addoldc.supplyPrice__c = oldc.supplyPrice__c;
                    addoldc.number__c = oldc.number__c;
                    addoldc.Order__c = orderlist[0].Id;
                    addoldc.OriginalPrice__c = oldc.OriginalPrice__c; 
                    addoldc.Contract__c = cpid;
                    insert addoldc;
                }    
            }
        }
        return reference;    
    }
    
    //취소
    public PageReference cancel()
    {
        PageReference reference = new PageReference('/'+ cpid);
        return reference;
    }   
}