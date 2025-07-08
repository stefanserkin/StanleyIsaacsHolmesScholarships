public class SchAppLotteryComparator implements Comparator<Scholarship_Application__c> {
    
    public Integer compare(Scholarship_Application__c app1, Scholarship_Application__c app2) {
        Integer returnValue = 0;
        
        if(app1 == null && app2 == null) {
            returnValue = 0;
        } else if (app1 == null) {
            returnValue = 1; 
        } else if (app2 == null) {
            returnValue = -1;
        } else if ((app1.Lottery_Order__c == null) && (app2.Lottery_Order__c == null)) {
            returnValue = 0;
        } else if (app1.Lottery_Order__c == null){
            returnValue = 1;
        } else if (app2.Lottery_Order__c == null){
            returnValue = -1;
        } else if (app1.Lottery_Order__c < app2.Lottery_Order__c) {
            returnValue = -1;
        } else if (app1.Lottery_Order__c > app2.Lottery_Order__c) {
            returnValue = 1;
        }
        return returnValue;
    }

}