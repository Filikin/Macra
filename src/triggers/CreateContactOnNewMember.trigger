trigger CreateContactOnNewMember on Member__c (after insert) 
{
	// Create the contact the set the club
	// also set the owner of the club to be the owner of the member - so that the club secretary can see the member
	// also create an affiliation for that member on the club's current statement
	List<Contact>newContacts = new List<Contact>();
	List<Member__c>members = [select ID, OwnerID, Name, Home_club__c, College_club__c, Email__c, Salutation__c from Member__c where ID in :trigger.newMap.keySet()];
	
	Set <ID>memberClubs = new Set<ID>();
	
	// find the club of the current user, only use if the club is not already filled in
	User secretary = [select Contact.Club_details__c from User where ID=:UserInfo.getUserID() limit 1];
	ID secretaryHomeClub = null;
	if (secretary != null)
		secretaryHomeClub = secretary.Contact.Club_details__c;
	
	for (Member__c oneMember: members)
	{
		if (oneMember.Home_club__c == null && secretaryHomeClub != null)
			oneMember.Home_club__c = secretaryHomeClub; 
	
		if (oneMember.Home_club__c !=null)
			memberClubs.add (oneMember.Home_club__c);
	}
	
	Map <ID, Club__c> clubsWithTheseMembers = new Map<ID, Club__c>([select ID, OwnerID, (select ID from Statements__r where Payment_Method__c = 'Payment pending' order by Membership_year__c desc) from Club__c where id in :memberClubs]);
	list <Membership__c> affiliationsForNewMembers = new list<Membership__c>();
	
	Id memberRecordTypeID = null;
	List<RecordType>memberRecordType =  [Select Id from RecordType where Name = 'Member' limit 1];
	if (memberRecordType.size() > 0) memberRecordTypeID =  memberRecordType[0].id;
	
	 
	for (Member__c oneMember: members)
	{
		if (oneMember.Home_club__c != null) 
		{
			Club__c membersClub = clubsWithTheseMembers.get (oneMember.Home_club__c);
			if (membersClub != null) 
			{
				oneMember.OwnerId = membersClub.OwnerId;
				
				if (oneMember.College_club__c == null && membersClub.Statements__r.size() > 0) // then create a new affilitation linked to this club and statement - unless a student
				{
					
					// set expiry date:  From March onwards, expiry date is end of October NEXT year
					Integer endYear = system.today().year();
					if (system.today().month()> 2) endYear++;   
			 				
					Date expiryDate =  Date.newinstance(endYear,10,31);
					system.debug('Expiry date:' + expiryDate);		
					
					Membership__c newAffiliation = new Membership__c (Member__c=oneMember.id, Club__c=membersClub.id, Status__c='Pending', Statement__c=membersClub.Statements__r[0].id, Expiry__c=expiryDate);
					affiliationsForNewMembers.add (newAffiliation);
				}
			}
		} 
		
		String[]names = oneMember.Name.split(' ',2);
		String firstName, lastName;
		if (names.size() > 1) 
		{
			firstName = names[0];
			lastName = names[1];
		}
		else lastName = names[0];
		
		Contact newContact = new Contact (RecordTypeID=memberRecordTypeID, FirstName=firstName, LastName=lastName);
		newContact.EMail = oneMember.Email__c;
		newContact.Salutation = oneMember.Salutation__c;
		newContact.Member_details__c = oneMember.Id;
		newContacts.add (newContact);
		
				
	}	
	if (newContacts.size() > 0) insert newContacts;
	update members;
	if (affiliationsForNewMembers.size() > 0) insert affiliationsForNewMembers;
}