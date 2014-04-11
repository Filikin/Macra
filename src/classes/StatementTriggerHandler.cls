public class StatementTriggerHandler implements TriggerDispatcher.ITriggerEntry
{
	public void MainEntry (String TriggerObject, Boolean isBefore, Boolean isDelete, Boolean isAfter, Boolean isInsert, Boolean isUpdate, Boolean isExecuting,
		List<SObject> newList, Map<Id, SObject> newMap, List<SObject> oldList, Map<Id, SObject> oldMap)
	{
		if (trigger.isUpdate)
		{
			StatementUpdated ((Map<ID, Statement__c>)newMap, (Map<ID, Statement__c>)oldMap);
		}
		else if (trigger.isInsert)  
		{
			StatementInserted (newList);  
		}
	}
	
	public void StatementInserted (List<Statement__c> stmList)
	{
		// make sure that the owner of the club owns the statement	
		Set <ID>statementClubs = new Set<ID>();
		for (Statement__c oneStm: stmList)
		{
			if (oneStm.Club__c != null) statementClubs.add (oneStm.Club__c);	
		}
		Map <ID, Club__c> clubsWithTheseStatements = new Map<ID, Club__c>([select ID, OwnerID from Club__c where id in :statementClubs]);
		
		for (Statement__c oneStm: stmList)
		{
			ID clubOwnerID = oneStm.Club__c != null ? clubsWithTheseStatements.get(oneStm.Club__c).OwnerID : null;
			if (clubOwnerID != null) oneStm.OwnerId = clubOwnerID; 
		}
	}
	
	public void StatementUpdated (Map<ID, Statement__c> newStatementMap, Map<ID, Statement__c> oldStatementMap)
	{
		// Create a new statement will all the unpaid memberships from the old one - all whose status is pending and do not have "Fee paid to club" ticked
		// create a new statement even if there are no members to add
		List <Statement__c> submittedStatements = [select ID, Payment_method__c, Membership_Year__c, Club__c, 
			(select ID, Statement__c from Memberships__r where Status__c = 'Pending' and Fee_Paid_To_Club__c = false) from Statement__c 
			where Payment_method__c != 'Payment pending' and Id in :newStatementMap.keySet() and Date_Submitted__c = null];
		for (Statement__c oneStatement: submittedStatements)
		{
			Statement__c oldStatement = (Statement__c)oldStatementMap.get (oneStatement.ID);
			if (oldStatement != null && oldStatement.Payment_method__c == 'Payment pending') // it has changed from payment pending
			{
				Statement__c newStatement = new Statement__c (Membership_Year__c=oneStatement.Membership_year__c, Club__c=oneStatement.Club__c, Payment_Method__c='Payment pending');
				insert newStatement;
				for (Membership__c oneMembership : oneStatement.Memberships__r)
				{
					oneMembership.Statement__c = newStatement.ID; // reparent the membership
				}
				update oneStatement.Memberships__r;
			}
		} 
		// SendEmailToClubSecretary(newStatementMap, oldStatementMap);
	}
	
	public void SendEmailToClubSecretary(Map<ID, Statement__c> newStatementMap, Map<ID, Statement__c> oldStatementMap)
	{
		// Send an email to the Club secretary if Payment received flag has been set to True as part of this update
		// Note:  There should only ever be one record in the set of updates as this change will be made from the UI
		//  	  and updating a large number of records would cause the email governor limit to be exceeded 
		List<Statement__c> newStatement = new List<Statement__c>();
		newStatement = newStatementMap.values();
		Statement__c oldStatement = new Statement__c();
		
		if (newStatement.size()==1)
		{
			oldStatement = oldStatementMap.get(newStatement[0].ID);
			if (newStatement[0].Payment_received__c 
				&& (newStatement[0].Payment_received__c != oldStatement.Payment_received__c))
			{
				// Get Club Email address
				List<Contact> clubContactDetails =  new List<Contact> ([SELECT Id, Email, Phone from Contact where Club_details__c = :newStatement[0].Club__c]);
				String contactEmail = clubContactDetails[0].Email;
				
				// Get Email Template identifier
				EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Club_Secretary_Payment_Received' LIMIT 1];
				
				// Send Email
				
				system.debug('clubContactDetails: '+clubContactDetails[0]);
				
				Messaging.SingleEmailMessage paymentConfirmationMail = new Messaging.SingleEmailMessage();
				paymentConfirmationMail.templateId = template.Id; 
				paymentConfirmationMail.targetObjectID = clubContactDetails[0].Id;
				paymentConfirmationMail.setToAddresses(new String[]{clubContactDetails[0].Email});
				paymentConfirmationMail.setWhatId(newStatement[0].Id);
	
				system.debug('paymentConfirmationMail: '+paymentConfirmationMail);
				Messaging.sendEmail (new Messaging.SingleEmailMessage[] {paymentConfirmationMail});
			}
			
		}
		
	}
}