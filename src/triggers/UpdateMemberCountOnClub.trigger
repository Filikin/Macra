// this was just a test to see if this trigger fired on a related list - it doesn't
trigger UpdateMemberCountOnClub on Club__c (before update) {
	system.debug ('Before update in UpdateMemberCountOnClub');
}