import { api, LightningElement, track } from 'lwc';

export default class Week extends LightningElement {
    week;
    @api readOnly;
    @track earnings;
    tempEarningId = 1;
    weekDays = [];
    daysOfWeek = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    // @track earnings = [
    //     { Id: 1, earningType: 'ordinary', hours: [0, 0, 0, 0, 0, 0, 0], weekNUmber: 0 }, // hours: [ { Id: '', day: '', hours: 0} ]
    // ];

    set currentWeek(value) {
        this.week = value;
        this.weekDays = [];
        var weekStart = new Date(this.currentWeek.weekStart);
        var weekEnding = new Date(this.currentWeek.weekEnding);

        // { dayId: 0, day: 'Mon', date: '01 May', disabled: boolean };
        /*
        *
        * This code is for weekstart Sunday and weekend Saturday
        *
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
        *
        *
        */
        for (let i = 1; i < 7; i++) {
            var date = new Date(weekStart);

            if (i < weekStart.getDay()) {
                date.setDate(weekStart.getDate() - (weekStart.getDay() - i));
                this.weekDays.push({
                    dayId: i,
                    date: date.toDateString().substring(4, 10),
                    day: this.daysOfWeek[i],
                    disabled: true
                });
            } else if (weekStart.getDay() <= i && i <= weekEnding.getDay()) { // 3 <= 6 && 6 <= 5
                date.setDate(weekStart.getDate() + (i - weekStart.getDay()));

                this.weekDays.push({
                    dayId: i,
                    date: date.toDateString().substring(4, 10),
                    day: this.daysOfWeek[i],
                    disabled: false
                });
            } else {
                date.setDate(weekEnding.getDate() + (i - weekEnding.getDay())); // 3 + 1

                this.weekDays.push({
                    dayId: i,
                    date: date.toDateString().substring(4, 10),
                    day: this.daysOfWeek[i],
                    disabled: true
                });
            }
        }
        let sunday = new Date(weekEnding);
        sunday.setDate(weekEnding.getDate() + (7 - weekEnding.getDay()))
        this.weekDays.push({
            dayId: 7,
            date: sunday.toDateString().substring(4, 10),
            day: this.daysOfWeek[0],
            disabled: true
        });

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
        this.earnings = [...this.earnings, {
            Id: this.tempEarningId,
            earningType: '',
            hours: []
        }];
    }

    changeValue(event) {
        const dayId = event.detail.dayId;
        const day = event.detail.day;

        if (dayId !== '') {
            this.dispatchEvent(new CustomEvent('changevalue', { detail: event.detail }));
        } else {
            let weekDay = day + this.daysOfWeek[day];
            let name = 'TD' + this.weekDays[day - 1].date.substring(4,6);
            this.dispatchEvent(new CustomEvent('changevalue', { detail: { earningsId: event.detail.earningsId, dayId: '', day: weekDay, name: name, value: event.detail.value } }));
        }
    }

    handleChangeEarningType(event) {
        const detail = event.detail;
        this.dispatchEvent(new CustomEvent('changeearningtype', { detail: detail }));
    }

    removeEarning(event) {
        this.earnings = this.earnings.filter(earning => !(earning.Id === event.detail.Id));
    }
}