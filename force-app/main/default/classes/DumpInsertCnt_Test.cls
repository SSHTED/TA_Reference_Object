@isTest(SeeAllData=true)
private class DumpInsertCnt_Test {
    static testMethod void TestInsrtDump(){
        Dump_Header__c[] dump_header = [select id from Dump_Header__c Limit 1];
        String header_id = dump_header[0].id;
        Dump_Body__c dump = new Dump_Body__c();
        dump.Subject__c = 'test';
        dump.Dump_Header__c = header_id;
        dump.Answer__c = 'A';
        dump.Name = 'test1';
        dump.Option_A__c = 'test';
        insert dump;
    }
}