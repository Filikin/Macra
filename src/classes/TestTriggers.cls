@isTest
public class TestTriggers 
{
	static testMethod void testNewOfficePosition ()
	{
		TestConnectContactWithClubOfficerPosition();
		Club__c testClub = [select ID from Club__c where Name='Test club'];
		
 	  	Member__c m = new Member__c (Name='NewOfficer', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis');
    	m.City_or_County__c='County Clare';
    	m.Phone__c = '0851034567';
    	m.Email__c = 'test2@test.com';
    	m.Home_club__c = testClub.id;
    	insert m; 
    	
		Office_position__c officer = new Office_position__c (Member__c = m.id, Position__c = 'Club Secretary', Start_Date__c=Date.newInstance(2013, 6, 5), End_Date__c=Date.newInstance(2014,11,11), Club__c=testclub.id);
		insert officer;
		
		Date expectedEndDate = Date.newInstance(2013, 6, 4); // the date before the new position starts
		List<Office_position__c>oldPositions = [select ID, End_Date__c from Office_position__c where Start_Date__c < 2013-01-01];
		system.assertEquals (expectedEndDate, oldPositions[0].End_date__c);
	}
	
    static testMethod void TestCreateNewContactFromMember() 
    {
    	Member__c m = new Member__c (Name='Joe Walsh890', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis');
    	m.City_or_County__c='County Clare';
    	m.Phone__c = '0851234567';
    	m.Email__c = 'test@test.com';
    	insert m;
    	
    	Contact newContact = [select ID, EMail from Contact where FirstName='Joe' and LastName='Walsh890' limit 1];
    	system.assertEquals (m.Email__c, newContact.EMail);
    }

    static testMethod void TestDeleteContactFromMember() 
    {
    	Member__c m = new Member__c (Name='Joe Walsh890', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis');
    	m.City_or_County__c='County Clare';
    	m.Phone__c = '0851234567';
    	m.Email__c = 'test@test.com';
    	insert m;

		delete m;    	
    	Integer contacts = [select count() from Contact where FirstName='Joe' and LastName='Walsh890'];
    	system.assertEquals (0, contacts);
    }

    static testMethod void TestCreateNewContactFromMember2() 
    {
    	Member__c m = new Member__c (Name='JoeWalsh890', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis');
    	m.City_or_County__c='County Clare';
    	m.Phone__c = '0851234567';
    	m.Email__c = 'test@test.com';
    	insert m;
    	
    	Contact newContact = [select ID, EMail from Contact where LastName='JoeWalsh890' limit 1];
    	system.assertEquals (m.Email__c, newContact.EMail);
    }
    
    static testMethod void TestConnectContactWithClubOfficerPosition ()
    {
		Club__c club = new Club__c (Name = 'Test club');
		insert club; 
		
    	Member__c m = new Member__c (Name='JoeWalsh890', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis');
    	m.City_or_County__c='County Clare';
    	m.Phone__c = '0851234567';
    	m.Email__c = 'test@test.com';
    	m.Home_club__c = club.id;
    	insert m;
    	
		Office_position__c officer = new Office_position__c (Member__c = m.id, Position__c = 'Club Secretary', Start_Date__c=Date.newInstance(2012, 11, 11), End_Date__c=Date.newInstance(2013,11,11), Club__c=club.id);
		insert officer;
		
    	Contact newContact = [select ID, Club_officer_position__c from Contact where LastName='JoeWalsh890' limit 1];
    	system.assertEquals (officer.id, newContact.Club_officer_position__c);
    }
    
    static testMethod void TestConnectContactWithCountyOfficerPosition ()
    {
    	Member__c m = new Member__c (Name='JoeWalsh890', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis');
    	m.City_or_County__c='County Clare';
    	m.Phone__c = '0851234567';
    	m.Email__c = 'test@test.com';
    	insert m;
    	
		Region__c county = new Region__c (Name = 'Test county');
		insert county; 
		
		Office_position__c officer = new Office_position__c (Member__c = m.id, Position__c = 'Club Secretary', Start_Date__c=Date.newInstance(2012, 11, 11), End_Date__c=Date.newInstance(2013,11,11), County_Executive__c=county.id);
		insert officer;
		
    	Contact newContact = [select ID, County_Officer_position__c from Contact where LastName='JoeWalsh890' limit 1];
    	system.assertEquals (officer.id, newContact.County_Officer_position__c);
    }
    
    static testMethod void TestCreateNewContactFromClub() 
    {
    	Club__c m = new Club__c (Name='Donegally Macra');
    	insert m;
    	
    	Contact newContact = [select ID from Contact where FirstName='Donegally' and LastName='Macra' limit 1];
    	system.assertNotEquals (null, newContact);
    }
    
    static testMethod void TestCreateNewContactFromClub2() 
    {
    	Club__c m = new Club__c (Name='Donegally2');
    	insert m;
    	
    	Contact newContact = [select ID from Contact where LastName='Donegally2' limit 1];
    	system.assertNotEquals (null, newContact);
    }
    
    static public testMethod void TestUpdateMembership()
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
    }
    
    static testMethod void testCampaignTiggers ()
    {
    	Campaign camp = new Campaign (Name='Test campaign', Description='Some description', StartDate=system.today(), Closing_date_for_entries__c=system.today());
    	insert camp;
    	
    	Competition__c newComp = [select ID, Description__c, Start_date__c from Competition__c where Name='Test campaign' limit 1];
    	system.assertEquals ('Some description', newComp.Description__c);
    	system.assertEquals(system.today(), newComp.Start_date__c);
    	
    	camp.Description = 'New description';
    	update camp;
    	
    	newComp = [select ID, Description__c, Start_date__c from Competition__c where Name='Test campaign' limit 1];
    	system.assertEquals ('New description', newComp.Description__c);
    	
    	delete camp;
    	List<Competition__c> newComps = [select ID, Description__c, Start_date__c from Competition__c where Name='Test campaign'];
    	system.assertEquals (0, newComps.size());
    }

    static testMethod void testCompetitionMemberTiggers ()
    {
    	Campaign camp = new Campaign (Name='Test campaign', Description='Some description', StartDate=system.today(), Closing_date_for_entries__c=system.today()+7);
    	insert camp;
    	
    	Competition__c newComp = [select ID, Description__c, Start_date__c from Competition__c where Name='Test campaign' limit 1];
    	
     	Club__c club = new Club__c (Name='Donegally Macra');
    	insert club;
 
     	Member__c m = new Member__c (Name='JoeWalsh890', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis', Date_joined__c=system.today());
     	m.Home_club__c = club.id;
    	insert m;
    	
		Statement__c s = new Statement__c();
		insert s;

		String thisYear = system.today().year().format().replace(',', '');
		Membership__c mship1 = new Membership__c (Member__c=m.id, Club__c=club.id, Year__c=thisYear, Status__c='Paid', Statement__c=s.id);
		insert mship1;

    	Competition_Member__c cm = new Competition_Member__c (Competition__c=newComp.id, Member__c=m.id, Status__c='Applied');
    	insert cm;
    	
    	Contact newContact = [select ID from Contact where LastName='JoeWalsh890' limit 1];
    	
    	CampaignMember campM = [select ID, Payment_status__c, CampaignId, ContactId from CampaignMember where Competition_Member__c=:cm.id];
    	system.assertEquals (cm.Status__c, campM.Payment_status__c);
    	system.assertEquals (camp.id, campM.CampaignId);
    	system.assertEquals (newContact.id, campM.ContactId);
    	
    	cm.Status__c='Paid';
    	update cm;
    	
    	campM = [select ID, Payment_status__c, CampaignId, ContactId from CampaignMember where Competition_Member__c=:cm.id];
    	system.assertEquals (cm.Status__c, campM.Payment_status__c);
    	
    	delete cm;
    	List<CampaignMember> campMs = [select ID from CampaignMember where Competition_Member__c=:campM.id];
    	system.assertEquals (0, campMs.size());
    }
    
    static testMethod void testCampaignMemberTigger ()
    {
    	Campaign parentcamp = new Campaign (Name='Parent campaign', Description='Some description', StartDate=system.today(), Closing_date_for_entries__c=system.today()+7);
    	insert parentcamp;

    	Campaign camp = new Campaign (Name='Test campaign', Description='Some description', StartDate=system.today(), ParentID=parentcamp.id, Closing_date_for_entries__c=system.today()+7);
    	insert camp;
    	
    	Competition__c newComp = [select ID, Description__c, Start_date__c from Competition__c where Name='Test campaign' limit 1];
    	
      	Club__c club = new Club__c (Name='Donegally Macra');
    	insert club;
 
     	Member__c m = new Member__c (Name='JoeWalsh890', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis', Date_joined__c=system.today());
     	m.Home_club__c = club.id;
    	insert m;
    	
		Statement__c s = new Statement__c();
		insert s;
		
		String thisYear = system.today().year().format().replace(',', '');
		Membership__c mship1 = new Membership__c (Member__c=m.id, Club__c=club.id, Year__c=thisYear, Status__c='Paid', Statement__c=s.id);
		insert mship1;

     	Competition_Member__c cm = new Competition_Member__c (Competition__c=newComp.id, Member__c=m.id, Status__c='Applied');
    	insert cm;
    }
    
    static testMethod void TestUpdateMemberEmail() 
    {
    	Member__c m = new Member__c (Name='Joe Walsh890', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis');
    	m.City_or_County__c='County Clare';
    	m.Phone__c = '0851234567';
    	m.Email__c = 'test@test.com';
    	insert m;
    	
    	Contact newContact = [select ID, EMail from Contact where FirstName='Joe' and LastName='Walsh890' limit 1];
    	system.assertEquals (m.Email__c, newContact.EMail);
    	
    	m.Email__c = 'newemail@test.com';
    	update m;
    	
    	newContact = [select ID, EMail from Contact where FirstName='Joe' and LastName='Walsh890' limit 1];
    	system.assertEquals (m.Email__c, newContact.EMail);
    }
    
	static testMethod void TestClubPositionUpdate()
    {
		Club__c club = new Club__c (Name = 'Test club');
		insert club; 
		Date pEndDate = Date.today().addDays(30); // Always want position end date to be in the future for these tests to work.
		
		
    	Member__c m = new Member__c (Name='JoeWalsh890', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis');
    	m.City_or_County__c='County Clare';
    	m.Phone__c = '0851234567';
    	m.Email__c = 'test@test.com';
    	m.Home_club__c = club.id;
    	insert m;
    	
		Office_position__c secretary = new Office_position__c (Member__c = m.id, Position__c = 'Club Secretary', Start_Date__c=Date.newInstance(2012, 11, 11), End_Date__c=pEndDate, Club__c=club.id);
		
		
		Member__c n = new Member__c (Name='MaryJane001', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis');
    	n.City_or_County__c='County Clare';
    	n.Phone__c = '0851234567';
    	n.Email__c = 'test@test.com';
    	n.Home_club__c = club.id;
    	insert n;
    	
		Office_position__c chair = new Office_position__c (Member__c = n.id, Position__c = 'Club Chair', Start_Date__c=Date.newInstance(2012, 11, 11), End_Date__c=pEndDate, Club__c=club.id);
		
		
		Member__c o = new Member__c (Name='AnneKelly002', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis');
    	o.City_or_County__c='County Clare';
    	o.Phone__c = '0851234567';
    	o.Email__c = 'test@test.com';
    	o.Home_club__c = club.id;
    	insert o;
    	
		Office_position__c pro = new Office_position__c (Member__c = o.id, Position__c = 'Club PRO', Start_Date__c=Date.newInstance(2012, 11, 11), End_Date__c=pEndDate, Club__c=club.id);
		
		
		Member__c p = new Member__c (Name='JohnSmith003', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis');
    	p.City_or_County__c='County Clare';
    	p.Phone__c = '0851234567';
    	p.Email__c = 'test@test.com';
    	p.Home_club__c = club.id;
    	insert p;
    	
		Office_position__c treasurer = new Office_position__c (Member__c = p.id, Position__c = 'Club Treasurer', Start_Date__c=Date.newInstance(2012, 11, 11), End_Date__c=pEndDate, Club__c=club.id);
		
		
    	Contact newContact = [select ID, Club_officer_position__c from Contact where LastName='JoeWalsh890' limit 1];
    	system.assertEquals (secretary.id, newContact.Club_officer_position__c);
    	
    	Club__c club2 = new Club__c (Name = 'Second Test club');
		insert club2; 
		
		Member__c c2m = new Member__c (Name='MaryMurphy101', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis');
    	c2m.City_or_County__c='County Clare';
    	c2m.Phone__c = '0851234567';
    	c2m.Email__c = 'test@test.com';
    	c2m.Home_club__c = club2.id;
    	insert c2m;
    	
    	Office_position__c c2secretary = new Office_position__c (Member__c = c2m.id, Position__c = 'Club Secretary', Start_Date__c=Date.newInstance(2012, 11, 11), End_Date__c=pEndDate, Club__c=club2.id);
		 
    	
    	Region__c r = new Region__c (Name='Test Region');
    	insert r;
    
    	Member__c c2n = new Member__c (Name='JohnDoe102', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis');
    	c2n.City_or_County__c='County Clare';
    	c2n.Phone__c = '0851234567';
    	c2n.Email__c = 'test@test.com';
    	c2n.Home_club__c = club2.id;
    	insert c2n;
		
		Office_position__c countysecretary = new Office_position__c (Member__c = c2n.id, Position__c = 'County Secretary', Start_Date__c=Date.newInstance(2012, 11, 11), End_Date__c=pEndDate, Club__c=club2.id);
	
		
		List<Office_position__c> OfficesToBeUpdated = new List<Office_position__c> ();
		OfficesToBeUpdated.Add(secretary);
		OfficesToBeUpdated.Add(chair);
		OfficesToBeUpdated.Add(treasurer);
		OfficesToBeUpdated.Add(pro);
		OfficesToBeUpdated.Add(countysecretary);
		OfficesToBeUpdated.Add(c2secretary);
		
		insert OfficesToBeUpdated;
		System.Debug('OfficesToBeUpdated: '+OfficesToBeUpdated);
		
		List<Club__c> clubs = [SELECT Name, Club_Secretary__c, Club_Chair__c, Club_Treasurer__c, Club_PRO__c from Club__c where Club__c.ID = :club.ID];
		System.Debug('clubs: '+clubs);
		
		system.assertEquals (m.ID, clubs[0].Club_Secretary__c);
		system.assertEquals (n.ID, clubs[0].Club_Chair__c);
		system.assertEquals (o.ID, clubs[0].Club_PRO__c);
		system.assertEquals (p.ID, clubs[0].Club_Treasurer__c);
		
		
    }
    

    
    
}