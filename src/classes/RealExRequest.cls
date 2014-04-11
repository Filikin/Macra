public with sharing class RealExRequest
{
	static MacraMembership__c realExSettings;
	private Statement__c statement = null;
	public String merchantID {get;set;}
	public String amountToPay {get;set;}
	public String timestamp {get;set;}
	public String sha1hash {get;set;}
	
	HttpResponse res;
	public RealExRequest (ApexPages.StandardController controller)
	{
		statement = (Statement__c)controller.getRecord();
		Initialise ();
	}
	
    private void Initialise ()
    {
    }
    
	public void getRealExSettings ()
	{
		realExSettings = MacraMembership__c.getOrgDefaults();
		if (realExSettings.RealEx_Merchant_ID__c == null)
		{
			realExSettings = new MacraMembership__c ();
			insert realExSettings;
		}
	}

    public void sendToRealEx ()
    {
    	getRealExSettings ();
    	if (statement.Total_paid_by_members_to_club__c > 0)
    	{
	    	String amountInCent = (statement.Total_paid_by_members_to_club__c * 100).toPlainString().remove('.');
    		CGICallToRealEx (statement.Name, amountInCent);
    	}
    	else
    	{
    	   	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'The amount paid to the club must be greater than zero - ensure that "Fee paid to club is ticked on the memberships that you are submitting"');
			ApexPages.addMessage(myMsg);
    	}
    }
    
    /*
    <form method="POST" action="https://epage.payandshop.com/epage.cgi">
	<input type="hidden" name="MERCHANT_ID" value="Real	ex Payments	merchant-id">
	<input type="hidden" name="ORDER_ID" value="uniqueorder-id">
	<input type="hidden" name="ACCOUNT" value="sub account name">
	<input type="hidden" name="AMOUNT" value="amount">
	<input type="hidden" name="CURRENCY" value="currency code">
	<input type="hidden" name="TIMESTAMP" value="yyyymmddhhmmss">
	<input type="hidden" name="MD5HASH" value="32 character string">
	<input type="hidden" name="AUTO_SETTLE_FLAG" value="1 or 0">
	<input type="submit" value="Click here to Purchase"	>
	</form> 
	*/
/*    @future (callout=true)
    static*/ public void CGICallToRealEx (String orderID, String amount)
    {
 		realExSettings = MacraMembership__c.getOrgDefaults();
 		merchantID = realExSettings.RealEx_Merchant_ID__c;
 		amountToPay = amount;
        HttpRequest req = new HttpRequest();
        res = new HttpResponse();
        Http http = new Http();
 
        req.setHeader ('referer', URL.getSalesforceBaseUrl().toExternalForm());
        req.setEndpoint('https://epage.payandshop.com/epage.cgi');
        req.setMethod('POST');
        system.debug ('HTTPRequest:referer ' + req.getHeader('referer'));
        
        timestamp = Datetime.now().format ('yyyyMMddHHmmss');
        system.debug ('Timestamp: ' + timestamp);
        
        // order ID needs to be unique, so add the timestamp
        String uniqueOrderID = orderID + timestamp;
        String shaInput = timestamp + '.' + realExSettings.RealEx_Merchant_ID__c + '.' + uniqueOrderID + '.' + amount + '.EUR';
        system.debug ('shaInput: ' + shaInput);
        
        Blob sha = Blob.valueof(shaInput);
        Blob shaStage1 = Crypto.generateDigest('SHA1', sha);
        system.debug ('Blob: ' + shaStage1);
        
        String shaStage2Input =  EncodingUtil.convertToHex(shaStage1).toLowerCase();
        system.debug ('First SHA: ' + shaStage2Input);
        
        shaStage2Input += '.' + realExSettings.RealEx_Shared_Secret__c;
	
	    system.debug ('Second SHA: ' + shaStage2Input);
        Blob sha2 = Blob.valueOf(shaStage2Input);
        Blob shaStage2 = Crypto.generateDigest ('SHA1', sha2);
        
        sha1hash = EncodingUtil.convertToHex(shaStage2);
        system.debug ('Final SHA: ' + sha1hash);
        
//        req.setBody('MERCHANT_ID='+EncodingUtil.urlEncode(name, 'UTF-8')+'&city='+EncodingUtil.urlEncode(city, 'UTF-8'));
		String params = 'MERCHANT_ID='+EncodingUtil.urlEncode(realExSettings.RealEx_Merchant_ID__c, 'UTF-8');
		params += '&ORDER_ID=' + EncodingUtil.urlEncode(uniqueOrderID, 'UTF-8');
		params += '&ACCOUNT=' + EncodingUtil.urlEncode(realExSettings.RealEx_Account_Name__c, 'UTF-8');
		params += '&AMOUNT=' + EncodingUtil.urlEncode(amount, 'UTF-8');
		params += '&CURRENCY=EUR';
		params += '&TIMESTAMP=' + EncodingUtil.urlEncode(timestamp, 'UTF-8');
		params += '&SHA1HASH=' + EncodingUtil.urlEncode(sha1hash, 'UTF-8');
		params += '&AUTO_SETTLE_FLAG=1';
		params += '&STATEMENT_NAME=' + EncodingUtil.urlEncode(orderID, 'UTF-8');
		system.debug ('Params: ' + params);
        req.setBody(params);
 
        try {
            res = http.send(req);
            system.debug (res.toString());
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);
            System.debug(res.toString());
        }
        	
    }
    public String getResponse ()
    {
    	if (res != null) return res.getBody();
    	else return '';
    }
}