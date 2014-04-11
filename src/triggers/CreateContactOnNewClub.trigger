trigger CreateContactOnNewClub on Club__c (after insert) 
{
	// Create the contact the set the club
	List<Contact>newContacts = new List<Contact>();
	
	Id clubRecordTypeID = null;
	List<RecordType>clubRecordType =  [Select Id from RecordType where Name = 'Club contact' limit 1];
	if (clubRecordType.size() > 0) clubRecordTypeID =  clubRecordType[0].id;
	
	for (Club__c oneClub:trigger.new)
	{
		String[]names = oneClub.Name.split(' ',2);
		String firstName, lastName;
		if (names.size() > 1) 
		{
			firstName = names[0];
			lastName = names[1];
		}
		else lastName = names[0];
		
		Contact newContact = new Contact (RecordTypeID=clubRecordTypeID, FirstName=firstName, LastName=lastName, Club_details__c=oneClub.id);
		newContacts.add (newContact);
	}	
	if (newContacts.size() > 0) insert newContacts;
}