/*
	Author: Maeve Kerney, Enclude
	Purpose: Stub for updating club positions 
	Called from: Salesforce scheduler
*/

global class ScheduleClubPositionUpdate implements Schedulable 
{
	global void execute(SchedulableContext SC)
	{
		RefreshClubPositions refreshClubs = new RefreshClubPositions();
		refreshClubs.RemoveOldPositions();
		refreshClubs.AddNewPositions();
	}
}