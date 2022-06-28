import { LightningElement, track, api } from 'lwc';

export default class HeadingCmp extends LightningElement {
    @api timePeriod;
    weeks = []; // [{ weekEnding: '', weekStart: '', weekNumber: 0 }]

    @track Draft;
    date;
    currentWeekNumber = 0;

    Draft = 'Draft'; //status
    disablePreviousButton = true;
    disableNextButton = false;

    connectedCallback() {
        if (this.timePeriod) {
            const firstDate = new Date('01 ' + this.timePeriod + ' 00:00');
            const lastDate = (new Date(firstDate.getFullYear(), firstDate.getMonth() + 1, 0));
            var weekNumber = 0;
            var weekStart = new Date(firstDate);
            var weekEnd = new Date(firstDate);

            /*
            *
            * Here weekstart from Sunday week end is Saturday *
            *
            for (let i = 1; i < lastDate.getDate();) {
                if ((weekStart.getDate() + (6 - weekStart.getDay())) < lastDate.getDate()) {
                    weekEnd.setDate(weekStart.getDate() + (6 - weekStart.getDay()));
                } else {
                    weekEnd.setDate(lastDate.getDate());
                }

                // [{ weekEnding: '', weekStart: '', weekNumber: 0 }]
                this.weeks.push({
                    weekNumber: weekNumber,
                    weekStart: weekStart.toDateString(),
                    weekEnding: weekEnd.toDateString()
                });
                weekStart.setDate(weekEnd.getDate() + 1);

                i = weekEnd.getDate();
                weekNumber += 1;
            }
            *
            *
            */

            // [BEGIN] - Weekstart from Monday weekend is Friday
            for (let i = 1; i < lastDate.getDate();) {
                if ((weekStart.getDate() + (5 - weekStart.getDay())) < lastDate.getDate()) {
                    weekEnd.setDate(weekStart.getDate() + (5 - weekStart.getDay()));
                } else {
                    weekEnd.setDate(lastDate.getDate());
                }

                // [{ weekEnding: '', weekStart: '', weekNumber: 0 }]
                this.weeks.push({
                    weekNumber: weekNumber,
                    weekStart: weekStart.toDateString(),
                    weekEnding: weekEnd.toDateString()
                });
                weekStart.setDate(weekEnd.getDate() + 3);

                i = weekEnd.getDate();
                weekNumber += 1;
            }
            // [END] - Weekstart from Monday weekend is Friday
            this.handleSetWeek(this.currentWeekNumber);
        }
    }

    handleSetWeek(weekNumber) {
        if (this.weeks.length > 0) {
            this.date = this.weeks[weekNumber].weekEnding;
            this.changeWeekNumber(weekNumber);
        }
    }

    switchTopreviousWeek() {
        if (this.currentWeekNumber > 0) {
            this.currentWeekNumber -= 1;
            this.handleSetWeek(this.currentWeekNumber);

            this.disablePreviousButton = false;
            this.disableNextButton = false;

        }
        if (this.currentWeekNumber === 0) {
            this.disablePreviousButton = true;
        }
    }

    switchToNextWeek() {
        if (this.currentWeekNumber < this.weeks.length) {
            this.currentWeekNumber += 1;
            this.handleSetWeek(this.currentWeekNumber);

            this.disableNextButton = false;
            this.disablePreviousButton = false;
        }
        if (this.currentWeekNumber === this.weeks.length - 1) {
            this.disableNextButton = true;
        }
    }

    changeWeekNumber(weekNumber) {
        this.dispatchEvent(new CustomEvent('changeweek', { detail: { week: this.weeks[weekNumber], weekNumber: weekNumber } }));
    }

    @api
    handleStatus() {
        this.Draft = 'Submitted';
    }
}