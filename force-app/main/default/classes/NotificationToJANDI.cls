/**
* Desc : Notification To JANDI
*
* @Author : Yong-Jin, Cha
* @Date : 2017. 3. 14.
* @Version : 1.0
*/
global class NotificationToJANDI
{   
    public static String d_body {set; get;}
    public static String return_body {set; get;}

    @future (callout=true)
    public static void send(String connectColor, String body, String title, String description, String imageUrl, String target){

        setValue(connectColor, body, title, description, imageUrl);

        Http h = buildHttp();
        HttpRequest req = buildWebServiceRequest(target);
        HttpResponse res;
        
        if(!Test.isRunningTest()) {
        	res = invokeWebService(h, req);
        	handleWebServiceResponse(res);
        }
   }
    
   public static void send_batch(String connectColor, String body, String title, String description, String imageUrl, String target){

        setValue(connectColor, body, title, description, imageUrl);

        Http h = buildHttp();
        HttpRequest req = buildWebServiceRequest(target);
        HttpResponse res;
       
        if(!Test.isRunningTest()) {
        	res = invokeWebService(h, req);
        	handleWebServiceResponse(res);
        }
   }

   public static void setValue(String connectColor, String body, String title, String description, String imageUrl) {

       List<ConnectInfoWarp> connectInfo = new List<ConnectInfoWarp>();
       ConnectInfoWarp con = new ConnectInfoWarp();
       con.title = title;
       con.description = description;
       con.imageUrl = imageUrl;
       connectInfo.add(con);

       JandiConnectWarp jandi = new JandiConnectWarp();

       jandi.body = body;
       jandi.connectColor = connectColor;
       jandi.connectInfo = connectInfo;

       d_body = JSON.serialize((Object)jandi);

       System.debug(d_body);
   }

   public static Http buildHttp(){

        Http h = new Http();
        return h;
    }

    public static HttpRequest buildWebServiceRequest(String target){

        //Build HTTP Request object
        HttpRequest req = new HttpRequest();
        if(target == 'Chatter') {
            req.setEndpoint(System.Label.JANDI_URL);
        } else if(target == 'Event') {
            req.setEndpoint(System.Label.JANDI_EVENT_URL);
        } else if(target == 'Expense') {
            req.setEndpoint(System.Label.JANDI_EXPENSE_URL);
        } else if(target == 'Council') { // 이사회
        	req.setEndpoint(System.Label.JANDI_COUNCIL_URL);
        } else if(target == 'Trailhead') { // Trailhead
        	req.setEndpoint(System.Label.JANDI_TRAILHEAD_URL);
        }
        
        req.setMethod('POST');
        req.setHeader('Accept', 'application/vnd.tosslab.jandi-v2+json');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(d_body);
        return req;
    }

    public static HttpResponse invokeWebService(Http h, HttpRequest req){

         //Invoke Web Service
         HttpResponse res = h.send(req);
         return res;
    }

    public static void handleWebServiceResponse(HttpResponse res){
         //Parse and apply logic to the res message
         return_body = res.getBody();
         System.debug(return_body );
    }

    public class ConnectInfoWarp {
        public String title {set; get;}
        public String description {set; get;}
        public String imageUrl {set; get;}
    }

    public class JandiConnectWarp {
        public String body {set; get;}
        public String connectColor {set; get;}
        public List<ConnectInfoWarp> connectInfo {set; get;}
    }
}