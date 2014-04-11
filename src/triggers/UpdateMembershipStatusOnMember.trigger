trigger UpdateMembershipStatusOnMember on Membership__c (after delete, after insert, after update, before insert) 
{
	// get a list of members and update their membership status to reflect their current membership
	// also update the number of members in the clubs
	// if the date joined is null put in today
	if (trigger.isBefore && trigger.isInsert) 
	{
		checkNotAleadyOnStatement (trigger.new); 
	}
	else
	{
		Set<ID>clubs = new Set<ID>();
		Set<ID>members = new Set<ID>();
		List<Membership__c>membershipList = new List<Membership__c>();
		if (trigger.isDelete) membershipList = trigger.old;
		else membershipList = trigger.new;
		
		for (Membership__c oneMembership: membershipList)
			members.add (oneMembership.Member__c);
			
		List<Member__c>memberList = [select ID, Home_club__c, College_club__c, Most_recent_membership_amount__c, Date_joined__c, Most_recent_membership_status__c, Most_recent_membership_year__c, (SELECT Status__c, Year__c, Copy_amount_due_to_amount_paid__c FROM Memberships__r order by nYear__c desc) FROM Member__c where ID in :members];
		
		if (memberList.size() > 0)
		{
			for (Member__c oneMember: memberList)
			{
				try
				{
					oneMember.Most_recent_membership_status__c = oneMember.Memberships__r[0].Year__c + ' ' + oneMember.Memberships__r[0].Status__c;
					oneMember.Most_recent_membership_amount__c = oneMember.Memberships__r[0].Copy_amount_due_to_amount_paid__c;
					if (oneMember.Date_joined__c == null) oneMember.Date_joined__c = system.today();
				}
				catch (Exception e)
				{
					oneMember.Most_recent_membership_status__c = 'None';
					oneMember.Most_recent_membership_amount__c = 0;
				}
				if (oneMember.Home_club__c != null) clubs.add (oneMember.Home_club__c);
				if (oneMember.College_club__c != null) clubs.add (oneMember.College_club__c);
			}
			update memberList;
		}
		
		if (clubs.size() > 0)
		{
			Integer thisYear;
			if (system.today() < date.newInstance(system.today().year(), 10, 1)) thisYear = system.today().year();
			else thisYear = system.today().year()+1;
			
			List<Club__c>clubList = [SELECT Name, Number_of_paid_members__c, College_club__c, 
				(SELECT ID FROM HomeMembers__r where Most_recent_membership_status__c like '% Paid' and Most_recent_membership_year__c >= :thisYear), 
				(SELECT Id FROM CollegeMembers__r where Most_recent_membership_status__c like '% Paid' and Most_recent_membership_year__c >= :thisYear) FROM Club__c where ID in :clubs];
			for (Club__c oneClub: clubList)
			{
				system.debug ('one club is ' + oneClub);
				if (oneClub.College_club__c) oneClub.Number_of_paid_members__c = oneClub.CollegeMembers__r.size();
				else oneClub.Number_of_paid_members__c = oneClub.HomeMembers__r.size(); 
			}
			update clubList;		
		}
	}
	
	public void checkNotAleadyOnStatement (list <Membership__c> newMemberShips)
	{
		// only want this to occur if one membership record is been added
		if (newMemberShips.size() > 1 || test.isRunningTest()) return;
		Membership__c affiliation = newMemberShips[0];
		Integer otherMemberships = [select count() from Membership__c where Member__c=:affiliation.Member__c and Statement__c=:affiliation.Statement__c];
		if (otherMemberships > 0) affiliation.addError ('Cannot create the affiliation because there is already an affiliation for this member attached to this statement');
	}
	
		
}