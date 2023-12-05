public with sharing class ContractDocumentTriggerHandler {
    
    private Boolean isExecuting {get;set;} 	// Web Service와 구분하기 위한 Context 파라미터
    private Integer size {get;set;} 		// Trigger에서 Execute된 List Size
    
    public ContractDocumentTriggerHandler(Boolean isExecuting, Integer size){
        this.isExecuting = isExecuting;
        this.size = size;
        
        System.debug('#isExecuting [' + isExecuting + '] #size [' + size + ']');
    }

    public void onBeforeInsert(List<ContractDocument__c> news){
        System.debug('size ? ' + news.size());
        if(news.size() == 1){ // 221222_이호재 AutoNumber 기능 추가
            // System.debug('코드는 1 ? : ' + news.get(0).ContractDocumentCode__c);

            String thisYear = String.valueOf(System.today().year());
            String cutThisYear = 'C-' + thisYear.substring(2) + '-%';
            System.debug('올해는 ? ' + cutThisYear);

            // List로 변환해서 사이즈 1이면 그대로 로직, 없으면 디폴트로 하나넣어주기
            List<ContractDocument__c> cCodeList = [SELECT Id, ContractDocumentCode__c
                                                   FROM ContractDocument__c
                                                   WHERE ContractDocumentCode__c != null
                                                   AND ContractDocumentCode__c LIKE :cutThisYear
                                                   ORDER BY ContractDocumentCode__c DESC
                                                   LIMIT 1];
            System.debug('cCodeList는 ? ' + cCodeList);
            System.debug('cCodeList size는 ? ' + cCodeList.size());
            
            // O-22-0011
            if(cCodeList == null || cCodeList.size() == 0){
                System.debug('new !');
                news.get(0).ContractDocumentCode__c = 'C-' + thisYear.substring(2) + '-0001';
            }else if(cCodeList != null || cCodeList.size() == 1){
                System.debug('old !');
                String cCode;
                for(ContractDocument__c c : cCodeList){
                    cCode = String.valueOf(c.ContractDocumentCode__c);
                }
                System.debug('cCode는 ? ' + cCode);

                Integer subCode = Integer.valueOf(cCode.substring(5));
                System.debug('subCode ? ' + subCode);
                String plusOneCode = String.valueOf(subCode + 1);
                System.debug('plusOneCode ? ' + plusOneCode);

                String lpadedCode = plusOneCode.leftPad(4, '0');
                System.debug('lpadedCode ? ' + lpadedCode);
                news.get(0).ContractDocumentCode__c = 'C-' + thisYear.substring(2) + '-' + lpadedCode;
            }
        }
    }

    public void onAfterInsert(List<ContractDocument__c> news){
        List<ContractDocument__Share> cdShareList = new List<ContractDocument__Share>();
        
        system.debug('news is : ' + news);
        
        user gurs = [SELECT UserRoleId
                     FROM User 
                     WHERE Id = :news.get(0).OwnerId LIMIT 1];
        
        System.debug('gurs : ' + gurs);
        System.debug('gurs UserRoleId is :' + gurs.UserRoleId);

        Set<Id> userIdSet = new Set<Id>();
        userIdSet.add(gurs.UserRoleId);
        
        System.debug('userIdSet : ' + userIdSet);
        
        Set<Id> finalUserIdSet = getParentRoleId(userIdSet);
        
        System.debug('finalUserIdSet : ' + finalUserIdSet);
        
        List<UserRole> urList = [SELECT Id, Name FROM UserRole WHERE Id IN: finalUserIdSet];
        
        for(UserRole ur : urList) { 
            // System.debug('------역할 이름:' + ur.Id);
            List<User> uList = [SELECT Id, UserRoleId FROM User WHERE UserRoleId = :ur.Id AND IsActive = true];
            
            for(User u : uList) {
                System.debug('------ Id:' + u.Id);
                
                cdShareList.add(
                    new ContractDocument__Share(
                        AccessLevel = 'Edit'
                        , ParentId = news.get(0).Id
                        , RowCause = 'Manual'
                        , UserOrGroupId = u.id
                    )
                );
            }
        }
    }
    
    public void onAfterUpdate(List<ContractDocument__c> olds, List<ContractDocument__c> news, Map<Id, ContractDocument__c> newMap){
        /*List<Messaging.SingleEmailMessage> mailList =  new List<Messaging.SingleEmailMessage>();
        List<ContractDocument__c> cdList = [SELECT Id, Step__c FROM ContractDocument__c WHERE Id = :news.get(0).OwnerId];
        
        for(ContractDocument__c cd : cdList){
            if(cd.Step__c == '날인'){
                Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
                // Step 2: Set list of people who should get the email
                List<String> sendTo = new List<String>();
                sendTo.add(man.email);
                mail.setToAddresses(sendTo);
                
                // Step 3: Set who the email is sent from
                mail.setReplyTo('utkarsha.up10@gmail.com');
                mail.setSenderDisplayName('Utz patil');
                
                // (Optional) Set list of people who should be CC'ed
                List<String> ccTo = new List<String>();
                ccTo.add('puja.patil@aress.com');
                mail.setCcAddresses(ccTo);
                
                // Step 4. Set email contents - you can use variables!
                mail.setSubject('URGENT BUSINESS PROPOSAL');
                String body = 'Dear ' + con.FirstName;
                
                mail.setHtmlBody(body);
                
                // Step 5. Add your email to the master list
                mailList.add(mail);
            }
        }*/
    }
    
    public static Set<Id> getParentRoleId(Set<Id> roleIds) {
        Set<Id> currentRoleIds = new Set<Id>();
        // get all of the parent roles.
        for(UserRole ur :[select Id, ParentRoleId from UserRole where Id IN: roleIds]) {
            currentRoleIds.add(ur.ParentRoleId);
        }
        
        // go fetch some more rolls!
        if(currentRoleIds.size() > 0) {
            currentRoleIds.addAll(getParentRoleId(currentRoleIds));
        }
        return currentRoleIds;
    }
}