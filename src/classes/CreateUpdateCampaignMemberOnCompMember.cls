public with sharing class CreateUpdateCampaignMemberOnCompMember implements TriggerDispatcher.ITriggerEntry
{
	public void MainEntry (String TriggerObject, Boolean isBefore, Boolean isDelete, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isExecuting,
		List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap)
	{
		if (trigger.isUpdate)
		{
			CompetitionMemberBeingUpdated (newMap);
		}
		else if (trigger.isInsert && isAfter)
		{
			CompetitionMemberBeingInserted (newList);
		}
		else if (trigger.isDelete)
		{
			CompetitionMemberBeingDeleted (oldMap);
		}
	}
	
	public void CompetitionMemberBeingDeleted (Map<ID, sObject> compMemberMap)
	{
		delete [select ID from CampaignMember where Competition_Member__c in :compMemberMap.keyset()];
	}

	public void CompetitionMemberBeingInserted (List<Competition_Member__c> cmList)
	{
		// need to create a campaign member with the campaign matching the competition of the competition member
		// the contact of the campaign member needs to match the member of the competition member
		Set<Id>membersSet = new Set<Id>();
		Set<Id>competitionsSet = new Set<Id>();
		for (Competition_Member__c oneCM: cmList)
		{
			membersSet.add (oneCM.Member__c);
			competitionsSet.add (oneCM.Competition__c);
		}
		
		List<Contact> contacts = [select ID, Member_details__c from Contact where Member_details__c in :membersSet];
		Map<ID, ID>memberToContact = new Map<ID,ID>();
		for (Contact oneContact: contacts)
			memberToContact.put (oneContact.Member_details__c, oneContact.ID);
		
		List<Campaign> campaigns = [select ID, Competition_details__c from Campaign where Competition_details__c in :competitionsSet];
		Map<ID, ID>competitionToCampaign = new Map<ID,ID>();
		for (Campaign oneCampaign: campaigns)
			competitionToCampaign.put (oneCampaign.Competition_details__c, oneCampaign.ID);
		
		List<CampaignMember>cms = new List<CampaignMember>();
		for (Competition_Member__c oneCM: cmList)
		{
			ID competitionID = competitionToCampaign.get(oneCM.Competition__c);
			ID memberContactID = memberToContact.get(oneCM.Member__c);
			if (competitionID == null)
			{
				oneCM.Competition__c.addError ('Failed to add member to competition, no campaign assocated with this competition found');
			} 
			else if (memberContactID == null)
			{
				oneCM.Member__c.addError ('Failed to add member to competition, no contact found for this member');
			}
			else
			{
				CampaignMember oneCampaignMember = new CampaignMember (Competition_Member__c=oneCM.id, CampaignID=competitionID, ContactID=memberContactID, Payment_status__c=oneCM.Status__c);
				oneCampaignMember.Team_contact__c = oneCM.Team_contact__c;
				cms.add (oneCampaignMember);
			}
		}
		try
		{		
			if (cms.size() > 0) insert cms;
		}
		catch (Exception e)
		{
			cmList[0].addError ('Failed to add member to competition ' + e.getMessage());
		}
	}

	public void CompetitionMemberBeingUpdated (Map<ID, sObject> compMemberMap)
	{
		// only the status and the team contact flag can be updated
		List<CampaignMember> cms = [select ID, Competition_Member__c, Payment_status__c, Team_contact__c from CampaignMember where Competition_Member__c in :compMemberMap.keyset()];
		List<Competition_Member__c> cmList = (List<Competition_Member__c>)compMemberMap.Values();
		system.debug ('CompetitionMemberBeingUpdated ' + cms);
		if (cms.size() > 0)
		{
			for (CampaignMember oneCM: cms)
			{
				Competition_Member__c oneCompetitionMember = (Competition_Member__c)compMemberMap.get (oneCM.Competition_Member__c);
				if (oneCompetitionMember != null) 
				{
					oneCM.Payment_status__c = oneCompetitionMember.Status__c;
					oneCM.Team_contact__c = oneCompetitionMember.Team_contact__c;
				}
			}
			update cms;
		}
	}		
}