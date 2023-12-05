global class JandiSendScheduler implements Schedulable {
    
    global void execute(SchedulableContext SC){        
        JandiSendBatch batch = new JandiSendBatch();
		database.executeBatch(batch, 1);
    }
}