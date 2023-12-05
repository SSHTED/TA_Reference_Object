/**
* Desc : ProjectGanttChartController
*
* @Method : 
*         @RemoteAction GanttItemList(recordId)
*
* @Author : Yong-Jin, Cha
* @Date : 2018. 11. 12.
* @Version : 1.0
* @Modified : 
*  ---------------------------------------------
*  NO | Date       | Modifier      | Description 
*  ---------------------------------------------
*  1. | 2018-11-12 | Yong-Jin, Cha | 최초작성
*  2. | 2018-11-16 | Yong-Jin, Cha | 담당자 검색 기능 추가
*/
public class ProjectGanttChartController
{
    @RemoteAction
    public static List<WrapGanttChart> GanttItemList(Integer viewLevel, String p_managerName) {
        
        List<WrapGanttChart> GanttItemList = new List<WrapGanttChart>();
        
        List<PM_Phase__c> pList = [
            select
            	Id
            	, Name
            	, AchieveRate__c
            	, StartDate__c
            	, EndDate__c
            	, ActivityCount__c
            	, PhaseNo__c
            	, WBSName__c
            from
            	PM_Phase__c 
            where
            	IsActive__c = true
            order by
            	DisplayOrder__c
        ];
        
        List<PM_Activity__c> aList = [
            select
            	Id
            	, Name
            	, AchieveRate__c
            	, StartDate__c
            	, EndDate__c
            	, TaskCount__c
            	, ActivityNo__c
            	, PhaseId__c
            	, PhaseId__r.PhaseNo__c
            	, DependActivityId__r.ActivityNo__c
            	, WBSName__c
            	, InputStartDate__c
            	, InputEndDate__c
            from
            	PM_Activity__c 
            where
            	IsActive__c = true
            order by
            	DisplayOrder__c
        ];
        
        List<PM_Task__c> tList = [
            select
            	Id
            	, Name
            	, AchieveRate__c
            	, StartDate__c
            	, EndDate__c
            	, SubTaskCount__c
            	, TaskNo__c
            	, ActivityId__c
            	, ActivityId__r.ActivityNo__c
            	, DependTaskId__r.TaskNo__c
            	, WBSName__c
            	, InputStartDate__c
            	, InputEndDate__c
            from
            	PM_Task__c 
            where
            	IsActive__c = true
            order by
            	DisplayOrder__c
        ];
        
        List<PM_Sub_Task__c> sList = [
            select
            	Id
            	, Name
            	, AchieveRate__c
            	, StartDate__c
            	, EndDate__c
            	, Manager__c
            	, Note__c
            	, SubTaskNo__c
            	, TaskId__c
            	, TaskId__r.TaskNo__c
            	, DependSubTask__r.SubTaskNo__c
            	, WBSName__c
            from
            	PM_Sub_Task__c 
            where
            	IsActive__c = true
            order by
            	DisplayOrder__c
        ];
        
        /*
        	pID, pName, pStart, pEnd
            , pStyle, pLink (unused), pMile, pRes
            , pComp, pGroup, pParent, pOpen
            , pDepend, pCaption, pNotes, pGantt
        */
        Integer P_Id = 1;
        Integer A_Id = 100;
        Integer T_Id = 10000;
        Integer S_Id = 1000000;

        for(PM_Phase__c p : pList) {
            GanttItemList.add(new WrapGanttChart(P_Id, p.WBSName__c, p.StartDate__c, p.EndDate__c
                                                 , 'ggroupblack', '/' + p.Id, '0', ''
                                                 , String.valueOf(p.AchieveRate__c), p.ActivityCount__c > 0 ? '1' : '0', '', viewLevel >= 1 ? '1' : '0'
                                                 , '', 'Phase', ''));

            for(PM_Activity__c a : aList) {

                if(p.Id == a.PhaseId__c) {
                    GanttItemList.add(new WrapGanttChart(A_Id, a.WBSName__c
                                                         , a.InputStartDate__c == null ? a.StartDate__c : a.InputStartDate__c
                                                         , a.InputEndDate__c == null ? a.EndDate__c : a.InputEndDate__c
                                                         , 'gtaskblue', '/' + a.Id, '0', ''
                                                         , String.valueOf(a.AchieveRate__c), a.TaskCount__c > 0 ? '1' : '0', P_Id, viewLevel >= 2 ? '1' : '0'
                                                         , a.DependActivityId__r.ActivityNo__c, 'Activity', ''));
                    
                    for(PM_Task__c t : tList) {

                        if(a.Id == t.ActivityId__c) {
                            GanttItemList.add(new WrapGanttChart(T_Id, t.WBSName__c
                                                                 , t.InputStartDate__c == null ? t.StartDate__c : t.InputStartDate__c
                                                                 , t.InputEndDate__c == null ? t.EndDate__c : t.InputEndDate__c
                                                                 , 'gtaskpurple', '/' + t.Id, '0', ''
                                                                 , String.valueOf(t.AchieveRate__c), t.SubTaskCount__c > 0 ? '1' : '0', A_Id, viewLevel >= 3 ? '1' : '0'
                                                                 , t.DependTaskId__r.TaskNo__c, 'Task', ''));
                            for(PM_Sub_Task__c s : sList) {
                                if(t.Id == s.TaskId__c) {
                                    // 담당자 입력이 있을 경우 그 담당자 Sub Task 만 검색
                                    if((s.Manager__c == null ? '' : s.Manager__c).indexOf(p_managerName) > -1) {
                                        GanttItemList.add(new WrapGanttChart(S_Id, s.WBSName__c, s.StartDate__c, s.EndDate__c
                                                                 , 'gtaskyellow', '/' + s.Id, '0', s.Manager__c
                                                                 , String.valueOf(s.AchieveRate__c), '0', T_Id, '1'
                                                                 , s.DependSubTask__r.SubTaskNo__c, 'SubTask', s.Note__c));
                                    }
                                    S_Id++;
                                }
                            }
                            T_Id++;
                        }
                    }
                    A_Id++;
                }
            }
            P_Id++;
        }
        /*
        for(PM_Phase__c p : pList) {
            GanttItemList.add(new WrapGanttChart(p.PhaseNo__c, p.WBSName__c, p.StartDate__c, p.EndDate__c
                                                 , 'ggroupblack', '/' + p.Id, '0', ''
                                                 , String.valueOf(p.AchieveRate__c), p.ActivityCount__c > 0 ? '1' : '0', '', viewLevel >= 1 ? '1' : '0'
                                                 , '', 'Phase', ''));

            for(PM_Activity__c a : aList) {

                if(p.Id == a.PhaseId__c) {
                    GanttItemList.add(new WrapGanttChart(a.ActivityNo__c, a.WBSName__c
                                                         , a.InputStartDate__c == null ? a.StartDate__c : a.InputStartDate__c
                                                         , a.InputEndDate__c == null ? a.EndDate__c : a.InputEndDate__c
                                                         , 'gtaskblue', '/' + a.Id, '0', ''
                                                         , String.valueOf(a.AchieveRate__c), a.TaskCount__c > 0 ? '1' : '0', a.PhaseId__r.PhaseNo__c, viewLevel >= 2 ? '1' : '0'
                                                         , a.DependActivityId__r.ActivityNo__c, 'Activity', ''));
                    
                    for(PM_Task__c t : tList) {

                        if(a.Id == t.ActivityId__c) {
                            GanttItemList.add(new WrapGanttChart(t.TaskNo__c, t.WBSName__c
                                                                 , t.InputStartDate__c == null ? t.StartDate__c : t.InputStartDate__c
                                                                 , t.InputEndDate__c == null ? t.EndDate__c : t.InputEndDate__c
                                                                 , 'gtaskpurple', '/' + t.Id, '0', ''
                                                                 , String.valueOf(t.AchieveRate__c), t.SubTaskCount__c > 0 ? '1' : '0', t.ActivityId__r.ActivityNo__c, viewLevel >= 3 ? '1' : '0'
                                                                 , t.DependTaskId__r.TaskNo__c, 'Task', ''));
                            for(PM_Sub_Task__c s : sList) {
                                if(t.Id == s.TaskId__c) {
                                    // 담당자 입력이 있을 경우 그 담당자 Sub Task 만 검색
                                    if((s.Manager__c == null ? '' : s.Manager__c).indexOf(p_managerName) > -1) {
                                        GanttItemList.add(new WrapGanttChart(s.SubTaskNo__c, s.WBSName__c, s.StartDate__c, s.EndDate__c
                                                                 , 'gtaskyellow', '/' + s.Id, '0', s.Manager__c
                                                                 , String.valueOf(s.AchieveRate__c), '0', s.TaskId__r.TaskNo__c, '1'
                                                                 , s.DependSubTask__r.SubTaskNo__c, 'SubTask', s.Note__c));
                                    }
                                }
                            }
                        }
                    }
                }
            }

        }
        */

		system.debug(GanttItemList);        
        return GanttItemList;
    }
    
