@isTest(SeeAllData=true)
private class ExamController_Test{
    static testMethod void myUnitTest(){
        ExamController ec = new ExamController();
        list<SelectOption> a = ec.dumpList;
        ec.changeDump();
        ec.genExam();
        ec.getNext();
        ec.getPrevious();
        ec.finish();
    }
}