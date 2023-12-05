public class UTIL_CustomNoti {

    /**
    * @description trigger 관련 노티 전송.
    * @author Yong-Jin, Cha | ?
    * @param List<String> param 
    * @param List<ID> userIds 
    * @return void 
    **/
    @future(callout=true)
    public static void sendNoti(List<String> param, List<ID> userIds){
        String objId  = param[0];
        String title  = param[1];
        String body   = param[2];

        CustomNotification.send(
            'supportNoti' // Notification Type 명
            , new List<CustomNotification.NotificationBody>{ // Send할 대상
                new CustomNotification.NotificationBody(
                    Id.valueOf(objId) // targetId
                    , title // title <- sObject Name
                    , body // body <- 회람에 코멘트가 등록되었습니다. || 회람에 Action Detail이 등록되었습니다.
                )
                    }
            , userIds // 보낼 대상 (Users) -> Owner + Uni key 일치하는 회람 대상자들 전부
        );
    }

    /**
    * @description batch 관련 노티 전송.
    * @author Yong-Jin, Cha | ?
    * @param List<String> param 
    * @param List<ID> userIds 
    * @return void 
    **/
    public static void sendNoti_Batch(List<String> param,List<ID> userIds){
        String objId  = param[0];
        String title  = param[1];
        String body   = param[2];

        CustomNotification.send(
            'supportNoti' // Notification Type 명
            , new List<CustomNotification.NotificationBody>{ // Send할 대상
                new CustomNotification.NotificationBody(
                    Id.valueOf(objId) // targetId
                    , title // title
                    , body // body
                )
                    }
            , userIds // 보낼 대상 (Users)
        );
    }
}