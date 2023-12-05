global class PMS_PjtPartnerProjectInputBatchScheduler implements Schedulable{
    global void execute(SchedulableContext SC) {
 
        PMS_PjtPartnerProjectInputBatch batch = new PMS_PjtPartnerProjectInputBatch();
        Database.executeBatch(batch, 1);
    }
}