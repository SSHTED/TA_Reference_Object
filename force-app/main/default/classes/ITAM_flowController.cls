public class ITAM_flowController {
    
    @AuraEnabled
    public static List<property__c> findReqList(String setRecordType){
        String queryString;
        List<Object> StringArgment = New List<Object>();
        List<property__c> result = new List<property__c>();
        Employee__c getEmpId = [SELECT Id, Name FROM Employee__c WHERE  User__c =:userInfo.getUserId() LIMIT 1 ];

        
        System.debug(getEmpId);

        StringArgment.add('\''+(String)getEmpId.Id+'\'');

        queryString = 'SELECT Name, toLabel(largeType__c), toLabel(ProductType_2nd__c), toLabel(ProductType__c), ModelName__c, ProductName__c, manufacturer__c FROM property__c WHERE RealEmp__c ={0}';
        queryString = String.format(queryString, StringArgment);

        System.debug('query: '+queryString);

        result = Database.query(queryString);

        for(property__c tmp : result){
            System.debug('tmp: '+tmp);
            if (tmp.largeType__c == '소프트웨어'){
                tmp.ModelName__c = '-';
            }
        }

        return result;
    }

    @AuraEnabled
    public static List<property__c> findProcList(String filter){
        String queryString;
        List<Object> StringArgment = New List<Object>();
        List<property__c> result = new List<property__c>();

        //Employee__c getEmpId = [SELECT Id, Name FROM Employee__c WHERE  User__c =:userInfo.getUserId() LIMIT 1 ];

        System.debug('filter: '+filter);
        StringArgment.add('\''+filter+'\'');

        queryString = 'SELECT Name, toLabel(largeType__c), toLabel(ProductType_2nd__c), toLabel(ProductType__c), ModelName__c,Sortation001__c,'+
                        'ProductName__c, manufacturer__c, MonitorInch__c, MonitorType__c, toLabel(cpu_Type__c), cpu_creator__c, MemorySize__c'+
                        '  FROM property__c '+
                        'WHERE Condition__c=\'unUse\' AND ProductType_2nd__c ={0}';
        queryString = String.format(queryString, StringArgment);

        System.debug('query: '+queryString);

        result = Database.query(queryString);
        /*
        for(property__c tmp : result){
            System.debug('tmp: '+tmp);
            if (tmp.largeType__c == '소프트웨어'){
                tmp.ModelName__c = '-';
            }
        }
        */

        return result;
    }
}