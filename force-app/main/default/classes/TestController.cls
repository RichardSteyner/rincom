public class TestController {
    
    public String strNewContacts{ get;set; }
  	public String strBussinessOwners{ get;set; }
    public Opportunity opportunityPAF{ get;set; }
    public Contact contactPresident { get;set; }
    public Contact contactSecretary { get;set; }
    public Contact contactShareholder { get;set; }
    
    public Transient Blob imagePresident{ get;set; }
	public Transient Blob imageSecretary{ get;set; }
    
    public Account account { get;set; }
    public Contact contact { get;set; }
    public Contact contact1 { get;set; }
    public Opportunity opportunity {get;set;}
    
    public Date auxCloseDate {get;set;}
    public Date auxDateofBirth {get; set;}
    
    public List<Opportunity> opps {get;set;}
    
    public String messageAlert {get; set;}
    
    public TestController(){
        strNewContacts = '';
        strBussinessOwners = '';
        opportunityPAF = new Opportunity();
        contactPresident = new Contact();
        contactSecretary = new Contact();
        contactShareholder = new Contact();
        
        account = new Account();
        contact = new Contact();
        contact1 = new Contact();
        opportunity = new Opportunity();
        
        opportunity.Signed_Letter_of_Intent__c = system.today();
        
        auxDateofBirth = system.today();
        auxCloseDate = system.today();
        
        opportunity.Balloon_Payment__c = system.today();
        //opportunity.StageName = 'Closed Won';
        
        opps = [select Id, Name, Interest_Rate__c, Loan_Amount__c, Prepayment_expiration_date__c, Fixed_Period_Expiration__c
                from Opportunity
                where Borrower_Contact__c = '0033K000006zPP8QAM' and (StageName = 'Open' or StageName = 'Closed Won')];
        
        System.debug(opps);
    }
    
    public List<SelectOption> getRatingOptions()
	{
		List<SelectOption> options = new List<SelectOption>();
		Schema.DescribeFieldResult result = Schema.sObjectType.account.fields.Rating.getSobjectField().getDescribe();
		List<Schema.PicklistEntry> ple = result.getPicklistValues();

		for( Schema.PicklistEntry f : ple)
		{
			options.add(new SelectOption(f.getLabel(), f.getValue()));
		}
		return options;
	}
    
    public List<SelectOption> getAOC()
	{
		List<SelectOption> options = new List<SelectOption>();
		Schema.DescribeFieldResult result = Schema.sObjectType.opportunity.fields.LeadSource.getSobjectField().getDescribe();
		List<Schema.PicklistEntry> ple = result.getPicklistValues();

		for( Schema.PicklistEntry f : ple)
		{
			options.add(new SelectOption(f.getLabel(), f.getValue()));
		}
		return options;
	}
    
    public List<SelectOption> getStages()
	{
		List<SelectOption> options = new List<SelectOption>();
		Schema.DescribeFieldResult result = Schema.sObjectType.opportunity.fields.StageName.getSobjectField().getDescribe();
		List<Schema.PicklistEntry> ple = result.getPicklistValues();

		for( Schema.PicklistEntry f : ple)
		{
			options.add(new SelectOption(f.getLabel(), f.getValue()));
		}
		return options;
	}
    
    public PageReference save() {
		PageReference pr = ApexPages.currentPage();
        System.debug(auxCloseDate);
        return pr;
	}
    
    public PageReference changeStage(){
        System.debug('Hola');
        System.debug(opportunity.StageName);
        opportunity=null;
        return null;
    }

}