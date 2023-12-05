/*
 * @Class : PMS_PartnerEmpSkillGradeBatch
 *
 * @Method : 

 *  - start(BC)
 *  - execute(BC, scope)
 *  - finish(BC)
 * 
 * @Author : hojae-lee
 * @Date : 2023-01-19
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2023-01-19 | hojae-lee     | 최초작성
 */
global class PMS_PartnerEmpSkillGradeBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{

    global String BatchName = 'PMS_PartnerEmpSkillGradeBatch';
    global String OrgName = '';
    global String resultLog = '';
    global Integer SuccessCount = 0;
    global Integer FailCount = 0;
    global Integer BatchExecuteCount = 0;
    global Long BatchStartDateTimeLong = 0;
    global Id resourceId = null;
    global String resVal = '';

    global PMS_PartnerEmpSkillGradeBatch(){}
    global PMS_PartnerEmpSkillGradeBatch(Id resId){ // 230315_이호재 해당 협력사 자원 한 명 씩 돌리는 생성자
        if(resId != null){
            this.resourceId = resId;
            this.resVal = ' AND Id = :resourceId ';
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC){

        System.debug('[START] ' + BatchName);

        String SOQL = ' SELECT '
                    + '     Id '
                    + '     , Name '
                    + '     , PjtPartnerEmpId__c '
                    + '     , PjtPartnerEmpId__r.TechGrade__c '
                    + '     , PjtPartnerEmpId__r.SFGrade__c '
                    + '     , ITPeriodDays__c '
                    + '     , SFPeriodDays__c '
                    + ' FROM '
                    + '     PMS_PjtResource__c '
                    + ' WHERE '
                   // + '     IsActive__c = true '
                   // + ' AND '
                    + '     ResourceType__c = \'협력사 인력\' '
                    + resVal
                    + ' ORDER BY '
                    + '     Id ';

        return Database.getQueryLocator(SOQL);
    }
 
    global void execute(Database.BatchableContext BC, List<PMS_PjtResource__c> scope){
        try{
            List<PMS_PjtPartnerEmp__c> ppmList = new List<PMS_PjtPartnerEmp__c>();
            String resourceId = null;
            
            for(PMS_PjtResource__c c : scope){
                System.debug('직원(협력사) 이름은 ? ' + c.Name);

                if(scope.size() > 0) {
                    resourceId = scope.get(0).Id;
                }

                // 230119_이호재 협력사 기술등급, 두 기간 사이 기간 세기, 전 직장
                List<PMS_PjtCareer__c> pcDateList = [SELECT Id, InputStartDate__c, InputEndDate__c, FM_InputPeriod_Days__c
                                                     FROM PMS_PjtCareer__c
                                                     WHERE PjtResourceId__c = :resourceId];

                Set<Date> DateSet= new Set<Date>();
                if(pcDateList.size() > 0){
                    for(PMS_PjtCareer__c pc : pcDateList){
                        for(Integer i = 0; i < pc.FM_InputPeriod_Days__c; i++){
                            Date plusDaysDate = pc.InputStartDate__c; // 전 직장 시작일은 필수로 있을 예정
                            Date results = plusDaysDate.addDays(i);

                            DateSet.add(results);
                        }
                    }
                }
                System.debug('전 직장 DateSet 1 ? ' + DateSet);
                System.debug('전 직장 DateSet size 1 ? ' + DateSet.size());


                // 프로젝트 투입인력 기간 계산, 현 직장
                List<PMS_PjtManpower__c> pmDateList = [SELECT Id, InputStartDate__c, InputEndDate__c, PmPeriods__c, ContractPlanStartDate__c, ContractPlanEndDate__c
                                                       FROM PMS_PjtManpower__c
                                                       WHERE PjtResourceId__c = :resourceId];

                Set<Date> pmDateSet = new Set<Date>();
                if(pmDateList.size() > 0){

                    Date plusDaysDate = null;

                    for(PMS_PjtManpower__c pm : pmDateList){

                        if(pm.InputStartDate__c != null){ // 현 직장 시작일 계산
                            plusDaysDate = pm.InputStartDate__c;
                        }
                        if(pm.InputStartDate__c == null){
                            if(pm.ContractPlanStartDate__c != null){
                                plusDaysDate = pm.ContractPlanStartDate__c;
                            }else if(pm.ContractPlanStartDate__c == null){
                                plusDaysDate = null;
                            }
                        }

                        if(plusDaysDate != null){
                            for(Integer i = 0; i < pm.PmPeriods__c; i++){
                                Date results = plusDaysDate.addDays(i);

                                pmDateSet.add(results);
                                DateSet.add(results);
                            }
                        }
                    }
                }
                System.debug('현 직장 pmDateSet ? ' + pmDateSet.size());
                System.debug('DKBMC DateSet 2 ? ' + DateSet);
                System.debug('DKBMC DateSet 2 size ? ' + DateSet.size()); // 중복제거한 경력일수(프로젝트 투입인력 + 프로젝트 경력(전))
                c.ITPeriodDays__c = DateSet.size();

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
                                                         WHERE (GraduationType__c = '졸업' OR GraduationType__c = '수료')
                                                         AND PjtResourceId__c = :resourceId
                                                         LIMIT 1];

                String eduDegree = null;

                if(edList.size() > 0){
                    for(PMS_LastEduBackground__c ed : edList){
                        System.debug('졸업 및 수료인 학력 ? ' + ed.DegreeType__c); // 고졸, 전문학사, 학사, 석사, 박사
                        
                        eduDegree = ed.DegreeType__c;
                    }
                }
                System.debug('eduDegree 1 ? ' + eduDegree);

                // 기술등급 산정
                String skillGradeAcd = null;

                // 학력기준과 경력년수로 메타데이타 테이블에서 가져오기
                List<MT_Skill_Grade__mdt> mdtList = [SELECT Label FROM MT_Skill_Grade__mdt
                                                     WHERE CarrerYear__c LIKE : allCareerSumYear AND DegreeType__c = : eduDegree LIMIT 1];
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
                    for(PMS_Certificate__c cf : cfList){
                        System.debug('보유 자격증은 ? ' + cf.CertificateName__c);

                        if(cfList.size() == 1 && cf.CertificateName__c == '정보처리기능사'){
                            System.debug('정보처리기능사인가 ? ' + cf.CertificateName__c);
                            // 학력으로 계산하기
                            // 경력년수 조건
                            System.debug('eduDegree 2 ? ' + eduDegree);
                            skillGradeCrt = [SELECT Label FROM MT_Skill_Grade__mdt
                                             WHERE CarrerYear__c LIKE :allCareerSumYear AND DegreeType__c = :eduDegree].Label;

                            System.debug('skillGradeCrt 2 ? ' + skillGradeCrt);
                        }

                        if(cf.CertificateName__c == '정보처리산업기사' || cf.CertificateName__c == '사무자동화산업기사'){
                            System.debug('정보처리산업기사인가 ? ' + cf.CertificateType__c);
                            skillGradeCrt = [SELECT Label FROM MT_Skill_Grade__mdt WHERE CarrerYear__c LIKE :allCareerSumYear AND DegreeType__c = '산업기사'].Label; // 230214_이호재 산업기사 메타데이타 레코드 생성

                            System.debug('skillGradeCrt 3 ? ' + skillGradeCrt);
                        }
                        
                        if(cf.CertificateType__c == 'Salesforce' || cf.CertificateType__c == 'Tableau' || cf.CertificateName__c == '정보처리기사'){ // 전자계산기조작응용기사 및 산업기사는 자격증 목록에 없다.
                            System.debug('SF(민간) 및 정보처리기사인가 ? ' + cf.CertificateType__c);
                            // 기사 등급으로 계산하기, 석사와 같은 기준
                            // 경력년수 조건
                            skillGradeCrt = [SELECT Label FROM MT_Skill_Grade__mdt WHERE CarrerYear__c LIKE :allCareerSumYear AND DegreeType__c = '석사'].Label;

                            System.debug('skillGradeCrt 4 ? ' + skillGradeCrt);
                        }

                        if(cf.CertificateName__c == '정보관리기술사'){
                            // c.PjtPartnerEmpId__r.TechGrade__c = '기술사';
                            System.debug('나는 기술사');
                            yesSkill = true;
                        }
                    }
                }

                // 학력 등급과, 자격증 등급 비교, 높은 부분 기술등급 업데이트
                Decimal acdGrade = null;

                if(skillGradeAcd == null)acdGrade = 0;
                if(skillGradeAcd != null){
                    acdGrade = [SELECT Rank__c FROM MT_Skill_Grade__mdt WHERE Label = :skillGradeAcd LIMIT 1].Rank__c;
                }

                Decimal crtGrade = null;

                if(skillGradeCrt == null)crtGrade = 0;
                if(skillGradeCrt != null){
                    crtGrade = [SELECT Rank__c FROM MT_Skill_Grade__mdt WHERE Label = :skillGradeCrt LIMIT 1].Rank__c;
                }

                String techGrade = null;
                if(yesSkill) techGrade = '기술사';
				String tg = null;
                if(acdGrade != null && crtGrade != null && !yesSkill){
                    if(acdGrade >= crtGrade){
                        techGrade = skillGradeAcd;
                        System.debug('학력 기준 업데이트');
                    }
                    if(crtGrade >= acdGrade){
                        techGrade = skillGradeCrt;
                        System.debug('자격증 기준 업데이트');
                    }
                    if(acdGrade == 0 && crtGrade == 0){
                        techGrade = null; // 230313_이호재 기술등급 null, 프로필 없을 시.
                    }
                    tg = techGrade;
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

                List<PMS_PjtManpower__c> sfPmList = [SELECT Id, PmPeriods__c, InputStartDate__c,ContractPlanStartDate__c FROM PMS_PjtManpower__c WHERE PjtResourceId__c = :resourceId];

                Set<Date> sfPmsSet = new Set<Date>();
                if(sfPmList.size() > 0){
                    Date plusDaysDate = null;

                    for(PMS_PjtManpower__c sp : sfPmList){ // 현 직장 시작일 확인 구문
                        if(sp.InputStartDate__c != null){
                            plusDaysDate = sp.InputStartDate__c;
                        }
                        if(sp.InputStartDate__c == null){
                            if(sp.ContractPlanStartDate__c != null){
                                plusDaysDate = sp.ContractPlanStartDate__c;
                            }else if(sp.ContractPlanStartDate__c == null){
                                plusDaysDate = null;
                            }
                        }

                        for(Integer i = 0; i < sp.PmPeriods__c; i++){
                            Date results = plusDaysDate.addDays(i);

                            sfPmsSet.add(results);
                            sfDaysSet.add(results);
                        }
                    }
                }
                System.debug('현 직장 sfPmsSet ? ' + sfPmsSet);
                System.debug('총 경력일수 sfDaysSet size ? ' + sfDaysSet.size());
                c.SFPeriodDays__c = sfDaysSet.size();

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
                                // c.PjtPartnerEmpId__r.SFGrade__c = sfSkillGrade;
                                System.debug('SF등급에서 경력년 수 ? ' + allCareerSumYear);
                                System.debug('SF자격증 보유시, SF등급은 ? ' + sfSkillGrade);
                            }
                            if(sfList.size() == 0){ // SF자격증 미보유 시, SF경력으로 1년 위 아래 나누기
                                if(sfDaysSet.size() >= 365){ // SF경력 1년 이상, 석사와 정보처리기사의 메타데이타 값이 같다.
                                    /*sfSkillGrade = [SELECT Label FROM MT_Skill_Grade__mdt WHERE CarrerYear__c LIKE :allCareerSumYear AND DegreeType__c = '석사'].Label;
                                    if(sfSkillGrade != null) c.PjtPartnerEmpId__r.SFGrade__c = sfSkillGrade;*/
                                    // if(tg != null) 230313_이호재 기술등급 null일 경우 있으므로 조건 삭제
                                    sfSkillGrade = tg;
                                    System.debug('기술 및 sf 동일');
                                }
                                if(sfDaysSet.size() < 365){ // SF경력 1년 미만
                                    Decimal skillRank = [SELECT Rank__c FROM MT_Skill_Grade__mdt WHERE Label = :tg LIMIT 1].Rank__c - 1;
                                    if(skillRank != null && skillRank != 0){
                                        sfSkillGrade = [SELECT Label FROM MT_Skill_Grade__mdt WHERE Rank__c = :skillRank LIMIT 1].Label;
                                    }
                                    if(skillRank != null && skillRank == 0){
                                        skillRank = 1;
                                        sfSkillGrade = [SELECT Label FROM MT_Skill_Grade__mdt WHERE Rank__c = :skillRank LIMIT 1].Label;
                                    }
                                    // if(sfSkillGrade != null) c.PjtPartnerEmpId__r.SFGrade__c = sfSkillGrade;
                                }
                            }
                            ppmList.add(
                                new PMS_PjtPartnerEmp__c(
                                    Id = c.PjtPartnerEmpId__c
                                    , TechGrade__c = techGrade
                                    , SFGrade__c = sfSkillGrade
                                )
                            );
                        }
                        if(eduDegree == '박사'){
                            System.debug('박사 ? ' + eduDegree);
                            sfSkillGrade = [SELECT Label FROM MT_Skill_Grade__mdt WHERE CarrerYear__c LIKE :allCareerSumYear AND DegreeType__c = '박사'].Label;
                            if(sfDaysSet.size() < 365 && sfSkillGrade == '특급') sfSkillGrade = '고급';
                            if(sfSkillGrade != null){
                                ppmList.add(
                                    new PMS_PjtPartnerEmp__c(
                                        Id = c.PjtPartnerEmpId__c
                                        , TechGrade__c = techGrade
                                        , SFGrade__c = sfSkillGrade
                                    )
                                );
                            }
                        }
                    }
                }
                if(tg == null && !yesSkill){
                    ppmList.add(
                        new PMS_PjtPartnerEmp__c(
                            Id = c.PjtPartnerEmpId__c
                            , TechGrade__c = null
                            , SFGrade__c = null
                        )
                    );
                }
                if(yesSkill){
                    sfSkillGrade = '기술사';
                    ppmList.add(
                        new PMS_PjtPartnerEmp__c(
                            Id = c.PjtPartnerEmpId__c
                            , TechGrade__c = techGrade
                            , SFGrade__c = sfSkillGrade
                        )
                    );
                }
            }
            update scope;
            if(ppmList.size() > 0) update ppmList;
            SuccessCount++;
        }catch(System.Exception e){
            
            FailCount++;
            
            System.debug('[EXECUTE Error] ' + BatchName);
            System.debug(e);
            // resultLog += '\n[EXECUTE Error] (' + scope.get(0).Id + ') ' + e;

            System.debug('Error is ' + e.getLineNumber() + ' / ' + e.getMessage());
            
            throw e;
        }
    }

    /*@testVisible static List<MT_Skill_Grade__mdt> customMetadata{ 
        get{
            if(customMetadata == null)
                customMetadata = [SELECT CarrerYear__c, DegreeType__c, DeveloperName, Label, Rank__c, MasterLabel FROM MT_Skill_Grade__mdt]; 
            return customMetadata;
        }set;
    }*/

    global void finish(Database.BatchableContext BC){
        System.debug('[FINISH] ' + BatchName + ' ( ' + BatchExecuteCount + ' )' + ' [S] ' + SuccessCount + ' [F] ' + FailCount);

        // Notification 알림
          UTIL_CustomNoti.sendNoti_Batch(
            new List<String>{
                System.UserInfo.getUserId()
                , 'PMS_PartnerEmpSkillGradeBatch 배치완료'
                , FailCount == 0 ? '데이터 집계가 완료 되었습니다.' : '데이터 집계 오류 : ' + resultLog
            }
            , new List<Id>{ 
                System.UserInfo.getUserId()
            }
        );
    }
}