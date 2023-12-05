global class PMS_EmpSkillGradeScheduler implements Schedulable{
    global void execute(SchedulableContext SC) {
        Integer BATCH_SIZE = Test.isRunningTest() ? 200 : 1;
        PMS_EmpSkillGradeBatch batch = new PMS_EmpSkillGradeBatch();
        Database.executeBatch(batch, BATCH_SIZE);
    }
}