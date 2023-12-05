/**
 * Desc : ProjectGanttChartController_TEST
 *
 * @Method : 
 *   - myUnitTest() : test 실행
 *
 * @Author : Yong-Jin, Cha
 * @Date : 2019. 02. 25.
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description 
 *  ---------------------------------------------
 *  1. | 2019-02-25 | Yong-Jin, Cha | 최초작성
 */
@isTest
public class ProjectGanttChartController_TEST {

    public static PM_Phase__c phase;
    public static PM_Activity__c activity;
    public static PM_Task__c tasks;
    public static PM_Sub_Task__c subTask;
    
    static {
        phase = new PM_Phase__c(Name = 'Test Phase Name', IsActive__c = true);
        insert phase;
        
        activity = new PM_Activity__c(Name = 'Test Activity Name', IsActive__c = true, PhaseId__c = phase.Id);
        insert activity;
        
        tasks = new PM_Task__c(Name = 'Test Task Name', IsActive__c = true, ActivityId__c = activity.Id);
        insert tasks;
        
        subTask = new PM_Sub_Task__c(Name = 'Test Sub_Task Name', IsActive__c = true, TaskId__c = tasks.Id);
        insert subTask;
    }
    
    static testmethod void myUnitTest()
    {
        Test.startTest();
        
        Integer viewLevel = 1;
        String p_managerName = '';
            
        ProjectGanttChartController.GanttItemList(viewLevel, p_managerName);

        ProjectGanttChartController.WrapGanttChart wgc = new ProjectGanttChartController.WrapGanttChart();
        
        Test.stopTest();
    }
}