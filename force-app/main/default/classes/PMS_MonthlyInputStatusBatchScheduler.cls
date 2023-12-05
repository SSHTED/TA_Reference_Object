global class PMS_MonthlyInputStatusBatchScheduler implements Schedulable{
    global void execute(SchedulableContext SC) {
        Integer BATCH_SIZE = Test.isRunningTest() ? 200 : 1;
        PMS_MonthlyInputStatusBatch batch = new PMS_MonthlyInputStatusBatch();
        Database.executeBatch(batch, BATCH_SIZE);
    }
}