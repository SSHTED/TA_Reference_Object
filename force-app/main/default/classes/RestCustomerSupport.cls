@RestResource(urlMapping='/customerSupport')
global class RestCustomerSupport {
	
	@HttpGet
	global static void restProcess(){
		
		// JSON Padding callback
		String callback = RestContext.request.params.get('callback');
		
		// method
		String method = RestContext.request.params.get('method');
				
		// run method
		String response = '';
		if(method == 'create'){
			response = create();
		}
		
		// response Content-Type
		if(callback != null){
			RestContext.response.addHeader('Content-Type', 'application/javascript');	
		}
		else{
			RestContext.response.addHeader('Content-Type', 'application/json');
		}
		
		// response Body
		if(callback != null){
			RestContext.response.responseBody = Blob.valueOf(callback + '('+response+')');	
		}
		else{
			RestContext.response.responseBody = Blob.valueOf(response);
		}				
	}
	
	private static String create(){
		String result = '';
		
		try
		{
			CustomerSupport__c cs = new CustomerSupport__c();
        	cs.Name__c =  RestContext.request.params.get('name');
        	cs.Phone__c =  RestContext.request.params.get('phone');
        	cs.Email__c =  RestContext.request.params.get('email');
        	cs.ServiceType__c = RestContext.request.params.get('serviceType');
        	cs.CaseReason__c =  RestContext.request.params.get('reason');
        	cs.Title__c =  RestContext.request.params.get('title');
        	cs.Description__c = RestContext.request.params.get('description');
        	cs.SourcePath__c = RestContext.request.params.get('source');
        	
        	insert cs;
        	
        	result = '{result : \'success\', id:\''+cs.Id+'\'}';
		}
		catch(Exception ex){
			result = '{result : \'fail\', msg:\''+ex.getMessage()+'\'}';
		}

		return result;
	}
}