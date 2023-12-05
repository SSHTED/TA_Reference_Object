/**
 * @Class : SystemAdminDashboardController
 *
 * @Method : 
 * 
 * @Author : Yong-Jin, Cha
 * @Date : 2021-11-22
 * @Version : 1.0
 * @Modified : 
 *  ---------------------------------------------
 *  NO | Date       | Modifier      | Description
 *  ---------------------------------------------
 *  1. | 2021-11-22 | Yong-Jin, Cha | 최초작성
 *  2. | 2022-04-04 | Yong-Jin, Cha | 프로필 및 프로필별 사용자 조회 추가
 */
global without Sharing class SystemAdminDashboardController {
   
    @AuraEnabled
    global static Map<String, Object> getData() {
        Map<String, Object> resultMap = new Map<String, Object>();
        
        Map<String,System.OrgLimit> limitsMap = OrgLimits.getMap();

        resultMap.put('orglimits', limitsMap); // 임시
        resultMap.put('DataStorageMB', new limitItem(limitsMap.get('DataStorageMB')));
        resultMap.put('FileStorageMB', new limitItem(limitsMap.get('FileStorageMB')));
        resultMap.put('UserLicenseList', getUserLicenseList());
        resultMap.put('ProfileList', getProfileList());
        resultMap.put('PermissionSetLicenseList', getPermissionSetLicenseList());
        resultMap.put('ActiveFeatureLicenseMetricList', getActiveFeatureLicenseMetricList());
        resultMap.put('TenantUsageEntitlementList', getTenantUsageEntitlementList());

        return resultMap;
    }

    private static List<profileItem> getProfileList() {

        List<profileItem> profileList = new List<profileItem>();

        List<AggregateResult> uList = [
            select 
                ProfileId pId
               , count(Id) cnt
            from
                User
            where
                IsActive = true
            and Profile.Name != null
            and Profile.UserLicense.Name in ('Salesforce Platform', 'Force.com - App Subscription', 'Salesforce')
            group by ProfileId
        ];

        Map<Id, Decimal> uMap = new Map<Id, Decimal>();

        for(AggregateResult ar : uList) {
            uMap.put(String.valueOf(ar.get('pId')), Decimal.valueOf(String.valueOf(ar.get('cnt'))));
        }

        List<Profile> pList = [
            select 
                Description
                , Id
                , Name
                , UserLicenseId
                , UserLicense.Name
            from
                Profile
            where 
                UserLicense.Name in ('Salesforce Platform', 'Force.com - App Subscription', 'Salesforce')
            order by Name
        ];

        for(Profile p : pList) {
            profileList.add(new profileItem(p, uMap.get(p.Id)));
        }

        return profileList;
    }

    private static List<UserLicense> getUserLicenseList() {
        return [
            select 
                Id
                , Name
                , MasterLabel
                , LicenseDefinitionKey
                , Status
                , TotalLicenses
                , UsedLicenses
                , CreatedDate
                , UsedLicensesLastUpdated
                , LastModifiedDate
            from
                UserLicense
            where
                Status = 'Active'
            and LicenseDefinitionKey in ('SFDC', 'AUL', 'FDC_SUB')
            order by Name desc
        ];
    }

    private static List<PermissionSetLicense> getPermissionSetLicenseList() {
        return [
            select 
                DeveloperName
                , ExpirationDate
                , Id
                , Language
                , MasterLabel
                , PermissionSetLicenseKey
                , Status
                , TotalLicenses
                , UsedLicenses
            from
                PermissionSetLicense
            where 
                Status = 'Active'
            order by 
                MasterLabel
        ];
    }

    private static List<featureItem> getActiveFeatureLicenseMetricList() {

        List<featureItem> resultList = new List<featureItem>();
        Date lastDate = [select MetricsDate from ActiveFeatureLicenseMetric order by MetricsDate desc limit 1].get(0).MetricsDate;

        List<ActiveFeatureLicenseMetric> li = [
            select 
                Id
                , FeatureType
                , TotalLicenseCount               
                , AssignedUserCount
                , ActiveUserCount
                , MetricsDate
            from
                ActiveFeatureLicenseMetric
            where
                MetricsDate = :lastDate
            order by
                MetricsDate desc
                , TotalLicenseCount
                , Id
        ];

        List<ActiveFeatureLicenseMetric> nli = [
            select 
                Id
                , toLabel(FeatureType)
                , TotalLicenseCount               
                , AssignedUserCount
                , ActiveUserCount
                , MetricsDate
            from
                ActiveFeatureLicenseMetric
            where
                MetricsDate = :lastDate
            order by
                MetricsDate desc
                , TotalLicenseCount
                , Id
        ];
        
        Integer i = 0;
        for(ActiveFeatureLicenseMetric aflm : li) {
            resultList.add(new featureItem(aflm, nli.get(i).FeatureType));
            i++;
        }

        return resultList;
    }

    private static List<TenantUsageEntitlement> getTenantUsageEntitlementList() {
        return [
            select 
                Id
                , MasterLabel
                , ResourceGroupKey
                , StartDate
                , EndDate
                , Frequency
                , CurrentAmountAllowed
                , AmountUsed
                , UsageDate
                
                //, HasRollover                
                //, IsPersistentResource                
                //, OverageGrace                
                //, Setting                
            from
                TenantUsageEntitlement
        ];
    }

    @AuraEnabled
    global static List<User> getUserListByProfileId(String targetId) {
        return [
            select 
                Id
                , Name
                , UserName
                , Email
                , ProfileId
                , Profile.Description
                , IsActive
            from
                User
            where
                IsActive = true
            and ProfileId = :targetId
            order by 
                Name
        ];
    }

    @AuraEnabled
    global static List<User> getUserListByUserLicenseId(String targetId) {
        return [
            select 
                Id
                , Name
                , UserName
                , Email
                , ProfileId
                , Profile.Description
                , IsActive
            from
                User
            where
                IsActive = true
            and Profile.UserLicenseId = :targetId
            order by 
                Name
        ];
    }

    @AuraEnabled
    global static List<PermissionSetLicenseAssign> getUserListByPermissionSetLicenseId(String targetId) {
        return [
            select 
                AssigneeId
                , Assignee.Name
                , Assignee.UserName
                , Assignee.Email
                , Assignee.ProfileId
                , Assignee.Profile.Description
                , Assignee.IsActive
            from
                PermissionSetLicenseAssign
            where
                Assignee.IsActive = true
            and PermissionSetLicenseId = :targetId
            order by 
                Assignee.Name
        ];
    }

    @AuraEnabled
    global static List<User> getUserListByActiveFeatureLicenseId(String featureType) {

        String SOQL = ' select '
                    + ' 	Id '
                    + ' 	, Name '
                    + ' 	, UserName '
                    + ' 	, Email '
                    + ' 	, ProfileId '
                    + ' 	, Profile.Description '
                    + ' 	, IsActive '
                    + ' from '
                    + ' 	User '
                    + ' where '
                    + ' 	IsActive = true '
                    + ' and UserPermissions' + featureType + ' = true '
                    + ' order by '
                    + ' 	Name ';

        return Database.query(SOQL);
    }

    
    
    global class limitItem {
        
        @AuraEnabled global String name {get;set;} 
        @AuraEnabled global Integer value {get;set;}
        @AuraEnabled global Integer limitVal {get;set;}
        @AuraEnabled global Integer barVal {get;set;}
        @AuraEnabled global String barClass {get;set;}        

        global limitItem(System.OrgLimit item) {
            this.name = item.getName();
            this.value = item.getValue();
            this.limitVal = item.getLimit();
            this.barVal = Math.round((100 * this.value) / this.limitVal);
            
            if(this.barVal < 25) {
                this.barClass = '';
            } else if(this.barVal < 50) {
                this.barClass = 'warning25';
            } else if(this.barVal < 75) {
                this.barClass = 'warning50';
            } else if(this.barVal < 100) {
                this.barClass = 'warning75';
            } else {
                this.barClass = 'warning100';
            }
            if(this.barVal > 100) {
                this.barVal = 100;
            }
        }
    }

    global class featureItem {
        
        @AuraEnabled global String FeatureType {get;set;}
        @AuraEnabled global String FeatureTypeName {get;set;} 
        @AuraEnabled global Decimal TotalLicenseCount {get;set;}
        @AuraEnabled global Decimal AssignedUserCount {get;set;}
        @AuraEnabled global Decimal ActiveUserCount {get;set;}
        @AuraEnabled global Date MetricsDate {get;set;}        

        global featureItem(ActiveFeatureLicenseMetric item, String Name) {
            this.FeatureType = item.FeatureType;
            this.FeatureTypeName = Name;
            this.TotalLicenseCount = item.TotalLicenseCount;
            this.AssignedUserCount = item.AssignedUserCount;
            this.ActiveUserCount = item.ActiveUserCount;
            this.MetricsDate = item.MetricsDate;
        }
    }

    global class profileItem {
        
        @AuraEnabled global String pId {get;set;}
        @AuraEnabled global String pName {get;set;} 
        @AuraEnabled global String pDescription {get;set;}
        @AuraEnabled global String pUserLicense {get;set;}
        @AuraEnabled global Decimal ActiveUserCount {get;set;}

        global profileItem(Profile item, Decimal userCount) {
            this.pId = item.Id;
            this.pName = item.Name;
            this.pDescription = item.Description;
            this.pUserLicense = item.UserLicense.Name;
            this.ActiveUserCount = userCount == null ? 0 : userCount;
        }
    }
}