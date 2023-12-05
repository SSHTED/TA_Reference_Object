/**
* Desc : DK_UserListController
*        1. 
*        2. 
*
* @Author : Yong-Jin, Cha
* @Date : 2017. 7. 20.
* @Version : 1.0
*/
global class DK_UserListController
{
 	
    private static String getListViewsWhere(String id) 
    {
        Map<String, Object> returnDataMap = new Map<String, Object>();
        String endpoint = System.label.ListViewDesc_Endpoint;//'https://cs6.salesforce.com';

        Httprequest httpReq = new Httprequest();
        HttpResponse httpRes = new HttpResponse();
        Http http = new Http();

        String resBody = null;
        httpReq.setMethod('GET');          
        httpReq.setEndpoint(endpoint + '/services/data/v39.0/sobjects/User/listviews/'+id+'/describe');                       
        httpReq.setTimeout(120000);                    
        httpReq.setHeader('Authorization', 'Bearer ' + System.UserInfo.getSessionId());
        httpReq.setHeader('Content-Type', 'application/json');            

        if(!Test.isRunningTest()) {
            httpRes = http.send(httpReq);            
        }else{
            String blStr= '{"columns":[{"ascendingLabel":"Z-A","descendingLabel":"A-Z","fieldNameOrPath":"Name","hidden":false,"label":"Full Name","selectListItem":"Name","sortDirection":"ascending","sortIndex":0,"sortable":true,"type":"string"}],"id":"00B7F000003WRkG","orderBy":[{"fieldNameOrPath":"Name","nullsPosition":"first","sortDirection":"ascending"}],"query":"SELECT Name, Alias, Username, UserRole.Name, IsActive, Profile.Name, Manager.Name, Id, CreatedDate, LastModifiedDate, SystemModstamp, UserRole.Id, UserRoleId, Profile.Id, ProfileId, Manager.Id, ManagerId FROM User ORDER BY Name ASC NULLS FIRST, Id ASC NULLS FIRST","scope":"everything","sobjectType":"User","whereCondition":{"conditions":[],"conjunction":"and"}}';
            Blob bl = Blob.valueof(blStr);
            httpRes.setBody(blStr);
            httpRes.setStatusCode(200);
        }
        resBody = httpRes.getBody();           
        
        Map<String, Object> output = (Map<String, Object>)JSON.deserializeUntyped(resBody);
        
        String q = String.valueOf(output.get('query'));
        String x = q.substring(q.indexOf('FROM User') + 9, q.indexOf('ORDER BY'));
        System.debug('Condition [' + x + ']');
        return x;
    }
    
    @RemoteAction
    global static Map<String, Object> getListViews() 
    {
        Map<String, Object> retuenMap = new Map<String, Object>();
        List<ListView> uvList = [select Id, DeveloperName, Name from ListView where SobjectType = 'User' order by Name];
        List<ListViewClass> lvcList = new List<ListViewClass>();
        ListViewClass item;
        
        for(ListView lv : uvList) {
            item = new ListViewClass(lv.Id, lv.DeveloperName, lv.Name);
            lvcList.add(item);
        }
        
        // Recently Viewed Users
        lvcList.add(new ListViewClass('RecentlyViewedUsers', 'RecentlyViewedUsers', 'Recently Viewed Users'));
        
        retuenMap.put('listviews', lvcList);

        return retuenMap;
    }
    
    private static List<Profile> getProfileList() {
        return [select Id, Name, UserType from Profile where UserType in ('Standard', 'CsnOnly') order by UserType, Name];
    }

    private static List<UserRole> getRoleList() {
        return [select Id, Name, DeveloperName from UserRole order by Name];
    }
    
    private static List<wrapDateClass> getDateList() {
        List<wrapDateClass> returnList = new List<wrapDateClass>();
        
        returnList.add(new wrapDateClass('Day'));
        returnList.add(new wrapDateClass('YESTERDAY', 'Yesterday'));
        returnList.add(new wrapDateClass('TODAY', 'Today'));
        returnList.add(new wrapDateClass('Calendar Week'));
        returnList.add(new wrapDateClass('LAST_WEEK', 'Last Week'));
        returnList.add(new wrapDateClass('THIS_WEEK', 'This Week'));
        returnList.add(new wrapDateClass('Calendar Month'));
        returnList.add(new wrapDateClass('LAST_MONTH', 'Last Month'));
        returnList.add(new wrapDateClass('THIS_MONTH', 'This Month'));
        returnList.add(new wrapDateClass('Calendar Year'));
        returnList.add(new wrapDateClass('LAST_YEAR', 'Last Year'));
        returnList.add(new wrapDateClass('THIS_YEAR', 'This Year'));
        
        return returnList;
    }

    public class wrapDateClass
    {
        public String grp {get; set;}
        public String val {get; set;}
        public String Name {get; set;}
        
        public wrapDateClass(String grp) {
            this.grp = grp;
        }
        
        public wrapDateClass(String val, String Name) {
            this.val = val;
            this.Name = Name;
        }
    }
    
    @RemoteAction
    global static Map<String, Object> getFilterPickList() 
    {
        Map<String, Object> returnDataMap = new Map<String, Object>();

        returnDataMap.put('profileList', getProfileList());
        returnDataMap.put('roleList', getRoleList());
        returnDataMap.put('dateList', getDateList());

        return returnDataMap;
    }
    
    @RemoteAction
    global static Map<String, Object> getData(String sortingField, String sortingDirection, String listviewId
                                              , String filter_text, String filter_Profile, String filter_Role, String filter_LastLogin, Integer limit_size) 
    {
        Map<String, Object> returnDataMap = new Map<String, Object>();

        returnDataMap.put('userList', getUserList(sortingField, sortingDirection, listviewId, filter_text, filter_Profile, filter_Role, filter_LastLogin, limit_size));

        return returnDataMap;
    }
    
    private static List<User> getUserList(String sortingField, String sortingDirection, String listviewId
                                         , String filter_text, String filter_Profile, String filter_Role, String filter_LastLogin, Integer limit_size)
    {
        String sql = 'select';
        sql += '       Id';
        sql += '     , Name';
        sql += '     , Email';
        sql += '     , IsActive';
        sql += '     , LastLoginDate';
        sql += '     , ProfileId';
        sql += '     , SmallPhotoUrl';
        sql += '     , Title';
        sql += '     , MobilePhone';
        sql += '     , Username';
        sql += '     , UserRoleId';
        sql += '     , UserRole.Name';
        sql += '     , Profile.Name';
        sql += ' from';
        sql += '     User';
        
        if(String.isNotEmpty(listviewId)) {
            if(listviewId == 'RecentlyViewedUsers') {
                List<RecentlyViewed> RVList = [select Id, LastViewedDate from RecentlyViewed where Type = 'User' order by LastViewedDate desc limit 100];
                List<Id> inList = new List<Id>();
                for(RecentlyViewed RV : RVList) {
                    inList.add(RV.Id);
                }
                sql += ' WHERE Id in :inList ';
            } else {
        		sql += getListViewsWhere(listviewId);
            }
        }
        
        if(sql.indexOf('WHERE') == -1) {
        	sql += ' WHERE Id != null ';
        }
        
        if(String.isNotEmpty(filter_text)) {
            sql += ' AND ( Name Like \'%'+ filter_text + '%\' OR Username LIKE \'%'+ filter_text + '%\' OR Email LIKE \'%'+ filter_text + '%\' )';
        }
        if(String.isNotEmpty(filter_Profile)) {
            sql += ' AND ProfileId = :filter_Profile ';
        }
        if(String.isNotEmpty(filter_Role)) {
            sql += ' AND UserRoleId = :filter_Role ';
        }
        if(String.isNotEmpty(filter_LastLogin)) {
            sql += ' AND LastLoginDate = ' + filter_LastLogin;
        }
        
        if(String.isNotEmpty(sortingField)) {
            
            sql += ' order by ';
            
            if(sortingField == 'ProfileId') {
                sql += ' Profile.Name ' + sortingDirection;
            } else if(sortingField == 'UserRoleId') {
                sql += ' UserRole.Name ' + sortingDirection;
            } else if(sortingField == 'LastLoginDate') {
                if(sortingDirection == 'asc') {
                    sql += sortingField + ' ' + sortingDirection + ' NULLS LAST';
                } else {
                    sql += sortingField + ' ' + sortingDirection + ' NULLS FIRST';
                }
            } else {
                sql += sortingField + ' ' + sortingDirection;
            }   
        }
        
        sql += ' limit ' + limit_size;

        System.debug(sql);

        return Database.query(sql);
    }
    
    @RemoteAction
    global static Map<String, Object> doChangePassword(String userId, String password) {
        
        Map<String, Object> resultMap = new Map<String, Object>();
        String result = 'S';
        String errorMsg = '';
        try {
            System.setPassword(userId, password);
        } catch(Exception e) {
            result = 'E';
            errorMsg = e.getMessage();
        }
        
        resultMap.put('result', result);
        resultMap.put('errorMsg', errorMsg);

        return resultMap;
    }
    
    @RemoteAction
    global static Map<String, Object> doResetPassword(String userId, String sendUserEmail) {
        
        Map<String, Object> resultMap = new Map<String, Object>();
        
        String result = 'S';
        String errorMsg = '';
        String temp_password = '';
        
        try {
            System.debug('## sendUserEmail : ' + sendUserEmail);
            System.ResetPasswordResult results = System.resetPassword(userId, (sendUserEmail == 'Y' ? true : false));
            System.debug('## temp Password : ' + results.getPassword());
            temp_password = results.getPassword();
        } catch(Exception e) {
            result = 'E';
            errorMsg = e.getMessage();
        }
        
        resultMap.put('result', result);
        resultMap.put('errorMsg', errorMsg);
        resultMap.put('temp_password', temp_password);

        return resultMap;
    }
    
    public class ListViewClass {
        public String developerName	{ get; set; }
        public String id			{ get; set; }
        public String label			{ get; set; }
        
        public ListViewClass(String id, String developerName, String label) {
            this.id = id;
            this.developerName = developerName;
            this.label = label;
        }
    }
}