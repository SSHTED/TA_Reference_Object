public class OutSupportManagerBatchScheduler implements Schedulable{

    SchedulableContext ctx;
    
    public void execute(SchedulableContext ctx){
        this.ctx = ctx;
        OutSupportManagerBatch bat = new OutSupportManagerBatch(); 
		Database.executeBatch(bat, 1);
        
    }
    
}