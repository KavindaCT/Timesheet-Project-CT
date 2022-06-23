public with sharing class TimesheetEarning {
    public static List<earningsWrapper> getEarnings(List<Timesheet_Day__c> timesheetDays) {
        List<earningsWrapper> earnings = new List<earningsWrapper>();
        List<String> earningTypes = new List<String>();

        /*  TimesheetDays
            [
                {Id: '', Name: '20-1', Hours__c: 4, Week_Number__c: 4, Day__c: 'Tue', Earning_Type__c: 'ordinary'},
                {Id: '', Name: '20-2', Hours__c: 8, Week_Number__c: 4, Day__c: 'Tue', Earning_Type__c: 'overtime'},
                {Id: '', Name: '21-1', Hours__c: 5, Week_Number__c: 4, Day__c: 'Wed', Earning_Type__c: 'ordinary'},
                {Id: '', Name: '21-2', Hours__c: 9, Week_Number__c: 4, Day__c: 'Wed', Earning_Type__c: 'overtime'}
            ]
        */

        for(Timesheet_Day__c timesheetDay: timesheetDays) { // ['ordinary','overtime']
            if(earningTypes.size() > 0) {
                if(!earningTypes.contains(timesheetDay.Earning_Type__c)) {
                    earningTypes.add(timesheetDay.Earning_Type__c);
                }
            } else {
                earningTypes.add(timesheetDay.Earning_Type__c);
            }
        }

        Integer index = 0;

        for (String earningType : earningTypes) { // ordinary, id 0
            earningsWrapper newEarning = new earningsWrapper();
            List<earningHoursWrapper> earningHours = new List<earningHoursWrapper>();

            newEarning.id = String.valueOf(index);
            newEarning.earningType = earningType;

            for(Timesheet_Day__c timesheetDay: timesheetDays) {
                if (timesheetDay.Earning_Type__c == earningType) {
                    if(newEarning.weekNumber == null) {
                        newEarning.weekNumber = Integer.valueOf(timesheetDay.Week_Number__c);
                    }
                    earningHoursWrapper newEarningHours = new earningHoursWrapper(); // ordinary
                    newEarningHours.id = timesheetDay.Id;
                    newEarningHours.day = timesheetDay.Day__c;
                    newEarningHours.hours = timesheetDay.Hours__c;
                    earningHours.add(newEarningHours);
                }
            }
            newEarning.hours = earningHours;

            index += 1;
            earnings.add(newEarning);
        }

        return earnings;
    }

    public class earningsWrapper {
        public String id;
        public String earningType;
        public Integer weekNumber;
        public List<earningHoursWrapper> hours;
    }

    public class earningHoursWrapper {
        public String id;
        public String day;
        public Decimal hours;
    }
}