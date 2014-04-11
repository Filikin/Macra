public class RefreshMembershipAtStartOfYear 
{
	// direct debit memberships are created on the 1st of September and the remaining ones on the 1st of November
	// if goes through all the memberships for the previous year that are lasped or paid and creates new membership records
	// with a status of Paid for DD and Pending for everyone else
	// get all previous year's memberships and clone them, changing the year and status
	// need to create the statements first
	// probably needs to be future
	// First Time Members of new Clubs that affiliated after 1 March 2014 are entitled to free membership for the second year
	
	// use the custom setting membership fees
	
	

	public class applicationException extends Exception {}
	
	MacraMembership__c membershipFees;

	public RefreshMembershipAtStartOfYear ()
	{
	}
	
	public void getDefaultSettings ()
	{
		getDefaultMembershipRates();
	}
	
	private Integer createNewMemberships (Set<ID> currentMembersSet, String membershipStatus, Boolean freeMembership)
	{
		// for each member create a membership record linked to the club's statement 
		Map <ID, ID>clubsToStatements = mapClubsToNextYearsStatements ();
		
		String nextYear = (date.today().year()+1).format().replace(',','');
		
		List<Member__c> membersToJoin = [select ID, Home_club__c, College_club__c, Name, Membership_number__c, Date_joined__c, Pays_by_direct_debit__c from Member__c where ID in :currentMembersSet limit 500]; // the trigger on checking membership status will otherwise cause us to go over the limit
		List<Membership__c>newMemberships = new List<Membership__c>();
		for (Member__c oneMember: membersToJoin)
		{
			// Create a membership record linked to the club's statement - need a map of clubs to statements
			// set status to pending
			try
			{
				ID statementID = clubsToStatements.get (oneMember.College_club__c != null ? oneMember.College_club__c : oneMember.Home_club__c);
				if (statementID == null) throw new applicationException('No club found');
				
				Membership__c oneMembership = new Membership__c (Member__c=oneMember.id, Club__c=oneMember.Home_club__c, Statement__c=statementID, Status__c=membershipStatus, Free_Membership__c=freeMembership);
				if (oneMember.College_club__c != null)
				{
					oneMembership.Dual_membership__c = true;
				} 
				else
				{
					oneMembership.Dual_membership__c = false;
				}
				oneMembership.Year__c = nextYear;				
				newMemberships.add (oneMembership);
			}
			catch (Exception e)
			{
				ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Failed to create membership record for ' + oneMember.Membership_number__c + ' '+ oneMember.Name + ' ' + e.getMessage());
				ApexPages.addMessage(myMsg);
			}
		}
		if (newMemberships.size() > 0) insert newMemberships;
		return newMemberships.size();
	}
	
	// on 1st of November create the non-direct debit memberships
	public pageReference createRemainingMemberships ()
	{
		Map <ID, Member__c> newMembers = new Map<Id, Member__c>([select ID, Name from Member__c where Pays_by_direct_debit__c = False and Date_joined__c=This_Year]);
		Map <ID, Member__c> currentMembers = new Map<Id, Member__c>([select ID, Name from Member__c where id in (select Member__c from Membership__c where Year__c=:getThisYear())]);
		Map <ID, Member__c> futureMembers = new Map<Id, Member__c>([select ID, Name from Member__c where id in (select Member__c from Membership__c where Year__c=:getNextYear())]);

		Set <ID> membersToAddSet = new Set<ID>(currentMembers.keySet());
		membersToAddSet.addAll (newMembers.keySet());
		membersToAddSet.removeAll (futureMembers.keySet());
		
		Integer membershipsCreated = 0;
		if (membersToAddSet.size() > 0)	membershipsCreated = createNewMemberships (membersToAddSet, 'Pending', false);
		
		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, membershipsCreated + ' Pending Membership records created');
		ApexPages.addMessage(myMsg);

		return null;
	}	

	private Map<ID,ID> mapClubsToNextYearsStatements ()
	{
		Map <ID, ID>clubsToStatements = new Map <ID, ID>();
		List <Statement__c>statements = [select ID, Club__c from Statement__c where Membership_year__c=:getNextYear ()];
		for (Statement__c oneStatement: statements)
			clubsToStatements.put (oneStatement.Club__c, oneStatement.ID);
		return clubsToStatements;
	}
	
	public static String getThisYear ()
	{
		return date.today().year().format().replace(',','');
	}
	
	public static String getNextYear ()
	{
		return (date.today().year()+1).format().replace(',','');
	}
	
	// direct debit members are renewed at the start of September - giving time to retry failed direct debits
	public pageReference createDirectDebitMemberships ()
	{
		Map <ID, Member__c> newMembers = new Map<Id, Member__c>([select ID, Name from Member__c where Pays_by_direct_debit__c = True and Date_joined__c=This_Year]);
		Map <ID, Member__c> currentMembers = new Map<Id, Member__c>([select ID, Name from Member__c where Pays_by_direct_debit__c = True and id in (select Member__c from Membership__c where Year__c=:getThisYear())]);
		Map <ID, Member__c> futureMembers = new Map<Id, Member__c>([select ID, Name from Member__c where Pays_by_direct_debit__c = True and id in (select Member__c from Membership__c where Year__c=:getNextYear())]);
		
		Set <ID> membersToAddSet = new Set<ID>(currentMembers.keySet());
		membersToAddSet.addAll (newMembers.keySet());
		membersToAddSet.removeAll (futureMembers.keySet());
		
		Integer membershipsCreated = 0;
		if (membersToAddSet.size() > 0)	membershipsCreated = createNewMemberships (membersToAddSet, 'Paid', false);
		
		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, membershipsCreated + ' Direct Debit Membership records created');
		ApexPages.addMessage(myMsg);

		return null;
	}	

	// Create membership for new members of new clubs - who do not already have a membership for this year
	public pageReference createFreeMemberships ()
	{
		Date cutoffDateMembers = Date.newInstance (system.today().year(), 3, 1);
		Date cutoffDateClubs = Date.newInstance (system.today().year()-1, 10, 1);
		
		Map <ID, Member__c> futureMembers = new Map<Id, Member__c>([select ID, Name from Member__c where id in (select Member__c from Membership__c where Year__c=:getNextYear())]);
		Map <ID, Member__c> freeMembers = new Map<Id, Member__c>([select ID, Name from Member__c where Date_joined__c >= :cutoffDateMembers and Home_Club__r.Date_approved__c >= :cutoffDateClubs]);
		
		Set <ID> membersToAddSet = new Set<ID>(freeMembers.keySet());
		membersToAddSet.removeAll (futureMembers.keySet());

		Integer membershipsCreated = 0;
		if (membersToAddSet.size() > 0)	membershipsCreated = createNewMemberships (membersToAddSet, 'Paid', true);
		
		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, membershipsCreated + ' Free Membership records created');
		ApexPages.addMessage(myMsg);

		return null;
	}
	
	// All Teagasc College courses are for one year only, so all students who attended these colleges in 2012/13 should be removed from the college club 
	public pageReference removeTeagascStudents ()
	{
		List<Member__c> students = [select ID, College_club__c from Member__c where College_club__c in (select ID from Club__c where Teagasc_college__c = 'Yes')];
		if (students.size() > 0)
		{
			for (Member__c oneStudent: students)
			{
				oneStudent.College_club__c = null;
			}
			update students;
		}

		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, students.size() + ' students removed from Teagasc colleges');
		ApexPages.addMessage(myMsg);

		return null;
	}
	
	private void deleteUnusedStatements ()
	{
		// delete statements with no memberships - happens at the start of the year before the new statements are created
		List<Statement__c>toDelete = [select ID from Statement__c where Number_of_memberships__c = 0];
		if (toDelete.size() > 0) delete toDelete;

		List<Statement__c>notDelete = [select ID, Number_of_memberships__c from Statement__c];
		for (Statement__c nd: notDelete)
		{
			system.debug ('Statement: ' + nd);
		}
	}
	
	// statements are created at the start of September - before the direct debits
	public pageReference createStatements ()
	{
		Integer statementsCreated = 0;
		
		deleteUnusedStatements ();
		
		// clubs may already have statements for this year
		list <Club__c> clubsWithOutStatements = [select ID, OwnerID from Club__c where id not in (select Club__c from Statement__c where Membership_year__c=:getNextYear())];
		if (clubsWithOutStatements.size() > 0)
		{
			// the club needs to own the statement, so that they can process it
			List<Statement__c>newStatements = new List<Statement__c>();
			for (Club__c oneClub :clubsWithOutStatements)	
			{
				Statement__c oneStatement = new Statement__c (Membership_Year__c=getNextYear(), Club__c=oneClub.id, OwnerID=oneClub.OwnerID);
				newStatements.add (oneStatement);
			}
			if (newStatements.size() > 0)
			{
				insert newStatements;
				statementsCreated = newStatements.size();
			}
		}	
		
		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, statementsCreated + ' Statements created');
		ApexPages.addMessage(myMsg);
		return null;
	}
	
	void getDefaultMembershipRates ()
	{
		membershipFees = MacraMembership__c.getOrgDefaults();
		if (membershipFees.First_time_members__c == null)
		{
			membershipFees = new MacraMembership__c (First_time_members__c=20, Second_year_members__c=20, Direct_debit_members__c=35, Other_members__c=40);
			insert membershipFees;
		}
	}
}