global class HolidayScheduler implements Schedulable {

    global void execute(SchedulableContext SC) {
        HolidayUpdateStatusBatch batch = new HolidayUpdateStatusBatch();
        If (Test.isRunningTest ()) {
        	ID jobID = Database.executeBatch(batch, 200);
            System.abortJob(jobID);
        } else {
            Database.executeBatch(batch, 1);
        }
    }
}