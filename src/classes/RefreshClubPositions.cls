/*
	Author: Maeve Kerneyy, Enclude
	Purpose: Refresh club positions to cater for un-set positions or expiry of club positions
	Called from: ScheduleClubPositionUpdate - early each morning
	Tested in: TestRefreshClubPositions
*/

public with sharing class RefreshClubPositions 
{
	public RefreshClubPositions()
	{
		
	} 
	
	public void RemoveOldPositions()
	{
		// Check positions that expired yesterday.  
		// Assume AddNewPositions will always be run after this report so it is safe to set expired positions to null
		List<Office_position__c> officePositionCandidateRecords = new List<Office_position__c>();
		Date compareDate = Date.today().addDays(-1);
		officePositionCandidateRecords = [SELECT Id, Member__c, Start_date__c, End_date__c, Position__c, Position_is_current__c, Club__c 
				from Office_position__c where Type_of_Position__c = 'Club' and End_date__c = :compareDate];
		
		System.Debug('oPCandidateRecords: '+officePositionCandidateRecords);
		
		// Get club lookup records
		Set <ID> candidateClubs = new Set <ID>();
		for (Office_position__c position: officePositionCandidateRecords)
		{
			candidateClubs.add(position.Club__c); 
		}
		
		Map <ID, Club__c> candidateClubMap = 
		new Map<ID, Club__c>([SELECT ID, Club_Chair__c, Club_Secretary__c, Club_PRO__c, Club_Treasurer__c FROM Club__c WHERE ID in :candidateClubs]); 
		
		System.Debug('candidateClubs: '+candidateClubs);
		System.Debug('candidateClubMap: '+candidateClubMap);
		
		// Identify which club records need to be updated
		Map<ID, Club__c> clubsForUpdate = new Map<ID,Club__c>();
		for (Office_position__c thisPosition: officePositionCandidateRecords)
		{
			Club__c thisClub = candidateClubMap.get(thisPosition.Club__c);
			System.debug('thisClub: '+thisClub); 
			
			if (thisClub != null) 
			{
				if ((thisPosition.Position__c == 'Club Chair')&&(thisClub.Club_Chair__c == thisPosition.Member__c))
				{
					thisClub.Club_Chair__c = null;
					if (clubsForUpdate.get(thisClub.Id) == null)
						clubsForUpdate.put(thisClub.Id,thisClub);
				}
				else if ((thisPosition.Position__c == 'Club Secretary') && (thisClub.Club_Secretary__c == thisPosition.Member__c)) 
				{
					thisClub.Club_Secretary__c = null;
					if (clubsForUpdate.get(thisClub.Id) == null)
						clubsForUpdate.put(thisClub.Id,thisClub);			
				}
				else if((thisPosition.Position__c == 'Club PRO')&& (thisClub.Club_PRO__c == thisPosition.Member__c))
				{
					thisClub.Club_PRO__c = null;
					if (clubsForUpdate.get(thisClub.Id) == null)
						clubsForUpdate.put(thisClub.Id,thisClub);
				}
				else if((thisPosition.Position__c == 'Club Treasurer') && (thisClub.Club_Treasurer__c == thisPosition.Member__c))
				{
					thisClub.Club_Treasurer__c = null;
					if (clubsForUpdate.get(thisClub.Id) == null)
						clubsForUpdate.put(thisClub.Id,thisClub);
				}
			}
		}	
		
		System.Debug('clubsForUpdate: '+clubsForUpdate);
		if (clubsForUpdate.size()>0)
			update clubsForUpdate.values();
			
	
	}
	
	
	
	
	public void AddNewPositions()
	{
		// Check that all current positions are correctly reflected
		// Identify the office position records that need to have updates applied, then call the same code used in Trigger to update
		List<Office_position__c> officePositionCandidateRecords = new List<Office_position__c>();
		officePositionCandidateRecords = [SELECT Id, Member__c, Start_date__c, End_date__c, Position__c, Position_is_current__c, Club__c
				from Office_position__c where Type_of_Position__c = 'Club' and Position_is_current__c = True and Start_date__c <= TODAY];
		
		// Get club lookup records
		Set <ID> impactedClubs = new Set <ID>();
		for (Office_position__c position: officePositionCandidateRecords)
		{
			impactedClubs.add(position.Club__c);
		}
		Map <ID, Club__c> impactedClubMap = 
		new Map<ID, Club__c>([SELECT ID, Club_Chair__c, Club_Secretary__c, Club_PRO__c, Club_Treasurer__c FROM Club__c WHERE ID in :impactedClubs]); 
		
		System.debug('ImpactedClubMap: '+impactedClubMap);
		
		// Identify which position records need to be processed
		List<Office_position__c> officePositionsForUpdate = new List<Office_position__c>();
		for (Office_position__c thisPosition: officePositionCandidateRecords)
		{
			Club__c thisClub = impactedClubMap.get(thisPosition.Club__c);
			System.debug('thisClub: '+thisClub); 
			
			if ( (thisClub != null) && (
				((thisPosition.Position__c == 'Club Chair')&&(thisClub.Club_Chair__c != thisPosition.Member__c)) ||
			    ((thisPosition.Position__c == 'Club Secretary') && (thisClub.Club_Secretary__c != thisPosition.Member__c)) ||
			    ((thisPosition.Position__c == 'Club PRO')&& (thisClub.Club_PRO__c != thisPosition.Member__c)) ||
			    ((thisPosition.Position__c == 'Club Treasurer') && (thisClub.Club_Treasurer__c != thisPosition.Member__c))) )
			{
				officePositionsForUpdate.add(thisPosition);
			}
			
		}
		
		// Now call the code to update the clubs
		CreateUpdateOfficePosition updateClubs = new CreateUpdateOfficePosition();
		updateClubs.UpdateClubPosition(officePositionsForUpdate);
		 
	}
}