public class ResumeEmailManage{
    //Resume__c re = new Resume__c();

    public void postEmail(String name, String email, String condition, String jobGroup, 
                            String interviewDate1st, String interviewDate2nd, String action){
        System.debug(interviewDate1st);
        System.debug(interviewDate2nd);

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[]{email}; // 보내는 주소
        message.setToAddresses(toAddresses); 
        message.setInReplyTo('support@dkbmc.com');
        System.debug('email : ' + email);
        System.debug('action : ' + action);
        // SEND(default) , FILTER , REJECT 중 택1
        message.optOutPolicy = 'FILTER';
        
        
        String templateId = '';
        String templateName = '';
        if(action=='post'){
            if(condition == '서류접수' || condition == '서류심사'){
                templateName = 'ResumeEmailReceive';
            }else if(condition == '1차면접대상'){
                templateName = 'ResumeEmail1st';
            }else if(condition == '2차면접대상'){
                templateName = 'ResumeEmail2nd';
            }else if(condition == '최종합격'){
                templateName = 'ResumeEmailPass';
            }else if(condition == '불합격'){
                templateName = 'ResumeEmailFail';
            }else if(condition == '지원취소'){
                templateName = 'ResumeEmailCancel';
            }
            
        }else if(action=='resultConfirm'){
            templateName = 'ResumeEmailResult';
        }

        EmailTemplate temp = [SELECT Id, Subject, Body, HtmlValue FROM EmailTemplate WHERE developername =:templateName];
        
        System.debug('temp : ' + temp);
        // Email Template 에 컨디션 주지 못한 이유
        // 컨디션을 줘도 현재 메소드에서 문장 그대로 가져오기 때문입니다.
        // 또한, 레터헤드는 내용 자체를 읽어오지 못합니다.
                                        
        // template의 내용을 현재 메소드에서 받은 값으로 변환 후 setHtmlBody 에 넣어주는 것입니다.
        String temBody = '';  
        temBody = (String)temp.HtmlValue;                             
        temBody = temBody.replace('{!Resume__c.Name}' , name);
        temBody = temBody.replace('{!Resume__c.Email__c}' , email);                                                        
        temBody = temBody.replace('{!Resume__c.Condition__c}' , condition);
        temBody = temBody.replace('{!Resume__c.JobGroup__c}' , jobGroup);
        temBody = temBody.replace('{!Resume__c.InterviewDate1st__c}' , interviewDate1st);
        temBody = temBody.replace('{!Resume__c.InterviewDate2nd__c}' , interviewDate2nd);                                
        message.setHtmlBody(temBody);                      
                                
        String temSubject = '';
        temSubject = (String)temp.Subject;    
        temSubject = temSubject.replace('{!Resume__c.Name}' , name);
        message.subject = temSubject;
                                
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        System.debug(messages);        
        //Limit --> Dev Edition = 15, non Dev = 1000
        
        Messaging.SendEmailResult[] results = Messaging.SendEmail(messages);

        if (results[0].success){
            System.debug('The email was sent successfully.');
        } else{
            System.debug('The email failed to send: ' + results[0].errors[0].message);
        }
        
        
    }    
}