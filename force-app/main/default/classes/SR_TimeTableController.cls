/**
 * @Class : SR_TimeTableController
 *
 * @Method : 
 *	- @RemoteAction getInit()
 *	- @RemoteAction getData(mes_mgmtId)
*	- getMonthlySummarys(mes_mgmtId)
 * 
 * @Author : Yong-jin, Cha
 * @Date : 2021-03-30
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2021-03-30 | Yong-jin, Cha | 최초작성
 */
global with sharing class SR_TimeTableController {

    @AuraEnabled
    global static Map<String, Object> getData() {
        
        Map<String, Object> resultMap = new Map<String, Object>();

        List<MT_MD_Calculation__mdt> mdList = [
            select 
            	Id
				, DeveloperName
				, ImplementType__c 
				, Difficulty__c
				, MD_Analysis__c
				, MD_Development__c
				, MD_Test__c
				, MD_ApplyTest__c
            	, MD_Total__c
				, Description__c
            	, RowSpan__c
            from 
            	MT_MD_Calculation__mdt
            order by
				 DeveloperName
        ];

        resultMap.put('data', mdList);
       
        
        return resultMap;
    }
    
}