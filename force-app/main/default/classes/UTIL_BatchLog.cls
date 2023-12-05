/**
 * @Class : UTIL_BatchLog
 *
 * @Method :
 *
 * @Author : Yongjin, Cha
 * @Date : 2022-06-16
 * @Version : 1.0
 * @Modified :
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2022-06-16 | Yongjin, Cha  | 최초작성
 */
global without sharing class UTIL_BatchLog {

    global static Organization getOrganizationInfo() {
        return [
            select
                Division
                , Id
                , InstanceName
                , IsSandbox
                , Name
                , NamespacePrefix
                , OrganizationType
                , UiSkin
                , Country
                , DefaultLocaleSidKey
                , LanguageLocaleKey
                , PrimaryContact
                , SignupCountryIsoCode
                , TimeZoneSidKey
            from
                Organization
            limit 1
        ].get(0);
    }

    global static String startLog(String BatchName, Organization org) {

        startbodyWrap body = new startBodyWrap();
        body.BatchName = BatchName;
        body.OrgId = org.Id;
        body.IsSandbox = org.IsSandbox;
        body.LogExternalKey = org.Id + '_' + BatchName + '_' + System.now().format('yyyyMMddhhmmss');

        callout('start', JSON.serialize((Object)body));

        return body.LogExternalKey;
    }

    global static void finishLog(String LogExternalKey
                                , Integer TotalBatches
                                , Integer BatchesProcessed
                                , Integer BatchesFailed
                                , Integer TotalRows
                                , Integer RowsProcessed
                                , Integer RowsFailed
                                , String ResultMessage)
    {
        finishBodyWrap body = new finishBodyWrap();
        body.LogExternalKey = LogExternalKey;
        body.TotalBatches = TotalBatches;
        body.BatchesProcessed = BatchesProcessed;
        body.BatchesFailed = BatchesFailed;
        body.TotalRows = TotalRows;
        body.RowsProcessed = RowsProcessed;
        body.RowsFailed = RowsFailed;
        body.ResultMessage = ResultMessage;

        callout('finish', JSON.serialize((Object)body));
    }

    global static String getExceptionMessage(Exception e, Integer TotalBatches) {
        String message = '\n----------------------------[' + TotalBatches + ']';
        message += '\n# Type name => ' + e.getTypeName();
        message += '\n# Line number => ' + e.getLineNumber();
        message += '\n# Message => ' + e.getMessage();
        message += '\n# Cause => ' + e.getCause();
        message += '\n# Stack trace => ' + e.getStackTraceString();
        return message;
    }

    private static void callout(String callType, String body) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();

        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(System.Label.BATCH_LOG_URL + '/services/apexrest/batchlog/' + callType);
        req.setBody(body);
        if(!Test.isRunningTest())  res = h.send(req);
    }

    global class startBodyWrap {
        global String BatchName {set; get;}
        global String OrgId {set; get;}
        global String LogExternalKey {set; get;}
        global Boolean IsSandbox {set; get;}
    }

    global class finishBodyWrap {
        global String LogExternalKey {set; get;}
        global Integer TotalBatches {set; get;}
        global Integer BatchesProcessed {set; get;}
        global Integer BatchesFailed {set; get;}
        global Integer TotalRows {set; get;}
        global Integer RowsProcessed {set; get;}
        global Integer RowsFailed {set; get;}
        global String ResultMessage {set; get;}

    }
}