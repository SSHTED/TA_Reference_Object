@isTest
private class TEST_MilestonTaskTrigger{


    static testMethod void myTest() {
    
    
    Profile profileUsed;
        
    String ret = 'word' + math.rint(math.random() * 100000);
    for( Profile p : [ Select Id, PermissionsModifyAllData, Name from Profile limit 100 ] ){
         if( p.PermissionsModifyAllData ){
             profileUsed = p;
         }
    }
    Profile p = [SELECT id FROM Profile WHERE id = '00e28000000MeMfAAK' LIMIT 1];
    String namePrefix = ret;

     User testUser = new User();
     testUser.Email = 'test@test.com';
     testUser.Username = ret + '@testuser.com';
     testUser.LastName = 'test';
     testUser.Alias = 'test';
     testUser.ProfileId = p.id;
     testUser.LanguageLocaleKey = 'en_US';
     testUser.LocaleSidKey = 'en_US';
     testUser.TimeZoneSidKey = 'America/Chicago';
     testUser.EmailEncodingKey = 'UTF-8';
     testUser.employeenumber = '100001';
    
     insert testUser;      

    System.runAs(testUser)
    {
        test.startTest();
        
        // Create a project
        Milestone1_Project__c proj = new Milestone1_Project__c();
        proj.Name = 'test project';
        proj.Kickoff__c =  Date.newInstance(2016,1,1);
        proj.Deadline__c =  Date.newInstance(2016,1,1);
        proj.RecordTypeId = '0120I0000011JKJ';
        insert proj;
        
        // Create a milestone
        Milestone1_Milestone__c mstone= new Milestone1_Milestone__c();
        mstone.Name = proj.Name + '' + Datetime.now().getTime();
        mstone.Project__c = proj.id;
        mstone.Complete__c = false; //getRandomBool(.25);
        mstone.Kickoff__c = proj.Kickoff__c;
        mstone.Deadline__c = proj.Deadline__c;
        mstone.Description__c = 'Description for ' + proj.Name;
        mstone.Expense_Budget__c = Math.floor(Math.random() * 50000 * 100) / 100;
        mstone.Hours_Budget__c = Math.floor(Math.random() * 500 * 100) / 100;
        insert mstone;
        
        Milestone1_Task__c task = new Milestone1_Task__c();
        task.Project_Milestone__c = mstone.Id;
        task.Assigned_To__c = UserInfo.getUserId();
        task.Name = 'MS ' + mstone.Id+ ' task ' + Datetime.now().getTime();
        task.Complete__c = false; //getRandomBool(.25);
        task.Description__c   = 'test description ' + task.Name;
        task.Start_Date__c   = Date.newInstance(2016,1,1);
        task.Due_Date__c   = Date.newInstance(2016,1,1);
        task.Estimated_Expense__c = 100.00;
        task.Estimated_Hours__c = 110.00;
        task.Priority__c = '0';
        task.Task_Stage__c = 'None';
        task.Class__c = 'Ad Hoc';
        task.Blocked__c = false;      
        insert task;
        
        Milestone1_Task__c toUpdateTask = [SELECT Id FROM Milestone1_Task__c WHERE Id = :task.Id][0];
        update toUpdateTask;
        delete toUpdateTask;
        
        test.stopTest();
    }

  }
}