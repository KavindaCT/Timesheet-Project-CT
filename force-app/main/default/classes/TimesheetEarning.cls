public with sharing class TimesheetEarning {
    @AuraEnabled(cacheable=true)
    public static List<earningsWrapper> getEarnings(List<Timesheet_Day__c> timesheetDays) {
        List<earningsWrapper> earnings = new List<earningsWrapper>();
        List<String> earningTypes = new List<String>();
        Integer index = 0;

        /*  TimesheetDays
            [
                {Id: '', Name: '02-1', Hours__c: 4, Week_Number__c: 1, Day__c: 'Tue', Earning_Type__c: 'ordinary'},
                {Id: '', Name: '10-2', Hours__c: 8, Week_Number__c: 2, Day__c: 'Tue', Earning_Type__c: 'overtime'},
                {Id: '', Name: '21-1', Hours__c: 5, Week_Number__c: 4, Day__c: 'Wed', Earning_Type__c: 'ordinary'},
                {Id: '', Name: '21-2', Hours__c: 9, Week_Number__c: 4, Day__c: 'Wed', Earning_Type__c: 'overtime'}
            ]
        */

        // Map<String, List<Timesheet_Day__c>> dataMap = new Map<String, List<Timesheet_Day__c>>();
        List<Timesheet_Day__c> week1 = new List<Timesheet_Day__c>();
        List<Timesheet_Day__c> week2 = new List<Timesheet_Day__c>();
        List<Timesheet_Day__c> week3 = new List<Timesheet_Day__c>();
        List<Timesheet_Day__c> week4 = new List<Timesheet_Day__c>();
        List<Timesheet_Day__c> week5 = new List<Timesheet_Day__c>();

        if (timesheetDays.size() > 0) {
            for (Timesheet_Day__c timesheetDay : timesheetDays) {
                if (timesheetDay.Week_Number__c == '1') {
                    week1.add(timesheetDay);
                } else if(timesheetDay.Week_Number__c == '2') {
                    week2.add(timesheetDay);
                } else if(timesheetDay.Week_Number__c == '3') {
                    week3.add(timesheetDay);
                } else if(timesheetDay.Week_Number__c == '4') {
                    week4.add(timesheetDay);
                } else if(timesheetDay.Week_Number__c == '5') {
                    week5.add(timesheetDay);
                }
            }

            for(Timesheet_Day__c timesheetDay: timesheetDays) { // ['ordinary','overtime']
                if(earningTypes.size() > 0) {
                    if(!earningTypes.contains(timesheetDay.Earning_Type__c)) {
                        earningTypes.add(timesheetDay.Earning_Type__c);
                    }
                } else {
                    earningTypes.add(timesheetDay.Earning_Type__c);
                }
            }
        }else{
            for(Integer i = 1; i <= 5; i++){
                List <earningHoursWrapper> earningHoursList = new List<earningHoursWrapper> ();
                earningsWrapper earningWeek = new earningsWrapper(); 
                earningWeek.id = i +'0'; // 10
                earningWeek.earningType = 'Ordinary Hours';
                earningWeek.weekNumber = i;
                earningWeek.hours = earningHoursList;
                earnings.add(earningWeek);
                
            }
        }

        // Map<String, List<Timesheet_Day__c>> dataMap = new Map<String, List<Timesheet_Day__c>>{
        //     '1' => week1,
        //     '2' => week2,
        //     '3' => week3,
        //     '4' => week4,
        //     '5' => week5
        // };

        for (String earningType : earningTypes) { // ordinary, id 0
            //-------------------------------- For week 1 ----------------------------------------------------
                earningsWrapper newEarningForWeek1 = new earningsWrapper();
                List<earningHoursWrapper> earningHoursFor1 = new List<earningHoursWrapper>(); // earning record - every earning type & week number
                newEarningForWeek1.id = '1' + String.valueOf(index); // 10
                newEarningForWeek1.earningType = earningType;
                newEarningForWeek1.weekNumber = 1;

                if (week1.size() > 0) {
                    for (Timesheet_Day__c day1 : week1) {
                        if (day1.Earning_Type__c == earningType) {
                            earningHoursWrapper newEarningHours1 = new earningHoursWrapper(); // ordinary
                            newEarningHours1.id = day1.Id;
                            newEarningHours1.Name = day1.Name;
                            newEarningHours1.day = day1.Day__c;
                            newEarningHours1.hours = day1.Hours__c;
                            earningHoursFor1.add(newEarningHours1);
                        }
                    }
                }
                newEarningForWeek1.hours = earningHoursFor1;
            //-------------------------------- For week 1 ----------------------------------------------------

            //-------------------------------- For week 2 ----------------------------------------------------
                earningsWrapper newEarningForWeek2 = new earningsWrapper();
                List<earningHoursWrapper> earningHoursFor2 = new List<earningHoursWrapper>();
                newEarningForWeek2.id = '2' + String.valueOf(index); // 20
                newEarningForWeek2.earningType = earningType;
                newEarningForWeek2.weekNumber = 2;

            if (week2.size() > 0) {
                for (Timesheet_Day__c day2 : week2) {
                    if (day2.Earning_Type__c == earningType) {
                        earningHoursWrapper newEarningHours2 = new earningHoursWrapper(); // ordinary
                        newEarningHours2.id = day2.Id;
                        newEarningHours2.Name = day2.Name;
                        newEarningHours2.day = day2.Day__c;
                        newEarningHours2.hours = day2.Hours__c;
                        earningHoursFor2.add(newEarningHours2);
                    }
                }
            }
                newEarningForWeek2.hours = earningHoursFor2;
            //-------------------------------- For week 2 ----------------------------------------------------

            //-------------------------------- For week 3 ----------------------------------------------------
                earningsWrapper newEarningForWeek3 = new earningsWrapper();
                List<earningHoursWrapper> earningHoursFor3 = new List<earningHoursWrapper>();
                newEarningForWeek3.id = '3' + String.valueOf(index); // 30
                newEarningForWeek3.earningType = earningType;
                newEarningForWeek3.weekNumber = 3;

            if (week3.size() > 0) {
                for (Timesheet_Day__c day3 : week3) {
                    if (day3.Earning_Type__c == earningType) {
                        earningHoursWrapper newEarningHours3 = new earningHoursWrapper(); // ordinary
                        newEarningHours3.id = day3.Id;
                        newEarningHours3.Name = day3.Name;
                        newEarningHours3.day = day3.Day__c;
                        newEarningHours3.hours = day3.Hours__c;
                        earningHoursFor3.add(newEarningHours3);
                    }
                }
            }
                newEarningForWeek3.hours = earningHoursFor3;
            //-------------------------------- For week 3 ----------------------------------------------------

            //-------------------------------- For week 4 ----------------------------------------------------
                earningsWrapper newEarningForWeek4 = new earningsWrapper();
                List<earningHoursWrapper> earningHoursFor4 = new List<earningHoursWrapper>();
                newEarningForWeek4.id = '4' + String.valueOf(index); // 40
                newEarningForWeek4.earningType = earningType;
                newEarningForWeek4.weekNumber = 4;

            if (week4.size() > 0) {
                for (Timesheet_Day__c day4 : week4) {
                    if (day4.Earning_Type__c == earningType) {
                        earningHoursWrapper newEarningHours4 = new earningHoursWrapper(); // ordinary
                        newEarningHours4.id = day4.Id;
                        newEarningHours4.Name = day4.Name;
                        newEarningHours4.day = day4.Day__c;
                        newEarningHours4.hours = day4.Hours__c;
                        earningHoursFor4.add(newEarningHours4);
                    }
                }
            }
                newEarningForWeek4.hours = earningHoursFor4;
            //-------------------------------- For week 4 ----------------------------------------------------

            //-------------------------------- For week 5 ----------------------------------------------------
                earningsWrapper newEarningForWeek5 = new earningsWrapper();
                List<earningHoursWrapper> earningHoursFor5 = new List<earningHoursWrapper>();
                newEarningForWeek5.id = '5' + String.valueOf(index); // 50
                newEarningForWeek5.earningType = earningType;
                newEarningForWeek5.weekNumber = 5;

            if (week5.size() > 0) {
                for (Timesheet_Day__c day5 : week5) {
                    if (day5.Earning_Type__c == earningType) {
                        earningHoursWrapper newEarningHours5 = new earningHoursWrapper(); // ordinary
                        newEarningHours5.id = day5.Id;
                        newEarningHours5.Name = day5.Name;
                        newEarningHours5.day = day5.Day__c;
                        newEarningHours5.hours = day5.Hours__c;
                        earningHoursFor5.add(newEarningHours5);
                    }
                }
            }
                newEarningForWeek5.hours = earningHoursFor5;
            //-------------------------------- For week 5 ----------------------------------------------------

            index += 1;

            earnings.add(newEarningForWeek1);
            earnings.add(newEarningForWeek2);
            earnings.add(newEarningForWeek3);
            earnings.add(newEarningForWeek4);
            earnings.add(newEarningForWeek5);
        }

        return earnings;
    }

    public class earningsWrapper {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String earningType;
        @AuraEnabled
        public Integer weekNumber;
        @AuraEnabled
        public List<earningHoursWrapper> hours;
    }

    public class earningHoursWrapper {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String day;
        @AuraEnabled
        public Decimal hours;
    }
}