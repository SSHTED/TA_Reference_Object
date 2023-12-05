global class PMS_ProfileViewController {

    @RemoteAction
    global static Map<String, Object> getList(String recordId) {
        Map<String, Object> resultMap = new Map<String, Object>();
        
        ResourceWrap resource = new ResourceWrap();
        
        PMS_PjtResource__c pr = getPjtResource(recordId);
        PMS_LastEduBackground__c edu = getLastEduBackground(recordId);
        
        resource.CertificateName = getCertificate(recordId);
        
        resource.ResourceName = pr.FM_Name__c;
        resource.ResourceRank = pr.FM_Rank__c;
        resource.CompanyName = pr.ResourceType__c == '직원 ' ? pr.FM_OrgName__c : 'DK BMC';
        resource.Age = pr.FM_ManAge__c;
        resource.WorkTerm = pr.FM_CompanyPeriod__c;
        resource.ItCareer = pr.FM_ItCareer__c;
        resource.SfCareer = pr.FM_SfCareer__c;
        
        if(edu != null) {
			resource.SchoolName = edu.SchoolName__c;
        	resource.DegreeType = edu.DegreeType__c;
        	resource.MajorName = edu.MajorName__c;
        }        
        
        List<CareerWrap> CareerList = new List<CareerWrap>();
        
        List<PMS_PjtManpower__c> pmList = getPjtManpower(recordId);        
        List<PMS_PjtCareer__c> pcList = getPjtCareer(recordId);        
        
        for(PMS_PjtManpower__c pm : pmList) {
            CareerList.add(new CareerWrap(pm));
        }
        
        for(PMS_PjtCareer__c pc : pcList) {
            CareerList.add(new CareerWrap(pc));
        }
        
        List<CareerGroupWrap> CareerGroupList = new List<CareerGroupWrap>();
        
        Integer idx = 0;
        List<CareerWrap> newCareerList = new List<CareerWrap>();
        
        for(CareerWrap c : CareerList) {
            
            if(idx == 6) {
                CareerGroupWrap cg = new CareerGroupWrap(newCareerList);
           		CareerGroupList.add(cg);
                newCareerList = new List<CareerWrap>();
            } else if(math.mod(idx - 6, 9) == 0) {
                CareerGroupWrap cg = new CareerGroupWrap(newCareerList);
           		CareerGroupList.add(cg);
                newCareerList = new List<CareerWrap>();
            }
            newCareerList.add(c);            
            idx++;
        }
        
        if(newCareerList.size() > 0) {
            CareerGroupWrap cg = new CareerGroupWrap(newCareerList);
           	CareerGroupList.add(cg);
        } else {
            newCareerList = new List<CareerWrap>(); 
            for(Integer i = 0; i < 6; i++) {
            	newCareerList.add(new CareerWrap());
            }
            CareerGroupWrap cg = new CareerGroupWrap(newCareerList);
           	CareerGroupList.add(cg);
        }
        
        resource.CareerGroupList = CareerGroupList;
     
        resultMap.put('resource', resource);
        
        return resultMap;
    }
    
    private static PMS_PjtResource__c getPjtResource(String recordId) {
        return [
            select 
                Id
                , FM_Name__c
                , FM_Rank__c
                , FM_OrgName__c
                , ResourceType__c
            	, FM_ManAge__c
            	, FM_CompanyPeriod__c
            	, FM_ItCareer__c
            	, FM_SfCareer__c
            from
                PMS_PjtResource__c
            where
            	Id = :recordId
			limit 1
        ];
    }
    
    private static PMS_LastEduBackground__c getLastEduBackground(String recordId) {
        
        List<PMS_LastEduBackground__c> li = [
            select 
                Id
                , SchoolName__c 
                , DegreeType__c 
                , MajorName__c
                , LastEduCheck__c
            from
                PMS_LastEduBackground__c
            where
            	PjtResourceId__c = :recordId
                AND 
                LastEduCheck__c = TRUE
            order by 
            	EduType__c
			limit 1
        ];
        
        if(li.size() == 1) {
            return li.get(0);
        }
        
        return null;
    }
    
    private static String getCertificate(String recordId) {
        
        String certNames = '';
        
        List<PMS_Certificate__c> li = [
            select 
                Id
                , CertificateName__c 
            from
                PMS_Certificate__c
            where
            	PjtResourceId__c = :recordId
            and HoldPlanType__c = '보유'
            order by 
            	CertificateName__c
        ];
        
        if(li.size() > 0) {
            Integer i = 0;
            for(PMS_Certificate__c c : li) {
                if(i > 0)	certNames += ', ';
                certNames += c.CertificateName__c;
                i++;
            }
        }        
        
        return certNames;
    }
    
    private static List<PMS_PjtCareer__c> getPjtCareer(String recordId) {
        return [
            select 
                Agency__c
                , AppliedProduct_Solution__c
                , BusinessType__c
                , Buyer__c
                , ChargeTask__c
                , EmployeeId__c
                , FM_InputPeriod_Days__c
                , FM_InputPeriod_Months__c
                , Id
                , InputEndDate__c
                , InputStartDate__c
                , JoinDate__c
                , JoinProjectInfo__c
                , JoinProjectName__c
                , Name
                , PjtPartnerEmpId__c
                , PjtResourceId__c
                , RoleType__c
            from
                PMS_PjtCareer__c
            where
            	PjtResourceId__c = :recordId
            order by
            	InputStartDate__c desc
        ];
    }
    
    private static List<PMS_PjtManpower__c> getPjtManpower(String recordId) {
        return [
            select 
                Id
                , InputStartDate__c
                , InputEndDate__c
                , ContractPlanEndDate__c
                , Role__c 
            	, MainWork__c
                , ProjectId__r.EndCustomer__r.Name
                , ProjectId__r.Name
                , ProjectId__r.ProjectOutline__c                
            from
                PMS_PjtManpower__c
            where
            	PjtResourceId__c = :recordId
                AND ProjectId__r.ProjectType__c != 'Proposal' 
            order by
            	InputStartDate__c desc
            limit 18
        ];
    }
    
    global class ResourceWrap {
        global String ResourceName  {set;get;} 	// 성명
        global String ResourceRank  {set;get;} 	// 직위
        global String SchoolName {set;get;} 	// 최종학교
        global String DegreeType {set;get;} 	// 학위
        global String MajorName {set;get;} 		// 전공
        global Decimal Age {set;get;} 			// 연령
        global String ItCareer {set;get;} 		// 해당분야 경력
        global String SfCareer {set;get;} 		// Salesforce 경력
        global String CompanyName {set;get;} 	// 현 직장명
        global String WorkTerm {set;get;} 		// 현 직장 재직 기간
        global String CertificateName {set;get;}// 자격증
        
        global List<CareerGroupWrap> CareerGroupList {set;get;}
    }
    
    global class CareerGroupWrap {
        global List<CareerWrap> CareerList {set;get;}
        
        global CareerGroupWrap(List<CareerWrap> CareerList) {
            this.CareerList = CareerList;
        }
    }
    
    global class CareerWrap {
        global String ProjectName  {set;get;} 	// 사업명
        global String ProjectInfo  {set;get;} 	// 사업개요
        global Date InputStartDate {set;get;} 	// 참여기간(시작)
        global Date InputEndDate {set;get;} 	// 참여기간(종료)
        global String RoleType {set;get;} 		// 역할
        global String ChargeTask {set;get;} 	// 담당업무
        global String Buyer {set;get;} 			// 발주처
        
        global CareerWrap() {}
        
        global CareerWrap(PMS_PjtCareer__c pc) {
            ProjectName = pc.JoinProjectName__c;
            ProjectInfo = pc.JoinProjectInfo__c;
            InputStartDate = pc.InputStartDate__c;
            InputEndDate = pc.InputEndDate__c;
            RoleType = pc.RoleType__c;
            ChargeTask = pc.ChargeTask__c;
            Buyer = pc.Buyer__c;
        }

        global CareerWrap(PMS_PjtManpower__c pmp) {
            ProjectName = pmp.ProjectId__r.Name;
            ProjectInfo = pmp.ProjectId__r.ProjectOutline__c;
            InputStartDate = pmp.InputStartDate__c;
            InputEndDate = pmp.InputEndDate__c == null ? pmp.ContractPlanEndDate__c : pmp.InputEndDate__c;
            RoleType = pmp.Role__c;
            ChargeTask = pmp.MainWork__c;
            Buyer = pmp.ProjectId__r.EndCustomer__r.Name;
        }
    }
}