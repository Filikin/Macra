trigger UpdateContactWhenMemberUpdated on Member__c (after update) 
{
	list<Member__c> members = [select ID, Email__c, (select ID, Email from Contacts__r) from Member__c where ID in :trigger.newMap.keySet()];
	list<Contact> contactsToChange = new list<Contact>();
	for (Member__c oneMember : members)
	{
		if (oneMember.Contacts__r != null && oneMember.Contacts__r.size()>0 && oneMember.Email__c != oneMember.Contacts__r[0].Email)
		{
			oneMember.Contacts__r[0].Email = oneMember.Email__c;
			contactsToChange.add (oneMember.Contacts__r[0]);
		}
	}
	if (contactsToChange.size() > 0) update contactsToChange;
}