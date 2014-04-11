/*
Author: Eamon Kelly, Enclude
Purpose: If a member is a patron (Patron check box ticked), move them to the club called "Patrons" - assuming they are not already there
Called from: Trigger
Tested in: TestMoveMemberIfPatron
*/
trigger MoveMemberIfPatron on Member__c (before update) 
{
	Club__c patronClub = null;
	try
	{
		patronClub = [select ID, OwnerID from Club__c where Name = 'Patrons' limit 1];
	}
	catch (Exception e)
	{
		system.debug ('Patrons club not found');
	}
	for (Member__c oneMember: trigger.new)
	{
		if (oneMember.Patron__c)
		{
			if (patronClub != null)
			{
				if (oneMember.Home_club__c != patronClub.id)
				{
					oneMember.Home_club__c = patronClub.Id;
					oneMember.OwnerID = patronClub.OwnerID;
				}
			}
			else
			{
				oneMember.addError ('Cannot more member to Patrons club as Patrons club not found');
			}
		}
	}
}