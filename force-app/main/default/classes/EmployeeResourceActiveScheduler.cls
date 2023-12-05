global class EmployeeResourceActiveScheduler implements Schedulable{
    global void execute(SchedulableContext SC) {
        Integer BATCH_SIZE = Test.isRunningTest() ? 200 : 1;
        EmployeeResourceActiveBatch batch = new EmployeeResourceActiveBatch();
        Database.executeBatch(batch, BATCH_SIZE);
    }
}