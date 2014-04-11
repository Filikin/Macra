@isTest
private class TestMaintenanceSteps 
{
	static testMethod void testStatements ()
	{
		Club__c club = new Club__c (Name = 'Test club');
		insert club; 
		Club__c club2 = new Club__c (Name = 'Test club2');
		insert club2; 
		
		RefreshMembershipAtStartOfYear refmem = new RefreshMembershipAtStartOfYear();
		refmem.getDefaultSettings();
		refmem.createStatements();
		
		List<Statement__c>statements = [select ID from Statement__c];
		system.assertEquals (2, statements.size());
	}	
	
	static testMethod void testRenewMemberships ()
	{
		Integer membersToCreate = 3;
 		Club__c club = new Club__c (Name = 'Test club');
		insert club;
		
		Statement__c statement = new Statement__c (Membership_Year__c=RefreshMembershipAtStartOfYear.getThisYear(), Club__c=club.id); 
		insert statement;

		List<Membership__c>oldMemberships = new List<Membership__c>();
		for (Integer i=1; i<=membersToCreate; i++)
		{
			Member__c m = new Member__c (Name='JoeWalsh890'+i, Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis', Pays_by_direct_debit__c=true, Date_joined__c=system.today().addYears(-3), Home_club__c=club.id);
	    	m.City_or_County__c='County Clare';
	    	m.Phone__c = '0851234567';
	    	m.Email__c = 'test@test.com';
	    	insert (m);
			system.debug ('Date jointed: ' + m.Date_joined__c);
	    	Membership__c oneMembership = new Membership__c (Member__c=m.id, Club__c=m.Home_club__c, Statement__c=statement.ID, Status__c='Paid', Year__c=RefreshMembershipAtStartOfYear.getThisYear());
	    	oldMemberships.add (oneMembership);
		}

		for (Integer i=1; i<=membersToCreate; i++)
		{
			Member__c m = new Member__c (Name='FredWalsh890'+i, Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis', Pays_by_direct_debit__c=false, Date_joined__c=system.today().addYears(-3), Home_club__c=club.id);
	    	m.City_or_County__c='County Clare';
	    	m.Phone__c = '0851234567';
	    	m.Email__c = 'test@test.com';
	    	insert (m);
	    	Membership__c oneMembership = new Membership__c (Member__c=m.id, Club__c=m.Home_club__c, Statement__c=statement.ID, Status__c='Paid', Year__c=RefreshMembershipAtStartOfYear.getThisYear());
	    	oldMemberships.add (oneMembership);
		}
	    insert oldMemberships;
		
		RefreshMembershipAtStartOfYear refmem = new RefreshMembershipAtStartOfYear();
		refmem.getDefaultSettings();
		test.startTest();
		refmem.createStatements();
		test.stopTest();
/*		refmem.createDirectDebitMemberships(); -- this causes an internal salesforce error

		String nextYear = (date.today().year()+1).format().replace(',','');
		List <Member__c> futureMembers = [select ID, Name from Member__c where id in (select Member__c from Membership__c where Year__c=:nextYear)];
		system.assertEquals(membersToCreate, futureMembers.size());
		
		refmem.createRemainingMemberships();
		futureMembers = [select ID, Name from Member__c where id in (select Member__c from Membership__c where Year__c=:nextYear)];
		system.assertEquals(membersToCreate*2, futureMembers.size());
*/	}
	
	static testMethod void testCreateDDMemberships ()
	{/*
		Integer membersToCreate = 5;
		List<Club__c>clubs = new List<Club__c>();
		
 		for (Integer i=1; i<=membersToCreate; i++)
		{
	 		Club__c club = new Club__c (Name = 'Test club'+i);
			clubs.add (club);
		}
		insert clubs; 

		List<Member__c>ddMembers=new List<Member__c>();
		for (Integer i=1; i<=membersToCreate; i++)
		{
			Member__c m = new Member__c (Name='JoeWalsh890'+i, Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis', Pays_by_direct_debit__c=true, Date_joined__c=system.today(), Home_club__c=clubs[i-1].id);
	    	m.City_or_County__c='County Clare';
	    	m.Phone__c = '0851234567';
	    	m.Email__c = 'test@test.com';
	    	ddMembers.add (m);
		}
	    insert ddMembers;
		List<Member__c>nonddMembers=new List<Member__c>();
		for (Integer i=1; i<=membersToCreate; i++)
		{
			Member__c m = new Member__c (Name='FredWalsh890'+i, Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis', Pays_by_direct_debit__c=false, Date_joined__c=system.today(), Home_club__c=clubs[i-1].id);
	    	m.City_or_County__c='County Clare';
	    	m.Phone__c = '0851234567';
	    	m.Email__c = 'test@test.com';
	    	nonddMembers.add (m);
		}
	    insert nonddMembers;
		
		RefreshMembershipAtStartOfYear refmem = new RefreshMembershipAtStartOfYear();
		refmem.getDefaultSettings();
		refmem.createStatements();
		refmem.createDirectDebitMemberships();

		String nextYear = (date.today().year()+1).format().replace(',','');
		List <Member__c> futureMembers = [select ID, Name from Member__c where id in (select Member__c from Membership__c where Year__c=:nextYear)];
		system.assertEquals(membersToCreate, futureMembers.size());
		
		refmem.createRemainingMemberships();
		futureMembers = [select ID, Name from Member__c where id in (select Member__c from Membership__c where Year__c=:nextYear)];
		system.assertEquals(membersToCreate*2, futureMembers.size());
	*/}
	
	static testMethod void testCreateCollegeMemberships ()
	{
		Integer membersToCreate = 5;
		
  		Club__c homeclub = new Club__c (Name = 'Home club');
  		Club__c collegeclub = new Club__c (Name = 'College club', College_club__c=true);
		insert homeclub;
		insert collegeclub;

		List<Member__c>ddMembers=new List<Member__c>();
		for (Integer i=1; i<=membersToCreate; i++)
		{
			Member__c m = new Member__c (Name='JoeWalsh890'+i, Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis', Pays_by_direct_debit__c=true, Date_joined__c=system.today(), Home_club__c=homeclub.id);
	    	m.City_or_County__c='County Clare';
	    	m.Phone__c = '0851234567';
	    	m.Email__c = 'test@test.com';
	    	m.College_club__c = collegeclub.id;
	    	ddMembers.add (m);
		}
	    insert ddMembers;
		List<Member__c>nonddMembers=new List<Member__c>();
		for (Integer i=1; i<=membersToCreate; i++)
		{
			Member__c m = new Member__c (Name='FredWalsh890'+i, Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis', Pays_by_direct_debit__c=false, Date_joined__c=system.today(), Home_club__c=homeclub.id);
	    	m.City_or_County__c='County Clare';
	    	m.Phone__c = '0851234567';
	    	m.Email__c = 'test@test.com';
	    	m.College_club__c = collegeclub.id;
	    	nonddMembers.add (m);
		}
	    insert nonddMembers;
		
		RefreshMembershipAtStartOfYear refmem = new RefreshMembershipAtStartOfYear();
		refmem.getDefaultSettings();
		refmem.createStatements();
		refmem.createFreeMemberships();
		refmem.createDirectDebitMemberships();

		String nextYear = (date.today().year()+1).format().replace(',','');
/*		List <Member__c> futureMembers = [select ID, Name from Member__c where id in (select Member__c from Membership__c where Year__c=:nextYear)];
		system.assertEquals(membersToCreate, futureMembers.size());
		
		refmem.createRemainingMemberships();
		futureMembers = [select ID, Name from Member__c where id in (select Member__c from Membership__c where Year__c=:nextYear)];
		system.assertEquals(membersToCreate*2, futureMembers.size());
*/
	}
	
	static testMethod void testCreateTeagascCollegeMemberships ()
	{
		Integer membersToCreate = 5;
		
  		Club__c homeclub = new Club__c (Name = 'Home club');
  		Club__c collegeclub = new Club__c (Name = 'College club', College_club__c=true, Teagasc_college__c='Yes');
		insert homeclub;
		insert collegeclub;

		List<Member__c>ddMembers=new List<Member__c>();
		for (Integer i=1; i<=membersToCreate; i++)
		{
			Member__c m = new Member__c (Name='JoeWalsh890'+i, Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis', Pays_by_direct_debit__c=true, Date_joined__c=system.today(), Home_club__c=homeclub.id);
	    	m.City_or_County__c='County Clare';
	    	m.Phone__c = '0851234567';
	    	m.Email__c = 'test@test.com';
	    	m.College_club__c = collegeclub.id;
	    	ddMembers.add (m);
		}
	    insert ddMembers;
		List<Member__c>nonddMembers=new List<Member__c>();
		for (Integer i=1; i<=membersToCreate; i++)
		{
			Member__c m = new Member__c (Name='FredWalsh890'+i, Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis', Pays_by_direct_debit__c=false, Date_joined__c=system.today(), Home_club__c=homeclub.id);
	    	m.City_or_County__c='County Clare';
	    	m.Phone__c = '0851234567';
	    	m.Email__c = 'test@test.com';
	    	m.College_club__c = collegeclub.id;
	    	nonddMembers.add (m);
		}
	    insert nonddMembers;
		
		RefreshMembershipAtStartOfYear refmem = new RefreshMembershipAtStartOfYear();
		refmem.getDefaultSettings();
		refmem.removeTeagascStudents();
	}
}