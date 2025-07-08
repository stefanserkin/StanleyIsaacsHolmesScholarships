@IsTest
private class FlowScholarshipLotteryAssigner_Test {

    private static FlowScholarshipLotteryAssigner.Request request = new FlowScholarshipLotteryAssigner.Request();
    private static List<FlowScholarshipLotteryAssigner.Request> requests = new List<FlowScholarshipLotteryAssigner.Request>();
    private static List<FlowScholarshipLotteryAssigner.Result> results;
    
    @TestSetup
    static void makeData() {
        List<Contact> contacts = TestDataFactory.createContacts(5);
        insert contacts;

        Scholarship_Program__c program = new Scholarship_Program__c();
        program.Name = 'Test Scholarship Program';
        insert program;

        List<Scholarship_Application__c> applications = new List<Scholarship_Application__c>();
        for (Integer i = 0; i < 5; i++) {
            Scholarship_Application__c application = new Scholarship_Application__c();
            application.Applicant__c = contacts[i].Id;
            application.Scholarship_Program__c = program.Id;
            application.Name = 'Test application';
            application.Status__c = 'Approved';
            applications.add(application);
        }
        insert applications;
    }

    @IsTest
    static void testAssignLotteryNumbers() {
        Scholarship_Program__c program = [SELECT Id FROM Scholarship_Program__c LIMIT 1];

        request.programId = program.Id;
        request.saveChanges = true;
        requests.add(request);

        Test.startTest();
        results = FlowScholarshipLotteryAssigner.assignLotteryNumbers(requests);
        Test.stopTest();

        List<Scholarship_Application__c> apps = results[0].applications;
        System.Assert.areEqual(1, apps[0].Lottery_Order__c);
        System.Assert.areEqual(2, apps[1].Lottery_Order__c);
        System.Assert.areEqual(3, apps[2].Lottery_Order__c);
    }

}