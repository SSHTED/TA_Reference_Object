global class PMS_ObjShareByProjectUpdateScheduler implements Schedulable {
    
    global void execute(SchedulableContext SC) {

        Integer BATCH_SIZE = Test.isRunningTest() ? 200 : 1;
		PMS_ObjShareByProjectUpdateBatch batch = new PMS_ObjShareByProjectUpdateBatch();
        Database.executeBatch(batch, BATCH_SIZE);
    }
}