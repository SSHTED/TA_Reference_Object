/**
 * @Class : TA_CustomObjectManageBatch
 *
 * @Method : 

 *	- start(BC)
 *	- execute(BC, taComList)
 *	- finish(BC)
 * 
 * @Author : 안종민
 * @Date : 2023-10-27
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2023-10-27 | 안종민           | 최초작성
 *  2. | 2023-11-06 | 안종민           | 5만 건 이상의 데이터 처리되도록 수정
 */

public class TA_CustomObjectManageBatch implements Database.Batchable<SObject> , Database.Stateful {
    String batchName = 'TA_CustomObjectManageBatch';
    Integer batchExecuteCount = 0;
    Integer successCount = 0;
    Integer failCount = 0;
    Integer executeCount = 0;
    String resultLog = '';
    List<EntityDefinition> tempEdList = new List<EntityDefinition>();
    List<TA_CustomObjectManage__c> tempTaComList = new List<TA_CustomObjectManage__c>();

    public TA_CustomObjectManageBatch(){
        /*
            salesforce에서 Tooling API를 사용하는 오브젝트에 대해 Database.getQueryLocator를 할 수 없기 때문에 생성자에서 사전 쿼리 수행.
            start 메서드에서 EntityDefinition 쿼리 작성 시 아래 오류메세지 확인

            "EntityDefinition does not support queryMore(), use LIMIT to restrict the results to a single batch"
        */
        
        String soql = ' select '
                    + '     LastModifiedDate, QualifiedApiName '
                    + ' from '
                    + '     EntityDefinition '
                    + ' where '
                    + '     QualifiedApiName LIKE \'%__c\' '
                    + '     and IsTriggerable = true '
                    + '     and IsCustomizable = true ';
        
        System.debug('EntityDefinition soql query >>> \n' + soql);
        tempEdList = Database.query(soql);
        for(EntityDefinition ed: tempEdList){
            TA_CustomObjectManage__c taCom = new TA_CustomObjectManage__c();
            taCom.Name = ed.QualifiedApiName;
            tempTaComList.add(taCom);
        }
        try {
            if(!Test.isRunningTest()){
                upsert tempTaComList name;
            }
        } catch (DmlException e) {
            System.debug(e.getMessage());
        }
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('[START] ' + batchName);

        if(!Test.isRunningTest()){
            String soql = ' select '
                        + '     name '
                        + ' from '
                        + '     TA_CustomObjectManage__c ';
            
            System.debug('TA_CustomObjectManage__c soql query >>> ' + soql);
    
            return Database.getQueryLocator(soql);
        } else {
            return Database.getQueryLocator([SELECT name FROM TA_CustomObjectManage__c where name = 'Lead' LIMIT 1]);
        }
    }

    public void execute(Database.BatchableContext BC , List<TA_CustomObjectManage__c> taComList){
        System.debug('[EXECUTE] ' + batchName + ' ( ' + (++batchExecuteCount) + ' ) [BATCH SIZE] ' + taComList.size());
        String soql = '';
        
        try {
            for(TA_CustomObjectManage__c ta : taComList){
                TA_CustomObjectManage__c coMap = new TA_CustomObjectManage__c();
                
                /* 2023. 11. 06 안종민
                    오류 문구 : Too Many Query Rows 50001
                    쿼리 수행 시 MAX 함수는 데이터를 5만 건 까지만 처리할 수 있기 때문에
                    order by로 쿼리 결과를 가져오도록 수정
                */
                // set cnt
                soql = ' select Count() '
                     + ' from ' + ta.Name;
                ta.All_Record_Cnt__c =  Database.countQuery(soql);
                upsert ta name;
                // set lastCreated
                soql = ' select CreatedDate '
                     + ' from ' + ta.Name
                     + ' order by CreatedDate desc '
                     + ' limit 1 ';
                List<SObject> createDateSObjectList = Database.query(soql); // 1 건
                for(SObject so : createDateSObjectList){
                    ta.Last_Created_Date__c = Date.valueOf(so.get('CreatedDate'));
                    upsert ta name;
                }
                // set lastModified
                soql = ' select LastModifiedDate '
                     + ' from ' + ta.Name
                     + ' order by LastModifiedDate desc '
                     + ' limit 1 ';
                List<SObject> lastModifedDateSObjectList = Database.query(soql); // 1 건
                for(SObject so : lastModifedDateSObjectList){
                    ta.Last_Modified_Date__c = Date.valueOf(so.get('LastModifiedDate'));
                    upsert ta name;
                }
            }
        } catch (Exception e) {
            System.debug('[EXECUTE Error] ' + BatchName);
            System.debug('[EXECUTE Message] ' + e.getMessage());
            resultLog += ' [EXECUTE Error] ' + e;
        }
    }

    public void finish(Database.BatchableContext BC){
        System.debug('[FINISH] ' + batchName + ' ( ' + batchExecuteCount + ' )' + ' [S] ' + successCount + ' [F] ' + failCount);
    
    }
}