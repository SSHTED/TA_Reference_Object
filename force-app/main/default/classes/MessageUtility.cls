global class MessageUtility{
    
    global static void showMsg(ApexPages.Severity sev, String message){
		ApexPages.Message msg = new ApexPages.Message(sev, message);
		ApexPages.addMessage(msg);
    }
        
	global static void showConfirm(Object conf)
    {
		showMsg(ApexPages.Severity.Confirm,String.Valueof(conf));
	}
	global static void showInfo(Object info)
	{
        showMsg(ApexPages.Severity.Info,String.Valueof(info));
	}
        
    global static void showWarning(Object warning)
	{
        showMsg(ApexPages.Severity.Warning,String.Valueof(warning));
	}
        
    global static void showError(Object err)
	{
        showMsg(ApexPages.Severity.Error,String.Valueof(err));
	}  
}