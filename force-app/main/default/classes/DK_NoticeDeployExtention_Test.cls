/**
* Desc : DK_NoticeDeployExtention Test
*
* @Author : Yong-Jin, Cha
* @Date : 2018. 7. 16.
* @Version : 1.0
*/
@isTest
public class DK_NoticeDeployExtention_Test {
    
    static DK_Notice__c n;
    
    static {
        // EventAfterTrigger Test
        n = new DK_Notice__c(Name = '공지사항'
                            , OwnerId = System.UserInfo.getUserId()
                            , Contents__c = 'text', Category__c='교육');
        insert n;
    }
    
    static testMethod void DK_NoticeDeployExtention_Test()
    {
        DK_NoticeDeployExtention.deploy(n.Id);
    }
}