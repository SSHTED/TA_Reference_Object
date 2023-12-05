/**
* Desc : JandiWebhookCache
*
* @Method : 
*  		- doLoad(DeveloperName)
* 
* @Author : Yong-Jin, Cha
* @Date : 2019-08-11
* @Version : 1.0
* @Modified : 
*  ---------------------------------------------
*  NO | Date       | Modifier      | Description
*  ---------------------------------------------
*  1. | 2019-08-11 | Yong-Jin, Cha | 최초작성
*/
global class JandiWebhookCache implements Cache.CacheBuilder {

    global Object doLoad(String DeveloperName) {
        Jandi_Webhook_Setting__mdt jws = (Jandi_Webhook_Setting__mdt)[
            select
            	Connect_Color__c
            	, Webhook_URL__c
            from
            	Jandi_Webhook_Setting__mdt
            where
            	Active__c = true
            and DeveloperName = :DeveloperName
        ];
        return jws;
    }
}