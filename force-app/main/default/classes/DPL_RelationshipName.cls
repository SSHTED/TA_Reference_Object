/**
* @Class : DPL_RelationshipName
*   - 관계 이름
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
global class DPL_RelationshipName extends VisualEditor.DynamicPickList 
{
    VisualEditor.DesignTimePageContext context;

    global DPL_RelationshipName(VisualEditor.DesignTimePageContext context) {
       this.context = context;
    }
    
	global override VisualEditor.DataRow getDefaultValue() {
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('AttachedContentDocument (LinkedEntityId)', 'AttachedContentDocuments');
        return defaultValue;
    }
    
    global override VisualEditor.DynamicPickListRows getValues() {
        
        VisualEditor.DynamicPickListRows myValues = new VisualEditor.DynamicPickListRows();

        //System.debug(context.entityName);
        //System.debug(context.pageType);
        
        String objectStr = context == null ? 'Account' : context.entityName;

        DescribeSObjectResult describe = Schema.getGlobalDescribe().get(objectStr).getDescribe();

        for (Schema.ChildRelationship child : describe.getChildRelationships()) {
            if(child.getRelationshipName() != null) {
				myValues.addRow(new VisualEditor.DataRow(child.getChildSObject() + ' (' + child.getField() + ')'
                                                     	, child.getRelationshipName()));
            }
        }

        return myValues;
    }
}