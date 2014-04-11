trigger AddClubToPositionIfPortal on Office_position__c (before insert, before update) 
{
	// as well as assigning the club, also want to assign the contact, based on the member - required for reports
	// at the moment, only interested in this for club positions where the user is a portal user
	Set<ID>membersSet = new Set<ID>();
	for (Office_position__c oneOffice: trigger.new)
		if (oneOffice.Member__c != null) 
			membersSet.add (oneOffice.Member__c);
		
	if (membersSet.size() > 0)
	{
		Map<ID, Member__c> membersMap = new Map<ID, Member__c>([select ID, Home_club__c, (Select ID from Contacts__r) from Member__c where ID in :membersSet]);
		for (Office_position__c onePosition: trigger.new)
		{
			Member__c memberToadd = membersMap.get (onePosition.Member__c);
			if (memberToadd != null && memberToadd.Contacts__r.size() > 0)
			{
				onePosition.Contact__c = memberToadd.Contacts__r[0].id;
				if (UserInfo.getUserType().contains('Portal'))
				{
					if (onePosition.Club__c == null)
					{
						if (memberToadd != null) onePosition.Club__c = memberToadd.Home_club__c;
					}
				}
			}
		}
	}
}