global class EmployeeBatchScheduler implements Schedulable{
    global void execute(SchedulableContext SC) {
        Integer BATCH_SIZE = Test.isRunningTest() ? 200 : 1;
        EmployeeBatch batch = new EmployeeBatch();
        Database.executeBatch(batch, BATCH_SIZE);
    }
}