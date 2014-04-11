public class UpdateCampaignMember implements TriggerDispatcher.ITriggerEntry
{
	public void MainEntry (String TriggerObject, Boolean isBefore, Boolean isDelete, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isExecuting,
		List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap)
	{
		if (trigger.isInsert)
		{
			CampaignMemberBeingInserted (newList);
		}
		else if (trigger.isUpdate)
		{
			CampaignMemberBeingUpdated (oldMap, newList);
		}
		else if (trigger.isDelete)
		{
			CampaignMemberBeingDeleted (oldList);
		}
	}

	public void CampaignMemberBeingInserted (List<CampaignMember> cmList)
	{
		// if the user is creating a new campaign member on a competition, then create the competition member
		List<Competition_Member__c> newCompMembers = new List<Competition_Member__c>();
		Set<ID>campaignSet = new Set<ID>();
		Set<ID>contactSet = new Set<ID>();
		for (CampaignMember oneCM: cmList)
		{
			campaignSet.add (oneCM.CampaignId);
			contactSet.add (oneCM.ContactId);
		}
		Map <ID, Contact> contactMap = new Map<ID, Contact>([select ID, Member_details__c from Contact where ID in :contactSet and Member_details__c != null]);
		
		if (campaignSet.size()>0)
		{
			Map<ID, Campaign>campaignMap = new Map<ID, Campaign>([select ID, Competition_details__c from Campaign where ID in :campaignSet and Type = 'Competition' and Competition_details__c != null]);
			if (campaignMap.size() > 0)
			{
				for (CampaignMember oneCM: cmList)
				{
					if (campaignMap.keySet().contains(oneCM.CampaignID) && contactMap.keySet().contains(oneCM.ContactID))
					{
						Competition_Member__c newCM = new Competition_Member__c (Competition__c = campaignMap.get(oneCM.CampaignID).Competition_details__c, Member__c = contactMap.get(oneCM.ContactID).Member_details__c);
						newCM.Team_contact__c = oneCM.Team_contact__c;
						newCompMembers.add(newCM);
					}
				}
				if (newCompMembers.size() > 0) 
				{
					insert newCompMembers;	
					// Now make the link between the campaign member and the competition member
					Map<ID, ID>MembersToCompMembersMap = new Map<ID, ID>();
					for (Competition_Member__c oneCompM : newCompMembers)
						MembersToCompMembersMap.put (oneCompM.Member__c, oneCompM.id);
					for (CampaignMember oneCM: cmList)
					{
						if (campaignMap.keySet().contains(oneCM.CampaignID) && contactMap.keySet().contains(oneCM.ContactID))
						{
							ID idofMember = contactMap.get(oneCM.ContactID).Member_details__c;
							system.debug ('Member is: ' + idofMember);
							ID idofCompMember = MembersToCompMembersMap.get(idofMember);
							oneCM.Competition_Member__c = idofCompMember;
							system.debug ('Competition Member is: ' + idofCompMember);
						}
						
					}
				}
				
			}
		}
	}

	public void CampaignMemberBeingUpdated (Map<ID, sObject> oldCMMap, List<CampaignMember> cmList)
	{
		Set<ID>toChange = new Set <ID>();
		List<Competition_Member__c> membersToChange = new List<Competition_Member__c>();
		for (CampaignMember cm: cmList)
		{
			if (cm.Competition_Member__c != null) 
			{
				toChange.add (cm.Competition_Member__c);
				system.debug ('Competition Member ID is: ' + cm.Competition_Member__c);
			}
		}
		if (toChange.size() > 0)
		{
			Map<ID, Competition_Member__c> compmmemToChange = new Map <ID, Competition_Member__c>([select ID, Team_contact__c from Competition_Member__c where ID in :toChange]);
			for (CampaignMember cm: cmList)
			{
				Competition_Member__c compMem = compmmemToChange.get(cm.Competition_Member__c);
				if (compMem != null) 
				{
					compMem.Team_contact__c = cm.Team_contact__c;
					membersToChange.add (compMem);
				}
			}
			update membersToChange;
		}
	}

	public void CampaignMemberBeingDeleted (List<CampaignMember> cmList)
	{
		Set<ID>toDelete = new Set <ID>();
		for (CampaignMember cm: cmList)
			toDelete.add (cm.Competition_Member__c);
		if (toDelete.size() > 0) delete [select ID from Competition_Member__c where ID in :toDelete];
	}
	
	static testMethod void testCampaignMemberCreated ()
    {
    	Campaign parentcamp = new Campaign (Name='Parent campaign', Description='Some description', StartDate=system.today(), Closing_date_for_entries__c=system.today()+7);
    	insert parentcamp;

    	Campaign camp = new Campaign (Name='Test campaign', Description='Some description', StartDate=system.today(), ParentID=parentcamp.id, Closing_date_for_entries__c=system.today()+7);
    	insert camp;
    	
    	Competition__c newComp = [select ID, Description__c, Start_date__c from Competition__c where Name='Test campaign' limit 1];
    	
      	Club__c club = new Club__c (Name='Donegally Macra');
    	insert club;
 
     	Member__c m = new Member__c (Name='JoeWalsh890', Date_of_Birth__c=Date.newInstance(1994, 1, 1), Street__c='3 Main street', Area_or_Town__c='Ennis', Date_joined__c=system.today());
     	m.Home_club__c = club.id;
    	insert m;
    	
		Statement__c s = new Statement__c();
		insert s;

		Membership__c mship1 = new Membership__c (Member__c=m.id, Club__c=club.id, Year__c='2013', Status__c='Paid', Statement__c=s.id);
		insert mship1;

		Contact newContact = [select ID from Contact where LastName='JoeWalsh890' limit 1];
		CampaignMember cm = new CampaignMember (CampaignID=Camp.ID, ContactId=newContact.id);
		cm.Team_contact__c = false;
		insert cm; // this should add the member to the competition
		
		cm = [select id, competition_member__c, team_contact__c from CampaignMember where id = :cm.id];
		Competition_Member__c memberAdded = [select ID, Member__c, Team_contact__c from Competition_Member__c where Competition__c = :newComp.id limit 1];
		system.assertEquals (m.id, memberAdded.Member__c);
		system.assertEquals (false, memberAdded.Team_contact__c);
		system.assertEquals (cm.Competition_Member__c, memberAdded.id);
		
		cm.Team_contact__c = true;
		update cm;
		Competition_Member__c memberChanged = [select ID, Member__c, Team_contact__c from Competition_Member__c where Competition__c = :newComp.id limit 1];
		system.assertEquals (true, memberChanged.Team_contact__c);
		
		delete cm;
    }
}