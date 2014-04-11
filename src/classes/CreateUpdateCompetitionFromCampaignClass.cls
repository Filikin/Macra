public with sharing class CreateUpdateCompetitionFromCampaignClass implements TriggerDispatcher.ITriggerEntry
{
	public void MainEntry (String TriggerObject, Boolean isBefore, Boolean isDelete, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isExecuting,
		List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap)
	{
		if (trigger.isUpdate)
		{
			CampaignBeingUpdated (newList);
		}
		else if (trigger.isInsert)
		{
			CampaignBeingInserted (newList);
		}
		else if (trigger.isDelete)
		{
			CampaignBeingDeleted (oldList);
		}
	}
	
	public void CampaignBeingDeleted (List<Campaign> campaignList)
	{
		List<Competition__c>competitionsToDelete = new List<Competition__c>();
		for (Campaign oneCampaign: campaignList)
		{
			if (oneCampaign.Type == 'Competition' && oneCampaign.Competition_details__c != null)
			{
				competitionsToDelete.add (new Competition__c (ID=oneCampaign.Competition_details__c));
			}
		}
		if (competitionsToDelete.size() > 0) delete competitionsToDelete;
	}
	
	public void CampaignBeingInserted (List<Campaign> campaignList)
	{
		for (Campaign oneCampaign: campaignList)
		{
			if (oneCampaign.Type == 'Competition')
			{
				Competition__c oneComp = new Competition__c (Name=oneCampaign.Name, Start_date__c=oneCampaign.StartDate, Description__c=oneCampaign.Description, Closing_date_for_entries__c=oneCampaign.Closing_date_for_entries__c);
				oneComp.Show_on_competition_portal__c = oneCampaign.Show_on_competition_portal__c;
				oneComp.Maximum_age__c = oneCampaign.Maximum_age__c;
				oneComp.Minimum_age__c = oneCampaign.Minimum_age__c;
				insert oneComp;
				oneCampaign.Competition_details__c = oneComp.id;				
			}
		}
	}
	
	public void CampaignBeingUpdated (List<Campaign> campaignList)
	{
		Set<ID>compSetToUpdate = new Set<ID>();
		Map<Id, Competition__c>compListToUpdate = new Map<Id,Competition__c>();
		for (Campaign oneCampaign: campaignList)
		{
			if (oneCampaign.Type == 'Competition' && oneCampaign.Competition_details__c != null)
			{
				compSetToUpdate.add (oneCampaign.Competition_details__c);		
			}
		}
		if (compSetToUpdate.size() > 0)
		{
			compListToUpdate = new Map<Id, Competition__c>([select Name, Start_Date__c, Description__c, Closing_date_for_entries__c, Maximum_age__c, Minimum_age__c, Show_on_competition_portal__c from Competition__c where ID in :compSetToUpdate]);
			for (Campaign oneCampaign: campaignList)
			{
				if (oneCampaign.Type == 'Competition' && oneCampaign.Competition_details__c != null)
				{
					Competition__c oneComp = compListToUpdate.get(oneCampaign.Competition_details__c);
					if (oneComp != null)
					{
						oneComp.Name=oneCampaign.Name;
						oneComp.Start_date__c=oneCampaign.StartDate;
						oneComp.Description__c=oneCampaign.Description;
						oneComp.Closing_date_for_entries__c=oneCampaign.Closing_date_for_entries__c;
						oneComp.Maximum_age__c = oneCampaign.Maximum_age__c;
						oneComp.Minimum_age__c = oneCampaign.Minimum_age__c;
						oneComp.Show_on_competition_portal__c = oneCampaign.Show_on_competition_portal__c;
					}
				}
			}
			update compListToUpdate.Values();
		}
	}
}