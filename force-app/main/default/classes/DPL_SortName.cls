/**
* @Class : DPL_SortName
*   - 정렬 순서명
*
* @Method : 
*   - override getDefaultValue()
*   - override getValues()
*
* @Author : YongJin, Cha
* @Date : 2019. 02. 16.
* @Version : 0.1
* @Modified : 
*  ----------------------------------------------
*  NO | Date       | Modifier       | Description 
*  ----------------------------------------------
*  1. | 2019-02-16 | YongJin, Cha  	| 최초작성
*/
global class DPL_SortName extends VisualEditor.DynamicPickList 
{
	global override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('ASC', 'asc');
        return defaultValue;
    }
    
    global override VisualEditor.DynamicPickListRows getValues() {
        
        VisualEditor.DynamicPickListRows myValues = new VisualEditor.DynamicPickListRows();

        List<Dynamic_Pick_List__mdt> mdt = [select Label, Value__c, Category__c 
                                              from Dynamic_Pick_List__mdt 
                                             where Category__c = 'SortName'
                                             order by Label];

        for(Dynamic_Pick_List__mdt DPL : mdt) {
			myValues.addRow(new VisualEditor.DataRow(DPL.Label, DPL.Value__c));
        }
/*        
        List<MT_Dynamic_Pick_List__c> li = [select Label__c, Value__c from MT_Dynamic_Pick_List__c where Category__c = 'SortName' order by Label__c];

        VisualEditor.DynamicPickListRows myValues = new VisualEditor.DynamicPickListRows();
        
        for(MT_Dynamic_Pick_List__c DPL : li) {
			myValues.addRow(new VisualEditor.DataRow(DPL.Label__c, DPL.Value__c));
        }
*/        
        return myValues;
    }
}