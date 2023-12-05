public class TeamStatusMonthlyBatchScheduler implements Schedulable{
    SchedulableContext ctx;
    
    public void execute(SchedulableContext ctx){
        this.ctx = ctx;
        TeamStatusMonthlyBatch bat = new TeamStatusMonthlyBatch(); 
		Database.executeBatch(bat, 1);
    }

}