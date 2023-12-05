public with sharing class PrdController 
{
    public Product__c prd {get; set;}  //Product   
    public list<Product__c> plist {get;set;} //ProductList
    public list<OpportunityProduct__c> oplist {get;set;} //OpportuniryProductList(License)
    public list<OpportunityProduct__c> oplist2 {get;set;} //OpportuniryProductList2(컨설팅)
    public string paramValue {get;set;}   
    public list<OpportunityProduct__c> delList {get;set;}
    public list<OpportunityProduct__c> delList2 {get;set;}    
    public OpportunityProduct__c oprd {get;set;}
    public String selectedid{get;set;} //SelectButton ID
    public String deletedid {get;set;} //DeleteButton ID
    public String deletedid2 {get;set;} //DeleteButton ID test 
    public set<Id> delPrdid; // 해제 id(License)
    public set<Id> delPrdid2; // 해제 id(컨설팅) 
    public String oppid {get;set;} //vf Parameter
    
    public String parentId{get;set;} //Opportunity__c ID
    
    public set<Id> prdid; //Product ID
    
    public Map<String,String> pickMap {get;set;}
    
    public PrdController()  //Constructor
    {
        prdid = new set<Id>();
        prd = new Product__c();
        plist = new list<Product__c>();
        oplist = new list<OpportunityProduct__c>();
        oplist2 = new list<OpportunityProduct__c>();
        delList = new list<OpportunityProduct__c>();
        delList2 = new list<OpportunityProduct__c>();
        
        oprd = new OpportunityProduct__c();
        oppid = ApexPages.currentPage().getParameters().get('opid');
        selectedid = this.selectedid;
        deletedid = this.deletedid;
        deletedid2 = this.deletedid2;
        
        pickMap = new Map<String, String>();
        
        parentId = String.valueOf(System.currentPageReference().getParameters().get('opid'));
        System.debug('parent Id : ' + parentId);
        
        if(!String.isBlank(parentId)) {
            delPrdid = new set<Id>(); 
            oplist = [
                SELECT Product__c, SalePrice__c, number__c, Discount__c, Month__c, StartDate__c, Id, Product__r.depth_one__c
                FROM OpportunityProduct__c
                WHERE Opportunity__c = :parentId AND depth_one__c LIKE '%License'
            ]; 
            
            for(OpportunityProduct__c op : oplist){ 
                pickMap.put(op.Product__c, op.Product__r.depth_one__c); 
                delPrdid.add(op.Product__c);
            } 
        } 
        if(!String.isBlank(parentId)) {
            delPrdid2 = new set<Id>(); 
            oplist2 = [
                SELECT Product__c, SalePrice__c, number__c, Discount__c, Remarks__c, Product__r.depth_one__c
                FROM OpportunityProduct__c
                WHERE Opportunity__c = :parentId AND depth_one__c LIKE '%용역'
            ];
            
            for(OpportunityProduct__c op : oplist2) {
                pickMap.put(op.Product__c, op.Product__r.depth_one__c);
                delPrdid2.add(op.Product__c);
            }
        } 
    }
    // -------------------------------검색---------------------------------
    public string searchName{get; set;}
    
    public void getProductList() //SearchList
    {        
        String query = 'select depth_one__c, depth_two__c, depth_three__c, depth_four__c, id, name from Product__c where id !=: delPrdid and id !=: delPrdid2 ';
        system.debug('prdid : '+prdid);
        
        if(String.isNotEmpty(prd.depth_one__c)) // 그룹을 선택했을때
        {
            query = query+'and depth_one__c =\''+prd.depth_one__c+'\'';
            System.debug('query111111111111==========='+query); 
            if(String.isNotEmpty(selectedid)) // 검색한 값을 선택했을때
            {
                query = query+'and id not in: prdid '+' and depth_one__c =\''+prd.depth_one__c+'\'';
                System.debug('quer222222222222y==========='+query);
            }
            if(String.isNotEmpty(searchName))
            {
                query = query+'and depth_one__c =\''+prd.depth_one__c+'\''+' and name like \'%'+searchName+'%\'';
                
                if(String.isNotEmpty(selectedid))
                {
                    query = query+'and id not in: prdid and depth_one__c =\''+prd.depth_one__c+'\''+' and name like \'%'+searchName+'%\'';
                }
            }
        } else if(String.isEmpty(prd.depth_one__c) && String.isEmpty(searchName)){
            plist = null;
            return;
        } else if(String.isEmpty(prd.depth_one__c) && String.isNotEmpty(searchName)){
            query = query+'and id not in: prdid and name like \'%'+searchName+'%\'';
        }
        system.debug(query);
        plist = Database.query(query); 
         system.debug('plist-----'+plist);
    }  
    
    public void selectProduct() //SelectList
    {
        integer num = 0;
        System.debug('plist : ' + plist);
        for(Product__c p : plist)
        {
            if(p.id == selectedid && p.depth_one__c == 'License')
            {
                OpportunityProduct__c op1 = new OpportunityProduct__c();
                op1.Opportunity__c = oppid;
                op1.Product__c = p.id;
                op1.SalePrice__c = 0;
                op1.number__c = 0;  
                op1.Discount__c = 0;
                op1.Month__c = 0;
                op1.StartDate__c = System.today();
                oplist.add(op1);
                pickMap.put(p.Id, p.depth_one__c);
                
                break;
            } 
            /*
            else if(p.id == selectedid && p.depth_one__c == 'Salesforce License')
            {
                OpportunityProduct__c op1 = new OpportunityProduct__c();
                op1.Product__c = p.id;
                op1.Opportunity__c = oppid;  
                op1.SalePrice__c = 0;
                op1.number__c = 0;  
                op1.Discount__c = 0;
                op1.Month__c = 0;
                op1.StartDate__c = System.today();
                oplist.add(op1);
                pickMap.put(p.Id, p.depth_one__c);
                
                break;
            }  
			*/
            
            if(p.id == selectedid && p.depth_one__c == '용역')
            {
                OpportunityProduct__c op2 = new OpportunityProduct__c();
                op2.Product__c = p.id;  
                op2.Opportunity__c = oppid;  
                op2.SalePrice__c = 0;
                op2.number__c = 0;  
                op2.Discount__c = 0;
                op2.Month__c = 0;
                op2.StartDate__c = System.today();
                oplist2.add(op2);
                pickMap.put(p.Id, p.depth_one__c);
                
                break;
            } 
            /*
            else if(p.id == selectedid && p.depth_one__c == 'Salesforce 컨설팅')
            {
                OpportunityProduct__c op2 = new OpportunityProduct__c();
                op2.Product__c = p.id;  
                op2.Opportunity__c = oppid;  
                op2.SalePrice__c = 0;
                op2.number__c = 0;  
                op2.Discount__c = 0;
                op2.Month__c = 0;
                op2.StartDate__c = System.today();
                oplist2.add(op2);
                pickMap.put(p.Id, p.depth_one__c);
                
                break;
            }
			*/
            num++;
        }
        system.debug(plist.size());  
        
        if((plist != null) && (plist.size() != 0) && (String.isNotEmpty(selectedid)))
        {
            plist.remove(num);
            prdid.add(selectedid);
            system.debug(plist.size());
        }
        system.debug('prdid : '+prdid);
    }
    
    public void deleteProduct() //DeleteList
    {  
        integer index = 0;
        Product__c p = new Product__c();
        if(delPrdid.contains(deletedid)) delPrdid.remove(deletedid);
        
        for(OpportunityProduct__c op : oplist)
        {    
            if(op.Product__c == deletedid) 
            {             
                p = [select depth_one__c, depth_two__c, depth_three__c, depth_four__c, id, Name 
                     from Product__c where id =: deletedid];
                break;              
            }        
            index ++;
        }
        if((oplist != null) && (oplist.size() != 0) && (String.isNotEmpty(deletedid)))
        {      
            if(oplist[index].Id != null) {
                delList.add(oplist[index]);
            }
            oplist.remove(index);
            prdid.remove(deletedid);
        } 
        // delete License
        if((p.depth_one__c==prd.depth_one__c) && (!(prdid.contains(deletedid))))                                                                                                                   
        {
            plist.add(p);
            plist = [select  depth_one__c, depth_two__c, depth_three__c, depth_four__c, id, Name 
                     from Product__c 
                     where id !=: prdid and depth_one__c =:prd.depth_one__c
                     AND id !=: delPrdid
                     order by depth_two__c DESC];
            system.debug('=====1-1=====');
        }
    }
    
    public void deleteProduct2()
    {  
        integer index2 = 0;
        Product__c p = new Product__c();
        if(delPrdid2.contains(deletedid2)) delPrdid2.remove(deletedid2);   
        
        for(OpportunityProduct__c op2 : oplist2)
        {    
            if(op2.Product__c == deletedid2) 
            {             
                p = [select depth_one__c, depth_two__c, depth_three__c, depth_four__c, id, Name 
                     from Product__c
                     where id =: deletedid2]; 
                break;              
            }        
            index2 ++;
        }
        if((oplist2 != null) && (oplist2.size() != 0) && (String.isNotEmpty(deletedid2)))
        {      
            if(oplist2[index2].Id != null) {
                delList2.add(oplist2[index2]);
            }
            oplist2.remove(index2);
            prdid.remove(deletedid2);
        } 
        
        // delete '용역'
        if((p.depth_one__c==prd.depth_one__c) && (!(prdid.contains(deletedid2))))                                                                                                                   
        {
            plist.add(p);
            plist = [select  depth_one__c, depth_two__c, depth_three__c, depth_four__c, id, Name 
                     from Product__c 
                     where id !=: prdid and depth_one__c =:prd.depth_one__c     
                     AND id !=: delPrdid2
                     order by depth_two__c DESC];
            system.debug('=====1-1=====');
        }
    } 
    public PageReference listSave() //Save
    {
        for(integer i = 0; i < oplist.size(); i++){
            if(oplist[i].Discount__c > 100 || oplist[i].Discount__c < 0){
                System.debug('oplist[0].Discount__c'+oplist[0].Discount__c );
                Apexpages.addMessage(new ApexPages.Message(Apexpages.Severity.ERROR, '할인율을 0보다 작거나 100보다 큰 수로 입력할 수 없습니다.'));
                return null;
            }
            
        }
        for(integer i = 0; i < oplist2.size(); i++){
            if(oplist2[i].Discount__c > 100 || oplist2[i].Discount__c < 0){
                System.debug('oplist2[0].Discount__c'+oplist2[0].Discount__c );
                Apexpages.addMessage(new ApexPages.Message(Apexpages.Severity.ERROR, '할인율을 0보다 작거나 100보다 큰 수로 입력할 수 없습니다.'));
                return null;
            }
        }
        
        OpportunityProduct__c op = new OpportunityProduct__c();  
        PageReference reference = new PageReference('/' + oppid); 
        
        List<OpportunityProduct__c> updateData = new List<OpportunityProduct__c>();
        // System.debug('첫번째 할인율 라이선스 : ' + oplist[0].Discount__c);
        for(Integer i = 0 ; i < oplist.size() ; i++) {
            System.debug('oplist[i] : ' + oplist[i]);
            
            if(oplist[i].Id != null) {
                updateData.add(oplist[i]);
                oplist.remove(i);
                i--;
            }
        }
        
        for(Integer i = 0 ; i < oplist2.size() ; i++) {
            System.debug('oplist2[i] : ' + oplist2[i]);
            
            if(oplist2[i].Id != null) {
                updateData.add(oplist2[i]);
                oplist2.remove(i);
                i--;
            }
        }
        
        if(updateData.size() > 0) {
            update updateData;
        }
        
        if(op.Product__c !='')
        {
            System.debug('oplist? : ' + oplist);
            System.debug('oplist2? : ' + oplist2);
            insert oplist; 
            insert oplist2;
        }
        
        if(delList.size() > 0) {
            delete delList;
        } else if(delList2.size() > 0) {
            delete delList2;
        }
        return reference;             
    } 
    public PageReference cancel()
    {
        PageReference reference = new PageReference('/' + oppid);
        return reference;
    }  
    public boolean DisplayPopup {get; set;}    
    
    public void ClosePopup() {       
        DisplayPopup = false;   
    }
    
    public void ShowPopup() {
        DisplayPopup = true;   
    }
    
    public PageReference selectLeft(){
        system.debug(oplist);
        for(OpportunityProduct__c o : oplist){
            if(string.valueOf(o.Id).contains(this.paramValue) && o.Discount__c > 0){
                o.Discount__c--;
            }
            System.debug('paramValue : '+string.valueOf(o.Id).contains(this.paramValue));
            system.debug(o.Discount__c);
        }
        this.oplist = oplist;
        return null;
    }
    
    public void selectRight(){
        system.debug(oplist);
        for(OpportunityProduct__c o : oplist){
            if(string.valueOf(o.Id).contains(this.paramValue) && o.Discount__c < 100){
                o.Discount__c++;
            }
            System.debug('paramValue : '+string.valueOf(o.Id).contains(this.paramValue));
                system.debug(o.Discount__c);
        }
        this.oplist = oplist;
        system.debug(oplist);
    }
    
    public PageReference selectLeft2(){
        List<OpportunityProduct__c> opprd = [select id,Discount__c from OpportunityProduct__c where id =: this.paramValue AND Discount__c > 0];
        for(OpportunityProduct__c o : oplist2){
            if(o.Id == this.paramValue && o.Discount__c > 0){
                o.Discount__c--;
            } 
        }
        System.debug('paramValue : '+this.paramValue);
        return null;
    }
    
    public void selectRight2(){
        List<OpportunityProduct__c> opprd = [select id,Discount__c from OpportunityProduct__c where id =: this.paramValue];
        for(OpportunityProduct__c o : oplist2){
            if(o.Id == this.paramValue && o.Discount__c < 100){
                o.Discount__c++;
            } 
        }
        // System.debug('paramValue : '+this.paramValue);
    }
}