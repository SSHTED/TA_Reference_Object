public with sharing class HR_OrgMemberUpdateScheduler implements Schedulable {
    public void execute(SchedulableContext SC) {
        Integer BATCH_SIZE = Test.isRunningTest() ? 200 : 1;
        HR_OrgMemberUpdateBatch batch = new HR_OrgMemberUpdateBatch();
        Database.executeBatch(batch, BATCH_SIZE);
    }
}