trigger CreateUpdateCampaignMemberOnCompetitionMember on Competition_Member__c (before delete, after insert, after update) 
{
	TriggerDispatcher.MainEntry ('Competition_Member__c', trigger.isBefore, trigger.isDelete, trigger.isAfter, trigger.isInsert, trigger.isUpdate, trigger.isExecuting,
		trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
}