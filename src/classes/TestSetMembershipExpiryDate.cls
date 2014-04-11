@isTest
public class TestSetMembershipExpiryDate {
	


	static public testMethod void TestNewMembership()
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

/*		
		Statement__c s = new Statement__c();
		insert s;
		
		Membership__c mship2 = new Membership__c (Member__c=m.id, Club__c=club.id, Year__c='2012', Status__c='Paid', Statement__c=s.id);
		insert mship2;
		Membership__c mship1 = new Membership__c (Member__c=m.id, Club__c=club.id, Year__c='2013', Status__c='Pending', Statement__c=s.id);
		insert mship1;
		
		Club__c homeclub = [select Number_of_paid_members__c from Club__c where id=:club.id];
		system.assertEquals (0, homeclub.Number_of_paid_members__c);
		
		Member__c changedMember = [select ID, Most_recent_membership_status__c from Member__c where ID=:m.id];
		system.assertEquals ('2013 Pending', changedMember.Most_recent_membership_status__c);
		
		mship1.Status__c = 'Paid';
		update mship1;
		changedMember = [select ID, Most_recent_membership_status__c from Member__c where ID=:m.id];
		
		system.assertEquals ('2013 Paid', changedMember.Most_recent_membership_status__c);
		
		mship2.Status__c = 'Gone';
		update mship2;
		changedMember = [select ID, Most_recent_membership_status__c from Member__c where ID=:m.id];
		system.assertEquals ('2013 Paid', changedMember.Most_recent_membership_status__c);
			
		delete mship1;
		changedMember = [select ID, Most_recent_membership_status__c from Member__c where ID=:m.id];
		system.assertEquals ('2012 Gone', changedMember.Most_recent_membership_status__c);
			    	
		Membership__c mship3 = new Membership__c (Member__c=m.id, Club__c=club.id, Year__c='2014', Status__c='Expired', Statement__c=s.id);
		insert mship3;
		changedMember = [select ID, Most_recent_membership_status__c from Member__c where ID=:m.id];
		system.assertEquals ('2014 Expired', changedMember.Most_recent_membership_status__c);

		Membership__c mship4 = new Membership__c (Member__c=m.id, Club__c=club.id, Year__c='2010', Status__c='Expired', Statement__c=s.id);
		insert mship4;
		changedMember = [select ID, Most_recent_membership_status__c from Member__c where ID=:m.id];
		system.assertEquals ('2014 Expired', changedMember.Most_recent_membership_status__c);

		delete m;
		
		*/
    }


}