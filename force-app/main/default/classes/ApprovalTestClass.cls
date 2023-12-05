@isTest
public class ApprovalTestClass {
    public static Resolution_To_Spend__c spend;
    public static HolidayAction__c holiday;
    public static Holiday__c holi;
    static {
       	Date todaydate = Date.Today();
        spend = new Resolution_To_Spend__c(ownerId=userInfo.getUserId());
        insert spend;
        holi = new Holiday__c(Holiday_JoinDate__c=todaydate);
        insert holi;
    
        holiday = new HolidayAction__c(HolidayAction_Parent__c=holi.id,HolidayAction_Date1__c= todaydate);
		insert holiday;
        
    }
   @isTest static void fetchTest(){
       //public static void submitApproval(String recordId,String comment,Id approvalId,boolean mybool){
        Test.startTest();
        ApprovalProcess.submitApproval(spend.id,'안녕하세요',spend.ownerId,false);
        Test.stopTest();
        
    }
}