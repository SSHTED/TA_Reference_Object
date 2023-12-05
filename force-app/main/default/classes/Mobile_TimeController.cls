public class Mobile_TimeController {

    //task 리턴 클래스 객체
    public class DataItem{
        public String projectName	{get;set;}
        public String mileStoneName	{get;set;}
        public String taskName		{get;set;}
        public String taskTime				{get;set;}
        public String description 	  {get;set;}
    }
    
    //display date
    public String dueDate  {get;set;}
    
    public Mobile_TimeController(){
        //시간계산
        Date systemDate =  system.today();
        String dateYear = String.valueOf(systemDate.year());
        String dateMonth = String.valueOf(systemDate.month()).length() == 1 ? '0'+String.valueOf(systemDate.month()) : String.valueOf(systemDate.month());
        String dateDay = String.valueOf(systemDate.day()).length() == 1 ? '0'+String.valueOf(systemDate.day()) : String.valueOf(systemDate.day());
        dueDate = dateYear +'-'+ dateMonth +'-'+ dateDay;
        //시간계산 끝
    }
    
    /**
     * 조회 함수
     * param : string date (yyyy-mm-dd)
     * return List<DataItem>
     */
    @RemoteAction
    public static List<Map<String,String>> getDataItem(String dueDate){
        User activeUser = [select id, name, employeenumber from user where id =: UserInfo.getUserId() Limit 1];
        system.debug('dueDate' + dueDate);
        
        List<Map<String,String>> userTimeList = new List<Map<String,String>>();
        Map<String,String> userTimeMap;
        List<Milestone1_Milestone__c> mileStoneList = new List<Milestone1_Milestone__c>();
        List<Milestone1_Task__c> taskList = new List<Milestone1_Task__c>();
        List<Milestone1_Time__c> timeInfo = new List<Milestone1_Time__c>();
      
        //로그인 한 사용자가 투입된 프로젝트 조회
        List<Milestone1_Project__c> projectList = [SELECT Name,id,Deadline__c FROM Milestone1_Project__c where id in (SELECT Project__c FROM Project_Assigned_Period__c where employee__r.Emp_No__c = :activeUser.EmployeeNumber and Project__c !=:system.label.DKBMC_ADMIN_TIME)  and Kickoff__c <= :Date.valueOf(dueDate) and (Deadline__c >= :Date.valueOf(dueDate) or Deadline__c = null)];
        Milestone1_Project__c[] dkbmcAdminProject = [SELECT Name,id,DeadLine__c FROM Milestone1_Project__c where id =:system.label.DKBMC_ADMIN_TIME];
         
        if(dkbmcAdminProject.size() >0){
            projectList.add(dkbmcAdminProject[0]);
        }
        
        system.debug('projectList : '+projectList);   
        
               
        for(Milestone1_Project__c project : projectList){
            // milestone 조회 
            mileStoneList = [SELECT Id,Name,Project__c FROM Milestone1_Milestone__c WHERE Project__c = :project.id and (Deadline__c >= :Date.valueOf(dueDate) or Deadline__c = null) and (Kickoff__c <= :Date.valueOf(dueDate) or Kickoff__c = null)];
            system.debug('#mileStoneList : '+mileStoneList);
            for(Milestone1_Milestone__c mileStone :mileStoneList ){
                //task 조회
                taskList = [SELECT Id,Name,LookupProject__c,Project_Milestone__c FROM Milestone1_Task__c WHERE LookupProject__c =:project.id and Project_Milestone__c = :mileStone.id and (Due_Date__c >= :Date.valueOf(dueDate) or Due_Date__c = null) and (Start_Date__c <= :Date.valueOf(dueDate) ) ];
            	system.debug('#taskList : '+taskList);
                for(Milestone1_Task__c task : taskList){
                    //userTimeMap 초기화
                    userTimeMap = new Map<String,String>();   

                    //time,description 조회
                    timeInfo = [SELECT Id,Project_Task__c,Description__c,Hours__c FROM Milestone1_Time__c WHERE Project_Task__c =:task.id and Date__c =: Date.valueOf(dueDate) and Incurred_By__c =:activeUser.id ];
                    system.debug('timeInfo : '+timeInfo);
                    if(timeInfo.size()>0){
                        for(Milestone1_Time__c times : timeInfo){
                            //userTimeMap 초기화
                    		userTimeMap = new Map<String,String>();   
                            //time data exist
                            userTimeMap.put('project',project.Name);
                        	userTimeMap.put('mileStone',mileStone.Name);
                        	userTimeMap.put('task',task.Name);
                            userTimeMap.put('projectId',project.Id);
                        	userTimeMap.put('taskId',task.Id);
                            userTimeMap.put('timeId',times.Id);
                            userTimeMap.put('description',times.Description__c);
                            if(String.valueOf(times.Hours__c) == null){
                                userTimeMap.put('hours','0');  
                            }else{
                                userTimeMap.put('hours',String.valueOf(times.Hours__c));  
                            }
                            userTimeList.add(userTimeMap);
                        }
                    } else{
                        userTimeMap.put('project',project.Name);
                        userTimeMap.put('mileStone',mileStone.Name);
                        userTimeMap.put('task',task.Name);
                        userTimeMap.put('taskId',task.Id);
                        userTimeMap.put('timeId','');
                        userTimeMap.put('description','');
                        userTimeMap.put('hours','0');
                        userTimeList.add(userTimeMap);
                    }
                }   
            }
        }
        
        return userTimeList;
    }
    
    @RemoteAction
    public static void insertDailyTask(List<String> dataList){
		system.debug('dataList : '+dataList);
		Map<String, Object> dataMap = new Map<String,Object>();
        List<Milestone1_Time__c> newTimeList = new List<Milestone1_Time__c>();
        List<Milestone1_Time__c> updateTimeList = new List<Milestone1_Time__c>();

        for (String data : dataList) {
            // convert json to map
            dataMap = (Map<String, Object>) JSON.deserializeUntyped(data);
                   
            //data setting
            String timeId = (String)dataMap.get('timeId');
            String taskId = (String)dataMap.get('taskId');
            String dueDate = (String)dataMap.get('dueDate');
            Integer hours = Integer.valueOf(dataMap.get('hours'));
           
            //time 정보가 있으면 update, 없으면 insert
            if(timeId != '' ){
                Milestone1_Time__c timeInfo = [select Id,Project_Task__c,Description__c,Hours__c FROM Milestone1_Time__c where Id =:timeId];
                system.debug('timeInfo :'+timeInfo);
                timeInfo.Description__c = (String)dataMap.get('description');
                timeInfo.Hours__c = hours;
                updateTimeList.add(timeInfo);
                system.debug('timeInfo :'+timeInfo);
            } else{
                Milestone1_Time__c newTime = new Milestone1_Time__c(Project_Task__c=taskId, Description__c=(String)dataMap.get('description'), Hours__c= hours, Date__c =Date.valueOf(dueDate));
                newTimeList.add(newTime);
                
                System.debug('newTime : '+newTime);
            } 
        }
        
         if(updateTimeList.size() >0){
            update updateTimeList;
            system.debug('update success!! '+updateTimeList);
        }
        
        if(newTimeList.size() >0){
            insert newTimeList;
            system.debug('success!! '+newTimeList);
        }

    }    
}