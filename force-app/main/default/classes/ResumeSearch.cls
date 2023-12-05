@RestResource(urlMapping='/resumeSearch/*')
global with sharing class ResumeSearch {
    @HttpPost
    global static Map<String, String> doPost(String action, String name, String email){
        Map<String, String> resultMap = new Map<String, String>();
        Resume__c re = new Resume__c();

        ResumeEmailManage et = new ResumeEmailManage();

        System.debug('action : ' + action);
        System.debug('name : ' + name);
        System.debug('email : ' + email);

        if(action=='searchCondition'){

            // 입력 받은 name 과 email 로 데이터를 조회합니다.
            List<Resume__c> reLst = [SELECT Id, Name, Email__c, Condition__c, JobGroup__c, InterviewDate1st__c, InterviewDate2nd__c
                                    FROM Resume__c
                                    WHERE Name =:name AND Email__c =:email];
            System.debug(reLst);
            System.debug('reLst Size : ' + reLst.size());
            System.debug(reLst[0].Name);
            
            //String name = reLst[0].Name;
            //String email = reLst[0].Email__c;
            String condition = reLst[0].Condition__c;
            String jobGroup = reLst[0].JobGroup__c;
            String interviewDate1st = '';
            String interviewDate2nd = '';
            if(reLst[0].InterviewDate1st__c != null){
                interviewDate1st = reLst[0].InterviewDate1st__c.format('yyyy/MM/dd HH:mm');
                //interviewDate1st = reLst[0].InterviewDate1st__c.format('yyyy/MM/dd HH:mm') == null ? '' : reLst[0].InterviewDate1st__c.format('yyyy/MM/dd HH:mm') == null;
            }
            if(reLst[0].InterviewDate2nd__c != null){
                interviewDate2nd = reLst[0].InterviewDate2nd__c.format('yyyy/MM/dd HH:mm');
            }
            String action2 = 'resultConfirm';
            
            // reLst 가 1개 라도 있으면 결과값이 존재하는 것입니다.
            if(reLst.size() > 0){
                et.postEmail(name, email, condition, jobGroup, interviewDate1st, interviewDate2nd, action2);
                resultMap.put('result', '지원자의 입사현황이 이메일로 발송되었습니다.');
            }else{
                resultMap.put('result', '지원자의 정보가 올바르지 않습니다.');
            }
        }

        return resultMap;
    }
}