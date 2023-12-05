@isTest
public class BellNotificationMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        
        
        HttpResponse res = new HttpResponse();
        res.setStatus('Success');
        res.setStatusCode(200);
        res.setBody('TestDataReturn');
        return res;
    }
}