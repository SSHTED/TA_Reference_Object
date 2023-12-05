@isTest
global class PMS_PjtManpowerMMButtonController_TEST {

    global static Employee__c emp;
    global static Employee__c emp2;
    global static Employee__c emp3;
    global static Organization__c org;
    global static PMS_Project__c p;
    global static PMS_PjtResource__c pr;
    global static PMS_PjtResource__c pr2;
    global static PMS_PjtResource__c pr3;
    global static PMS_PjtManpower__c pm;
    global static PMS_PjtManpower__c pm2;
    global static PMS_PjtManpower__c pm3;
    global static PMS_PjtManpowerMonth__c pmm0;
    global static PMS_PjtManpowerMonth__c pmm01;
    global static PMS_PjtManpowerMonth__c pmm1;
    global static PMS_PjtManpowerMonth__c pmm2;
    global static PMS_PjtManpowerMonth__c pmm3;
    global static PMS_PjtManpowerMonth__c pmm4;
    global static List<Object> datas = new List<Object>();

    static{

        User u = [SELECT Id FROM User WHERE Name = '이호재' LIMIT 1];
        User u2 = [SELECT Id FROM User WHERE Name = 'Org Admin' LIMIT 1];
        User u3 = [SELECT Id FROM User WHERE Name = '김동식' LIMIT 1];

        emp = new Employee__c(
            Name = 'TestEmp'
            , Emp_No__c = '1'
            , Rank__c = '사원'
            , Start__c = System.today()
            , User__c = u.Id
        );
        insert emp;

        emp2 = new Employee__c(
            Name = 'TestEmp2'
            , Emp_No__c = '12'
            , Rank__c = '사원'
            , Start__c = System.today()
            , User__c = u2.Id
        );
        insert emp2;

        emp3 = new Employee__c(
            Name = 'TestEmp3'
            , Emp_No__c = '123'
            , Rank__c = '사원'
            , Start__c = System.today()
            , User__c = u3.Id
        );
        insert emp3;

        org = new Organization__c(
            Code__c = 'Tset1'
            , DisplayOrder__c = 8
            , IsActive__c = true
            , Level__c = '1'
            , Name = 'Tset2'
            , Note__c = 'Tset3'
        );
        insert org;

        p = new PMS_Project__c(
            Name = 'TestProject'
        );
        insert p;

        pr = new PMS_PjtResource__c(
            Name = '이호재'
            , ResourceType__c = '직원'
            , IsActive__c = true
            , EmployeeId__c = emp.Id
        );
        insert pr;

        pr2 = new PMS_PjtResource__c(
            Name = 'admin2'
            , ResourceType__c = '직원'
            , IsActive__c = true
            , EmployeeId__c = emp2.Id
        );
        insert pr2;

        pr3 = new PMS_PjtResource__c(
            Name = 'admin3'
            , ResourceType__c = '직원'
            , IsActive__c = true
            , EmployeeId__c = emp3.Id
        );
        insert pr3;

        pm = new PMS_PjtManpower__c(
            PjtResourceId__c = pr.Id
            , ProjectId__c = p.Id
            , JoinHQ__c = org.Id
            , ContractPlanStartDate__c = Date.newInstance(2021, 01, 01)
            , ContractPlanEndDate__c = Date.newInstance(2023, 12, 31) // 21.01.01 - 23.12.31
            , PlannedBillableMM__c = 1
        );
        insert pm;

        pm2 = new PMS_PjtManpower__c(
            PjtResourceId__c = pr2.Id
            , ProjectId__c = p.Id
            , JoinHQ__c = org.Id
            , ContractPlanStartDate__c = Date.newInstance(2021, 02, 01)
            , ContractPlanEndDate__c = Date.newInstance(2023, 11, 01) // 21.02.01 - 23.11.31
            , InputStartDate__c = Date.newInstance(2021, 02, 01)
            , InputEndDate__c = Date.newInstance(2023, 11, 01)
            , BillableRecognizedMM__c = 10
        );
        insert pm2;

        pm3 = new PMS_PjtManpower__c(
            PjtResourceId__c = pr3.Id
            , ProjectId__c = p.Id
            , JoinHQ__c = org.Id
            , ContractPlanStartDate__c = Date.newInstance(2021, 03, 01)
            , ContractPlanEndDate__c = Date.newInstance(2023, 10, 31) // 21.03.01 - 23.10.31
            , PlannedNonBillableMM__c = 7
        );
        insert pm3;

        pmm0 = new PMS_PjtManpowerMonth__c(
            PjtManpower__c = pm2.Id
            , Project__c = p.Id
            , BaseDate__c = Date.newInstance(2021, 01, 01)
            , Type__c = '계획'
            , ManpowerMM__c = 12
            , ExId__c = pm2.Id + String.valueOf(2021) + String.valueOf(1) + '계획' + 'Billable'
            , Billing__c = 'Billable'
            , IsAvailable__c = true
        );
        insert pmm0;

        pmm01 = new PMS_PjtManpowerMonth__c(
            PjtManpower__c = pm2.Id
            , Project__c = p.Id
            , BaseDate__c = Date.newInstance(2021, 01, 01)
            , Type__c = '실적'
            , ManpowerMM__c = 123
            , ExId__c = pm2.Id + String.valueOf(2021) + String.valueOf(1) + '실적' + 'Billable'
            , Billing__c = 'Billable'
            , IsAvailable__c = true
        );
        insert pmm01;

        /*pmm1 = new PMS_PjtManpowerMonth__c(
            PjtManpower__c = pm.Id
            , Project__c = p.Id
            , BaseDate__c = Date.newInstance(2023, 07, 07)
            , Type__c = '계획'
            , ManpowerMM__c = 1
            , ExId__c = pm.Id + String.valueOf(2023) + String.valueOf(7) + '계획'
        );
        insert pmm1;*/

        pmm2 = new PMS_PjtManpowerMonth__c(
            PjtManpower__c = pm.Id
            , Project__c = p.Id
            , BaseDate__c = Date.newInstance(2023, 07, 01)
            , Type__c = '실적'
            , ManpowerMM__c = 2
            , ExId__c = pm.Id + String.valueOf(2023) + String.valueOf(7) + '실적' + 'Non-Billable'
            , Billing__c = 'Non-Billable'
        );
        insert pmm2;

        pmm3 = new PMS_PjtManpowerMonth__c(
            // PjtManpower__c = pm.Id
            Project__c = p.Id
            , BaseDate__c = Date.newInstance(2023, 07, 01)
            , Type__c = '계획'
            , ManpowerMM__c = 3
            , ExId__c = pm.Id + String.valueOf(2023) + String.valueOf(7) + '계획' + 'Non-Billable'
            , Billing__c = 'Non-Billable'
        );
        insert pmm3;

        pmm4 = new PMS_PjtManpowerMonth__c(
            PjtManpower__c = pm2.Id
            , Project__c = p.Id
            , BaseDate__c = Date.newInstance(2023, 12, 01)
            , Type__c = '계획'
            , ManpowerMM__c = 12
            , ExId__c = pm2.Id + String.valueOf(2023) + String.valueOf(12) + '계획' + 'Non-Billable'
            , Billing__c = 'Non-Billable'
        );
        insert pmm4;
    }

    @isTest
    static void myUnitTest(){
        Test.startTest();
            PMS_PjtManpowerMMButtonController con = new PMS_PjtManpowerMMButtonController();

            Id recordId = p.Id;
            datas.add(pmm0);
            datas.add(pmm1);
            datas.add(pmm2);
            datas.add(pmm3);
            datas.add(pmm4);
            /*Object str1 = JSON.serialize(pmm1);
            Object str2 = JSON.serialize(pmm2);
            datas.add(str1);
            datas.add(str2);*/

            /*pm.ContractPlanEndDate__c = Date.newInstance(2025, 12, 31);
            update pm;*/

            List<PMS_PjtManpower__c> dataList = [SELECT Id, PjtResourceId__r.Name, PlannedBillableMM__c, PlannedNonBillableMM__c, ActualBillableMM__c, ActualNonBillableMM__c
                                                 FROM PMS_PjtManpower__c
                                                 WHERE ProjectId__c = :p.Id];

            List<Date> dateList = PMS_PjtManpowerMMButtonController.getDateData(recordId);
            PMS_PjtManpowerMMButtonController.createData(recordId, dataList, dateList);
            // PMS_PjtManpowerMMButtonController.CreateDefaultData(recordId);
            PMS_PjtManpowerMMButtonController.CreateReport(recordId);
            PMS_PjtManpowerMMButtonController.getDate(recordId);
            PMS_PjtManpowerMMButtonController.getSumMM(recordId);
            PMS_PjtManpowerMMButtonController.saveData(datas, recordId);
        	PMS_PjtManpowerMMButtonController.getSumTotalMM(recordId);
        	PMS_PjtManpowerMMButtonController.getTotalMMperMonth(recordId);
        Test.stopTest();
    }

    @isTest
    static void myUnitTest02(){
        Test.startTest();
            Id recordId = p.Id;

            pm2.ContractPlanStartDate__c = Date.newInstance(2020, 03, 01);
            pm2.ContractPlanEndDate__c = Date.newInstance(2024, 10, 01); // 20.03.01 - 24.10.31
            update pm2;

            PMS_PjtManpowerMMButtonController.CreateDefaultData(recordId);
        Test.stopTest();
    }

    @isTest
    static void myUnitTest03(){
        Test.startTest();
            Id recordId = p.Id;

            pm.ContractPlanStartDate__c = Date.newInstance(2022, 03, 01);
            pm.ContractPlanEndDate__c = Date.newInstance(2022, 10, 01); // 20.03.01 - 24.10.31
            update pm;

            PMS_PjtManpowerMMButtonController.CreateDefaultData(recordId);
        Test.stopTest();
    }

    @isTest
    static void myUnitTest04(){
        Test.startTest();
            Id recordId = p.Id;

            List<PMS_PjtManpower__c> dataList = [SELECT Id, PjtResourceId__r.Name, PlannedBillableMM__c, PlannedNonBillableMM__c, ActualBillableMM__c, ActualNonBillableMM__c
                                                 FROM PMS_PjtManpower__c
                                                 WHERE ProjectId__c = :p.Id];
            List<Date> dateList = PMS_PjtManpowerMMButtonController.getDateData(recordId);
            PMS_PjtManpowerMMButtonController.createData(recordId, dataList, dateList);
            // PMS_PjtManpowerMMButtonController.CreateDefaultData(recordId);
            PMS_PjtManpowerMMButtonController.CreateReport(recordId);
            PMS_PjtManpowerMMButtonController.getSumMM(recordId);
            PMS_PjtManpowerMMButtonController.saveData(datas, recordId);
        	PMS_PjtManpowerMMButtonController.getSumTotalMM(recordId);
        	PMS_PjtManpowerMMButtonController.getTotalMMperMonth(recordId);

            
            pm.ContractPlanStartDate__c = Date.newInstance(2002, 03, 01);
            pm.ContractPlanEndDate__c = Date.newInstance(2025, 10, 01); // 20.03.01 - 24.10.31
            update pm;

            PMS_PjtManpowerMMButtonController.getDateData(recordId);

            pm.ContractPlanStartDate__c = Date.newInstance(2000, 03, 01);
            pm.ContractPlanEndDate__c = Date.newInstance(2035, 10, 01); // 20.03.01 - 24.10.31
            update pm;

            pm3.ContractPlanStartDate__c = null;
            pm3.ContractPlanEndDate__c = null;
            update pm3;

            pm2.InputStartDate__c = null;
            pm2.InputEndDate__c = null;
            update pm2;

            PMS_PjtManpowerMMButtonController.getDateData(recordId);
            PMS_PjtManpowerMMButtonController.CreateDefaultData(recordId);
        Test.stopTest();
    }
}