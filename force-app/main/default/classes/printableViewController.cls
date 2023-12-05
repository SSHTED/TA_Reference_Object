public with sharing class printableViewController {
    public String recordId {get; set;}
    public Map<String, String> Maps {get; set;}

    public printableViewController(ApexPages.StandardController printableViewController){
        recordId  = ApexPages.CurrentPage().getparameters().get('id'); 
        String myGeneratedFilename = 'ResolutionExpenditure.pdf';
        Apexpages.currentPage().getHeaders().put('content-disposition', 'inline; filename='+myGeneratedFilename); 
        getProcess();
    }
    public void getProcess() {
        system.debug('recordId : '+recordId);
        List<ProcessInstance> processList = [SELECT Id, Status, CreatedDate, TargetObjectId,
                                             (SELECT Actor.Name, ProcessNode.Name FROM StepsAndWorkitems ORDER BY ProcessNode.Name) 
                                             FROM ProcessInstance WHERE TargetObjectId =: recordId AND Status = 'Approved' ORDER BY CreatedDate DESC LIMIT 1];
        Maps = new Map<String,String>();        
        
        if(processList.size() > 0){
            for(Sobject s : processList[0].StepsAndWorkitems){
                if(s.getSobject('ProcessNode') == null && s.getSobject('Actor') != null){
                    Maps.put('step0', String.valueOf(s.getSobject('Actor').get('Name')));
                    System.debug('step0 Maps1111:::' + Maps);
                }else{
                    if(s.getSobject('ProcessNode') != null && s.getSobject('Actor') != null){
                        Maps.put(String.valueOf(s.getSobject('ProcessNode').get('Name')), String.valueOf(s.getSobject('Actor').get('Name')));
                        System.debug('Maps1111:::' + Maps);
                    }
                }
                system.debug(Maps.get('Step0'));
            }
            System.debug('Maps:::' + Maps);
        }
    }
}