public class ClassContractProduct 
{
    public Product__c p {get;set;} //제품
    public List<Product__c> plist {get;set;} //제품리스트
    public List<ContractProduct__c> cplist {get;set;} //영업기회를 통해 등록된 계약제품리스트
    public List<ContractProduct__c> addcplist {get;set;} //추가 계약제품리스트
	public List<Order__c> orderlist {get;set;} //현재페이지에 등록된 주문 
    public String cpid {get;set;} //현재 페이지 아이디(계약페이지)
    public String selectedid {get;set;} // 선택된 제품아이디
    public String deselectedid {get;set;} //해제된 제품아이디
    public String deletedid {get;set;} //삭제된 제품아이디
    public List<ContractProduct__c> pidlist {get;set;} //해제된 계약제품리스트
    public List<ContractProduct__c> allcplist {get;set;} //현재 페이지에 등록된 모든 계약제품리스트
    //생성자
    public ClassContractProduct()
    {  
        //현재페이지 아이디
        cpid = Apexpages.currentPage().getParameters().get('cid'); 
        
        //현재 등록된 계약제품리스트
        cplist = [SELECT Id, product__c, productprice__c, supplyPrice__c, number__c, Order__c, OriginalPrice__c  
                     FROM ContractProduct__c 
                     WHERE Contract__c = :cpid];        
		
        addcplist = new List<ContractProduct__c>(); //추가로 등록된 계약제품리스트
        pidlist = new List<ContractProduct__c>(); //해제된 계약제품리스트
        
        //현재 페이지에 등록된 모든 계약제품리스트
        allcplist = [SELECT Id, product__c, productprice__c, supplyPrice__c, number__c, Order__c, OriginalPrice__c  
                     FROM ContractProduct__c 
                     WHERE Contract__c = :cpid]; 
        
        //현재페이지에 등록된 주문
        orderlist = [SELECT Id, Name, Contract__c  
                     FROM Order__c 
                     WHERE Contract__c =:cpid];
        
        p = new Product__c(); //제품
        plist = new List<Product__c>(); //제품리스트

        selectedid = this.selectedid;    
        deselectedid = this.deselectedid;
        deletedid = this.deletedid; 
    }
    
    //제품 조회
    public void ProductSearch()
    {
        if(p.Name == null && p.depth_two__c == null)
        {
            plist = [SELECT Id, 
                     Name, 
                     depth_two__c, 
                     depth_three__c, 
                     depth_four__c, 
                     Price__c  
                     FROM Product__c ];
        }
        else if(p.Name != null && p.depth_two__c != null)
        {
            String pName = '%'+p.Name+'%';
            String pType1 = '%'+p.depth_two__c+'%';
            String pType2 = '%'+p.depth_three__c+'%';
            String pType3 = '%'+p.depth_four__c+'%';
            
            plist = [SELECT Id, Name, depth_two__c, depth_three__c, depth_four__c, Price__c   
                     FROM Product__c 
                     WHERE depth_two__c = :p.depth_two__c
                     AND  
                     ((Name LIKE :pName AND
                       depth_two__c LIKE :pType1)
                      OR
                      (Name LIKE :pName AND
                       depth_three__c LIKE :pType2)
                      OR
                      (Name LIKE :pName AND
                       depth_four__c LIKE :pType3))]; 
        }
        else if(p.Name != null && p.depth_two__c == null)
        {    
            String pName = '%'+p.Name+'%';
            String pType1 = '%'+p.depth_two__c+'%';
            String pType2 = '%'+p.depth_three__c+'%';
            String pType3 = '%'+p.depth_four__c+'%';
            
            plist = [SELECT Id, Name, depth_two__c, depth_three__c, depth_four__c, Price__c   
                     FROM Product__c 
                     WHERE  Name LIKE :pName OR
                     depth_two__c LIKE :pType1 OR
                     depth_three__c LIKE :pType2 OR
                     depth_four__c LIKE :pType3];
        }
        else if(p.Name == null && p.depth_two__c != null)
        {
            plist = [SELECT Id, Name, depth_two__c, depth_three__c, depth_four__c, Price__c   
                     FROM Product__c 
                     WHERE depth_two__c = :p.depth_two__c]; 
        }
    }
    
    //제품 생성   
    public void SelectProduct()
    {
        integer num = 0;
        
        System.debug(selectedid);  
        
        for(Product__c p : plist)
        {  
            for(ContractProduct__c cp : cplist)
            {
                //전체 제품 중에 중복선택하였다면
                if((cp.product__c == p.Id ) && (p.id == selectedid))
                {
                    apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'이전에 선택된 제품입니다.'));
                    return;
                }
            }
            for(ContractProduct__c addcp : addcplist)
            {
                //추가한 제품 중에 중복선택이 있다면
                if((addcp.product__c == p.Id ) && (p.id == selectedid))
                {
                    apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'이전에 선택된 제품입니다.'));
                    return;
                }
            }
            if(p.id == selectedid)
            {   
                System.debug(p.id);
                System.debug(selectedid);
                //추가 계약제품에 추가제품리스트 추가
                ContractProduct__c addcp = new ContractProduct__c();
                addcp.Contract__c = cpid;
                addcp.product__c = selectedid; 
                addcp.Order__c = orderlist[0].Id;
                addcp.OriginalPrice__c = p.Price__c;
                addcplist.add(addcp); 
                System.debug(addcplist);
                break;
            }
            num++; 
        } 
    }
    

    //제품 선택해제
    public void DeselectProduct()
    {
        integer num = 0; 
        
        System.debug(deselectedid);
        //추가된 계약제품리스트에서
        for(ContractProduct__c addcp : addcplist)
        {    
            //선택된 제품이 계약제품과 같다면
            if(addcp.Product__c == deselectedid) 
            {        
                break;
            }        
            num ++;
        }  
        //추가된 계약제품리스트에서 제거
        addcplist.remove(num);
    }
 
    
    //제품 삭제
    public void DeleteProduct()
    {
        integer num = 0;
        
        System.debug(cplist.size());
        //영업기회를 통해 등록된 계약제품
        if(cplist.size() > 0)
        {
            for(ContractProduct__c cp : cplist)
            {
                //삭제를 선택하였다면
                if(cp.Product__c == deletedid) 
                {   
                    pidlist.add(cp);
                    break;
                } 
                num++;
            }
            //영업기회를 통해 등록된 계약제품리스트에서 삭제
            cplist.remove(num);
            
			System.debug(pidlist);	
            System.debug(pidlist.size());	
            //System.debug(cplist.size());
        } 
    }
    
      //저장
    public PageReference Save()
    {
        PageReference reference = new PageReference('/' + cpid); 
		
        if(cplist.size() > 0)
        {
            //전체 계약제품 리스트
            for(ContractProduct__c acp : allcplist)
            {
                //해제된 계약제품 리스트
                for(ContractProduct__c pl : pidlist)
                {
                    //해제된 계약제품이 있다면
                    if(acp.Id == pl.Id)
                    {
                        System.debug(pidlist);
                        delete acp; 
                    }
                }
            }
            update cplist;
        }
        
        if(addcplist.size() > 0)
        {
            insert addcplist;
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