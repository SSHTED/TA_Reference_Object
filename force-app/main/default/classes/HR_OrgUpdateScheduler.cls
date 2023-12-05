public with sharing class HR_OrgUpdateScheduler implements Schedulable {
    public void execute(SchedulableContext SC) {
        Integer BATCH_SIZE = Test.isRunningTest() ? 200 : 1;
        HR_OrgUpdateBatch batch = new HR_OrgUpdateBatch();
        Database.executeBatch(batch, BATCH_SIZE);
    }
}