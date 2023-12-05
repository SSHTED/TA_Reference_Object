/**
* Desc : ConferenceSurvey2020Controller
*
* @Author : 한선웅
* @Date : 2020. 1. 10
*/
public class ConferenceSurvey2020Controller {

    // ConferenceSurvey Picklist 가져옴
    @AuraEnabled
    public static Map<String, Object> getPicklist(){
        Map<String, Object> pickMap = getPickValueFieldLabel('ConferenceSurvey__c');
        System.debug(pickMap);
        return pickMap;
    }

    // 데이터 저장
    @AuraEnabled
    public static String submitData(String strJSON){
        System.debug(strJSON); 

        Map<String, Object> csData = (Map<String, Object>)JSON.deserializeUntyped(strJSON);

        List<Object> q2_1 = (List<Object>)csData.get('Q_Question2_1__c');
        List<Object> q3 = (List<Object>)csData.get('Q_Question3__c');
        List<Object> q4 = (List<Object>)csData.get('Q_Question4__c');
        String value2_1 = '';
        String value3 = '';
        String value4 = '';

        if(q2_1.size() > 0) {
            for(Integer i = 0 ; i < q2_1.size() ; i++) {
                value2_1 += String.valueOf(q2_1[i]);
                if(i != q2_1.size()-1) {
                    value2_1 += ';';
                }
            }
            System.debug(value2_1);
        }
        if(q3.size() > 0) {
            for(Integer i = 0 ; i < q3.size() ; i++) {
                value3 += String.valueOf(q3[i]);
                if(i != q3.size()-1) {
                    value3 += ';';
                }
            }
            System.debug(value3);
        }
        if(q4.size() > 0) {
            for(Integer i = 0 ; i < q4.size() ; i++) {
                value4 += String.valueOf(q4[i]);
                if(i != q4.size()-1) {
                    value4 += ';';
                }
            }
            System.debug(value4);
        }

        ConferenceSurvey__c cs = new ConferenceSurvey__c(
            isSF_Agree__c = true,
            isAgree__c = true,
            P_Name__c = String.valueOf(csData.get('P_Name__c')),
            P_Company__c = String.valueOf(csData.get('P_Company__c')),
            P_Position__c = String.valueOf(csData.get('P_Position__c')),
            P_Department__c = String.valueOf(csData.get('P_Department__c')),
            P_Phone__c = String.valueOf(csData.get('P_Phone__c')),
            P_EMail__c = String.valueOf(csData.get('P_EMail__c')),
            Q_Question1__c = String.valueOf(csData.get('Q_Question1__c')),
            Q_Question2__c = String.valueOf(csData.get('Q_Question2__c')),
            Q_Question2_1__c = value2_1,
            Q_Question3__c = value3,
            Q_Question4__c = value4,
            Q_Question5__c = String.valueOf(csData.get('Q_Question5__c')),
            Q_Other_1__c = String.valueOf(csData.get('Q_Other_1__c')),
            Q_Other_2__c = String.valueOf(csData.get('Q_Other_2__c')),
            Q_Other_3__c = String.valueOf(csData.get('Q_Other_3__c'))
        );

        insert cs;
        
        return String.valueOf(cs.Id);
    }

    // Object Picklist 전부 가져옴
    public static Map<String,Object>  getPickValueFieldLabel(String objectApiName){
        Map<String,Object> rtnData = new Map<String,Object>();
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objectApiName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();

        List<String> picklistFieldList = new List<String>();
        for (String fieldName: fieldMap.keySet()) {
            String fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
            //picklist type 가져오기
            Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
            if(fielddataType == Schema.DisplayType.Picklist || fielddataType == Schema.DisplayType.MultiPicklist) {
                picklistFieldList.add(fieldName);
            }
        }
        
        //PickList API Name List Loop 
        for(String fieldApiName : picklistFieldList){
            Schema.DescribeFieldResult pickList = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().get(fieldApiName).getDescribe();  //지정한 Object Api 및 Field Api 명을 넣어주어 요약
            List<Schema.PicklistEntry> values = pickList.getPicklistValues();              
            
            //Label Value 가져오기
            List<Object> pickMapList = new List<Object>();
            for(Schema.PicklistEntry pick : values){
                Map<String, String> pickMap = new Map<String, String>();
                pickMap.put('label', pick.getLabel());
                pickMap.put('value', pick.getValue());
                pickMapList.add(pickMap);
            }
            rtnData.put(fieldApiName, pickMapList);
        }
        
        return rtnData;
    }
}