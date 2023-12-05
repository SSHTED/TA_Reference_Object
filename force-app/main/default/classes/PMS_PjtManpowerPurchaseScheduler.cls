global class PMS_PjtManpowerPurchaseScheduler implements Schedulable{
    global void execute(SchedulableContext SC) {
        Integer BATCH_SIZE = Test.isRunningTest() ? 200 : 1;
        PMS_PjtManpowerPurchaseBatch batch = new PMS_PjtManpowerPurchaseBatch();
        Database.executeBatch(batch, BATCH_SIZE);
    }
}