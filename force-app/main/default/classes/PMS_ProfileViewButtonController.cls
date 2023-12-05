/**
 * @Class : PMS_ProfileViewButtonController
 *
 * @Method : 
 *	- @AuraEnabled getPerm()
 *	- getPermissionSetAssignment()
 * 
 * @Author : Yong-jin, Cha
 * @Date : 2022-03-16
 * @Version : 1.01
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2022-03-16 | Yong-jin, Cha | 최초작성
 *  2. | 2022-12-20 | hojae-lee     | 쿼리수정
 */

global class PMS_ProfileViewButtonController {

    @AuraEnabled
    global static Map<String, Object> getPerm() {
        Map<String, Object> resultMap = new Map<String, Object>();

        resultMap.put('isPerm', getPermissionSetAssignment().size() > 0 ? true : false);

        return resultMap;
    }
    
    private static List<PermissionSetAssignment> getPermissionSetAssignment() {
        
        String userId = System.UserInfo.getUserId();
        
        // 221220_이호재 쿼리에 PMS_PERM_CX 추가, 김정용 팀장 프로필 출력 가능 
		return [
            select 
                AssigneeId
                , ExpirationDate
                , Id
                , IsActive
                , PermissionSetGroupId
                , PermissionSetId
                , SystemModstamp
            from
                PermissionSetAssignment
            where 
            	PermissionSetId in (
            				select 
                    			Id
            				from
                				PermissionSet
            				where 
            					Name in ('PMS_PERM_HQ', 'PMS_PERM_PMO', 'PMS_PERM_CX')
                )
            and IsActive = true
            and AssigneeId = :userId
        ];
    }
}