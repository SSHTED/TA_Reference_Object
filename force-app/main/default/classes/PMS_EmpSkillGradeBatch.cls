/*
 * @Class : PMS_EmpSkillGradeBatch
 *
 * @Method : 

 *  - start(BC)
 *  - execute(BC, scope)
 *  - finish(BC)
 * 
 * @Author : hojae-lee
 * @Date : 2022-12-28
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2022-12-28 | hojae-lee     | 최초작성
 */
global class PMS_EmpSkillGradeBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{

    global String BatchName = 'PMS_EmpSkillGradeBatch';
    global String OrgName = '';
    global String resultLog = '';
    global Integer SuccessCount = 0;
    global Integer FailCount = 0;
    global Integer BatchExecuteCount = 0;
    global Long BatchStartDateTimeLong = 0;
    global Id employeeId = null;
    global String empVal = '';

    global PMS_EmpSkillGradeBatch(){}
    global PMS_EmpSkillGradeBatch(Id empId){ // 230315_이호재 해당 자원만 돌리는 생성자
        if(empId != null){
            this.employeeId = empId;
            this.empVal = ' AND Id = :employeeId ';
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        System.debug('[START] ' + BatchName);

        String SOQL = ' SELECT '
                    + '     Id '
                    + '     , Name '
                    + '     , User__c '
                    + '     , Start__c '
                    + '     , TechGrade__c '
                    + '     , SFGrade__c '
            		+ '     , Status__c '
                    + ' FROM '
                    + '     Employee__c '
                    + ' WHERE '
                    + '     Status__c = \'재직\' '
                  //  + ' AND User__c != null '
                 //   + ' AND User__r.IsActive = true '
                    + empVal
                    + ' ORDER BY '
                    + '     Id ';

        return Database.getQueryLocator(SOQL);
    }

    global void execute(Database.BatchableContext BC, List<Employee__c> scope){
        try{
            List<PMS_PjtResource__c> empResourceList = new List<PMS_PjtResource__c>();

            for(Employee__c c : scope){
                List<PMS_PjtResource__c> isResActiveList = [SELECT IsActive__c FROM PMS_PjtResource__c WHERE EmployeeId__c = :c.Id AND IsActive__c = true LIMIT 1];
                if(isResActiveList.size() > 0 && isResActiveList[0].IsActive__c == true){ // 자원 활성여부 확인 조건 추가 230313
                    // System.debug('resource Active ?? ' + c.PjtResource__r[0].IsActive__c);
                    Set<Date> DateSet = new Set<Date>();
                    Set<Date> pmDateSet = new Set<Date>();
                    Set<Date> RestDateSet = new Set<Date>();
                    String resourceId = null;
                    
                    System.debug('직원(협력사) 이름은 ? ' + c.Name);
                    List<PMS_PjtResource__c> pjtResList = [SELECT Id, Name, EmpBeforeSfCareer__c, EmpBeforeCareer__c, PartnerBeforeCareer__c, PartnerBeforeSfCareer__c, EmployeeId__r.start__c, EmployeeId__r.Status__c , EmployeeId__r.Leave__c ,EmployeeId__r.rehabilitation__c 
                                                           FROM PMS_PjtResource__c
                                                           WHERE EmployeeId__c = :c.Id
                                                           AND IsActive__c = true
                                                           LIMIT 1];
                    if(pjtResList.size() > 0){ // 230410 현 직장 기간 및 resourceId
                        Date plusDaysDate = null;
						Date minusDaysDate = null;
                        for(PMS_PjtResource__c res : pjtResList){
                            resourceId = res.Id;
                            if(res.EmployeeId__r.start__c != null){
                                plusDaysDate = res.EmployeeId__r.start__c;
                                minusDaysDate = res.EmployeeId__r.Leave__c;
                            }
                        }
                        if(plusDaysDate != null){
                            Integer dkPeriod = plusDaysDate.daysBetween(System.today());
                            for(Integer i = 0; i < dkPeriod; i++){
                                Date results = plusDaysDate.addDays(i);

                                pmDateSet.add(results);
                                DateSet.add(results);
                            }
                        }
                        if(minusDaysDate != null){
                            Integer dkPeriod = minusDaysDate.daysBetween(pjtResList[0].EmployeeId__r.rehabilitation__c);
                            for(Integer i = 0; i < dkPeriod; i++){
                                Date results = minusDaysDate.addDays(i);

                                RestDateSet.add(results);
                           
                            }
                        }
                        System.debug('RestDateSet '+RestDateSet);
                    }

                    // 230404_이호재 전 직장 근무경력 기간으로 변경
                    List<PMS_BeforeCompanyCareer__c> bccDateList = [SELECT Id, Start__c, FM_CompanyPeriodDays__c
                                                                    FROM PMS_BeforeCompanyCareer__c
                                                                    WHERE CompanyType__c = 'IT' AND PjtResourceId__c = :resourceId];
                    if(bccDateList.size() > 0){
                        for(PMS_BeforeCompanyCareer__c bcc : bccDateList){
                            for(Integer i = 0; i < bcc.FM_CompanyPeriodDays__c; i++){
                                // System.debug('i ? ' + i);
                                Date plusDaysDate = bcc.Start__c; // 전 직장 경력 레코드 시작일은 필수로 있을 예정
                                Date results = plusDaysDate.addDays(i);

                                DateSet.add(results);
                            }
                        }
                    }
                    System.debug('현 직장 pmDateSet ? ' + pmDateSet.size());
                    System.debug('DKBMC DateSet 2 ? ' + DateSet);
                    System.debug('DKBMC DateSet 2 size ? ' + DateSet.size()); // 중복제거한 경력일수(프로젝트 투입인력 + 프로젝트 경력(전))

                    String allCareerSumYear = null;

                    System.debug('경력년수(정수) ? ' + Decimal.valueOf(DateSet.size() / 365).intValue());

                    if(DateSet != null){
                        allCareerSumYear = '%,' + String.valueOf(Decimal.valueOf(DateSet.size() / 365).intValue()) + ',%';
                        if(Decimal.valueOf(DateSet.size() / 365).intValue() == 0){
                            allCareerSumYear = '%,1,%';
                        }
                        if(Decimal.valueOf(DateSet.size() / 365).intValue() >= 20){
                            allCareerSumYear = '%,20,%';
                        }
                    }
                    System.debug('allCareerSumYear ? ' + allCareerSumYear);

                    // 학력 추출
                    List<PMS_LastEduBackground__c> edList = [SELECT Id, DegreeType__c
                                                             FROM PMS_LastEduBackground__c
                                                             WHERE (GraduationType__c = '졸업' OR GraduationType__c = '수료' OR GraduationType__c = '졸업예정') // 230407_이호재 졸업예정 추가
                                                             AND PjtResourceId__c = :resourceId
                                                             LIMIT 1];
                    System.debug('edList ? ' + edList);
                    String eduDegree = null;

                    if(edList.size() > 0){
                        for(PMS_LastEduBackground__c ed : edList){
                            System.debug('졸업인 학력 ? ' + ed.DegreeType__c); // 고졸, 전문학사, 학사, 석사, 박사
                            eduDegree = ed.DegreeType__c;
                        }
                    }
                    System.debug('eduDegree 1 ? ' + eduDegree);

                    // 기술등급 산정
                    String skillGradeAcd = null;

                    // 학력기준과 경력년수로 메타데이타 테이블에서 가져오기
                    List<MT_Skill_Grade__mdt> mdtList = [SELECT Label FROM MT_Skill_Grade__mdt
                                                         WHERE CarrerYear__c LIKE :allCareerSumYear AND DegreeType__c = :eduDegree LIMIT 1];
                    if(mdtList.size() > 0) skillGradeAcd = mdtList.get(0).Label;

                    System.debug('skillGradeAcd 1 ? ' + skillGradeAcd);
                    
                    // 자격증 기준
                    String skillGradeCrt = null;
                    String crtName = null;
                    Boolean yesSkill = false;

                    List<PMS_Certificate__c> cfList = [SELECT Id, CertificateName__c, CertificateType__c, ExpirationDate__c
                                                       FROM PMS_Certificate__c
                                                       WHERE HoldPlanType__c = '보유'
                                                       AND PjtResourceId__c = :resourceId
                                                       AND (ExpirationDate__c > TODAY OR ExpirationDate__c = null)
                                                       ORDER BY AcquisitionDate__c ASC];
                    
                    if(cfList.size() > 0){
                        Decimal skRank01 = 0;
                        for(PMS_Certificate__c cf : cfList){
                            System.debug('보유 자격증은 ? ' + cf.CertificateName__c);

                            if(cfList.size() == 1 && cf.CertificateName__c == '정보처리기능사'){
                                System.debug('정보처리기능사인가 ? ' + cf.CertificateName__c);
                                // 학력으로 계산하기
                                // 경력년수 조건
                                System.debug('eduDegree 2 ? ' + eduDegree);
                                
                                if(skRank01 <= [SELECT Rank__c FROM MT_Skill_Grade__mdt WHERE CarrerYear__c LIKE :allCareerSumYear AND DegreeType__c = :eduDegree].Rank__c){
                                    skRank01 = [SELECT Rank__c FROM MT_Skill_Grade__mdt WHERE CarrerYear__c LIKE :allCareerSumYear AND DegreeType__c = :eduDegree].Rank__c;
                                    skillGradeCrt = [SELECT Label FROM MT_Skill_Grade__mdt WHERE CarrerYear__c LIKE :allCareerSumYear AND DegreeType__c = :eduDegree].Label;
                                }

                                System.debug('skillGradeCrt 2 ? ' + skillGradeCrt);
                                // 기술등급 업데이트
                            }

                            if(cf.CertificateName__c == '정보처리산업기사' || cf.CertificateName__c == '사무자동화산업기사'){
                                System.debug('정보처리산업기사인가 ? ' + cf.CertificateType__c);
                                
                                if(skRank01 <= [SELECT Rank__c FROM MT_Skill_Grade__mdt WHERE CarrerYear__c LIKE :allCareerSumYear AND DegreeType__c = '산업기사'].Rank__c){
                                    skRank01 = [SELECT Rank__c FROM MT_Skill_Grade__mdt WHERE CarrerYear__c LIKE :allCareerSumYear AND DegreeType__c = '산업기사'].Rank__c;
                                    skillGradeCrt = [SELECT Label FROM MT_Skill_Grade__mdt WHERE CarrerYear__c LIKE :allCareerSumYear AND DegreeType__c = '산업기사'].Label; // 230214_이호재 산업기사 메타데이타 레코드 생성
                                }

                                System.debug('skillGradeCrt 3 ? ' + skillGradeCrt);
                                // 기술등급 업데이트
                            }
                            
                            if(cf.CertificateType__c == 'Salesforce' || cf.CertificateType__c == 'Tableau' || cf.CertificateName__c == '정보처리기사' 
                               || cf.CertificateType__c == 'ServiceNow' || cf.CertificateType__c == 'Mulesoft' || cf.CertificateType__c == 'Workato' || cf.CertificateType__c == 'MS power Platform'){ // 전자계산기조작응용기사 및 산업기사는 자격증 목록에 없다.
                                System.debug('SF(민간) 및 정보처리기사인가 ? ' + cf.CertificateType__c);
                                // 기사 등급으로 계산하기, 석사와 같은 기준
                                // 경력년수 조건
                                if(skRank01 <= [SELECT Rank__c FROM MT_Skill_Grade__mdt WHERE CarrerYear__c LIKE :allCareerSumYear AND DegreeType__c = '석사'].Rank__c){
                                    skRank01 = [SELECT Rank__c FROM MT_Skill_Grade__mdt WHERE CarrerYear__c LIKE :allCareerSumYear AND DegreeType__c = '석사'].Rank__c;
                                    skillGradeCrt = [SELECT Label FROM MT_Skill_Grade__mdt WHERE CarrerYear__c LIKE :allCareerSumYear AND DegreeType__c = '석사'].Label;
                                }

                                System.debug('skillGradeCrt 4 ? ' + skillGradeCrt);
                            }

                            if(cf.CertificateName__c == '정보관리기술사'){
                                System.debug('나는 기술사');
                                yesSkill = true;
                            }
                        }
                    }
                    System.debug('skillGradeCrt ? ' + skillGradeCrt);

                    // 학력 등급과, 자격증 등급 비교, 높은 부분 기술등급 업데이트
                    Decimal acdGrade = null;

                    if(skillGradeAcd == null)acdGrade = 0;
                    if(skillGradeAcd != null){
                        acdGrade = [SELECT Rank__c FROM MT_Skill_Grade__mdt WHERE Label = :skillGradeAcd LIMIT 1].Rank__c;
                    }
                    System.debug('acdGrade ? ' + acdGrade);

                    Decimal crtGrade = null;

                    if(skillGradeCrt == null)crtGrade = 0;
                    if(skillGradeCrt != null){
                        crtGrade = [SELECT Rank__c FROM MT_Skill_Grade__mdt WHERE Label = :skillGradeCrt LIMIT 1].Rank__c;
                    }
                    System.debug('crtGrade ? ' + crtGrade);

                    if(yesSkill)c.TechGrade__c = '기술사';
                    String tg = null;
                    if(acdGrade != null && crtGrade != null && !yesSkill){
                        if(acdGrade >= crtGrade){
                            c.TechGrade__c = skillGradeAcd;
                            System.debug('학력 기준 업데이트');
                        }
                        if(crtGrade >= acdGrade){
                            c.TechGrade__c = skillGradeCrt;
                            System.debug('자격증 기준 업데이트');
                        }
                        if(acdGrade == 0 && crtGrade == 0){
                            c.TechGrade__c = null;  // 230313_이호재 기술등급 null, 프로필 없을 시.
                            System.debug('yes 기술등급 null!');
                        }
                        tg = c.TechGrade__c;
                    }

                    // SF등급 산정, SF자격증 유무 확인 후, 경력으로 판단
                    String sfSkillGrade = null;

                    List<PMS_PjtCareer__c> sfDaysList = [SELECT Id, FM_InputPeriod_Days__c, InputStartDate__c
                                                         FROM PMS_PjtCareer__c
                                                         WHERE PjtResourceId__c = :resourceId
                                                         AND (BusinessType__c = 'Salesforce' OR BusinessType__c = 'Tableau')];
                    Set<Date> sfDaysSet = new Set<Date>();
                    if(sfDaysList.size() > 0){
                        for(PMS_PjtCareer__c sd : sfDaysList){ // 전 직장에서는 시작일이 필수로 있을 예정
                            for(Integer i = 0; i < sd.FM_InputPeriod_Days__c; i++){
                                Date plusDaysDate = sd.InputStartDate__c;
                                Date results = plusDaysDate.addDays(i);

                                sfDaysSet.add(results);
                            }
                        }
                    }
                    System.debug('전 직장 sfDaysSet ? ' + sfDaysSet);
                    System.debug('전 직장 sfDaysSet size ? ' + sfDaysSet.size());

                    if(pmDateSet.size() > 0){
                        for(Date d : pmDateSet) sfDaysSet.add(d);
                    }
                    System.debug('총 경력일수 sfDaysSet size ? ' + sfDaysSet.size());
                    
                    if(tg != null){
                        List<PMS_Certificate__c> sfList = [SELECT Id, CertificateType__c, CertificateName__c
                                                           FROM PMS_Certificate__c
                                                           WHERE PjtResourceId__c = :resourceId
                                                           AND (CertificateType__c = 'Salesforce' OR CertificateType__c = 'Tableau')
                                                           AND HoldPlanType__c = '보유'
                                                           AND (ExpirationDate__c > TODAY OR ExpirationDate__c = null)];
                        if(!yesSkill){
                            if(eduDegree != '박사'){ // 230313_이호재 eduDegree != null && 조건 삭제
                                if(sfList.size() > 0){
                                    // SF자격증 보유 시, IT경력(allCareerSumYear)으로 판단, 기사 자격과 동일하게.. (석사 == 기사)
                                    sfSkillGrade = [SELECT Label FROM MT_Skill_Grade__mdt WHERE CarrerYear__c LIKE :allCareerSumYear AND DegreeType__c = '석사'].Label;
                                    c.SFGrade__c = sfSkillGrade;
                                    System.debug('SF등급에서 경력년 수 ? ' + allCareerSumYear);
                                    System.debug('SF자격증 보유시, SF등급은 ? ' + sfSkillGrade);
                                }
                                if(sfList.size() == 0){ // SF자격증 미보유 시, SF경력으로 1년 위 아래 나누기
                                    if(sfDaysSet.size() >= 365){ // SF경력 1년 이상, 석사와 정보처리기사의 메타데이타 값이 같다.
                                        // sfSkillGrade = [SELECT Label FROM MT_Skill_Grade__mdt WHERE CarrerYear__c LIKE :allCareerSumYear AND DegreeType__c = '석사'].Label;
                                        // if(tg != null) 230313_이호재 기술등급 null일 경우 있으므로 조건 삭제
                                        c.SFGrade__c = tg;
                                        System.debug('기술 및 sf 동일');
                                    }
                                    if(sfDaysSet.size() < 365){ // SF경력 1년 미만
                                        // Decimal skillRank = [SELECT Rank__c FROM MT_Skill_Grade__mdt WHERE CarrerYear__c LIKE :allCareerSumYear AND DegreeType__c = '석사'].Rank__c - 1;
                                        Decimal skillRank = [SELECT Rank__c FROM MT_Skill_Grade__mdt WHERE Label = :tg LIMIT 1].Rank__c - 1;
                                        if(skillRank != null && skillRank != 0){
                                            sfSkillGrade = [SELECT Label FROM MT_Skill_Grade__mdt WHERE Rank__c = :skillRank LIMIT 1].Label;
                                        }
                                        if(skillRank != null && skillRank == 0){
                                            skillRank = 1;
                                            sfSkillGrade = [SELECT Label FROM MT_Skill_Grade__mdt WHERE Rank__c = :skillRank LIMIT 1].Label;
                                        }
                                        if(sfSkillGrade != null) c.SFGrade__c = sfSkillGrade;
                                    }
                                }
                            }
                            if(eduDegree == '박사'){
                                System.debug('박사 ? ' + eduDegree);
                                sfSkillGrade = [SELECT Label FROM MT_Skill_Grade__mdt WHERE CarrerYear__c LIKE :allCareerSumYear AND DegreeType__c = '박사'].Label;
                                if(sfDaysSet.size() < 365 && sfSkillGrade == '특급') sfSkillGrade = '고급';
                                if(sfSkillGrade != null) c.SFGrade__c = sfSkillGrade;
                            }
                        }
                    }
                    if(tg == null && !yesSkill) c.SFGrade__c = null;
                    if(yesSkill) c.SFGrade__c = '기술사';
					System.debug('RestDateSet.size() '+RestDateSet.size());
                    empResourceList.add(
                        new PMS_PjtResource__c(
                            Id = resourceId
                            , ITPeriodDays__c = DateSet.size() - RestDateSet.size()
                            , SFPeriodDays__c = sfDaysSet.size() - RestDateSet.size()
                        )
                    );
                }
            }
            update empResourceList;
            update scope;
            SuccessCount++;
            
        }catch(System.Exception e){
            
            FailCount++;
            
            System.debug('[EXECUTE Error] ' + BatchName);
            System.debug(e);
            resultLog += '\n[EXECUTE Error] (' + scope.get(0).Id + ') ' + e;

            System.debug('Error is ' + e.getLineNumber() + ' / ' + e.getMessage());
            
            throw e;
        }
    }

    global void finish(Database.BatchableContext BC){
        System.debug('[FINISH] ' + BatchName + ' ( ' + BatchExecuteCount + ' )' + ' [S] ' + SuccessCount + ' [F] ' + FailCount);

        // Notification 알림
          UTIL_CustomNoti.sendNoti_Batch(
            new List<String>{
                System.UserInfo.getUserId()
                , 'PMS_EmpSkillGradeBatch 배치완료'
                , FailCount == 0 ? '데이터 집계가 완료 되었습니다.' : '데이터 집계 오류 : ' + resultLog
            }
            , new List<Id>{ 
                System.UserInfo.getUserId()
            }
        );
    }
}