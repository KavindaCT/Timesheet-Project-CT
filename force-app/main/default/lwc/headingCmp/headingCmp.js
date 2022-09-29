import { LightningElement, api } from "lwc";

const MONTH = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];
export default class HeadingCmp extends LightningElement {
  @api timePeriod;
  weeks = []; // [{ weekEnding: '', weekStart: '', weekNumber: 0 }]

  @api timesheetStatus;
  @api monthlyTotal;
  date;
  currentWeekNumber = 0;
  disablePreviousButton = true;
  disableNextButton = false;
  // currentUserId = uId;

  connectedCallback() {
    const currentDate = new Date();
    this.timePeriod =
      MONTH[currentDate.getMonth()] + " " + currentDate.getFullYear(); // June 2022
    if (this.timePeriod) {
      const firstDate = new Date("01 " + this.timePeriod);
      const lastDate = new Date(
        firstDate.getFullYear(),
        firstDate.getMonth() + 1,
        0
      );

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
      for (let i = 1; i < lastDate.getDate(); ) {
        if (i === 1 && weekStart.getDay() === 6) {
          weekStart.setDate(firstDate.getDate() + 2); // If month start with saturday
        } else if (i === 1 && weekStart.getDay() === 0) {
          weekStart.setDate(firstDate.getDate() + 1); // If month starts with sunday
        }

        if (
          weekStart.getDate() + (7 - weekStart.getDay()) <
          lastDate.getDate()
        ) {
          weekEnd.setDate(weekStart.getDate() + (5 - weekStart.getDay()));

          i = weekEnd.getDate();
        } else {
          if (lastDate.getDay() === 0) {
            weekEnd.setDate(lastDate.getDate() - 2); // If month ending is Sunday
          } else if (lastDate.getDay() === 6) {
            weekEnd.setDate(lastDate.getDate() - 1); // If month ending is saturday
          } else {
            weekEnd.setDate(lastDate.getDate()); // If month ending is weekday
          }

          i = lastDate.getDate(); // exit loop when reach to final day of the month
        }

        // [{ weekEnding: '', weekStart: '', weekNumber: 0 }]
        this.weeks.push({
          weekNumber: weekNumber,
          weekStart: weekStart.toDateString(),
          weekEnding: weekEnd.toDateString()
        });
        weekStart.setDate(weekEnd.getDate() + 3);
        weekNumber += 1;
      }
      // [END] - Weekstart from Monday weekend is Friday
      this.handleSetWeek(this.currentWeekNumber);
    }
  }

  handleSetWeek(weekNumber) {
    if (this.weeks.length > 0) {
      this.date = this.weeks[weekNumber].weekEnding;
      // console.log('printing date '+this.date)
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
    this.dispatchEvent(
      new CustomEvent("changeweek", {
        detail: { week: this.weeks[weekNumber], weekNumber: weekNumber }
      })
    );
  }
}
