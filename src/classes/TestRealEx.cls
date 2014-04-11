@isTest
private class TestRealEx 
{
	static testMethod void RealExRequestTest()
    {
    	MacraMembership__c membershipfees = new MacraMembership__c ();
    	insert membershipfees;
    	
 		Club__c club = new Club__c (Name = 'Test club');
		insert club; 

  	 	Member__c m = new Member__c (Name='JoeWalsh890', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis', Date_joined__c=system.today(), Home_club__c=club.id);
    	m.City_or_County__c='County Clare';
    	m.Phone__c = '0851234567';
    	m.Email__c = 'test@test.com';
    	insert m;
		
		Statement__c s = new Statement__c(Membership_year__c='2014', Club__c=club.id);
		insert s;
		
		Membership__c mship = new Membership__c (Member__c=m.id, Club__c=club.id, Year__c='2014', Status__c='Pending', Statement__c=s.id);
		mship.Fee_paid_to_club__c = true;
//		insert mship; -- causing an internal Salesforce error
		
    	ApexPages.StandardController rlxController = new ApexPages.StandardController(s);
    	RealExRequest rlx = new RealExRequest(rlxController);
    	rlx.getRealExSettings();
    	rlx.sendToRealEx ();
    	rlx.getResponse();
   	
   		rlx.CGICallToRealEx ('STM-1234', '2000');
    }
    
    static testMethod void RealExOKResponseTest()
    {
    	PageReference pageRef = Page.RealExResponse;
     	pageRef.getParameters().put('RESULT','00');
     	pageRef.getParameters().put('PASREF','12345');
     	test.setCurrentPage(pageRef);
     
    	RealExResponse resp = new RealExResponse();
    	resp.processResult();
    }

    static testMethod void RealExFailResponseTest()
    {
    	PageReference pageRef = Page.RealExResponse;
     	pageRef.getParameters().put('RESULT','01');
     	pageRef.getParameters().put('MESSAGE','Some Error');
     	test.setCurrentPage(pageRef);
     
    	RealExResponse resp = new RealExResponse();
    	resp.processResult();
    }
}