@isTest
private class TestCountClubMembers {

    static testMethod void CountClubMembersTest() 
    {
    	TestTriggers.TestUpdateMembership();
		CountClubMembers countMembers = new CountClubMembers();
      	countMembers.CountMembers();
    }
}