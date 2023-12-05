@isTest
public class eLearningController_TEST {
    static CommunityNotice__c cn;
    static eLearningContents__c elc;
    static Education__c edu;
    static {
        System.runAs([SELECT Id FROM User WHERE Id =:UserInfo.getUserId()][0]){
			CommunityNotice__c cn = new CommunityNotice__c();
            cn.Name ='TEST CommunityNotice';
            cn.Description__c ='TEST';
            insert cn;
			
            Education__c edu = new Education__c();
            edu.Name = 'TEST Education';
            edu.Related_data_and_Development_resources__c='TEST';
            edu.Detailed_business_requirements__c='TEST';
            edu.TrainingStep__c = '1';
            insert edu;
            
            eLearningContents__c elc = new eLearningContents__c();
            elc.Name ='TEST';
            elc.Category1__c='Salesforce';
            elc.Category__c ='Basic Admin';
            insert elc;
            

            
        }
    }
    
    static testMethod void testMethod1(){
        TEST.startTest();
        List<CommunityNotice__c> cnList = [SELECT ID FROM CommunityNotice__c limit 1];
        List<User> userList = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId() Limit 1];
        List<eLearningContents__c> elcList = [SELECT ID FROM eLearningContents__c limit 1];
        List<Education__c> eduList = [SELECT ID FROM Education__c Limit 1];
        
        eLearningController.getNoticeDetail(cnList[0].Id);
        eLearningController.getNoticeList();
        eLearningController.getNoticeListOne();
        eLearningController.getPickList();
        eLearningController.getTrainingChallengeList();        
        eLearningController.setVideoComplete(elcList[0].Id);

        eLearningController.setCategoryComplete('Salesforce', 'Basic Admin');
        eLearningController.getCategoryCompleteList('Salesforce', 'Basic Admin');
        
        
        eLearningController.getTrainingChallengeDetail(eduList[0].Id);
        
        eLearningController.getVideoList('Basic Admin', 'Salesforce', UserInfo.getUserId());
        eLearningController.getVideoDetailAndFiles('', UserInfo.getUserId());
        TEST.stopTest();
    }

}