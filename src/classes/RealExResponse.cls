/*
	<h2>Statement:&nbsp;<apex:outputText value="{!$CurrentPage.parameters.ORDER_ID}"/></h2>
	<h2>AUTHCODE:&nbsp;<apex:outputText value="{!$CurrentPage.parameters.AUTHCODE}"/></h2>
	<h2>RESULT:&nbsp;<apex:outputText value="{!$CurrentPage.parameters.RESULT}"/></h2>
	<h2>MESSAGE:&nbsp;<apex:outputText value="{!$CurrentPage.parameters.MESSAGE}"/></h2>
	<h2>PASREF:&nbsp;<apex:outputText value="{!$CurrentPage.parameters.PASREF}"/></h2>
*/
public with sharing class RealExResponse 
{
	public String happened {get;set;}
	public RealExResponse ()
	{
		happened = 'Yes';
	}
	
	public void processResult ()
	{
		try
		{
			String result = ApexPages.currentPage().getParameters().get('RESULT');
			if (result == '00')
			{
				happened = 'Payment received, please update the statement with the RealEx Confirmation number: ' + ApexPages.currentPage().getParameters().get('PASREF');
				happened += '<br/>and change the payment method to "Paid by RealEx"';
			}
			else
			{
				happened = 'Error ' + result + ' ' + ApexPages.currentPage().getParameters().get('MESSAGE');
			}
		}
		catch (Exception e)
		{
			happened = e.getMessage();
		}
	}
	
// this version attempts to update the statement directly, however it uses the credentitals of the portal guest user and they cannot change the ownership
// of the statement created by the trigger 
// if using this code, turn off the "with sharing" on the CreteNewStatementOnUpdate class
/*	public void processResultV1 ()
	{
		try
		{
			String result = ApexPages.currentPage().getParameters().get('RESULT');
			if (result == '00')
			{
				String statementName = ApexPages.currentPage().getParameters().get('STATEMENT_NAME');
				List <Statement__c> stms = [select ID, Name, Payment_method__c, Realex_confirmation_number__c from Statement__c where Name=:statementName limit 1];
				if (stms.size() > 0)
				{
					Statement__c stm = stms[0];
					stm.Payment_method__c = 'Paid by RealEx';
					stm.Realex_confirmation_number__c = ApexPages.currentPage().getParameters().get('PASREF');
					update stm;
					happened = 'Payment received, the statement has been updated with the reference: ' + stm.Realex_confirmation_number__c;
				}
				else happened = 'Error: No statement found';
			}
			else
			{
				happened = 'Error ' + result + ' ' + ApexPages.currentPage().getParameters().get('MESSAGE');
			}
		}
		catch (Exception e)
		{
			happened = e.getMessage();
		}
	}
	*/
}