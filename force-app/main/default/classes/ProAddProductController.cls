public class ProAddProductController {
    public static Map<Id, String> recordtypemap {get;set;}
    
    @AuraEnabled
    public static Map<String,Object> fetchProduct(String entryList){//메인 
        Map<String,Object> resMap = new Map<String,Object>();
        List<Price_Book_Entry__c> pbList = [select Price_Book_Test__r.id,id,Price_Book_Test__r.Name,UnitPrice__c,UseStandardPrice__c,IsActive__c,Price_Book_Test__r.IsStandard__c 
                                            from Price_Book_Entry__c where  Product__r.id =: entryList];
        
        List<Price_Book_Test__c> standardPbList =[select id,IsStandard__c from Price_Book_Test__c where IsStandard__c=true ];
        if(pbList.size() == 0){
            resMap.put('standardId', standardPbList[0].id); //스탠다드 아이디값
            resMap.put('standardChk', standardPbList[0].IsStandard__c);
        }else if(pbList.size() > 0){
            for(Price_Book_Entry__c i : pbList){
                if(i.Price_Book_Test__r.IsStandard__c == false){
            		resMap.put('customChk', false);
                }
            }
        }
        
        resMap.put('pbList', pbList);// 데이터가 있을시 뿌려줄값
        return resMap;
    }
    @AuraEnabled
    public static List<Price_Book_Test__c > optionSel (String getReocrdId){//entry -> 제품 아이디 모달 add to price Book
         List<Price_Book_Test__c > listPrb = new List<Price_Book_Test__c >();
        List<Price_Book_Entry__c > listProductId = new List<Price_Book_Entry__c >();
        
        List<Price_Book_Test__c > isPrbName = [select name,id from Price_Book_Test__c where IsStandard__c = false];
         List<Price_Book_Entry__c> pbList = [select Price_Book_Test__r.id from Price_Book_Entry__c where  Product__r.id =: getReocrdId];//제품 -> 해당 프라이스북 , 스탠다드프라이스북 
        Set<Id> insPBSet = new Set<Id>();
        for(Price_Book_Entry__c pb : pbList){
            insPBSet.add(pb.Price_Book_Test__r.id);
        }
        for(Price_Book_Test__c  i : isPrbName)    {
            listPrb.add(i);
        }   
		
        return listPrb;
       
    }
     @AuraEnabled
    public static  List<Price_Book_Entry__c > getpriceBookName(String getReocrdId) {//a1WN000000DUS6QMAX
         List<Price_Book_Entry__c > listPrb = new List<Price_Book_Entry__c >();//where  Product2__r.id =: getReocrdId
         List<Price_Book_Entry__c> pbList = [select Price_Book_Test__r.id,Price_Book_Test__r.Name from Price_Book_Entry__c where  Product__r.id =: getReocrdId ];//제품 -> 해당 프라이스북 , 스탠다드프라이스북 
        
         system.debug('pbList 쿼리 네임 >'+pbList);
     
      
        return pbList;
    }
    @AuraEnabled
    public static Price_Book_Entry__c deleteCustomBKEntry(Price_Book_Entry__c customPriceBookEntry) {
        delete customPriceBookEntry;
        return customPriceBookEntry;
    }
}