    public class WrapGanttChart {

        public String pID {get; set;}
        public String pName {get; set;}
        public String pStart {get; set;}
        public String pEnd {get; set;}
        public String pClass {get; set;}
        public String pLink {get; set;}
        public String pMile {get; set;}
        public String pRes {get; set;}
        public String pComp {get; set;}
        public String pGroup {get; set;}
        public String pParent {get; set;}
        public String pOpen {get; set;}
        public String pDepend {get; set;}
        public String pCaption {get; set;}
        public String pNotes {get; set;}

        public WrapGanttChart() {

        }

        public WrapGanttChart(Object vID, String vName, Date vStart, Date vEnd
                                   , String vClass, String vLink, String vMile, String vRes
                                   , String vComp, String vGroup, Object vParent, String vOpen
                                   , String vDepend, String vCaption, String vNotes){

            Time vTime = Time.newInstance(3, 3, 3, 0);

            this.pID   		= vID == null ? '' : String.valueOf(vID);
            this.pName      = vName;
            
            this.pStart     = vStart == null ? DateTime.now().format('yyyy-MM-dd') : DateTime.newInstance(vStart, vTime).format('yyyy-MM-dd');
            this.pEnd       = vEnd == null ? DateTime.now().format('yyyy-MM-dd') : DateTime.newInstance(vEnd, vTime).format('yyyy-MM-dd');

            this.pClass     = vClass;
            this.pLink    	= vLink;
            this.pMile    	= vMile;
            this.pRes    	= vRes == null ? '' : vRes;

            this.pComp    	= vComp == null ? '1' : vComp;
            this.pGroup    	= vGroup;
            this.pParent    = vParent == null ? '' : String.valueOf(vParent);
            this.pOpen    	= vOpen;

            this.pDepend    = vDepend;
            this.pCaption   = vCaption;
            this.pNotes    	= vNotes;
        }
    }
}