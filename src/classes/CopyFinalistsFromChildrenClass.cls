// EK 3 April 2013
// Copy all the campaign members from the previous level that won (or same second) to this campaign
public with sharing class CopyFinalistsFromChildrenClass 
{
	Campaign finalCompetition;
	public CampaignMember cm {get;set;}
	public Map<ID,Campaign>earlierCompetitions;
	public Map<ID,CampaignMember>candidates;

	public CopyFinalistsFromChildrenClass (ApexPages.StandardController controller)
	{
        finalCompetition = [select id from Campaign where ID = :controller.getRecord().id];
		earlierCompetitions = new Map<ID,Campaign>([select ID from Campaign where ParentID = :finalCompetition.id]);
		candidates = new Map<ID,CampaignMember>();
		
		if (earlierCompetitions.size() > 0)
		{
	        // use one of the campaign members as a template
	        cm = null;
			for (ID oneCompetitionID: earlierCompetitions.keySet())
			{
		        try
		        {
		       		cm = [select id, Final_place__c from CampaignMember where CampaignID = :oneCompetitionID limit 1];
		        }
		        catch (Exception e)
		       	{
		       	}
		       	if (cm != null) break;
			}
			if (cm == null)
			{
		    	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning, 'No competitors in the earlier round of this competition.');
				ApexPages.addMessage(myMsg);
			}
		}
		else
		{
	    	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Warning, 'No earlier rounds in this competition. Make sure you have set up the competition heirarchy.');
			ApexPages.addMessage(myMsg);
		}
		
	}
	
	public Integer getNumberOfQualifyingMembers ()
	{
		if (cm == null) return 0;
		List<String> finalPlaces = new List<String>();
		if (cm.Final_place__c == 'Third' || cm.Final_place__c == 'Second' || cm.Final_place__c == 'First')
		{
			finalPlaces.add ('First');
			if (cm.Final_place__c == 'Second' || cm.Final_place__c == 'Third')
			{
				finalPlaces.add ('Second');
				if (cm.Final_place__c == 'Third')
				{
					finalPlaces.add ('Third');
				}
			}
		}
		
		// candidates already in the competition
		Set <ID>contactSetInAlready = new Set<ID>();
		for (CampaignMember oneCM : [select ID, ContactID from CampaignMember where CampaignID = :finalCompetition.ID])
			contactSetInAlready.add (oneCM.ContactID);
		
		candidates = new Map<ID, CampaignMember>([select ID, ContactID, Team_contact__c from CampaignMember where CampaignID in :earlierCompetitions.keySet() and Final_place__c in :finalPlaces and (not (ContactID in :contactSetInAlready))]);
				
		return candidates.size();
	}
	
	public List <Contact> getCandidatesList ()
	{
		if (getNumberOfQualifyingMembers () > 0)
		{
			Set <ID>contactSet = new Set<ID>();
			for (CampaignMember oneCandidate: candidates.values())
				contactSet.add (oneCandidate.ContactID);
			return [select ID, Name, Home_Club__c from Contact where ID in :contactSet];
		}
		else return null;
	}
	
	public pageReference copyFinalists ()
	{
		if (getNumberOfQualifyingMembers () > 0)
		{
			List<CampaignMember> newCMs = new List<CampaignMember>();
			for (CampaignMember oneCM: candidates.values())
			{
				CampaignMember oneCampaignMember = new CampaignMember (CampaignID=finalCompetition.ID, ContactID=oneCM.ContactId, Team_contact__c = oneCM.Team_contact__c);
				newCMs.add (oneCampaignMember);
			}
			insert newCMs;
		}
    	PageReference finalPage = new PageReference ('/' + finalCompetition.id);
		return finalPage;
	}
	
// TESTING

	static void createCampaignMembers (ID CampaignID, Integer numberrequired)
	{
		List<Contact>newContacts = new List<Contact>();
		List<CampaignMember>newCMs = new List<CampaignMember>();
		for (Integer i=1; i<=numberrequired; i++)
		{
			Contact fred = new Contact (LastName='Fred'+numberrequired, email='fred'+numberrequired+'@test.com');
			newContacts.add(fred);
		}
		insert newContacts;    	
		for (Integer i=1; i<=numberrequired; i++)
		{
			CampaignMember cm = new CampaignMember (CampaignID=CampaignID, ContactId=newContacts[i-1].id);
    		if (i==1) cm.Final_place__c = 'First';
    		else if (i==2) cm.Final_place__c = 'Second';
    		else if (i==3) cm.Final_place__c = 'Third';
    		newCMS.add(cm);
		}
		insert newCMS;
	}
	
	static testMethod void testCampaignCopy ()
    {
    	Campaign campFinal = new Campaign (Name='Test campaign', Description='Some description', StartDate=system.today());
    	insert campFinal;

		Campaign semiFinal1 = new Campaign (Name='Semi 1', Parent=campFinal, ParentID=campFinal.id);
		insert semiFinal1;    	

		Campaign semiFinal2 = new Campaign (Name='Semi 2', Parent=campFinal, ParentID=campFinal.id);
		insert semiFinal2;
		
		createCampaignMembers (semiFinal1.id, 5);
		createCampaignMembers (semiFinal2.id, 5);

        ApexPages.StandardController CopyCampaignPage = new ApexPages.StandardController(campFinal);
        CopyFinalistsFromChildrenClass cc = new CopyFinalistsFromChildrenClass (CopyCampaignPage);
        cc.cm.Final_place__c = 'Third';
 		system.assertEquals(6, cc.getNumberOfQualifyingMembers());

		cc.getCandidatesList();
       	
        cc.cm.Final_place__c = 'First';
 		system.assertEquals(2, cc.getNumberOfQualifyingMembers());

        cc.cm.Final_place__c = 'Second';
      	cc.copyFinalists();
		
		// if this worked, should have 4 members in the final
		List <CampaignMember> cms = [SELECT Id FROM CampaignMember where CampaignId = :campFinal.id];
		system.assertEquals(4, cms.size());
		
        cc.cm.Final_place__c = '';
		cc.getCandidatesList();
		
    }
}