trigger DeleteContactWhenMemberDeleted on Member__c (before delete) 
{
	list<Member__c> members = [select ID, (select ID from Contacts__r) from Member__c where ID in :trigger.oldMap.keySet()];
	list<Contact> contactsToDelete = new list<Contact>();
	for (Member__c oneMember : members)
	{
		if (oneMember.Contacts__r != null && oneMember.Contacts__r.size()>0)
		{
			contactsToDelete.add (oneMember.Contacts__r[0]);
		}
	}
	if (contactsToDelete.size() > 0) delete contactsToDelete;
}