global class PMS_PjtBillScheduleScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        Integer BATCH_SIZE = Test.isRunningTest() ? 200 : 1;
        PMS_PjtBillScheduleBatch batch = new PMS_PjtBillScheduleBatch();
        Database.executeBatch(batch, BATCH_SIZE);
    }
}