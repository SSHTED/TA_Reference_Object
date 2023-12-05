global class PMS_PjtResourceActualSumScheduler implements Schedulable {
    
    global void execute(SchedulableContext SC) {

        Integer BATCH_SIZE = Test.isRunningTest() ? 200 : 1;
		PMS_PjtResourceActualSumBatch batch = new PMS_PjtResourceActualSumBatch();
        Database.executeBatch(batch, BATCH_SIZE);
    }

}