public class BCEmailTemplate {
    
    private static String templateHtmlValue; 
    
    public BCEmailTemplate(String TemplateName){
        
        EmailTemplate template = [SELECT Id
                                  , Name
                                  , HtmlValue 
                                  FROM EmailTemplate 
                                  Where Name =:TemplateName
                                  Limit 1];
        templateHtmlValue = template.HtmlValue;        
           
    }
    
    public String generate(String UserName){        
        templateHtmlValue = templateHtmlValue.replace('%%user_name%%', UserName);
        
        return templateHtmlValue;
    }
    
}