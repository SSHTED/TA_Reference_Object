global class PMS_ObjShareUpdateScheduler implements Schedulable {
    
    global void execute(SchedulableContext SC) {

        Integer BATCH_SIZE = Test.isRunningTest() ? 200 : 1;
		PMS_ObjShareUpdateBatch batch = new PMS_ObjShareUpdateBatch();
        Database.executeBatch(batch, BATCH_SIZE);
    }
}