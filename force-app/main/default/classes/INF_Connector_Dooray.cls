/**
 * @Class : INF_Connector_Dooray
 *
 * @Method : 
 *	- @HttpPost doPost()
 *	- StringToDatetime(dt)
 *	- StringToDate(dt)
 * 
 * @Author : Yong-Jin, Cha
 * @Date : 2023-04-06
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2023-04-06 | Yong-Jin, Cha | 최초작성
 */
@RestResource(urlmapping = '/dooray/*')
global without sharing class INF_Connector_Dooray {

    @HttpPost
    global static PostResultWrap doPost() {

        PostResultWrap result = new PostResultWrap();

        RestRequest request = RestContext.request;
        
        String reqURI = request.requestURI;
        String uriType = reqURI.substring(reqURI.lastIndexOf('/')+1);

        System.debug('# reqURI : ' + reqURI);
        System.debug('# uriType : ' + uriType);

        /**
        for(String key : request.headers.keySet()) {
            System.debug(key + ' : ' + request.headers.get(key));
        }
        /**/

        String param = RestContext.request.requestBody.toString();

        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(param);

        for(String key : m.keySet()) {
            System.debug(key + ' : ' + JSON.serialize(m.get(key)));
        }

        Customer_Org__c customerOrg = [select Id, Customer__c from Customer_Org__c where Name = 'HDC 현대산업개발' limit 1];

        List<PMS_Project__c> projectList = [
            select 
                Id
            from
                PMS_Project__c 
            where
                EndCustomer__c = :customerOrg.Customer__c
            and Status__c = 'Active'
            and ContractStartDate__c <= today
            and ContractEndDate__c >= today
            limit 1
        ];

        Id CustomerOrgId = customerOrg.Id;
        Id projectId = projectList.size() > 0 ? projectList.get(0).Id : null;

        String baseUrl = 'https://hdc.dooray.com/project/posts/';
        
        if('iclick' == uriType) {

            String sourceText = JSON.serialize(m.get('source'));
            System.debug('# sourceText : ' + sourceText);
            Map<String, Object> source = (Map<String, Object>)JSON.deserializeUntyped(sourceText);
            System.debug('#---------------------------');
            for(String key : source.keySet()) {
                System.debug(key + ' : ' + JSON.serialize(source.get(key)));
            }

            String memberText = JSON.serialize(source.get('member'));
            System.debug('# memberText : ' + memberText);
            Map<String, Object> member = (Map<String, Object>)JSON.deserializeUntyped(memberText);

            String memberName = String.valueOf(member.get('name'));
            String memberEmail = String.valueOf(member.get('emailAddress'));

            String postText = JSON.serialize(m.get('post'));
            System.debug('# postText : ' + postText);
            Map<String, Object> post = (Map<String, Object>)JSON.deserializeUntyped(postText);
            System.debug('#---------------------------');
            for(String key : post.keySet()) {
                System.debug(key + ' : ' + JSON.serialize(post.get(key)));
            }

            System.debug('#---------------------------');

            String subject = String.valueOf(post.get('subject'));
            String taskId = String.valueOf(post.get('id'));
            String createdAt = String.valueOf(post.get('createdAt'));
            String dueDate = String.valueOf(post.get('dueDate'));
            String priority = String.valueOf(post.get('priority'));
            String num = String.valueOf(post.get('number'));

            BodyWrap body = (BodyWrap)JSON.deserialize(JSON.serialize(post.get('body')), BodyWrap.class);

            System.debug('# memberName : ' + memberName);
            System.debug('# memberEmail : ' + memberEmail);            
            System.debug('# subject : ' + subject);
            System.debug('# taskId : ' + taskId);
            System.debug('# createdAt : ' + createdAt);
            System.debug('# dueDate : ' + dueDate);
            System.debug('# priority : ' + priority);
            System.debug('# number : ' + num);
            // System.debug('# body.content : ' + body.content);
            // System.debug('# body.content (data:image/png;base64, : ' + body.content.indexOf('(data:image/png;base64,'));
            // System.debug('# body.content =) : ' + body.content.indexOf('=)'));

            Integer sIdx = body.content.indexOf('(data:image/');
            Integer eIdx = body.content.indexOf('=)');
            Integer e2Idx = body.content.indexOf('Z)');
            Integer e3Idx = body.content.indexOf('U)');
            Integer e4Idx = body.content.indexOf('C)');

            if(sIdx > -1) {
                if(eIdx > -1) {
                    body.content = body.content.substring(0, sIdx) + body.content.substring(eIdx + 2);
                    //System.debug('# body.content1 : ' + body.content);
                } else if(e2Idx > -1) {
                    body.content = body.content.substring(0, sIdx) + body.content.substring(e2Idx + 2);
                } else if(e3Idx > -1) {
                    body.content = body.content.substring(0, sIdx) + body.content.substring(e3Idx + 2);
                } else if(e4Idx > -1) {
                    body.content = body.content.substring(0, sIdx) + body.content.substring(e4Idx + 2);
                }

                Integer sIdx2 = body.content.indexOf('(data:image/');
                Integer eIdx2 = body.content.indexOf('=)');
                Integer e2Idx2 = body.content.indexOf('Z)');
                Integer e3Idx2 = body.content.indexOf('U)');
                Integer e4Idx2 = body.content.indexOf('C)');

                if(sIdx2 > -1) {
                    if(eIdx2 > -1) {
                        body.content = body.content.substring(0, sIdx2) + body.content.substring(eIdx2 + 2);
                    } else if(e2Idx2 > -1) {
                        body.content = body.content.substring(0, sIdx2) + body.content.substring(e2Idx2 + 2);
                    } else if(e3Idx2 > -1) {
                        body.content = body.content.substring(0, sIdx2) + body.content.substring(e3Idx2 + 2);
                    } else if(e4Idx2 > -1) {
                        body.content = body.content.substring(0, sIdx2) + body.content.substring(e4Idx2 + 2);
                    }
                }
            }

            insert new Support_Manager__c(
                Name = subject
                , Customer_Org__c = CustomerOrgId
                , PMS_Project__c = projectId
                , Request_Date__c = StringToDatetime(createdAt)
                , Request_Deadline__c = StringToDate(dueDate)
                , Request_Content__c = baseUrl + taskId + '<br/><br/>' + body.content.replaceAll('\n', '<br/>')
                , Requester__c = memberName
                , Requester_Email__c = memberEmail
                , Customer__c = '아이클릭'
                , Channel__c = 'Customer System'
                , Person_In_Charge__c = null
                , Request_No__c = num
                , OwnerId = System.Label.INF_CONNECTOR_DOORAY_OWNER
            );
        } else if('icontrols' == uriType) {
            String sourceText = JSON.serialize(m.get('source'));
            System.debug('# sourceText : ' + sourceText);
            Map<String, Object> source = (Map<String, Object>)JSON.deserializeUntyped(sourceText);
            System.debug('#---------------------------');
            for(String key : source.keySet()) {
                System.debug(key + ' : ' + JSON.serialize(source.get(key)));
            }

            String memberText = JSON.serialize(source.get('member'));
            System.debug('# memberText : ' + memberText);
            Map<String, Object> member = (Map<String, Object>)JSON.deserializeUntyped(memberText);

            String memberName = String.valueOf(member.get('name'));
            String memberEmail = String.valueOf(member.get('emailAddress'));

            String postText = JSON.serialize(m.get('post'));
            System.debug('# postText : ' + postText);
            Map<String, Object> post = (Map<String, Object>)JSON.deserializeUntyped(postText);
            System.debug('#---------------------------');
            for(String key : post.keySet()) {
                System.debug(key + ' : ' + JSON.serialize(post.get(key)));
            }

            System.debug('#---------------------------');

            String subject = String.valueOf(post.get('subject'));
            String taskId = String.valueOf(post.get('id'));
            String createdAt = String.valueOf(post.get('createdAt'));
            String dueDate = String.valueOf(post.get('dueDate'));
            String priority = String.valueOf(post.get('priority'));
            String num = String.valueOf(post.get('number'));

            BodyWrap body = (BodyWrap)JSON.deserialize(JSON.serialize(post.get('body')), BodyWrap.class);

            System.debug('# memberName : ' + memberName);
            System.debug('# memberEmail : ' + memberEmail);            
            System.debug('# subject : ' + subject);
            System.debug('# taskId : ' + taskId);
            System.debug('# createdAt : ' + createdAt);
            System.debug('# dueDate : ' + dueDate);
            System.debug('# priority : ' + priority);
            //System.debug('# body.content : ' + body.content);
            System.debug('# number : ' + num);
            
            Integer sIdx = body.content.indexOf('(data:image/');
            Integer eIdx = body.content.indexOf('=)');
            Integer e2Idx = body.content.indexOf('Z)');
            Integer e3Idx = body.content.indexOf('U)');
            Integer e4Idx = body.content.indexOf('C)');

            if(sIdx > -1) {
                if(eIdx > -1) {
                    body.content = body.content.substring(0, sIdx) + body.content.substring(eIdx + 2);
                    //System.debug('# body.content1 : ' + body.content);
                } else if(e2Idx > -1) {
                    body.content = body.content.substring(0, sIdx) + body.content.substring(e2Idx + 2);
                } else if(e3Idx > -1) {
                    body.content = body.content.substring(0, sIdx) + body.content.substring(e3Idx + 2);
                } else if(e4Idx > -1) {
                    body.content = body.content.substring(0, sIdx) + body.content.substring(e4Idx + 2);
                }

                Integer sIdx2 = body.content.indexOf('(data:image/');
                Integer eIdx2 = body.content.indexOf('=)');
                Integer e2Idx2 = body.content.indexOf('Z)');
                Integer e3Idx2 = body.content.indexOf('U)');
                Integer e4Idx2 = body.content.indexOf('C)');

                if(sIdx2 > -1) {
                    if(eIdx2 > -1) {
                        body.content = body.content.substring(0, sIdx2) + body.content.substring(eIdx2 + 2);
                    } else if(e2Idx2 > -1) {
                        body.content = body.content.substring(0, sIdx2) + body.content.substring(e2Idx2 + 2);
                    } else if(e3Idx2 > -1) {
                        body.content = body.content.substring(0, sIdx2) + body.content.substring(e3Idx2 + 2);
                    } else if(e4Idx2 > -1) {
                        body.content = body.content.substring(0, sIdx2) + body.content.substring(e4Idx2 + 2);
                    }
                }
            }

            insert new Support_Manager__c(
                Name = subject
                , Customer_Org__c = CustomerOrgId
                , PMS_Project__c = projectId
                , Request_Date__c = StringToDatetime(createdAt)
                , Request_Deadline__c = StringToDate(dueDate)
                , Request_Content__c = baseUrl + taskId + '<br/><br/>' + body.content.replaceAll('\n', '<br/>')
                , Requester__c = memberName
                , Requester_Email__c = memberEmail
                , Customer__c = '아이콘트롤스'
                , Channel__c = 'Customer System'
                , Person_In_Charge__c = null
                , Request_No__c = num
                , OwnerId = System.Label.INF_CONNECTOR_DOORAY_OWNER
            );
        }
        
        result.RequestCode = '200';
        result.Message = 'OK';
        
        return result;
    }

    // 2023-04-06T08:41:09.396+09:00
    private static DateTime StringToDatetime(String dt) {

        if(dt == null || dt == 'null')  return null;

        String DateStr = dt.substring(0, 10);
        
        Integer year = Integer.valueOf(DateStr.substring(0, 4));
        Integer month = Integer.valueOf(DateStr.substring(5, 7));
        Integer day = Integer.valueOf(DateStr.substring(8, 10));

        String TimeStr = dt.substring(11, 19);

        Integer hour = Integer.valueOf(TimeStr.substring(0, 2));
        Integer minute = Integer.valueOf(TimeStr.substring(3, 5));
        Integer second = Integer.valueOf(TimeStr.substring(6, 8));

        return DateTime.newInstanceGMT(year, month, day, hour, minute, second).addHours(-9);
    }

    private static Date StringToDate(String dt) {

        if(dt == null || dt == 'null')  return null;

        String DateStr = dt.substring(0, 10);
        
        Integer year = Integer.valueOf(DateStr.substring(0, 4));
        Integer month = Integer.valueOf(DateStr.substring(5, 7));
        Integer day = Integer.valueOf(DateStr.substring(8, 10));

        return Date.newInstance(year, month, day);
    }

    global class BodyWrap {
        global String mimeType;        
        global String content;
        global Boolean emptyContent;
    }
    
    global class PostResultWrap {
        global String RequestCode;
        global String Message;
    }
}