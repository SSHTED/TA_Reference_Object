/**
* @Class : DPL_TimeZoneName
*   - 타임존명
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
global class DPL_TimeZoneName extends VisualEditor.DynamicPickList {
	global override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('[S] Custom', 'standard:custom');
        return defaultValue;
    }
    
    global override VisualEditor.DynamicPickListRows getValues() {
        
        VisualEditor.DynamicPickListRows myValues = new VisualEditor.DynamicPickListRows();

        Schema.DescribeFieldResult fieldResult = User.TimeZoneSidKey.getDescribe();
        
        list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();      
        for(Schema.PicklistEntry f : ple){
            myValues.addRow(new VisualEditor.DataRow(f.getLabel(), f.getValue()));
        }      
        
        return myValues;
    }
}