@isTest
public class TestMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        
                 String TestId =System.Label.TestId;

        HttpResponse res = new HttpResponse();
        res.setStatus('Success');
        res.setStatusCode(200);
        res.setBody('{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Event","url":"/services/data/v55.0/sobjects/Event/00Up000000IXXLoEAP"},"Id":"00Up000000IXXLoEAP","WhatId":"'+ TestId +'"}]}');
        return res;
    }
}