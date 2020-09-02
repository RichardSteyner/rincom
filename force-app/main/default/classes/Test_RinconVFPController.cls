@isTest
public class Test_RinconVFPController {
    
    static{
    }
    
    @isTest static void testController(){
        PageReference pageRef = Page.RinconVFP;
       	Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('contactId', '9063A000000DkKSQA0');
        RinconVFPController controller = new RinconVFPController();
    }

}