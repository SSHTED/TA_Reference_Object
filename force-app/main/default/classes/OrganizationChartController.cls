global class OrganizationChartController {

    @AuraEnabled
    global static Map<String, Object> getInit() {
        Map<String, Object> resultMap = new Map<String, Object>();

        resultMap.put('orgList', getOrganizationList());

        return resultMap;
    }
    
    private static List<Organization__c> getOrganizationList() {
		return [
            select 
                Code__c
                , DisplayOrder__c
                , Id
                , IsActive__c
                , Level__c
                , Name
                , Note__c
                , ParentOrgId__c
            	, ParentOrgId__r.Code__c
            from
                Organization__c
            where
            	IsActive__c = true
            order by 
            	DisplayOrder__c          
        ];
    }
}