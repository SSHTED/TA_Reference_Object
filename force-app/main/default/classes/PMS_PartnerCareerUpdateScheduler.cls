global class PMS_PartnerCareerUpdateScheduler implements Schedulable {
    
    global void execute(SchedulableContext SC) {

        Integer BATCH_SIZE = Test.isRunningTest() ? 200 : 1;
		PMS_PartnerCareerUpdateBatch batch = new PMS_PartnerCareerUpdateBatch();
        Database.executeBatch(batch, BATCH_SIZE);
    }
}