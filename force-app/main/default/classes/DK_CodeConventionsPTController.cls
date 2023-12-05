/**
 * Desc : DK_CodeConventionsPTController
 *
 * @Method : 
 *   - @RemoteAction getList() : 코드규칙 목록
 *
 * @Author : Yong-Jin, Cha
 * @Date : 2018. 01. 25.
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description 
 *  ---------------------------------------------
 *  1. | 2018-01-25 | Yong-Jin, Cha | 최초작성
 */
global class DK_CodeConventionsPTController
{   
    @RemoteAction
    global static List<CodeConventions__c> getList() 
    {        
        return [
            select
            	Id
            	, Name
            	, CreatedById
            	, CreatedDate
            	, CreatedBy.Name
            	, LastModifiedById
            	, LastModifiedDate
				, LastModifiedBy.Name
            	, DisplayOrder__c
            	, Descriptions__c
            	, ItemCount__c
            	, IsActive__c
            	, (select
                   		Id
                   		, Name
                   		, Descriptions__c
                   		, ExampleCode__c
                   		, CodeConventionsId__r.Name
                   		, CodeFormat__c
                   from
                   		CodeConventionsDetail__r
                   where
                   		IsActive__c = true
                   order by 
                   		DisplayOrder__c
                   )
            from
            	CodeConventions__c
            where
                IsActive__c = true
            order by
            	DisplayOrder__c
       	];
    }
}