@IsTest
public class SchAppLotteryComparator_Test {

    @IsTest
    static void testSortApplications() {
        List<Scholarship_Application__c> apps = new List<Scholarship_Application__c>{
            new Scholarship_Application__c(Lottery_Order__c = 3),
            new Scholarship_Application__c(Lottery_Order__c = 1),
            new Scholarship_Application__c(Lottery_Order__c = 2)
        };

        Test.startTest();
        apps.sort(new SchAppLotteryComparator());
        Test.stopTest();

        System.Assert.areEqual(1, apps[0].Lottery_Order__c);
        System.Assert.areEqual(2, apps[1].Lottery_Order__c);
        System.Assert.areEqual(3, apps[2].Lottery_Order__c);
    }

    @IsTest
    static void testSortApplicationsWithNullApps() {
        List<Scholarship_Application__c> nullApps = new List<Scholarship_Application__c>{null, null};
        List<Scholarship_Application__c> firstWasNull = new List<Scholarship_Application__c>{null, new Scholarship_Application__c(Lottery_Order__c = 5)};
        List<Scholarship_Application__c> secondWasNull = new List<Scholarship_Application__c>{new Scholarship_Application__c(Lottery_Order__c = 5), null};

        SchAppLotteryComparator comparator = new SchAppLotteryComparator();
        Test.startTest();
        nullApps.sort(comparator);
        firstWasNull.sort(comparator);
        secondWasNull.sort(comparator);
        Test.stopTest();

        System.Assert.isNotNull(firstWasNull[0], 'First element should not be null');
        System.Assert.isNotNull(secondWasNull[0], 'First element should not be null');
    }

    @IsTest
    static void testSortApplicationsWithNullLotteryOrders() {
        List<Scholarship_Application__c> nullApps = new List<Scholarship_Application__c>{
            new Scholarship_Application__c(),
            new Scholarship_Application__c()
        };

        List<Scholarship_Application__c> firstWasNull = new List<Scholarship_Application__c>{
            new Scholarship_Application__c(),
            new Scholarship_Application__c(Lottery_Order__c = 5)
        };

        List<Scholarship_Application__c> secondWasNull = new List<Scholarship_Application__c>{
            new Scholarship_Application__c(Lottery_Order__c = 5),
            new Scholarship_Application__c()
        };

        SchAppLotteryComparator comparator = new SchAppLotteryComparator();
        Test.startTest();
        nullApps.sort(comparator);
        firstWasNull.sort(comparator);
        secondWasNull.sort(comparator);
        Test.stopTest();

        System.Assert.areEqual(5, firstWasNull[0].Lottery_Order__c, 'First element should have the lottery number');
        System.Assert.areEqual(5, secondWasNull[0].Lottery_Order__c, 'First element should have the lottery number');
    }

}