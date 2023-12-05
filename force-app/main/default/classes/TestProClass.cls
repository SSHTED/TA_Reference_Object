public class TestProClass {
    public static Map<Id, String> recordtypemap {get;set;}
    
    @AuraEnabled
    public static List <Price_Book_Entry__c> fetchProduct1(String entryList,boolean stanChk){//main
        List<Price_Book_Test__c> IstPriEntryCus=new List<Price_Book_Test__c>();
        List<Price_Book_Entry__c> entryValueIterater = new List<Price_Book_Entry__c>();
        List<Price_Book_Test__c> getCheckStan = new  List<Price_Book_Test__c>();
        getCheckStan = [SELECT IsStandard__c FROM Price_Book_Test__c where id =: entryList];
        for(Price_Book_Test__c p : getCheckStan) {
            if(p.IsStandard__c == true) {
                IstPriEntryCus= [SELECT (select Product__r.id,Product_Code__c,Product__r.Name,Product__r.Product_Code_c__c,UnitPrice__c,IsActive__c,Parent_PriceBookEntry__c,Product__r.custom_url_c__c from Price_Book_Entries__r ORDER BY  Product__r.Name desc) FROM Price_Book_Test__c where id =: entryList and IsStandard__c=:p.IsStandard__c order by CreatedDate DESC];
                for(integer i = 0;i<IstPriEntryCus[0].Price_Book_Entries__r.size();i++){
                    entryValueIterater.add(IstPriEntryCus[0].Price_Book_Entries__r[i]);
                }
            } else { 
                IstPriEntryCus = [SELECT (select Product__r.Name,Product_Code__c,Product__r.Product_Code_c__c,UnitPrice__c,IsActive__c,Parent_PriceBookEntry__c,Product__r.custom_url_c__c from Price_Book_Entries__r ORDER BY  Product__r.Name desc) FROM Price_Book_Test__c where  id =: entryList and IsStandard__c =:p.IsStandard__c order by CreatedDate DESC];
                for(integer i = 0;i<IstPriEntryCus[0].Price_Book_Entries__r.size();i++){
                    entryValueIterater.add(IstPriEntryCus[0].Price_Book_Entries__r[i]);
                }
            }
        }	
        return entryValueIterater;
    }
    @AuraEnabled
    public static List<Price_Book_Entry__c> modalProduct(String entryList){//모달 테이블창
        List<Price_Book_Entry__c> IstPriEntryCus = new List<Price_Book_Entry__c>();
        Set<Id> insPBSet = new Set<Id>();
        List<Price_Book_Entry__c> insPBList = new  List<Price_Book_Entry__c>();
        insPBList = [select Id,Parent_PriceBookEntry__c from Price_Book_Entry__c where Price_Book_Test__r.id =: entryList];
        for(Price_Book_Entry__c pb : insPBList){
            insPBSet.add(pb.Parent_PriceBookEntry__c);
        }
        IstPriEntryCus= [select Id,Product__r.Name,Product__r.Product_Code_c__c,UnitPrice__c,Product__r.Product_Description__c,Product__r.custom_url_c__c 
                         from Price_Book_Entry__c where Price_Book_Test__r.IsStandard__c = true AND Id not in: insPBSet ORDER BY createdDate desc];
              return IstPriEntryCus;
    }
    
    @AuraEnabled
    public static Price_Book_Entry__c deleteCustomBKEntry(Price_Book_Entry__c customPriceBookEntry) {
        delete customPriceBookEntry;
        return customPriceBookEntry;
    }
    
    @AuraEnabled
    public static void insertPriceProduct( List<Price_Book_Entry__c> updatedList, String pRecordId,List<Price_Book_Entry__c> mydata) {
        List<Price_Book_Entry__c> abc = new List<Price_Book_Entry__c>();
        if(updatedList!=null){
            for(Price_Book_Entry__c pb : updatedList){ 
                Price_Book_Entry__c testPBE = new Price_Book_Entry__c(); 
                testPBE.Product__c = pb.Product__r.Id;
                testPBE.Product__c = pb.Product__c;
                testPBE.UnitPrice__c = pb.UnitPrice__c;
                testPBE.Product_Code__c = pb.Product__r.Product_Code_c__c;
                testPBE.IsActive__c = pb.IsActive__c;
                testPBE.Price_Book_Test__c = pRecordId;//해당 프라이스 레코드값
                testPBE.Parent_PriceBookEntry__c = pb.Id;
                abc.add(testPBE); 
                system.debug(abc + '   ' +'최종 인설트할 결과값');
            }
        }else{
            for(Price_Book_Entry__c pb : mydata){ 
                Price_Book_Entry__c testPBE = new Price_Book_Entry__c(); // 
                testPBE.Product__c = pb.Product__r.Id;
                testPBE.Product__c = pb.Product__c;
                testPBE.UnitPrice__c = pb.UnitPrice__c;
				testPBE.Product_Code__c = pb.Product__r.Product_Code_c__c;
                testPBE.IsActive__c = pb.IsActive__c;
                testPBE.Price_Book_Test__c = pRecordId;
                testPBE.Parent_PriceBookEntry__c = pb.Id;
                abc.add(testPBE);
                system.debug(abc + '   ' +'최종 인설트할 결과값');
                
            }
        }
        system.debug(abc + '   ' +'최종 인설트할 결과값');
        insert abc;
        
        
    }
    @AuraEnabled      //체크박스
    public static List<Price_Book_Entry__c> nextScreenValue(List<Price_Book_Entry__c> selList)
    {
        List<Price_Book_Entry__c> selCheck = [select Product__r.Name, Product__r.Product_Code_c__c, IsActive__c, UnitPrice__c,id,Product__r.custom_url_c__c from Price_Book_Entry__c where id In : selList]; 
        for(Price_Book_Entry__c abc : selCheck){
            system.debug('화면 넘길때 제품 코드 '+abc.Product__r.Product_Code_c__c);
        }
        return selCheck;
        
    }
    @AuraEnabled      //체크박스 스탠다드 체크박스 확인
    public static Price_Book_Test__c standardBtnChk(String recordId){
        Price_Book_Test__c chkStanActive =  [select IsStandard__c from Price_Book_Test__c where id =:recordId ];
        
        
        return chkStanActive;
    }
    @AuraEnabled
    public static List < Price_Book_Entry__c > fetchLookUpValues(String searchKeyWord, String ObjectName, List<sObject> ExcludeitemsList,String entryList) {
        String searchKey = '%' + searchKeyWord + '%';
        Set<Id> insPBSet = new Set<Id>();
        List<Price_Book_Entry__c> insPBList = new  List<Price_Book_Entry__c>();
        insPBList = [select Id,Parent_PriceBookEntry__c from Price_Book_Entry__c where Price_Book_Test__r.id =: entryList];
        for(Price_Book_Entry__c pb : insPBList){
            insPBSet.add(pb.Parent_PriceBookEntry__c);
        }
        system.debug('insPBSet'+insPBSet);
        List < sObject > returnList = new List < sObject > ();
        
        List<string> lstExcludeitems = new List<string>();
        for(sObject item : ExcludeitemsList ){
            lstExcludeitems.add(item.id);
        }
         List<Price_Book_Entry__c> lstOfRecords2 =  [select Product__r.Name, Product__r.Product_Code_c__c, IsActive__c, UnitPrice__c,id,Product__r.custom_url_c__c 
                                                     from Price_Book_Entry__c
          											  where Product__r.Name LIKE: searchKey AND Id NOT IN :lstExcludeitems AND Id NOT IN :insPBSet 
                                                      AND Price_Book_Test__r.IsStandard__c = true order by createdDate DESC limit 8];

        for (Price_Book_Entry__c obj: lstOfRecords2) {
            returnList.add(obj);
        }

        return returnList;
    }
}