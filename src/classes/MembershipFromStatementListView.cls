public with sharing class MembershipFromStatementListView 
{
	private Statement__c statement = null;
	private Membership__c [] memberships= null;
	public MembershipFromStatementListView (ApexPages.StandardController controller)
	{
		statement = (Statement__c)controller.getRecord();
		Initialise ();
	}
	
    private void Initialise ()
    {
		memberships = [select Name, id, Member__c, Member__r.Name, Membership_number__c, Fee_paid_to_club__c, Status__c, Reason_for_rejection__c from Membership__c where Statement__c = :statement.id order by Member__r.Name asc];
    }
    
    public Membership__c [] getMembershipList ()
    {
    	return memberships;
    }
    
    public PageReference submit ()
    {
    	update memberships;
    	String theId = ApexPages.currentPage().getParameters().get('id');
 
    	// Redirect the user back to the original page
        PageReference pageRef = new PageReference('/' + theId);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    static testMethod void TestUpdateMembership()
    {
 		Club__c club = new Club__c (Name = 'Test club');
		insert club; 

 		Club__c collegeclub = new Club__c (Name = 'collgege club', College_club__c=true);
		insert collegeclub; 

  	 	Member__c m = new Member__c (Name='JoeWalsh890', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis', Date_joined__c=system.today(), Home_club__c=club.id);
  	 	m.College_club__c = collegeclub.id;
    	m.City_or_County__c='County Clare';
    	m.Phone__c = '0851234567';
    	m.Email__c = 'test@test.com';
    	insert m;
		
		Statement__c s = new Statement__c();
		insert s;
		
		Membership__c mship2 = new Membership__c (Member__c=m.id, Club__c=club.id, Year__c='2012', Status__c='Paid', Statement__c=s.id);
		insert mship2;
		Membership__c mship1 = new Membership__c (Member__c=m.id, Club__c=club.id, Year__c='2013', Status__c='Pending', Statement__c=s.id);
		insert mship1;
		
        ApexPages.StandardController stmController = new ApexPages.StandardController(s);
		MembershipFromStatementListView mslv = new MembershipFromStatementListView (stmController);
		system.assertEquals (2, mslv.getMembershipList().size());
		mslv.submit();
    }
}