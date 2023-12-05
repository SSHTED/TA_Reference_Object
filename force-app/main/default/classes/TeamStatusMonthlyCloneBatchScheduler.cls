public class TeamStatusMonthlyCloneBatchScheduler implements Schedulable{
    
    SchedulableContext ctx;
     
    public void execute(SchedulableContext ctx){
        this.ctx = ctx;
        TeamStatusMonthNewCloneBatch bat = new TeamStatusMonthNewCloneBatch(); 
        Database.executeBatch(bat, 200);
    }
}