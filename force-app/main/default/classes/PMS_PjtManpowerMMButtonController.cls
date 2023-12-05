/*
 * @Class : PMS_PjtManpowerMMButtonController
 *
 * @Method : CreateDefaultData
 *           CreateReport
 *           getDate
 *           saveData
 *           getDateData
 *           getSumMM
 *           getSumTotalMM
 * 
 * @Author : hojae-lee
 * @Date : 2022-12-20
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2022-12-20 | hojae-lee     | 최초작성
 *  2. | 2023-01-18 | hojae-lee     | 기준 월 생성 로직 변경
 *  3. | 2023-01-30 | hojae-lee     | Non-Billable 추가 및 코드정리
 *  4. | 2023-02-02 | hojae-lee     | 기준 월 생성 기능, 메소드 분리(getDateData)
 */
global with sharing class PMS_PjtManpowerMMButtonController {
    public static List<Date> getDateData(Id recordId){ // 230202_이호재 달력 만드는 메소드 추가
        List<Date> dateList = new List<Date>();
        Map<String, Object> resultMap = new Map<String, Object>();
        String pmmYes = '';

        try{
            List<PMS_PjtManpowerMonth__c> pmmList = [SELECT PjtManpower__c FROM PMS_PjtManpowerMonth__c WHERE PjtManpower__c != null AND Project__c = :recordId];
            if(pmmList.size() > 0) pmmYes = ' AND Id IN (SELECT PjtManpower__c FROM PMS_PjtManpowerMonth__c WHERE PjtManpower__c != null) ';
            String query = 'SELECT '
                         + '     ProjectId__c '
                         + '     , MIN(ContractPlanStartDate__c)min '
                         + '     , MAX(ContractPlanEndDate__c)max '
                         + '     , MIN(InputStartDate__c)perMin '
                         + '     , MAX(InputEndDate__c)perMax '
                         + ' FROM '
                         + '     PMS_PjtManpower__c '
                         + ' WHERE '
                         + '     ProjectId__c = :recordId '
                         + pmmYes
                         // + ' AND ' // 230324_다시 수정
                         // + '     Id IN (SELECT PjtManpower__c FROM PMS_PjtManpowerMonth__c WHERE PjtManpower__c != null) '
                         + ' GROUP BY '
                         + '     ProjectId__c ';
            
            if(Database.query(query).size() > 0){
                Date minDate; Date maxDate;
                Date min; Date max; Date perMin; Date perMax;
                for(AggregateResult d : Database.query(query)){
                    min = Date.valueOf(d.get('min'));        max = Date.valueOf(d.get('max'));
                    perMin = Date.valueOf(d.get('perMin'));  perMax = Date.valueOf(d.get('perMax'));
                    
                    if(perMin != null && perMax != null){
                        if(min < perMin){minDate = min;}
                        else if(min >= perMin){minDate = perMin;}
                        if(max > perMax){maxDate = max;}
                        else if(max <= perMax){maxDate = perMax;}
                    }else if(perMin == null || perMax == null){
                        if(perMin == null){
                            minDate = min;
                            if(max > perMax){maxDate = max;}
                            else if(max <= perMax){maxDate = perMax;}}
                        if(perMax == null){
                            if(min < perMin){minDate = min;}
                            else if(min >= perMin){minDate = perMin;}
                            maxDate = max;}
                    }
                }
                // System.debug('minDate : ' + minDate); System.debug('maxDate : ' + maxDate);

                if(minDate != null && maxDate != null){
                    Integer miny = minDate.year();  Integer maxy = maxDate.year();
                    Integer mind = minDate.month(); Integer maxd = maxDate.month();
                    Integer minusDate = ((maxy - miny) * 12) + (maxd - mind) + 1;
                    // System.debug('minusDate : ' + minusDate);
                    for(Integer i = 0; minusDate > i; i++){
                        Date month = Date.valueOf(minDate.addMonths(i));
                        dateList.add(month);
                    }
                }
            }
        }catch(System.Exception e){
                System.debug('# Exception ' + e.getMessage());
                resultMap.put('result', false);
                resultMap.put('error', e.getMessage());
                System.debug('Error is ' + e.getLineNumber() + ' / ' + e.getMessage());
        }
        return dateList;
    }

    public static void createData(Id recordId, List<PMS_PjtManpower__c> dataList, List<Date> dateList){ // 230221_이호재 데이타 생성 메소드
        List<PMS_PjtManpowerMonth__c> pmmInsertList1 = new List<PMS_PjtManpowerMonth__c>();
        for(PMS_PjtManpower__c pm : dataList){
            if(pm.PlannedBillableMM__c != null || pm.ActualBillableMM__c != null){ // 빌 데이터 최초 삽입
                for(Date d : dateList){
                    pmmInsertList1.add(
                        new PMS_PjtManpowerMonth__c(
                            Project__c = recordId
                            , PjtManpower__c = pm.Id
                            , Type__c = '실적'
                            , BaseDate__c = d
                            , ExId__c = pm.Id + String.valueOf(d.year()) + String.valueOf(d.month()) + '실적' + 'Billable'
                            , Billing__c = 'Billable'
                            , IsAvailable__c = true
                        )
                    );
                }

                for(Date d : dateList){
                    pmmInsertList1.add(
                        new PMS_PjtManpowerMonth__c(
                            Project__c = recordId
                            , PjtManpower__c = pm.Id
                            , Type__c = '계획'
                            , BaseDate__c = d
                            , ExId__c = pm.Id + String.valueOf(d.year()) + String.valueOf(d.month()) + '계획' + 'Billable'
                            , Billing__c = 'Billable'
                            , IsAvailable__c = true
                        )
                    );
                }
            }
            if(pm.PlannedNonBillableMM__c != null || pm.ActualNonBillableMM__c != null){ // 논빌 데이터 최초 삽입
                for(Date d : dateList){
                    pmmInsertList1.add(
                        new PMS_PjtManpowerMonth__c(
                            Project__c = recordId
                            , PjtManpower__c = pm.Id
                            , Type__c = '실적'
                            , BaseDate__c = d
                            , ExId__c = pm.Id + String.valueOf(d.year()) + String.valueOf(d.month()) + '실적' + 'Non-Billable'
                            , Billing__c = 'Non-Billable'
                            , IsAvailable__c = true
                        )
                    );
                }

                for(Date d : dateList){
                    pmmInsertList1.add(
                        new PMS_PjtManpowerMonth__c(
                            Project__c = recordId
                            , PjtManpower__c = pm.Id
                            , Type__c = '계획'
                            , BaseDate__c = d
                            , ExId__c = pm.Id + String.valueOf(d.year()) + String.valueOf(d.month()) + '계획' + 'Non-Billable'
                            , Billing__c = 'Non-Billable'
                            , IsAvailable__c = true
                        )
                    );
                }
            }
        }
        System.debug('1st logic create!');
        upsert pmmInsertList1 ExId__c;
    }

    @AuraEnabled // default 데이터 생성
    public static void CreateDefaultData(Id recordId){
        Map<String, Object> resultMap = new Map<String, Object>();

        try{
            Set<Integer> existDateSet = new Set<Integer>();

            List<Date> dateList = new List<Date>();
            dateList = getDateData(recordId);
            // System.debug('dateList2 : ' + dateList);

            Set<Date> oldDateSet = new Set<Date>(dateList);      // System.debug('oldDateSet1 : ' + oldDateSet);
            Set<Date> PlusDateSet = new Set<Date>(dateList);     // System.debug('PlusDateSet : ' + PlusDateSet);
            List<Date> MinusDateSet = new List<Date>(dateList);  // System.debug('MinusDateSet : ' + MinusDateSet); System.debug('MinusDateSet Size : ' + MinusDateSet.size());

            // 투입인력이 없는 것 쿼리, 투입인력 신규 시 MM정보 생성
            List<AggregateResult> pmmList = [SELECT BaseDate__c FROM PMS_PjtManpowerMonth__c WHERE Project__c = :recordId GROUP by BaseDate__c ORDER BY BaseDate__c ASC];
            List<PMS_PjtManpower__c> dataList = [SELECT Id, PlannedBillableMM__c, PlannedNonBillableMM__c, ActualBillableMM__c, ActualNonBillableMM__c FROM PMS_PjtManpower__c WHERE ProjectId__c = :recordId];
            Set<Date> PlusPmmSet = new Set<Date>();
            Set<Date> MinusPmmSet = new Set<Date>();

            for(AggregateResult a : pmmList){
                PlusPmmSet.add(Date.valueOf(a.get('BaseDate__c')));
                MinusPmmSet.add(Date.valueOf(a.get('BaseDate__c')));
            }
             //System.debug('PlusPmmSet : ' + PlusPmmSet);
             //System.debug('MinusPmmSet : ' + MinusPmmSet);
             //System.debug('MinusPmmSet Size1 : ' + MinusPmmSet.size());
             //System.debug('Minus remove1 ? : ' + MinusPmmSet.removeAll(MinusDateSet));

            List<PMS_PjtManpower__c> pmList = [SELECT Id, PjtResourceId__r.Name, PlannedBillableMM__c, PlannedNonBillableMM__c, ActualBillableMM__c, ActualNonBillableMM__c
                                               FROM PMS_PjtManpower__c
                                               WHERE ProjectId__c = :recordId
                                               AND Id IN (SELECT PjtManpower__c FROM PMS_PjtManpowerMonth__c WHERE PjtManpower__c != null)];
            if(pmList.size() > 0 && pmmList.size() > 0){
                System.debug('최초생성 아닌 로직');
                // 230323_이호재 공수구분 추가 시(Bill + Non-Bill) 없는 부분 생성 
                List<PMS_PjtManpower__c> addNBPmList = [SELECT Id, PjtResourceId__r.Name, PlannedNonBillableMM__c, ActualNonBillableMM__c, PlannedBillableMM__c, ActualBillableMM__c
                                                        FROM PMS_PjtManpower__c
                                                        WHERE ProjectId__c = :recordId
                                                        AND (PlannedNonBillableMM__c != null OR ActualNonBillableMM__c != null)
                                                        AND Id NOT IN (SELECT PjtManpower__c FROM PMS_PjtManpowerMonth__c WHERE Billing__c = 'Non-Billable' AND (Type__c = '계획 'OR Type__c = '실적'))];
                if(addNBPmList.size() > 0){
                    createData(recordId, addNBPmList, dateList);
                    System.debug('NB 공수구분 데이터추가');
                }
                List<PMS_PjtManpower__c> addBPmList = [SELECT Id, PjtResourceId__r.Name, PlannedBillableMM__c, ActualBillableMM__c, PlannedNonBillableMM__c, ActualNonBillableMM__c
                                                       FROM PMS_PjtManpower__c
                                                       WHERE ProjectId__c = :recordId
                                                       AND (PlannedBillableMM__c  != null OR ActualBillableMM__c  != null)
                                                       AND Id NOT IN (SELECT PjtManpower__c FROM PMS_PjtManpowerMonth__c WHERE Billing__c = 'Billable' AND (Type__c = '계획 'OR Type__c = '실적'))];
                if(addBPmList.size() > 0){
                    createData(recordId, addBPmList, dateList);
                    System.debug('B 공수구분 데이터추가');
                }
                
                // 데이터에서 투입일과, 완료일이 없을 시 null로 업데이트
                List<PMS_PjtManpowerMonth__c> valiRealNullMMList = [SELECT Id, PjtResourceName__c, BaseDate__c, PjtManpower__r.InputStartDate__c, PjtManpower__r.InputEndDate__c, PjtManpower__r.ContractPlanStartDate__c, PjtManpower__r.ContractPlanEndDate__c, ManpowerMM__c, Type__c, IsAvailable__c
                                                                    FROM PMS_PjtManpowerMonth__c
                                                                    WHERE Project__c = :recordId
                                                                    AND (Type__c = '계획' OR Type__c = '실적')
                                                                    AND ((PjtManpower__r.InputStartDate__c = null AND PjtManpower__r.InputEndDate__c = null)
                                                                         OR (PjtManpower__r.ContractPlanStartDate__c = null AND PjtManpower__r.ContractPlanEndDate__c = null))
                                                                    AND IsAvailable__c = true
                                                                    ORDER BY PjtResourceName__c ASC];
                if(valiRealNullMMList.size() > 0){
                    for(PMS_PjtManpowerMonth__c pmm : valiRealNullMMList){ // 230130_이호재 변경
                        // System.debug('데이타 pmm' + pmm);
                        if(pmm.PjtManpower__r.InputStartDate__c == null && pmm.PjtManpower__r.InputEndDate__c == null && pmm.Type__c == '실적'){
                            pmm.ManpowerMM__c = null;
                            pmm.IsAvailable__c = false;
                        }
                        if(pmm.PjtManpower__r.ContractPlanStartDate__c == null && pmm.PjtManpower__r.ContractPlanEndDate__c == null && pmm.Type__c == '계획'){
                            pmm.ManpowerMM__c = null;
                            pmm.IsAvailable__c = false;
                        }
                        System.debug('데이타 중 기간 null');
                    }
                    update valiRealNullMMList;
                }
                
                // 230202_이호재 실적관리 데이터에서 투입인력의 공수(계획 실적 빌 논빌) 값 없을 시 null로 업데이트
                List<PMS_PjtManpowerMonth__c> bList = [SELECT Id, ManpowerMM__c, IsAvailable__c
                                                       FROM PMS_PjtManpowerMonth__c
                                                       WHERE ManpowerMM__c != null AND Billing__c = 'Billable'
                                                       AND PjtManpower__r.PlannedBillableMM__c = null
                                                       AND PjtManpower__r.ActualBillableMM__c = null
                                                       AND Project__c = :recordId];
                List<PMS_PjtManpowerMonth__c> nbList = [SELECT Id, ManpowerMM__c, IsAvailable__c
                                                        FROM PMS_PjtManpowerMonth__c
                                                        WHERE ManpowerMM__c != null AND Billing__c = 'Non-Billable'
                                                        AND PjtManpower__r.PlannedNonBillableMM__c = null
                                                        AND PjtManpower__r.ActualNonBillableMM__c = null
                                                        AND Project__c = :recordId];
                if(bList.size() > 0){
                    for(PMS_PjtManpowerMonth__c pmm : bList){
                        pmm.ManpowerMM__c = null;
                        pmm.IsAvailable__c = false;
                    }
                    update bList;
                    System.debug('bill 초기화');
                }
                if(nbList.size() > 0){
                    for(PMS_PjtManpowerMonth__c pmm : nbList){
                        pmm.ManpowerMM__c = null;
                        pmm.IsAvailable__c = false;
                    }
                    update nbList;
                    System.debug('nonbill 초기화');
                }
                // 기존 인력의 월별 현황 레코드 사이즈 비교
                List<PMS_PjtManpower__c> existList = [SELECT Id, PjtResourceId__r.Name
                                                      , (SELECT Id, BaseDate__c, ManpowerMM__c, Type__c
                                                         FROM lookup_PjtManpower__r
                                                         WHERE BaseDate__c != null
                                                         // AND ManpowerMM__c != null
                                                         AND Type__c != null
                                                         ORDER BY BaseDate__c ASC)
                                                      FROM PMS_PjtManpower__c
                                                      WHERE ProjectId__c = :recordId];

                Integer maxValue = existList[0].lookup_PjtManpower__r.size();
                for(Integer i = 0; i < existList.size(); i++){
                    if(existList[i].lookup_PjtManpower__r.size() > maxValue){
                        maxValue = existList[i].lookup_PjtManpower__r.size();
                        if(maxValue == existList[i].lookup_PjtManpower__r.size()){
                            // System.debug('lookup_PjtManpower__r : ' + existList[i].lookup_PjtManpower__r);
                        }
                    }
                }
                // System.debug('maxValue : ' + maxValue);

                for(PMS_PjtManpower__c pm : existList){
                    // System.debug('exist pm : ' + pm.lookup_PjtManpower__r.size());
                    existDateSet.add(pm.lookup_PjtManpower__r.size());
                }
                // System.debug('existDateSet ? ' + existDateSet);
    
                // System.debug('oldDateSet2 : ' + oldDateSet);
                // System.debug('check PlusDateSet1' + PlusDateSet);
                // System.debug('oldDateSet Size : ' + oldDateSet.size());
                // System.debug('check PlusDateSet Size1 : ' + PlusDateSet.size());
                // System.debug('check PlusPmmSet Size1 : ' + PlusPmmSet.size());
    
                // 총 기간과, 본인 월별 현황 레코드와 비교하여, 없는 부분 생성, 투입인력의 투입기간 변경 시
                if(PlusDateSet.removeAll(PlusPmmSet) == true && oldDateSet.containsAll(PlusDateSet)){
                    PlusDateSet.removeAll(PlusPmmSet);
                    // System.debug('dateSet1.5 : ' + PlusDateSet);
                    // System.debug('check PlusDateSet2 : ' + PlusDateSet);
                    // System.debug('check PlusDateSet Size2 : ' + PlusDateSet.size());

                    if(PlusDateSet != null && PlusDateSet.size() != 0){
                        List<Date> PlusDateList = new List<Date>(PlusDateSet);
                        createData(recordId, dataList, PlusDateList);
                        System.debug('3rd logic');
                    }
                }

                // 투입기간 중 제일 긴 기간 변경 시, 재삽입
                if(MinusPmmSet.removeAll(MinusDateSet) == false && MinusPmmSet.size() > 0){
                    System.debug('Minus remove ? ' + MinusPmmSet.removeAll(MinusDateSet));
                    System.debug('MinusPmmSet Size2 : ' + MinusPmmSet.size());

                    createData(recordId, dataList, MinusDateSet);
                    System.debug('4th logic');
                }

                // System.debug('Minus remove2 ? : ' + MinusPmmSet.removeAll(MinusDateSet));
                // 총 기간이랑, 본인 기간과 비교하여 오버되는 월별 레코드 삭제
                if(MinusPmmSet.removeAll(MinusDateSet) == false && MinusPmmSet.size() > 0){
                    MinusPmmSet.removeAll(MinusDateSet);
                    System.debug('MinusDateSet ' + MinusDateSet.size());
                    System.debug('MinusPmmSet Size2 : ' + MinusPmmSet.size());

                    delete [SELECT Id FROM PMS_PjtManpowerMonth__c WHERE Project__c = :recordId AND BaseDate__c = :MinusPmmSet];
                    System.debug('5th logic delpmmList');
                }

                // 생성된 기준 월 데이터와, 본인의 투입기간과 맞지 않는 경우 null로 업데이트(계획)
                List<PMS_PjtManpowerMonth__c> valiPlanMMList = [SELECT Id, PjtResourceName__c, BaseDate__c, PjtManpower__r.ContractPlanStartDate__c, PjtManpower__r.ContractPlanEndDate__c, ManpowerMM__c, Type__c, IsAvailable__c
                                                                FROM PMS_PjtManpowerMonth__c
                                                                WHERE Project__c = :recordId
                                                                AND Type__c = '계획'
                                                                AND PjtManpower__r.ContractPlanStartDate__c != null
                                                                AND PjtManpower__r.ContractPlanEndDate__c != null
                                                                ORDER BY PjtResourceName__c ASC];
                if(valiPlanMMList.size() > 0){
                    for(PMS_PjtManpowerMonth__c pmm : valiPlanMMList){
                        if(pmm.IsAvailable__c == true){
                            if(Date.newInstance(Integer.valueOf(pmm.BaseDate__c.year()), Integer.valueOf(pmm.BaseDate__c.month()), 1) < Date.newInstance(Integer.valueOf(pmm.PjtManpower__r.ContractPlanStartDate__c.year()), Integer.valueOf(pmm.PjtManpower__r.ContractPlanStartDate__c.month()), 1)){
                                pmm.ManpowerMM__c = null; //230130_이호재 변경
                                pmm.IsAvailable__c = false;
                                System.debug('6th logic');
                            }
                            if(Date.newInstance(Integer.valueOf(pmm.BaseDate__c.year()), Integer.valueOf(pmm.BaseDate__c.month()), 1) > Date.newInstance(Integer.valueOf(pmm.PjtManpower__r.ContractPlanEndDate__c.year()), Integer.valueOf(pmm.PjtManpower__r.ContractPlanEndDate__c.month()), 1)){
                                pmm.ManpowerMM__c = null; //230130_이호재 변경
                                pmm.IsAvailable__c = false;
                                System.debug('7th logic');
                            }
                        }
                        if(pmm.IsAvailable__c == false){
                            if((Date.newInstance(Integer.valueOf(pmm.BaseDate__c.year()), Integer.valueOf(pmm.BaseDate__c.month()), 1) >= Date.newInstance(Integer.valueOf(pmm.PjtManpower__r.ContractPlanStartDate__c.year()), Integer.valueOf(pmm.PjtManpower__r.ContractPlanStartDate__c.month()), 1))
                            && (Date.newInstance(Integer.valueOf(pmm.BaseDate__c.year()), Integer.valueOf(pmm.BaseDate__c.month()), 1) <= Date.newInstance(Integer.valueOf(pmm.PjtManpower__r.ContractPlanEndDate__c.year()), Integer.valueOf(pmm.PjtManpower__r.ContractPlanEndDate__c.month()), 1))){
                                pmm.IsAvailable__c = true; //230328_이호재 추가
                                System.debug('8th logic');
                            }
                        }
                    }
                    update valiPlanMMList;
                }

                // 생성된 기준 월 데이터와, 본인의 투입기간과 맞지 않는 경우 null로 업데이트(실적)
                List<PMS_PjtManpowerMonth__c> valiRealMMList = [SELECT Id, PjtResourceName__c, BaseDate__c, PjtManpower__r.InputStartDate__c, PjtManpower__r.InputEndDate__c, ManpowerMM__c, Type__c, IsAvailable__c
                                                                FROM PMS_PjtManpowerMonth__c
                                                                WHERE Project__c = :recordId
                                                                AND Type__c = '실적'
                                                                AND PjtManpower__r.InputStartDate__c != null
                                                                ORDER BY PjtResourceName__c ASC];
                if(valiRealMMList.size() > 0){
                    for(PMS_PjtManpowerMonth__c pmm : valiRealMMList){
                        if(pmm.IsAvailable__c == true){
                            if(Date.newInstance(Integer.valueOf(pmm.BaseDate__c.year()), Integer.valueOf(pmm.BaseDate__c.month()), 1) < Date.newInstance(Integer.valueOf(pmm.PjtManpower__r.InputStartDate__c.year()), Integer.valueOf(pmm.PjtManpower__r.InputStartDate__c.month()), 1)){
                                pmm.ManpowerMM__c = null; //230130_이호재 변경
                                pmm.IsAvailable__c = false;
                                System.debug('9th logic');
                            }
                            if(pmm.PjtManpower__r.InputEndDate__c != null && Date.newInstance(Integer.valueOf(pmm.BaseDate__c.year()), Integer.valueOf(pmm.BaseDate__c.month()), 1) > Date.newInstance(Integer.valueOf(pmm.PjtManpower__r.InputEndDate__c.year()), Integer.valueOf(pmm.PjtManpower__r.InputEndDate__c.month()), 1)){
                                pmm.ManpowerMM__c = null; //230130_이호재 변경
                                pmm.IsAvailable__c = false;
                                System.debug('10th logic');
                            }
                        }
                        if(pmm.IsAvailable__c == false && pmm.PjtManpower__r.InputEndDate__c != null){
                            if((Date.newInstance(Integer.valueOf(pmm.BaseDate__c.year()), Integer.valueOf(pmm.BaseDate__c.month()), 1) >= Date.newInstance(Integer.valueOf(pmm.PjtManpower__r.InputStartDate__c.year()), Integer.valueOf(pmm.PjtManpower__r.InputStartDate__c.month()), 1))
                            && (Date.newInstance(Integer.valueOf(pmm.BaseDate__c.year()), Integer.valueOf(pmm.BaseDate__c.month()), 1) <= Date.newInstance(Integer.valueOf(pmm.PjtManpower__r.InputEndDate__c.year()), Integer.valueOf(pmm.PjtManpower__r.InputEndDate__c.month()), 1))){
                                // pmm.ManpowerMM__c = null;
                                pmm.IsAvailable__c = true; //230328_이호재 추가
                                System.debug('11th logic');
                            }
                        }
                        if(pmm.IsAvailable__c == false && pmm.PjtManpower__r.InputEndDate__c == null){
                            if(Date.newInstance(Integer.valueOf(pmm.BaseDate__c.year()), Integer.valueOf(pmm.BaseDate__c.month()), 1) >= Date.newInstance(Integer.valueOf(pmm.PjtManpower__r.InputStartDate__c.year()), Integer.valueOf(pmm.PjtManpower__r.InputStartDate__c.month()), 1)){
                                pmm.IsAvailable__c = true; //230328_이호재 추가
                                System.debug('12th logic');
                            }
                        }
                    }
                    update valiRealMMList;
                }

                //230207_이호재 투입기간(실적) 없을 시 MM 및 IsAvail false로 업데이트
                List<PMS_PjtManpowerMonth__c> reList = [SELECT Id, PjtManpower__r.InputStartDate__c, PjtManpower__r.InputEndDate__c, ManpowerMM__c, IsAvailable__c
                                                        FROM PMS_PjtManpowerMonth__c
                                                        WHERE Project__c = :recordId
                                                        AND Type__c = '실적'
                                                        AND (PjtManpower__r.InputStartDate__c = null OR (PjtManpower__r.InputStartDate__c = null AND PjtManpower__r.InputEndDate__c = null))
                                                        AND IsAvailable__c = true
                                                        AND ManpowerMM__c != null
                                                        ORDER BY PjtResourceName__c ASC];
                if(reList.size() > 0){
                    for(PMS_PjtManpowerMonth__c pmm : reList){
                        pmm.ManpowerMM__c = null;
                        pmm.IsAvailable__c = false;
                        System.debug('실적 reset');
                    }
                    update reList;
                }
            }

            if(dataList.size() > 0 && (pmmList.size() <= 0 || pmmList == null)){
                // 투입인력에서 월별 현황 레코드에 없는 인력 레코드 최초 생성
                createData(recordId, dataList, dateList);
                System.debug('최초생성');
            }

            // 투입인력 신규 투입시, 사이즈 비교 후 안맞으면, 총 투입기간 최대 부분과 맞추기
            if(existDateSet.size() != 1 && existDateSet.size() != 0 && existDateSet.size() != null){
                List<PMS_PjtManpower__c> pmExistList = [SELECT Id, (SELECT BaseDate__c, ManpowerMM__c FROM lookup_PjtManpower__r), PlannedBillableMM__c, PlannedNonBillableMM__c, ActualBillableMM__c, ActualNonBillableMM__c
                                                        FROM PMS_PjtManpower__c
                                                        WHERE ProjectId__c = :recordId
                                                        AND ((PlannedBillableMM__c != null OR ActualBillableMM__c != null) OR (PlannedNonBillableMM__c != null OR ActualNonBillableMM__c != null))
                                                        AND Id NOT IN (SELECT PjtManpower__c FROM PMS_PjtManpowerMonth__c)];
                if(pmExistList.size() > 0){
                    createData(recordId, pmExistList, dateList);
                    System.debug('2nd logic Yes, upsert');
                }
            }
        }catch(System.Exception e){
            System.debug('# Exception ' + e.getMessage());
            resultMap.put('result', false);
            resultMap.put('error', e.getMessage());
            System.debug('Error is ' + e.getLineNumber() + ' / ' + e.getMessage());
        }
    }

    @AuraEnabled // 투입인력 대상으로, 투입인력 대상 정보 가져오기
    global static List<PMS_PjtManpowerMonth__c> CreateReport(Id recordId){
        System.debug('init!');
        
        // 230316_이호재 투입인력의 공수구분과 맞지 않는 실적관리 데이터 삭제
        List<PMS_PjtManpowerMonth__c> notBillingTypeList = [SELECT Id, PjtManpower__c, PjtResourceName__c
                                                            FROM PMS_PjtManpowerMonth__c
                                                            WHERE Project__c = :recordId
                                                            AND ((Billing__c = 'Non-Billable' AND PjtManpower__r.PlannedNonBillableMM__c = null AND PjtManpower__r.ActualNonBillableMM__c = null)
                                                                 OR (Billing__c = 'Billable' AND PjtManpower__r.PlannedBillableMM__c = null AND PjtManpower__r.ActualBillableMM__c = null))];
        System.debug('공수구분 맞지 않은 부분 삭제' + notBillingTypeList);
        if(notBillingTypeList.size() > 0) delete notBillingTypeList;

        // 투입인력 Id 없는 월별 현황 레코드 삭제
        List<PMS_PjtManpowerMonth__c> delList = [SELECT Id FROM PMS_PjtManpowerMonth__c WHERE Project__c = :recordId AND PjtManpower__c = null];
        if(delList.size() > 0) delete delList;

        String baseQuery = 'SELECT '
                         + '   Id '
                         + '   , PjtResourceId__r.Name '
                         + '   , BillingType__c '
                         + '   , ContractPlanStartDate__c '
                         + '   , ContractPlanEndDate__c '
                         + '   , InputStartDate__c '
                         + '   , InputEndDate__c '
                         + '   , ActualBillableMM__c ' // 230131_이호재 추가
                         + '   , ActualNonBillableMM__c ' // 230130_이호재 추가
                         + '   , PlannedBillableMM__c ' // 230130_이호재 추가
                         + '   , PlannedNonBillableMM__c ' // 230130_이호재 추가
                         + '   , (SELECT Id, BaseDate__c, ManpowerMM__c, Type__c, Billing__c, IsAvailable__c, BillingType__c FROM lookup_PjtManpower__r WHERE BaseDate__c != null AND Type__c != null ORDER BY BaseDate__c ASC) ' // 230206_이호재 IsAvaliable, BillingType__c 추가
                         + ' FROM '
                         + '   PMS_PjtManpower__c '
                         + ' WHERE '
                         + '   ProjectId__c = :recordId '
                         + ' AND '
                         + '   (ContractPlanStartDate__c != null AND ContractPlanEndDate__c != null) ' // 230202_이호재 계획 기간 없을 시 쿼리에서 제외
                         + ' AND '
                         + '   Id IN (SELECT PjtManpower__c FROM PMS_PjtManpowerMonth__c WHERE PjtManpower__c != null) '
                         + ' ORDER BY PjtResourceId__r.Name ASC, BillingType__c ASC';
        return Database.query(baseQuery);
    }

    @AuraEnabled // 테이블 화면에서 기준 월 생성
    global static List<String> getDate(Id recordId){
        List<PMS_PjtManpowerMonth__c> pmList = CreateReport(recordId);
        // System.debug('pmList : ' + pmList);

        Map<String, Object> resultMap = new Map<String, Object>();
        List<String> dateList = new List<String>();
        List<Date> dateList2 = new List<Date>(getDateData(recordId));

        try{ // 230202_이호재 메소드 사용으로 변경
            for(Date d : dateList2){
                String month = String.valueOf(d).substring(0, 7);
                // System.debug('cutMonth ? ' + month);
                dateList.add(month);
            }
            // System.debug('dateList : ' + dateList);

        }catch(Exception e){
            System.debug('# Exception ' + e.getMessage());
            resultMap.put('result', false);
            resultMap.put('error', e.getMessage());
        }
        return dateList;
    }

    @AuraEnabled // 테이블 화면에서 총 MM값 계산하는 쿼리
    global static Map<String, String> getSumMM(Id recordId){
        String baseQuery = 'SELECT '
                         + '   Id '
                         + ' FROM '
                         + '   PMS_PjtManpower__c '
                         + ' WHERE '
                         + '   ProjectId__c = :recordId ';
        Set<Id> manSet = new Set<Id>();
        for(PMS_PjtManpower__c pm : Database.query(baseQuery)) manSet.add(pm.Id);

        String sumQuery = 'SELECT '
                        + '   PjtManpower__c '
                        + '   , SUM(ManpowerMM__c) total '
                        + '   , Type__c '
                        + '   , Billing__c '
                        + ' FROM '
                        + '   PMS_PjtManpowerMonth__c '
                        + ' WHERE '
                        + '   Project__c = :recordId '
                        + ' AND '
                        + '   PjtManpower__c = :manSet '
                        + ' GROUP BY '
                        + '   PjtManpower__c, Type__c, Billing__c ';
        Map<String, String> sumMap = new Map<String, String>();
        List<Double> pSumList = new List<Double>();
        List<Double> rSumList = new List<Double>();
        for(AggregateResult sumP : Database.query(sumQuery)){
            if(sumP.get('total') == null){
                sumMap.put(String.valueOf(sumP.get('PjtManpower__c'))
                + String.valueOf(sumP.get('Type__c'))
                + String.valueOf(sumP.get('Billing__c')), '0');
            }
            if(sumP.get('total') != null){
                sumMap.put(String.valueOf(sumP.get('PjtManpower__c'))
                + String.valueOf(sumP.get('Type__c'))
                + String.valueOf(sumP.get('Billing__c')), String.valueOf(sumP.get('total')));
            }
            if(String.valueOf(sumP.get('Type__c')) == '계획' && sumP.get('total') != null){ // 230202_이호재 아래로 TotalMM 총 합 계산
                pSumList.add(Double.valueOf(sumP.get('total')));
            }
            if(String.valueOf(sumP.get('Type__c')) == '실적' && sumP.get('total') != null){
                rSumList.add(Double.valueOf(sumP.get('total')));
            }
        }
        Double pSum = 0; Double rSum = 0;
        for(Integer i = 0; i < pSumList.size(); i++) pSum += pSumList[i];
        for(Integer i = 0; i < rSumList.size(); i++) rSum += rSumList[i];
        
        sumMap.put('pSum', String.valueOf(pSum));
        sumMap.put('rSum', String.valueOf(rSum));
        // System.debug('sumMap : ' + sumMap);
        return sumMap;
    }

    @AuraEnabled // 생성화면 데이터 입력 저장
    public static Map<String, Object> saveData(List<Object> datas, Id recordId){
        // System.debug('saveDatas : ' + datas);

        Map<String, Object> resultMap = new Map<String, Object>();
        Map<Object, Object> pMap = new Map<Object, Object>();
        List<PMS_PjtManpowerMonth__c> pList = new List<PMS_PjtManpowerMonth__c>();

        try{
            // 데이터에서 투입일과, 완료일이 없을 시 null로 업데이트
            List<PMS_PjtManpowerMonth__c> valiRealNullMMList = [SELECT Id, PjtResourceName__c, BaseDate__c, PjtManpower__r.InputStartDate__c, PjtManpower__r.InputEndDate__c, PjtManpower__r.ContractPlanStartDate__c, PjtManpower__r.ContractPlanEndDate__c, ManpowerMM__c, Type__c, IsAvailable__c
                                                                FROM PMS_PjtManpowerMonth__c
                                                                WHERE Project__c = :recordId
                                                                AND (Type__c = '계획' OR Type__c = '실적')
                                                                AND ((PjtManpower__r.InputStartDate__c = null AND PjtManpower__r.InputEndDate__c = null)
                                                                OR (PjtManpower__r.ContractPlanStartDate__c = null AND PjtManpower__r.ContractPlanEndDate__c = null))
                                                                AND IsAvailable__c = true
                                                                ORDER BY PjtResourceName__c ASC];
            if(valiRealNullMMList.size() > 0){
                for(PMS_PjtManpowerMonth__c pmm : valiRealNullMMList){ //230130_이호재 변경
                    // System.debug('데이타 pmm' + pmm);
                    if(pmm.PjtManpower__r.InputStartDate__c == null && pmm.PjtManpower__r.InputEndDate__c == null && pmm.Type__c == '실적'){
                        pmm.ManpowerMM__c = null;
                        pmm.IsAvailable__c = false;
                    }
                    if(pmm.PjtManpower__r.ContractPlanStartDate__c == null && pmm.PjtManpower__r.ContractPlanEndDate__c == null && pmm.Type__c == '계획'){
                        pmm.ManpowerMM__c = null;
                        pmm.IsAvailable__c = false;
                    }
                    System.debug('데이타 중 기간 null');
                }
                update valiRealNullMMList;
            }

            // 생성된 기준 월 데이터와, 본인의 투입기간과 맞지 않는 경우 null로 업데이트(계획)
            List<PMS_PjtManpowerMonth__c> valiPlanMMList = [SELECT Id, PjtResourceName__c, BaseDate__c, PjtManpower__r.ContractPlanStartDate__c, PjtManpower__r.ContractPlanEndDate__c, ManpowerMM__c, Type__c, IsAvailable__c
                                                            FROM PMS_PjtManpowerMonth__c
                                                            WHERE Project__c = :recordId
                                                            AND Type__c = '계획'
                                                            AND PjtManpower__r.ContractPlanStartDate__c != null
                                                            AND PjtManpower__r.ContractPlanEndDate__c != null
                                                            ORDER BY PjtResourceName__c ASC];
            if(valiPlanMMList.size() > 0){
                for(PMS_PjtManpowerMonth__c pmm : valiPlanMMList){
                    if(pmm.IsAvailable__c == true){
                        if(Date.newInstance(Integer.valueOf(pmm.BaseDate__c.year()), Integer.valueOf(pmm.BaseDate__c.month()), 1) < Date.newInstance(Integer.valueOf(pmm.PjtManpower__r.ContractPlanStartDate__c.year()), Integer.valueOf(pmm.PjtManpower__r.ContractPlanStartDate__c.month()), 1)){
                            pmm.ManpowerMM__c = null; //230130_이호재 변경
                            pmm.IsAvailable__c = false;
                            System.debug('13th logic');
                        }
                        if(Date.newInstance(Integer.valueOf(pmm.BaseDate__c.year()), Integer.valueOf(pmm.BaseDate__c.month()), 1) > Date.newInstance(Integer.valueOf(pmm.PjtManpower__r.ContractPlanEndDate__c.year()), Integer.valueOf(pmm.PjtManpower__r.ContractPlanEndDate__c.month()), 1)){
                            pmm.ManpowerMM__c = null; //230130_이호재 변경
                            pmm.IsAvailable__c = false;
                            System.debug('14th logic');
                        }
                    }
                    if(pmm.IsAvailable__c == false){
                        if((Date.newInstance(Integer.valueOf(pmm.BaseDate__c.year()), Integer.valueOf(pmm.BaseDate__c.month()), 1) >= Date.newInstance(Integer.valueOf(pmm.PjtManpower__r.ContractPlanStartDate__c.year()), Integer.valueOf(pmm.PjtManpower__r.ContractPlanStartDate__c.month()), 1))
                        && (Date.newInstance(Integer.valueOf(pmm.BaseDate__c.year()), Integer.valueOf(pmm.BaseDate__c.month()), 1) <= Date.newInstance(Integer.valueOf(pmm.PjtManpower__r.ContractPlanEndDate__c.year()), Integer.valueOf(pmm.PjtManpower__r.ContractPlanEndDate__c.month()), 1))){
                            // pmm.ManpowerMM__c = null;
                            pmm.IsAvailable__c = true; //230328_이호재 추가
                            System.debug('15th logic');
                        }
                    }
                }
                update valiPlanMMList;
            }

            // 생성된 기준 월 데이터와, 본인의 투입기간과 맞지 않는 경우 null로 업데이트(실적)
            List<PMS_PjtManpowerMonth__c> valiRealMMList = [SELECT Id, PjtResourceName__c, BaseDate__c, PjtManpower__r.InputStartDate__c, PjtManpower__r.InputEndDate__c, ManpowerMM__c, Type__c, IsAvailable__c
                                                            FROM PMS_PjtManpowerMonth__c
                                                            WHERE Project__c = :recordId
                                                            AND Type__c = '실적'
                                                            AND PjtManpower__r.InputStartDate__c != null
                                                            ORDER BY PjtResourceName__c ASC];
            if(valiRealMMList.size() > 0){
                for(PMS_PjtManpowerMonth__c pmm : valiRealMMList){
                    if(pmm.IsAvailable__c == true){
                        if(Date.newInstance(Integer.valueOf(pmm.BaseDate__c.year()), Integer.valueOf(pmm.BaseDate__c.month()), 1) < Date.newInstance(Integer.valueOf(pmm.PjtManpower__r.InputStartDate__c.year()), Integer.valueOf(pmm.PjtManpower__r.InputStartDate__c.month()), 1)){
                            pmm.ManpowerMM__c = null; //230130_이호재 변경
                            pmm.IsAvailable__c = false;
                            System.debug('16th logic');
                        }
                        if(pmm.PjtManpower__r.InputEndDate__c != null && Date.newInstance(Integer.valueOf(pmm.BaseDate__c.year()), Integer.valueOf(pmm.BaseDate__c.month()), 1) > Date.newInstance(Integer.valueOf(pmm.PjtManpower__r.InputEndDate__c.year()), Integer.valueOf(pmm.PjtManpower__r.InputEndDate__c.month()), 1)){
                            pmm.ManpowerMM__c = null; //230130_이호재 변경
                            pmm.IsAvailable__c = false;
                            System.debug('17th logic');
                        }
                    }
                    if(pmm.IsAvailable__c == false && pmm.PjtManpower__r.InputEndDate__c != null){
                        if((Date.newInstance(Integer.valueOf(pmm.BaseDate__c.year()), Integer.valueOf(pmm.BaseDate__c.month()), 1) >= Date.newInstance(Integer.valueOf(pmm.PjtManpower__r.InputStartDate__c.year()), Integer.valueOf(pmm.PjtManpower__r.InputStartDate__c.month()), 1))
                        && (Date.newInstance(Integer.valueOf(pmm.BaseDate__c.year()), Integer.valueOf(pmm.BaseDate__c.month()), 1) <= Date.newInstance(Integer.valueOf(pmm.PjtManpower__r.InputEndDate__c.year()), Integer.valueOf(pmm.PjtManpower__r.InputEndDate__c.month()), 1))){
                            // pmm.ManpowerMM__c = null;
                            pmm.IsAvailable__c = true; //230328_이호재 추가
                            System.debug('18th logic');
                        }
                    }
                    if(pmm.IsAvailable__c == false && pmm.PjtManpower__r.InputEndDate__c == null){
                        if(Date.newInstance(Integer.valueOf(pmm.BaseDate__c.year()), Integer.valueOf(pmm.BaseDate__c.month()), 1) >= Date.newInstance(Integer.valueOf(pmm.PjtManpower__r.InputStartDate__c.year()), Integer.valueOf(pmm.PjtManpower__r.InputStartDate__c.month()), 1)){
                            pmm.IsAvailable__c = true; //230328_이호재 추가
                            System.debug('19th logic');
                        }
                    }
                }
                update valiRealMMList;
            }

            // 투입인력이 투입기간(계획)이 없을 시, MM데이터 null로 업데이트
            List<PMS_PjtManpowerMonth__c> noPlanDateList = [SELECT Id, ManpowerMM__c, IsAvailable__c
                                                            FROM PMS_PjtManpowerMonth__c
                                                            WHERE Project__c = :recordId
                                                            AND PjtManpower__r.ContractPlanStartDate__c = null
                                                            AND PjtManpower__r.ContractPlanEndDate__c = null];
            if(noPlanDateList.size() > 0){
                for(PMS_PjtManpowerMonth__c pmm : noPlanDateList){
                    pmm.ManpowerMM__c = null; //230130_이호재 변경
                    pmm.IsAvailable__c = false;
                    System.debug('20th logic');
                }
                update noPlanDateList;
            }

            //230207_이호재 투입기간(실적) 없을 시 MM 및 IsAvail false로 업데이트
            List<PMS_PjtManpowerMonth__c> reList = [SELECT Id, PjtManpower__r.InputStartDate__c, PjtManpower__r.InputEndDate__c, ManpowerMM__c, IsAvailable__c
                                                    FROM PMS_PjtManpowerMonth__c
                                                    WHERE Project__c = :recordId
                                                    AND Type__c = '실적'
                                                    AND (PjtManpower__r.InputStartDate__c = null OR (PjtManpower__r.InputStartDate__c = null AND PjtManpower__r.InputEndDate__c = null))
                                                    AND IsAvailable__c = true
                                                    ORDER BY PjtResourceName__c ASC];
            if(reList.size() > 0){
                for(PMS_PjtManpowerMonth__c pmm : reList){
                    pmm.ManpowerMM__c = null;
                    pmm.IsAvailable__c = false;
                    System.debug('실적 reset');
                }
                update reList;
            }

            // 230202_이호재 실적관리 데이터에서 투입인력의 공수(계획 실적 빌 논빌) 값 없을 시 null로 업데이트
            List<PMS_PjtManpowerMonth__c> bList = [SELECT Id, ManpowerMM__c, IsAvailable__c
                                                   FROM PMS_PjtManpowerMonth__c WHERE ManpowerMM__c != null AND Billing__c = 'Billable'
                                                   AND PjtManpower__r.PlannedBillableMM__c = null
                                                   AND PjtManpower__r.ActualBillableMM__c = null
                                                   AND Project__c = :recordId];
            List<PMS_PjtManpowerMonth__c> nbList = [SELECT Id, ManpowerMM__c, IsAvailable__c
                                                    FROM PMS_PjtManpowerMonth__c WHERE ManpowerMM__c != null AND Billing__c = 'Non-Billable'
                                                    AND PjtManpower__r.PlannedNonBillableMM__c = null
                                                    AND PjtManpower__r.ActualNonBillableMM__c = null
                                                    AND Project__c = :recordId];
            if(bList.size() > 0){
                for(PMS_PjtManpowerMonth__c pmm : bList){
                    pmm.ManpowerMM__c = null;
                    pmm.IsAvailable__c = false;
                }
                update bList;
            }
            if(nbList.size() > 0){
                for(PMS_PjtManpowerMonth__c pmm : nbList){
                    pmm.ManpowerMM__c = null;
                    pmm.IsAvailable__c = false;
                }
                update nbList;
            }

            // 데이터 저장
            for(Object pmm : datas){
                // System.debug('pmm ? ' + pmm);
                List<Object> li = (List<Object>)pmm;
                // System.debug('li ? ' + li);

                for(Object p : li){
                    pMap = (Map<Object, Object>)p;
                    if(pMap.get('ManpowerMM__c') == null || pMap.get('ManpowerMM__c') == ''){
                        // System.debug('d 1 ? ' + pMap.get('ManpowerMM__c'));
                        pList.add(
                            new PMS_PjtManpowerMonth__c(
                                Id = String.valueOf(pMap.get('Id'))
                                , ManpowerMM__c = null
                            )
                        );
                    }
                    // System.debug('입력값은 ? ' + pMap.get('ManpowerMM__c'));
                    if(pMap.get('ManpowerMM__c') != null &&  pMap.get('ManpowerMM__c') != ''){
                        pList.add(
                            new PMS_PjtManpowerMonth__c(
                                Id = String.valueOf(pMap.get('Id'))
                                , ManpowerMM__c = Double.valueOf(pMap.get('ManpowerMM__c'))
                            )
                        );
                    }
                    // System.debug('pMap ? '+ pMap);
                    // System.debug('pMap k ? '+ pMap.keySet());
                    // System.debug('pMap v ? '+ pMap.values());
                }
            }
            update pList;

            // System.debug('pList : ' + pList.size());
            // System.debug('saveData recordId : ' + recordId);
        }catch(System.Exception e){
            System.debug('# Exception ' + e.getMessage());
            resultMap.put('result', false);
            resultMap.put('error', e.getMessage());
            System.debug('Error is ' + e.getLineNumber() + ' / ' + e.getMessage());
        }
        resultMap.put('result', true);

        return resultMap;
    }

    @AuraEnabled
    global static Map<String, Double> getSumTotalMM(Id recordId){ // 230201_이호재 투입공수 총 합 계산
        Map<String, Object> resultMap = new Map<String, Object>();
        Map<String, Double> tMap = new Map<String, Double>();
        try{
            List<AggregateResult> qList = [SELECT SUM(PlannedBillableMM__c)p1Sum, SUM(ActualBillableMM__c)r1Sum, SUM(PlannedNonBillableMM__c)p2Sum, SUM(ActualNonBillableMM__c)r2Sum
                                           FROM PMS_PjtManpower__c
                                           WHERE ProjectId__c = :recordId
                                           AND ContractPlanEndDate__c != null
                                           AND ContractPlanStartDate__c != null];
            Double p1Sum; Double r1Sum; Double p2Sum; Double r2Sum;
            if(qList.size() == 1){
                for(AggregateResult a : qList){
                    p1Sum = (a.get('p1Sum') != null) ? Double.valueOf(a.get('p1Sum')) : 0; // null이면 0으로 치환
                    r1Sum = (a.get('r1Sum') != null) ? Double.valueOf(a.get('r1Sum')) : 0;
                    p2Sum = (a.get('p2Sum') != null) ? Double.valueOf(a.get('p2Sum')) : 0;
                    r2Sum = (a.get('r2Sum') != null) ? Double.valueOf(a.get('r2Sum')) : 0;
                }
            }
            Double pSum = p1Sum + p2Sum;
            Double rSum = r1Sum + r2Sum;

            tMap.put('계획', pSum);
            tMap.put('실적', rSum);
            // System.debug('tMap k ? ' + tMap.keySet());
            // System.debug('tMap v ? ' + tMap.values());
        }catch(System.Exception e){
            System.debug('# Exception ' + e.getMessage());
            resultMap.put('result', false);
            resultMap.put('error', e.getMessage());
            System.debug('Error is ' + e.getLineNumber() + ' / ' + e.getMessage());
        }
        return tMap;
    }

    @AuraEnabled
    global static Map<String, Double> getTotalMMperMonth(Id recordId){ // 230202_이호재 기준 월 및 자원 별 MM 총 합
        Map<String, Object> resultMap = new Map<String, Object>();
        Map<String, Double> newMap = new Map<String, Double>();
        
        try{
            Set<Date> dSet = new Set<Date>(getDateData(recordId));
            // System.debug('dSet ? ' + dSet);

            List<AggregateResult> smmList = [SELECT SUM(ManpowerMM__c)smm, BaseDate__c, Type__c
                                             FROM PMS_PjtManpowerMonth__c
                                             WHERE Project__c = :recordId
                                             AND BaseDate__c = :dSet
                                             GROUP BY BaseDate__c, Type__c
                                             ORDER BY BaseDate__c ASC];

            for(AggregateResult a : smmList){
                if(a.get('smm') == null){
                    newMap.put(String.valueOf(a.get('BaseDate__c')).substring(0, 7) + a.get('Type__c'), 0);  
                }
                if(a.get('smm') != null){
                    newMap.put(String.valueOf(a.get('BaseDate__c')).substring(0, 7) + a.get('Type__c'), Double.valueOf(a.get('smm')));
                } 
            }
            // System.debug('newMap ? ' + newMap);
        }catch(System.Exception e){
            System.debug('# Exception ' + e.getMessage());
            resultMap.put('result', false);
            resultMap.put('error', e.getMessage());
            System.debug('Error is ' + e.getLineNumber() + ' / ' + e.getMessage());
        }
        return newMap;
    }
}