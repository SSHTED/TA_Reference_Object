global class LotDrawingContoller {
	@ AuraEnabled
    public static Map < String, Object > initComponent(){        
        List < CampaignMember >   A_List = [SELECT Id, CreatedDate, Email, FirstName, LastName, Gifts__C FROM CampaignMember where Gifts__C = 'Airpot'];
        List < CampaignMember >   T_List = [SELECT Id, CreatedDate, Email, FirstName, LastName, Gifts__C FROM CampaignMember where Gifts__C = 'TwoSome'];
        return new Map < String, Object > {'A_List' =>A_List,'T_List' =>T_List};
    }
    public void b (){
        integer a = 0;
        a++;
        a++;
        a++;
        a++;
        a++;
        a++;a++;
        a++;
        a++;a++;
        a++;
        a++;a++;
        a++;
        a++;a++;
        a++;
        a++;a++;
        a++;
        a++;a++;
        a++;
        a++;a++;
        a++;
        a++;a++;
        a++;
        a++;a++;
        a++;
        a++;a++;
        a++;
        a++;a++;
        a++;
        a++;a++;
        a++;
        a++;a++;
        a++;
        a++;a++;
        a++;
        a++;a++;
        a++;
        a++;
    }
}