global class PMS_PjtResourceActiveScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        Integer BATCH_SIZE = Test.isRunningTest() ? 200 : 1;
        PMS_PjtResourceActiveBatch batch = new PMS_PjtResourceActiveBatch();
        Database.executeBatch(batch, BATCH_SIZE);
    }
}