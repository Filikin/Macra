public with sharing class CreateUpdateOfficePosition implements TriggerDispatcher.ITriggerEntry
{
	public void MainEntry (String TriggerObject, Boolean isBefore, Boolean isDelete, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isExecuting,
		List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap)
	{
		if (trigger.isInsert && isAfter)
		{
			OfficePositionBeingInserted (newList);
			LinkContactOnNewPosition (newList);
			UpdateClubPosition (newList);			
		}
	}
	
	
	public void LinkContactOnNewPosition (List<Office_position__c> newList) 
	{
		Map <ID, ID>newClubLinks = new Map <ID, ID>();
		Map <ID, ID>newCountyLinks = new Map <ID, ID>();
		for (Office_position__c onePosition: newList)
		{
			// at the moment, only interested in this for club and county positions
			if (onePosition.Club__c != null)
			{
				newClubLinks.put (onePosition.Member__c, onePosition.id);
			}
			if (onePosition.County_Executive__c != null)
			{
				newCountyLinks.put (onePosition.Member__c, onePosition.id);
			}
		}
		if (newClubLinks.size() > 0)
		{
			List<Contact>clubContacts = [select ID, Club_officer_position__c, Member_details__c from Contact where Member_details__c in :newClubLinks.keySet()];
			if (clubContacts.size() > 0)
			{
				for (Contact oneContact: clubContacts)
				{
					oneContact.Club_officer_position__c = newClubLinks.get (oneContact.Member_details__c);
				}
				update clubContacts;
			}
		}
	
		if (newCountyLinks.size() > 0)
		{
			List<Contact>countyContacts = [select ID, County_Officer_position__c, Member_details__c from Contact where Member_details__c in :newCountyLinks.keySet()];
			if (countyContacts.size() > 0)
			{
				for (Contact oneContact: countyContacts)
				{
					oneContact.County_Officer_position__c = newCountyLinks.get (oneContact.Member_details__c);
				}
				update countyContacts;
			}
		}
	}
	
	
	public void OfficePositionBeingInserted (List<Office_position__c> cmList)
	{
		// not going to work for batches
		if (cmList.size() > 20) return;
		
		List<Office_position__c>positionsToUpdate = new List<Office_position__c>();
//			if (onePosition.County_Executive__c != null) countyExecutives.add (onePosition.County_Executive__c);
//			if (onePosition.Committee__c != null) committees.add (onePosition.Committee__c);
		
		
		for (Office_position__c onePosition: cmList)
		{
			if (onePosition.Club__c != null)
			{
				List<Office_position__c>oldPositions = [select ID, End_Date__c from Office_position__c 
					where End_date__c > :onePosition.Start_date__c and Position__c = :onePosition.Position__c and Club__c = :onePosition.Club__c
					and ID != :onePosition.Id];
				for (Office_position__c oldPosit: oldPositions)
				{
					oldPosit.End_date__c = onePosition.Start_date__c - 1;
					positionsToUpdate.add (oldPosit);
				}					
			}	
			else if (onePosition.County_Executive__c != null)
			{
				List<Office_position__c>oldPositions = [select ID, End_Date__c from Office_position__c 
					where End_date__c > :onePosition.Start_date__c and Position__c = :onePosition.Position__c and County_Executive__c = :onePosition.County_Executive__c
					and ID != :onePosition.Id];
				for (Office_position__c oldPosit: oldPositions)
				{
					oldPosit.End_date__c = onePosition.Start_date__c - 1;
					positionsToUpdate.add (oldPosit);
				}					
			}	
			else if (onePosition.Committee__c != null)
			{
				List<Office_position__c>oldPositions = [select ID, End_Date__c from Office_position__c 
					where End_date__c > :onePosition.Start_date__c and Position__c = :onePosition.Position__c and Committee__c = :onePosition.Committee__c
					and ID != :onePosition.Id];
				for (Office_position__c oldPosit: oldPositions)
				{
					oldPosit.End_date__c = onePosition.Start_date__c - 1;
					positionsToUpdate.add (oldPosit);
				}					
			}	
		}
		if (positionsToUpdate.size() > 0) update positionsToUpdate;	
	}
	
	public void UpdateClubPosition (List<Office_position__c> newList) 
	{
		// For each updated club position, update club record to set relevant field 
		// to point to relevant member record. 
		
		Map<ID, Club__c> impactedClubs = new Map<ID, Club__c>();
		
		for( Office_position__c newPosition : newList)
		{ 
			Boolean isClubUpdate = true;
			Club__c updatedClub;
			ID thisClub = newPosition.club__c; 
			
			// If position end date is in the past or start date is in the future, we will not update
			if ((newPosition.Start_date__c <= system.today()) && (newPosition.End_date__c >= system.today()))
			{
			
				// The club may already be on our list of impacted clubs.
				if (impactedClubs.containsKey(thisClub))
					updatedClub = impactedClubs.get(thisClub);
				else 					
					updatedClub = new Club__c(ID=thisClub);
				
				
				if (newPosition.Position__c == 'Club Chair')
					updatedClub.Club_Chair__c = newPosition.member__c;
				else if (newPosition.Position__c == 'Club Secretary')
					updatedClub.Club_Secretary__c = newPosition.member__c;
				else if (newPosition.Position__c == 'Club Treasurer')
					updatedClub.Club_Treasurer__c = newPosition.member__c;
				else if (newPosition.Position__c == 'Club PRO')
					updatedClub.Club_PRO__c = newPosition.member__c;
				else isClubUpdate = false;
			
				// Do not add club to list if it already exists
				if (isClubUpdate && !impactedClubs.containsKey(thisClub))
					impactedClubs.put(thisClub, updatedClub);
					
				
				system.debug('In position Loop: '+ isClubUpdate + updatedClub); 
				system.debug('Impacted Clubs: ' + impactedClubs);	
			}	
				
		}
		
		if (impactedClubs.size() > 0)
			update impactedClubs.values();
		
		
	}
	
	
}