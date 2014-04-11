/*
	Author: Eamon Kelly, Enclude
	Purpose: Stub for counting number of current members in a club
	Called from: Salesforce scheduler
*/
global class ScheduleClubMemberCount implements Schedulable
{
   global void execute(SchedulableContext SC) 
   {
      CountClubMembers countMembers = new CountClubMembers(); 
      countMembers.CountMembers();
   }
}