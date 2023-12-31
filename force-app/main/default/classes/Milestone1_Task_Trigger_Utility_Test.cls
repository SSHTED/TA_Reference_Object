/*
Copyright (c) 2011, salesforce.com, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, 
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
    this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
    this list of conditions and the following disclaimer in the documentation 
    and/or other materials provided with the distribution.
    * Neither the name of the salesforce.com, Inc. nor the names of its contributors 
    may be used to endorse or promote products derived from this software 
    without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED 
OF THE POSSIBILITY OF SUCH DAMAGE.

*/
/**
* This Class test Task Trigger functionality  
*/

@isTest
private class Milestone1_Task_Trigger_Utility_Test {
	static Profile pf;
	static User user;

	/**
	* Test exceeded chatter suscription
	*/
    static testMethod void chatterSubscriptionLimitExceeded() {
		pf = DK_UTIL_TestDataFactory.getProfile('Profile : DK BMC - Dev/Consulting');
		user = DK_UTIL_TestDataFactory.createUserByName(pf, 'testuser1@test.kr');

		System.runAs(user) {
			// Create a poject
			Milestone1_Project__c proj = Milestone1_Test_Utility.sampleProjectActive('Chatter Blow');
			insert proj;

			// Create a milestone
			Milestone1_Milestone__c mstone = Milestone1_Test_Utility.sampleMilestone(proj);
			mstone.Kickoff__c = (mstone.Kickoff__c).addDays(3);
			mstone.Deadline__c = (mstone.Deadline__c).addDays(3);
			insert mstone;
			

			Milestone1_Milestone__c mstone1 = Milestone1_Test_Utility.sampleMilestone(proj);
			mstone1.Kickoff__c = (mstone1.Kickoff__c).addDays(3);
			mstone1.Deadline__c = (mstone1.Deadline__c).addDays(3);
			mstone1.Parent_Milestone__c = mstone.id;
			insert mstone1;
			mstone1 = [SELECT Id FROM Milestone1_Milestone__c WHERE Id = :mstone1.Id Limit 1];
			update mstone1;

			// Add 600 tasks to the milestone to exceed chatter user subscription limit
			List<Milestone1_Task__c> lTask = new List<Milestone1_Task__c>();

			for(Integer j = 0; j < 3; j++){        	
				for(Integer i = 0; i < 10; i++){
					lTask.add( Milestone1_Test_Utility.sampleTask(mstone.Id) );
				}
				
				try{
					insert lTask;
				}
				catch(Exception e){
					if( e.getMessage().contains( Milestone1_Task_Trigger_Utility.SUBSCRIPTION_LIMIT_EXCEEDED )){
						system.assert(true);
					}
					else{
						system.assert(false, e.getMessage());
					}
				}

				lTask.clear();
			}

			delete mstone1;
		}
	}
}