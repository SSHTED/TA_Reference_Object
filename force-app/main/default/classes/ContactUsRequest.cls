public without sharing class ContactUsRequest {

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getInit() {
        Map<String, Object> dataMap = new Map<String, Object>();
        Map<String, Object> resultMap = new Map<String, Object>();
        
        try{
            Set<String> categoryListVal = getCategoryPicklistValues();

            dataMap.put('categoryListVal', categoryListVal);

            resultMap.put('result', dataMap);
            resultMap.put('success', true);
        } catch(Exception e){
            resultMap.put('result', e.getMessage());
            resultMap.put('success', false);
        }
    
        return resultMap;
    }




    private static Set<String> getCategoryPicklistValues() {
        Set<String> picklistValues = new Set<String>();
        Schema.DescribeFieldResult fieldResult = Contact_Us__c.Category__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry PickValue : ple) {
            picklistValues.add(PickValue.getLabel());
        }
        
        return picklistValues;
    }


}