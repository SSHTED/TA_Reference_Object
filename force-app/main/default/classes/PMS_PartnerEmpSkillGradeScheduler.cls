global class PMS_PartnerEmpSkillGradeScheduler implements Schedulable{
    global void execute(SchedulableContext SC) {
        Integer BATCH_SIZE = Test.isRunningTest() ? 200 : 1;
        PMS_PartnerEmpSkillGradeBatch batch = new PMS_PartnerEmpSkillGradeBatch();
        Database.executeBatch(batch, BATCH_SIZE);
    }
}