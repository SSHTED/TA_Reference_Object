public class ApprovalProcess {
    @auraEnabled
    public static void submitApproval(String recordId,String comment,Id approvalId,boolean mybool){
        system.debug('approvalId'+ approvalId);
        List<HolidayAction__c> holiday = new List<HolidayAction__c>();
        date targetDate = date.today();
        String query = 'select HolidayAction_Date1__c from HolidayAction__c where HolidayAction_IsConfirm__c = true and HolidayAction_Parent__r.Holiday_User__c =: approvalId ';
        for(integer i=1;i<=30;i++){
            query += string.format(' {0} {2}(HolidayAction_Date{1}__c != null and HolidayAction_Date{1}__c =: targetDate){3}',
                                   new List<string>{i == 1 ? 'and' : 'or' ,string.valueOf(i), i == 1 ? '(' : '' , i == 30 ? ')' : '' });//,콤마기준
        }        
        system.debug(query);
        List<HolidayAction__c> holidays = Database.query(query);
        system.debug(holidays.size());
        
        Resolution_To_Spend__c spending = [select Holiday_PreseAbse__c,id,CheckImp__c from Resolution_To_Spend__c where id =: recordId];
        spending.CheckImp__c = mybool;
        if(holidays.size() > 0){
            spending.Holiday_PreseAbse__c = true;
            system.debug('트루 펄스 구분'+  spending.Holiday_PreseAbse__c);
        }
        system.debug(mybool);
        system.debug('중대사항 체크여부 '+ spending.CheckImp__c);
        update spending;
        
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments(comment);
        req.setObjectId(recordId);
        req.setNextApproverIds(new Id[] {approvalId});//테스트라는 사용자를 선택했는 아이디값이 여기로 넘어옴 approvalId : 승인자 설정아이디 //
        Approval.ProcessResult res = Approval.process(req);
       
    }
}