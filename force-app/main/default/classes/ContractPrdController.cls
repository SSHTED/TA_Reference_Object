public with sharing class ContractPrdController
 {
		public Product__c prd {get; set;}	//Product 	
		public list<Product__c> plist {get;set;} //ProductList
		public list<ContractProduct__c> cplist {get;set;} //ContractProductList
		public ContractProduct__c cprd {get;set;} //ContractProduct
		public String selectedid{get;set;} //SelectButton ID
		public String deletedid {get;set;} //DeleteButton ID
		public String conid {get;set;} //vf Parameter
		
		public set<Id> prdid; //Product ID

		public ContractPrdController()  //Constructor
		{
			 prdid = new set<Id>();
			 prd = new Product__c();
			 plist = new list<Product__c>();
			 cplist = new list<ContractProduct__c>();  
			 cprd = new ContractProduct__c();	
			 conid = ApexPages.currentPage().getParameters().get('cid');		
			 selectedid = this.selectedid;		
			 deletedid = this.deletedid;	 
		}
	
		public void getProductList() //SearchList
		{				
			if(String.isNotEmpty(prd.depth_one__c))
			{
				
				plist = [select depth_one__c, depth_two__c, depth_three__c, depth_four__c, id, Name 
							 from Product__c 
							 where depth_one__c =:prd.depth_one__c
							 order by depth_two__c DESC]; 
				
					if(String.isNotEmpty(selectedid)) 
					{
						
						plist = [select depth_one__c, depth_two__c, depth_three__c, depth_four__c, id, Name 
							 	from Product__c 
							 	where id !=:prdid
							 	and depth_one__c=:prd.depth_one__c
							 	order by depth_two__c DESC];
					}
					
				if(String.isNotEmpty(prd.depth_two__c))
				{
					plist = [select depth_one__c, depth_two__c, depth_three__c, depth_four__c, id, Name 
							 from Product__c 
							 where depth_one__c =:prd.depth_one__c 
							 and  depth_two__c =:prd.depth_two__c 
							 order by depth_three__c DESC];
					
					if(String.isNotEmpty(selectedid))
					{
						
						plist = [select depth_one__c, depth_two__c, depth_three__c, depth_four__c, id, Name 
							 	from Product__c 
							 	where id !=:prdid 
							 	and depth_one__c=:prd.depth_one__c
							 	and  depth_two__c =:prd.depth_two__c
							 	order by depth_two__c DESC]; 
					}		  
							 
							 					
					if(String.isNotEmpty(prd.depth_three__c)) 
					{
						plist = [select depth_one__c, depth_two__c, depth_three__c, depth_four__c, id, Name 
					        	 from Product__c 
								 where depth_one__c =:prd.depth_one__c 
							 	 and  depth_two__c =:prd.depth_two__c 
							 	 and depth_three__c =:prd.depth_three__c 
							 	 order by depth_four__c DESC];	
								
							if(String.isNotEmpty(selectedid))
							{
								prdid.add(selectedid);
								plist = [select depth_one__c, depth_two__c, depth_three__c, depth_four__c, id, Name 
							 	from Product__c 
							 	where id !=:prdid   
							 	and depth_one__c=:prd.depth_one__c
							 	and  depth_two__c =:prd.depth_two__c
							 	and depth_three__c =:prd.depth_three__c
							 	order by depth_two__c DESC]; 
							}		 								 	 
						}
					}					
				}	 		  	 
			}		 
			 		
				
		public void selectProduct() //SelectList
		{	
			integer num = 0;
			
			for(Product__c p : plist)
			{							      
				if(p.id == selectedid)
				{
					ContractProduct__c cp = new ContractProduct__c();			
					cp.product__c = p.id;	
					cp.contract__c = conid;	
					cp.supplyPrice__c = 0;
					cp.number__c = 0;	
					cplist.add(cp);	 
					break;
				}
				num++;
			} 
			system.debug(plist.size());	
			
			if((plist != null) && (plist.size() != 0) && (String.isNotEmpty(selectedid)))
			{			
			plist.remove(num);
			prdid.add(selectedid);
			system.debug(plist.size());	
			}
			 
		}

		public void deleteProduct() //DeleteList
		{	
			integer index = 0; 
		
			Product__c p = new Product__c();
			for(ContractProduct__c cp : cplist)
			{		
				if(cp.product__c == deletedid) 
				{		 				
	 				p = [select depth_one__c, depth_two__c, depth_three__c, depth_four__c, id, Name 
	 					 from Product__c
	 					 where id =: deletedid]; 
					break;							
				} 			 
				index ++;
			}	
			if((cplist != null) && (cplist.size() != 0) && (String.isNotEmpty(deletedid)))
			{			
			cplist.remove(index);
			prdid.remove(deletedid);
			}
			
			if((p.depth_one__c==prd.depth_one__c) && (!(prdid.contains(deletedid)))) 																																																									
			{
				plist.add(p);
				plist = [select  depth_one__c, depth_two__c, depth_three__c, depth_four__c, id, Name 
						from Product__c 
						where id !=: prdid and depth_one__c =:prd.depth_one__c 					
						order by depth_two__c DESC];
						system.debug('=====1-1=====');
						
				if((p.depth_two__c==prd.depth_two__c) && (!(prdid.contains(deletedid))))
				{
					plist.add(p);
					plist = [select  depth_one__c, depth_two__c, depth_three__c, depth_four__c, id, Name 
						from Product__c 
						where id !=: prdid 
						and depth_one__c =:prd.depth_one__c 
						and depth_two__c =:prd.depth_two__c 					
						order by depth_three__c DESC];
						system.debug('=====1-2=====');
				}		
				else if((p.depth_two__c != prd.depth_two__c) && (!(prdid.contains(deletedid))))
				{
					plist.add(p);
					plist = [select  depth_one__c, depth_two__c, depth_three__c, depth_four__c, id, Name 
						from Product__c 
						where id !=: prdid 
						and depth_one__c =:prd.depth_one__c 
						order by depth_two__c DESC];
						system.debug('=====1-3=====');
				}	
				
					if(String.isNotEmpty(prd.depth_two__c))
					{
						plist = [select depth_one__c, depth_two__c, depth_three__c, depth_four__c, id, Name 
								 from Product__c 
							 	 where depth_one__c =:prd.depth_one__c 
							 	 and  depth_two__c =:prd.depth_two__c 
							 	 order by depth_three__c DESC];
							 	 system.debug('=====2-1=====');
									
							if((p.depth_three__c==prd.depth_three__c) && (!(prdid.contains(deletedid))))
							{
								plist.add(p);
								plist = [select  depth_one__c, depth_two__c, depth_three__c, depth_four__c, id, Name 
										from Product__c 
										where id !=: prdid 
										and depth_one__c =:prd.depth_one__c 
										and depth_two__c =:prd.depth_two__c														
										order by depth_two__c DESC];
										system.debug('=====2-2=====');
							}											
							else if((p.depth_three__c != prd.depth_three__c) && (!(prdid.contains(deletedid))))
							{
								plist.add(p);
								plist = [select  depth_one__c, depth_two__c, depth_three__c, depth_four__c, id, Name 
										from Product__c 
										where id !=: prdid 
										and depth_one__c =:prd.depth_one__c 
										and depth_two__c =:prd.depth_two__c 
										order by depth_two__c DESC];
										system.debug('=====2-5=====');
							}
							
						if(String.isNotEmpty(prd.depth_three__c)) 
						{
							plist = [select depth_one__c, depth_two__c, depth_three__c, depth_four__c, id, Name 
					        		 from Product__c 
									 where depth_one__c =:prd.depth_one__c 
							 	 	 and  depth_two__c =:prd.depth_two__c 
							 	 	 and depth_three__c =:prd.depth_three__c 
							 	 	 order by depth_four__c DESC];
							 	 	 system.debug('=====3-1=====');	
							 	 	 
							if((p.depth_four__c==prd.depth_four__c) && (!(prdid.contains(deletedid))))
							{
								plist.add(p);
								plist = [select  depth_one__c, depth_two__c, depth_three__c, depth_four__c, id, Name 
										from Product__c 
										where id !=: prdid 
										and depth_one__c =:prd.depth_one__c 
										and depth_two__c =:prd.depth_two__c
										and depth_three__c =:prd.depth_three__c 				
										order by depth_three__c DESC];	
										system.debug('=====3-2=====');			
							}		
							else if((p.depth_four__c != prd.depth_four__c) && (!(prdid.contains(deletedid))))
							{
								plist.add(p);
								plist = [select  depth_one__c, depth_two__c, depth_three__c, depth_four__c, id, Name 
										from Product__c 
										where id !=: prdid 
										and depth_one__c =:prd.depth_one__c 
										and depth_two__c =:prd.depth_two__c 
										and depth_three__c =:prd.depth_three__c 
										order by depth_three__c DESC];
										system.debug('=====3-3=====');  
							} 
						}	 	 
					}	 
				}
			}
						
		public PageReference listSave() //Save
		{
				ContractProduct__c cp = new ContractProduct__c();	
				PageReference reference = new PageReference('/' + conid); 
				if(cp.product__c !='')
				{
				    insert cplist; 
				}
				if(cplist.size() == 0)
				{
					apexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'최소 하나의 제품을 선택하세요.'));
					return null; 	
				}		
			return reference; 						
		} 	
		 
		public PageReference cancel()
		{
			PageReference reference = new PageReference('/' + conid);
			return reference;
		}	 
}