public inherited sharing class FlowScholarshipLotteryAssigner {

    @InvocableMethod(
        label='Assign Scholarship Lottery Numbers'
        description='Takes the approved applications, draws the lottery, and assigns the lottery numbers to the applications'
        category='Scholarship'
        iconName='resource:agGlyph:Layer_1'
    )
    public static List<Result> assignLotteryNumbers(List<Request> requests) {
        Id programId = requests[0].programId;

        // Get all the applications with a status of Approved
        List<Scholarship_Application__c> applications = getApprovedApplications(programId);

        // Assign a random value to each application and sort them
        for (Scholarship_Application__c app : applications) {
            app.Lottery_Order__c = Crypto.getRandomInteger();
        }

        applications.sort(new SchAppLotteryComparator());

        // Set lottery numbers to new index position
        for (Integer i = 0; i < applications.size(); i++) {
            applications[i].Lottery_Order__c = i + 1;
        }

        Database.update(applications, AccessLevel.USER_MODE);

        Result result = new Result();
        result.applications = applications;
        return new List<Result>{ result };
    }

    private static List<Scholarship_Application__c> getApprovedApplications(Id programId) {
        return [
            SELECT Id, Name, Lottery_Order__c
              FROM Scholarship_Application__c
             WHERE Status__c = 'Approved'
               AND Scholarship_Program__c = :programId
             LIMIT 10000
        ];
    }
    
    public class Request {
        @InvocableVariable(label='Scholarship Program ID' description='The record ID of the program to assign lottery numbers to' required=true)
        public Id programId;

        @InvocableVariable(label='Save Changes' description='If set to true, the records will be updated with the new lottery numbers')
        public Boolean saveChanges;
    }

    public class Result {
        @InvocableVariable(label='Applications')
        public List<Scholarship_Application__c> applications;
    }

}