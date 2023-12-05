global class PMS_PjtBillSchedulePurIterable implements Iterable<AggregateResult>{
    private String query;

    global PMS_PjtBillSchedulePurIterable(String soql){
        query = soql;
    }

    global Iterator<AggregateResult> Iterator(){ 
        return new PMS_PjtBillSchedulePurIterator(query); 
    } 
}