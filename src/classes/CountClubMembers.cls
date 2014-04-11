/*
	Author: Eamon Kelly, Enclude
	Purpose: Count number of current members in each club
	Called from: ScheduleClubMemberCount - every night
	Tested in: TestCountClubMembers
*/
public with sharing class CountClubMembers 
{
	public CountClubMembers ()
	{
	}
	
	public void CountMembers ()
	{
		Integer thisYear;
		if (system.today() < date.newInstance(system.today().year(), 10, 1)) thisYear = system.today().year();
		else thisYear = system.today().year()+1;

		List<Club__c>clubList = [SELECT Name, Number_of_paid_members__c, College_club__c, 
			(SELECT ID FROM HomeMembers__r where Most_recent_membership_status__c like '% Paid' and Most_recent_membership_year__c >= :thisYear), 
			(SELECT Id FROM CollegeMembers__r where Most_recent_membership_status__c like '% Paid' and Most_recent_membership_year__c >= :thisYear) FROM Club__c];
		for (Club__c oneClub: clubList)
		{
			if (oneClub.College_club__c) oneClub.Number_of_paid_members__c = oneClub.CollegeMembers__r.size();
			else oneClub.Number_of_paid_members__c = oneClub.HomeMembers__r.size(); 
		}
		update clubList;		
	}
}