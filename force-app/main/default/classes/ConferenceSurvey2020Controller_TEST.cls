/**
* Desc : ConferenceSurvey2020Controller_TEST
*
* @Author : 한선웅
* @Date : 2020. 1. 10
*/
@isTest
public class ConferenceSurvey2020Controller_TEST {
    @isTest
    public static void ConferenceSurvey2020Controller_TEST() {
        //Picklist value Test
        Map<String, Object> pickMap = ConferenceSurvey2020Controller.getPicklist();
        List<Object> pickList = (List<Object>)pickMap.get('q_question1__c');
        Map<String, Object> q1Map = (Map<String, Object>)pickList[0];
        String pickValue = String.valueOf(q1Map.get('value'));
        System.assertEquals('예', pickValue);

        // insert Test
        Map<String, Object> dataMap = new Map<String, Object>();
        List<String> q2List = new List<String>();
        List<String> q3List = new List<String>();
        List<String> q4List = new List<String>();
        for(Integer i = 0 ; i < 5 ; i++) {
            q2List.add('q2 value ' + i);
            q3List.add('q3 value ' + i);
            q4List.add('q4 value ' + i);
        }
        dataMap.put('P_Name__c', 'test Name');
        dataMap.put('P_Company__c', 'test Com');
        dataMap.put('P_Department__c', 'test Dep');
        dataMap.put('P_Position__c', 'test 123');
        dataMap.put('P_Phone__c', '');
        dataMap.put('P_EMail__c', '');
        dataMap.put('Q_Question1__c', '');
        dataMap.put('Q_Question2__c', '');
        dataMap.put('Q_Question2_1__c', q2List);
        dataMap.put('Q_Question3__c', q3List);
        dataMap.put('Q_Question4__c', q4List);
        dataMap.put('Q_Other_1__c', 'other1');
        dataMap.put('Q_Other_2__c', 'other2');
        dataMap.put('Q_Other_3__c', 'other3');

        String strJSON = JSON.serialize(dataMap);

        ConferenceSurvey2020Controller.submitData(strJSON);

        ConferenceSurvey__c con = [SELECT P_Name__c FROM ConferenceSurvey__c LIMIT 1][0];
        System.assertEquals('test Name', con.P_Name__c);

    }
}