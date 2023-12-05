public class contractRenewCloneController {

    @AuraEnabled
    public static List<ContractProduct__c> fetchConProduct (Id recordId){ //계약
        system.debug('madeQuery : '+Database.query(madeQuery(recordId)));
        List<ContractProduct__c> queryList = Database.query(madeQuery(recordId, 'Contract__c', 'ContractProduct__c')); // madeQuery 쿼리를 queryList
        set<string> dupl = new set<string>();	// invoice_date__c invoiceduedate__c invoicenumber__c의 중복값들을 1개로만 출력하기 위해 만듬
        List<ContractProduct__c> result = new List<ContractProduct__c>();
        for(ContractProduct__c p : queryList){
            string keys = p.invoice_date__c.format()+p.invoiceduedate__c.format()+p.invoicenumber__c;	// 기존 제품 리스트의 값
            System.debug('keys'+ keys);
            // invoice_date__c invoiceduedate__c invoicenumber__c의 값을 포함하지 않으면 제품 리스트 값들을 dupl에 추가하고
            // set 인터페이스로 인해 중복되는 값들을 1개로만 보여준다.
            if(!dupl.contains(keys)){
                dupl.add(keys);
                result.add(p);
            }
        }
        return result;
    }
    
    @AuraEnabled
    public static void cloneAction(String conId, String upcon) {
        String query = madeQuery((Id) conId);			// string madeQuery(Id Id)
        List<Sobject> new_contracts = new List<Sobject>(); // Sobject 리스트형태의 new_contracts(계약*) 생성
        CustomContract__c cont = Database.query(query);	// 현제 페이지의 계약*의 모든 필드를 갖고있는 cont 생성
        cont.Name = cont.Name + ' Renewal';
        new_contracts.add(cont.clone());// cont를 리스트 형태의 new_contracts에 추가
        system.debug(new_contracts);
        
        if(new_contracts.size() > 0) {
            
            insert new_contracts;	// 계약* 생성
            
            String recordId = new_contracts[0].Id;	// 무조건 현제 페이지의 계약제품을 복제하기 때문에 0으로 설정 
            new_contracts = new List<Sobject>(); // Sobject 리스트 형태의 현제 페이지의 계약* id를 지정해준 new_contracts 선언
            
            // 기존 제품리스트 값을 Map에 담음
            map<string, ContractProduct__c> map_cont = new map<string, ContractProduct__c>();	
            
            // 제품 리스트형태의 upconlist에 수정한 값 upcon을 선언
            List<ContractProduct__c> upconList = (List<ContractProduct__c>)JSON.deserialize(upcon, List<ContractProduct__c>.class);
           	
            // upconList(수정한 값 리스트)를 Map에 담음
            map<Id, ContractProduct__c> upconMap = new map<Id, ContractProduct__c>(upconList);

            for(ContractProduct__c p : Database.query(madeQuery(upconList, 'upconList'))){ // 수정한 계약제품 p 만큼 반복
                // keys에는 수정한 값들이 들어감
                string keys = p.invoice_date__c.format()+p.invoiceduedate__c.format()+p.invoicenumber__c;
                // 제품의 수정값이 들어있는 Map에 기존 제품리스트의 값을 담은 Map에 넣음
                map_cont.put(keys, upconMap.get(p.Id));												
            }
            //  계약제품 복제
            List<ContractProduct__c> queryList = Database.query(madeQuery((Id) conId, 'Contract__c', 'ContractProduct__c'));
            
            for(ContractProduct__c p : queryList){
                ContractProduct__c upconP = map_cont.get(p.invoice_date__c.format()+p.invoiceduedate__c.format()+p.invoicenumber__c);
                system.debug('target : '+ p.invoice_date__c.format()+p.invoiceduedate__c.format()+p.invoicenumber__c);
                ContractProduct__c newconP = upconP.clone();
                
                newconP.invoice_date__c = newconP.invoice_date__c.addYears(1);		// invoice_date__c에 1년을 추가
                newconP.InvoiceDueDate__c = newconP.InvoiceDueDate__c.addYears(1);
                newconP.Contract__c = recordId;
                new_contracts.add(newconP);
            }
            if(new_contracts.size() > 0){
                insert new_contracts; // 계약제품* 생성
            }
        }
    }
    
    public static string madeQuery(Id Id){
        Schema.SObjectType objType = Id.getSObjectType();
        string objName = objType.getDescribe().getName();
        // 레코드 id에서 오브젝트의 이름을 가져옴

        String query_fields = setFields(objName); // query_fields에 contract_fields의 값들을 연결
        String query = 'select ' + query_fields + ' from '+objName+' where id =\''+id+'\'';
        System.debug('query : '+query);
        return query;
    }
    
    public static string madeQuery(Id Id, string id_Field, string objName){
        String query_fields = setFields(objName);
        System.debug('query_fields : '+query_fields);
        return 'select ' + query_fields + ' from '+objName+' where '+id_Field+' =\''+id+'\'';
    }
    
    public static string madeQuery(List<ContractProduct__c> prds, String listName){
        Schema.SObjectType objType = prds[0].Id.getSObjectType();
        String objName = objType.getDescribe().getName();
        System.debug('objName : '+objName);
        String query_fields = setFields(objName);
        System.debug('query_fields 2 : '+query_fields);
        return 'select ' + query_fields + ' from '+objName+' where Id IN: '+listName;
    }
    
    public static string setFields(string objName){
        Map<String, Schema.SObjectField> fileds = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap(); // 맵 생성
        List<String> objFields = new List<String>();
        for(String fieldName : fileds.keySet()) {
            if(fieldName != null && fileds.get(fieldName).getDescribe().isUpdateable()) {
                // fieldName의 값이 null이 아니고 
                // true를 반환하고('getDescribe().isUpdateable()') 필드에 키값을 할당하면
                
                objFields.add(fieldName);
                // contract_fields에 값들을 추가
            }
        }
        //system.debug('record : '+conId);
        //system.debug('end');
        return string.join(objFields,',');
    }

}