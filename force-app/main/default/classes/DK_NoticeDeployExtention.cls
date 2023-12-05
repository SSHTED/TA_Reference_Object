/**
* Desc : DK_NoticeDeployExtention
*        1. 공지사항 배포 시 채터로 알림
*
* @Author : Yong-Jin, Cha
* @Date : 2018. 7. 16.
* @Version : 1.0
* @Modify :
*/
public with sharing class DK_NoticeDeployExtention {
    private final DK_Notice__c notice;
    public ApexPages.StandardController con {get;set;}
    
    public DK_NoticeDeployExtention(ApexPages.StandardController stdCon){
        con = stdCon;
        notice = (DK_Notice__c)stdCon.getrecord();
    }
    
    @RemoteAction
    public static Boolean deploy(String noticeId){
        Boolean result = true;
        DK_Notice__c n = [select Id, Name, Contents__c, Owner.Name, OwnerId from DK_Notice__c where Id = :noticeId Limit 1][0];
        try {
            String title = '[**' + n.Owner.Name + '**님이 새로운 공지사항을 등록하였습니다.]';
            String body = n.Contents__c.replaceAll('<[^>]+>','Å').replaceAll('ÅÅ','\n').replaceAll('Å',' ');
            simpleLinkPost(n.OwnerId, n.Name + '\n\n' + body, System.Label.JANDI_INSTANCE_URL+'/'+n.Id, n.Name);
        } catch (Exception e) {
            System.debug('# Exception # ' + e);
            return false;
        }
        return result;
    }
    
    // makes a chatter post with some text and a link
    private static void simpleLinkPost(Id userId, String postText, String url, String urlName) {    

        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        feedItemInput.body = new ConnectApi.MessageBodyInput();

        // add the text segment
        ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
        feedItemInput.body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        textSegment.text = postText;
        feedItemInput.body.messageSegments.add(textSegment);

        // add the attachment
        ConnectApi.LinkAttachmentInput linkIn = new ConnectApi.LinkAttachmentInput();
        linkIn.urlName = urlName;
        linkIn.url = url;
        feedItemInput.attachment = linkIn;

        // post it!
        ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.UserProfile, userId, feedItemInput, null);
    }
}