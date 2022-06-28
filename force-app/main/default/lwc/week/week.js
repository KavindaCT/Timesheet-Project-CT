import { api, LightningElement, track } from 'lwc';

export default class Week extends LightningElement {
    week;
    @track earnings;
    tempEarningId = 1;
    weekDays = [];
    daysOfWeek = ['Sun','Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    // @track earnings = [
    //     { Id: 1, earningType: 'ordinary', hours: [0, 0, 0, 0, 0, 0, 0], weekNUmber: 0 }, // hours: [ { Id: '', day: '', hours: 0} ]
    // ];

    set currentWeek(value) {
        this.week = value;
        this.weekDays = [];
        var weekStart = new Date(this.currentWeek.weekStart);
        var weekEnding = new Date(this.currentWeek.weekEnding);

        // { dayId: 0, day: 'Mon', date: '01 May', disabled: boolean };
        for(let i = 0; i < 7; i++) {
            var date = new Date(weekStart);

            if(i < weekStart.getDay()) {
                date.setDate(weekStart.getDate() - (weekStart.getDay() - i));
                this.weekDays.push({
                    dayId: i,
                    date: date.toDateString().substring(4,10),
                    day: this.daysOfWeek[i],
                    disabled: true
                });
            } else if(weekStart.getDay() <= i && i <= weekEnding.getDay()) { // 0 <= 5 && 5 <= 4
                date.setDate(weekStart.getDate() + (i - weekStart.getDay()));

                this.weekDays.push({
                    dayId: i,
                    date: date.toDateString().substring(4,10),
                    day: this.daysOfWeek[i],
                    disabled: false
                });
            } else {
                date.setDate(weekEnding.getDate() + (i - weekEnding.getDay()));

                this.weekDays.push({
                    dayId: i,
                    date: date.toDateString().substring(4,10),
                    day: this.daysOfWeek[i],
                    disabled: true
                });
            }
        }
    }

    @api
    get currentWeek() {
        return this.week;
    }

    set earningData(value) {
        this.earnings = value;
    }

    @api
    get earningData() {
        return this.earnings;
    }

    addNewEarning() {
        this.tempEarningId += 1;
        this.earnings = [ ...this.earnings, {
            Id: this.tempEarningId,
            earningType: '',
            hours: []
        }];
    }

    removeEarning(event) {
        this.earnings = this.earnings.filter(earning => !(earning.Id === event.detail.Id));
    }
}