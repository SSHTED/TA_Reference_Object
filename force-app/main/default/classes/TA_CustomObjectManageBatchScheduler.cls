public class TA_CustomObjectManageBatchScheduler implements Schedulable {
    SchedulableContext ctx;
    
    public void execute(SchedulableContext ctx){
        this.ctx = ctx;
        TA_CustomObjectManageBatch bat = new TA_CustomObjectManageBatch(); 
		Database.executeBatch(bat, 1);
    }
}