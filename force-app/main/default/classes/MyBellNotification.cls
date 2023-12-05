global class MyBellNotification {
   	@future (callout=true)
    public static void notifyToEmployee(String message, String ManagerId, String recordId, String Employee)
    {	
        //ManagerId -- 해당 Employee의 관리자 (팀장)
        Set<String> userSet = new Set<String>();
        UserSet.add(ManagerId);
        UserSet.add(Employee);
        String Notifi_Id = [SELECT Id FROM CustomNotificationType where DeveloperName = 'Evaluation_Noti' LIMIT 1].Id;
        for(String IdSet : UserSet) {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(Url.getOrgDomainUrl().toExternalForm()
                            + '/services/data/v46.0/actions/standard/customNotificationAction');
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            req.setHeader('Content-Type', 'application/json');
            CustomNotificationActionInput input = new CustomNotificationActionInput();
            input.customNotifTypeId = Notifi_Id;
            input.recipientIds = new List<String>{IdSet};
                input.title = '프로젝트 완료 알림';
            input.body = message;
            input.targetId = recordId;
            CustomNotificationAction action = new CustomNotificationAction();
            action.inputs = new List<CustomNotificationActionInput>{input};
                req.setBody(JSON.serialize(action));
            HttpResponse res = h.send(req);
            System.debug(res.getBody());
        }
    }
    
    @future (callout=true)
    public static void notifyToManagers(String message, String recordId)
    {	
        
        Set<String> userSet = new Set<String>();
        String LabelNumbers = Label.Sending_to_Bell_Notification;
        String[] EmpNumbers = LabelNumbers.split(',');
        List<User> uList = [select id from User where EmployeeNumber IN :EmpNumbers];
        for(User u : uList) {
            userSet.add(u.Id);
        }
        
        String Notifi_Id = [SELECT Id FROM CustomNotificationType where DeveloperName = 'Evaluation_Noti' LIMIT 1].Id;
        for(String IdSet : UserSet) {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(Url.getOrgDomainUrl().toExternalForm()
                            + '/services/data/v46.0/actions/standard/customNotificationAction');
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            req.setHeader('Content-Type', 'application/json');
            CustomNotificationActionInput input = new CustomNotificationActionInput();
            input.customNotifTypeId = Notifi_Id;
            input.recipientIds = new List<String>{IdSet};
                input.title = '프로젝트 완료 알림';
            input.body = message;
            input.targetId = recordId;
            CustomNotificationAction action = new CustomNotificationAction();
            action.inputs = new List<CustomNotificationActionInput>{input};
                req.setBody(JSON.serialize(action));
            HttpResponse res = h.send(req);
            System.debug(res.getBody());
        }
    }
    public class CustomNotificationAction
    {
        public List<CustomNotificationActionInput> inputs { get; set; }
    }
    
    public class CustomNotificationActionInput
    {
        public String customNotifTypeId { get; set; }
        public List<String> recipientIds { get; set; }
        public String title { get; set; }
        public String body { get; set; }
        public String targetId { get; set; }
    }
}