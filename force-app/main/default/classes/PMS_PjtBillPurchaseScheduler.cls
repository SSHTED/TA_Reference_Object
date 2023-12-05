global class PMS_PjtBillPurchaseScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        Integer BATCH_SIZE = Test.isRunningTest() ? 200 : 1;
        PMS_PjtBillSchedulePurchaseBatch batch02 = new PMS_PjtBillSchedulePurchaseBatch();
        Database.executeBatch(batch02, BATCH_SIZE);
    }
}