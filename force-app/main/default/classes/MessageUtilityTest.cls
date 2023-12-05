@isTest(SeeAllData=true)
private class MessageUtilityTest {
    static testMethod void MessageShowTest(){
        MessageUtility.showConfirm('conf');
        MessageUtility.showError('err');
        MessageUtility.showInfo('info');
        MessageUtility.showMsg(ApexPages.Severity.ERROR, 'showMsg test');
        MessageUtility.showWarning('warning');
    }
}