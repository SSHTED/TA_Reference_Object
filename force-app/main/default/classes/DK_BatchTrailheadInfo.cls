/**
* Desc : Batch Trailhead Info
*
* @Author : Yong-Jin, Cha
* @Date : 2017. 4. 28.
* @Version : 1.0
*/
global class DK_BatchTrailheadInfo
{
    public static Http buildHttp(){

        Http h = new Http();
        return h;
    }

    public static HttpRequest buildWebServiceRequest(String Trailhead_Profile){

        //Build HTTP Request object
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        req.setTimeout(120000);
        //req.setEndpoint('https://trailhead.salesforce.com/en/users/profiles/' + Trailhead_Profile);
        req.setEndpoint('https://trailhead.salesforce.com/en/me/' + Trailhead_Profile);
        req.setHeader('Content-Type', 'text/html');
        return req;
    }

    public static HttpResponse invokeWebService(Http h, HttpRequest req){

        //Invoke Web Service
        HttpResponse res;
        if(!Test.isRunningTest()) {
            res = h.send(req);
        } else {
            res = new HttpResponse();
            String body = '';
            body += '<a class=\'slds-show slds-text-align_center\' data-test-current-rank href=\'/en/trailblazer-ranks\'>\n';
            body += '<img width="100px" src="/assets/ranks/mountaineer-121da937d748d9978cc681de9e6d968486ec25ab8a26ddd42a6c50a2c418ea7e.png" alt="Mountaineer" />\n';
            body += '</a>\n';
            body += '</div>\n';
            body += '<div class=\'slds-p-left_x-large slds-size_1-of-1 slds-medium-size_3-of-4\'>\n';
            body += '<div data-react-class="profile/UserBio" data-react-props="{&quot;full_name&quot;:&quot;YongJin Cha&quot;,&quot;work_info&quot;:&quot;Team Manager, DKBMC&quot;,&quot;bio&quot;:&quot;&quot;}" data-hydrate="t"><div class="user-information__bio" data-reactroot="" data-reactid="1" data-react-checksum="872176162"><h1 data-test-user-name="true" data-reactid="2">YongJin Cha</h1><h2 data-test-user-work-info="true" data-reactid="3">Team Manager, DKBMC</h2><p data-test-user-bio="true" data-reactid="4"></p></div></div>\n';
            body += '<div class=\'user-information__achievements\'>\n';
            body += '<h3 data-test-user-achievements>Achievements</h3>\n';
            body += '<div class=\'user-information__achievements-table slds-grid slds-wrap slds-grid_align-spread slds-text-align_center\'>\n';
            body += '<div class=\'slds-max-small-size_1-of-1\'>\n';
            body += '<div class=\'user-information__achievements-heading\' data-test-badges-title>Badges</div>\n';
            body += '<div class=\'user-information__achievements-data\' data-test-badges-count>26</div>\n';
            body += '</div>\n';
            body += '<div class=\'slds-max-small-size_1-of-1\'>\n';
            body += '<div class=\'user-information__achievements-heading\' data-test-points-title>Points</div>\n';
            body += 'Points\n';
            body += '</div>\n';
            body += '<div class=\'user-information__achievements-data\' data-test-points-count>\n';
            body += '19,050\n';
            body += '</div>\n';
            body += '</div>\n';
            body += '<div class=\'slds-max-small-size_1-of-1\'>\n';
            body += '<div class=\'user-information__achievements-heading\' data-test-trails-title>\n';
            body += 'Trails Completed\n';
            body += '</div>\n';
            body += '<div class=\'user-information__achievements-data\' data-test-trails-count>\n';
            body += '1\n';
            body += '</div>\n';
            res.setBody(body);
        }  
        return res;
    }

    public static String updateUserInfo(String[] bodyArray, User u) {

        Boolean p_val_flag = false;
    	Boolean p_point_flag = false;
    	Boolean p_trails_flag = false;

        String JSONContent = '';
        String Trailhead_Ranks = '';

        String[] Trailhead_value = new String[3];

        Integer i = 0;
        
        try {

            for(String lines : bodyArray) {

                if(lines.indexOf('data-test-current-rank') > -1) {
                    p_val_flag = true;
                }

                if(p_val_flag && lines.indexOf('img') > -1 && lines.indexOf('ranks') > -1) {
                    System.debug(lines);
                    Trailhead_Ranks = lines.substring(lines.indexOf('src')+5, lines.indexOf('" alt'));
                    System.debug(Trailhead_Ranks);
                    i++;
                    p_val_flag = false;
                }

                if(lines.indexOf('data-test-badges-count>') > -1) {
                    System.debug(lines);
                    Trailhead_value[0] = lines.substring(lines.indexOf('data-test-badges-count>')+23, lines.indexOf('</div>'));
                    System.debug(Trailhead_value[0]);
                    i++;
                }

                if(lines.indexOf('data-test-points-count>') > -1) {
                    p_point_flag = true;
                }

                if(p_point_flag && lines.indexOf('data-test-points-count>') == -1) {
                    Trailhead_value[1] = lines;
                    p_point_flag = false;
                }

                if(lines.indexOf('data-test-trails-count>') > -1) {
                    p_trails_flag = true;
                }

                if(p_trails_flag && lines.indexOf('data-test-trails-count>') == -1) {
                    Trailhead_value[2] = lines;
                    p_trails_flag = false;
                }

                if(i >= 4) {
                    break;
                }
            }

            u.Trailhead_Ranks__c = Trailhead_Ranks;
            u.Trailhead_Badges__c = Trailhead_value[0];
            u.Trailhead_Points__c = Trailhead_value[1];
            u.Trailhead_Trails__c = Trailhead_value[2];

            System.debug(u);

            update u;
        } catch(Exception e) {
            if(!Test.isRunningTest()) {
                NotificationToJANDI.send('#FE2E2E'
                                         , '[**'+u.Name+'**님의 points 스크래핑 오류](https://trailhead.salesforce.com/en/me/'+u.Trailhead_Profile__c+').'
                                         , '확인요망', String.valueOf(e), '', 'Trailhead');
            }
        }
        return JSONContent;
    }
    
    /*
    public static void updateTrailheadBadgesInfo(String JSONContent, User u) {
        List<Object> a = (List<Object>)JSON.deserializeUntyped(JSONContent);
        System.debug(a.size());
        Map<String, Object> v;

        List<Trailhead_Badges__c> tbList = [select Id, badge_type__c, icon_url__c, path__c, state__c, title__c, Name, Trailhead_User__c, OwnerId 
                                            from Trailhead_Badges__c 
                                            where Trailhead_User__c = :u.Id
                                           ];
        Trailhead_Badges__c tb = new Trailhead_Badges__c();
        delete tbList;
        tbList = new List<Trailhead_Badges__c>();
        for(Object m : a) {
            System.debug(m);
            v = (Map<String, Object>)m;
            System.debug(v.get('badge_type'));    // module
            System.debug(v.get('icon_url'));    // https://developer.salesforce.com/resource/images/trailhead/badges/modules/trailhead_module_lightning_service_basics.png
            System.debug(v.get('path'));        // /modules/service_lex
            System.debug(v.get('state'));        // Completed
            System.debug(v.get('finished_at'));    // 2017-04-26T20:05:04.207-07:00
            System.debug(v.get('title'));        // Lightning Service Basics

            tb = new Trailhead_Badges__c();
            tb.badge_type__c = String.valueOf(v.get('badge_type'));
            tb.icon_url__c = String.valueOf(v.get('icon_url'));
            tb.path__c = String.valueOf(v.get('path'));
            tb.state__c = String.valueOf(v.get('state'));
            tb.title__c = String.valueOf(v.get('title'));
            tb.Name = String.valueOf(v.get('title'));
            tb.Trailhead_User__c = u.Id;
            tb.OwnerId = u.Id;
            tbList.add(tb);
        }
        insert tbList;
    }
*/
    public static void handleWebServiceResponse(HttpResponse res, User u){

        String rtn_body = res.getBody();

        String[] bodyArray = rtn_body.split('\n');

        System.debug('#bodyArray ' + bodyArray.size());

        String JSONContent = updateUserInfo(bodyArray, u);

        //updateTrailheadBadgesInfo(JSONContent, u);

        System.debug('## Completed ##');
    }

    @future(callout=true)
    global static void updateTrailheadInfo(String uId) {

        User u = [
            select
            Id
            , Trailhead_Badges__c
            , Trailhead_Points__c
            , Trailhead_Ranks__c
            , Trailhead_Trails__c
            , Trailhead_Profile__c
            from
            User 
            where
            Id = :uId
        ];

        System.debug('## u ##' + u);

        Http h = buildHttp();

        HttpRequest req = buildWebServiceRequest(u.Trailhead_Profile__c);

        HttpResponse res = invokeWebService(h, req);

        handleWebServiceResponse(res, u);

    }
}