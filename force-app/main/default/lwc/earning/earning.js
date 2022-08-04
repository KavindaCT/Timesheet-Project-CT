import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Earning extends LightningElement {
    earning;
    @api readOnly;
    @api weekDays;
    earningType;
    error = false;

    renderedCallback() {
        var total = 0;
        if (this.earning) {
            // console.log('data: ' + JSON.stringify(this.earning));
            this.template.querySelector(`[data-id="earning-type"]`).value = this.earning.earningType;
            /*
            for(let i = 0; i < 7; i++) {
                this.template.querySelector(`[data-id="${i}"]`).value = this.earning.hours[i];
                total += this.earning.hours[i];
            }*/
            for (let i = 1; i < 6; i++) {
                if (this.earning.hours.length > 0) { // i = 5
                    let earningHours = this.earning.hours.find(earning => earning.day.charAt(0) === i.toString());
                    if (earningHours) {
                        this.template.querySelector(`[data-id="${i}"]`).value = earningHours.hours;
                        total += parseFloat(earningHours.hours);
                    } else if (!this.weekDays[i - 1].disabled) {
                        this.template.querySelector(`[data-id="${i}"]`).value = 0;
                    } else {
                        this.template.querySelector(`[data-id="${i}"]`).value = null;
                    }
                } else if (!this.weekDays[i - 1].disabled) {
                    this.template.querySelector(`[data-id="${i}"]`).value = 0;
                } else {
                    this.template.querySelector(`[data-id="${i}"]`).value = null;
                }
            }
            this.template.querySelector(`[data-id="total-hours"]`).value = total;
        }
    }


    set earningData(value) {
        this.earning = value;
    }

    @api
    get earningData() {
        return this.earning;
    }

    get earningTypes() {
        return [
            { label: 'Ordinary Hours', value: 'Ordinary Hours' },
            { label: 'Full Day Leave', value: 'Full Day Leave' },
            { label: 'Half Day Leave', value: 'Half Day Leave' },
            { label: 'Sick Leave', value: 'Sick Leave' }
        ];
    }

    get getErrorClass() {
        return this.error ? 'slds-box' : '';
    }
    get getTotalHoursClass() {
        return this.error ? 'slds-text-color_error' : 'slds-text-color_default';
    }


    // handleChange(event) {
    //     const id = event.currentTarget.dataset.id;
    //     const value = event.target.value;
        
    //     console.log('VALUE'+value);
    //     var newTotal = 0;
    //     for (let i = 1; i < 6; i++) {
    //         if (!this.weekDays[i - 1].disabled) {
    //             newTotal += parseFloat(this.template.querySelector(`[data-id="${i}"]`).value);
    //         }
    //     }

    //     // if (value > 9) {
    //     //     this.error = true;
    //     //     this.dispatchEvent(
    //     //         new ShowToastEvent({
    //     //             title: 'Daily Working Hours limit exceeded',
    //     //             message: 'Please review your working hours',
    //     //             variant: 'error',
    //     //         }),
    //     //     );
    //     // } 
    //     // else
    //     //  if(value) {
    //         // id = id + 1; 
    //         this.error = false;
    //         let relatedDay = this.earning.hours.find(day => day.day.charAt(0) === id);
    //         if(value){
    //             console.log('test')
    //             value == 0;
    //             console.log('test2')

    //         }
    //         console.log('t1 '+value);
    //         var hValue = JSON.stringify(relatedDay);
    //         console.log('t2 '+hValue);
    //         if(hValue){

    //         var hoursValue = JSON.parse(hValue);
    //         console.log('t3 '+hoursValue);
    //         hoursValue.hours = value; 
    //         console.log('latest'+JSON.stringify(relatedDay));
    //         console.log('hoursvalue '+hoursValue.hours);
    //         }else{
    //             hValue = 0;
    //         }
    //         if(hoursValue) {
    //             let dayId = hoursValue.id;
    //             console.log('aa'+JSON.stringify(hoursValue));
    //             this.dispatchEvent(new CustomEvent('changevalue', { detail: { earningsId: this.earning.id, dayId: dayId, value: hoursValue.hours } }));
    //         } else {
    //             this.dispatchEvent(new CustomEvent('changevalue', { detail: { earningsId: this.earning.id, dayId: '', day: id, value: value } }));
    //         }
    //     }


    handleChange(event) {
        const id = event.currentTarget.dataset.id;
        const value = event.target.value;
        
        // console.log('VALUE'+value);
        var newTotal = 0;
        for (let i = 1; i < 6; i++) {
            if (!this.weekDays[i - 1].disabled) {
                newTotal += parseFloat(this.template.querySelector(`[data-id="${i}"]`).value);
            }
        }

        // if (value > 9) {
        //     this.error = true;
        //     this.dispatchEvent(
        //         new ShowToastEvent({
        //             title: 'Daily Working Hours limit exceeded',
        //             message: 'Please review your working hours',
        //             variant: 'error',
        //         }),
        //     );
        // } 
        // else
        //  if(value) {
            // id = id + 1; 
            this.error = false;
            let relatedDay = this.earning.hours.find(day => day.day.charAt(0) === id);
            var hValue = JSON.stringify(relatedDay);

            if(hValue!== undefined){
 
            var hoursValue = JSON.parse(hValue);
            hoursValue.hours = value; 
            }else{
                hValue = 0;
            }
            if(hValue != 0 && hoursValue.id != undefined) {
            
                let dayId = hoursValue.id;
                this.dispatchEvent(new CustomEvent('changevalue', { detail: { earningsId: this.earning.id, dayId: dayId, value: hoursValue.hours } }));
            } else {
                this.dispatchEvent(new CustomEvent('changevalue', { detail: { earningsId: this.earning.id, dayId: '', day: id, value: value } }));
            }

         }

    //     this.template.querySelector('[data-id="total-hours"]').value = newTotal;
    // }
    //  handleChange(event) {
    //     const id = event.currentTarget.dataset.id;
    //     const value = event.target.value;

    //     var newTotal = 0;
    //     for (let i = 1; i < 6; i++) {
    //         if (!this.weekDays[i - 1].disabled) {
    //             newTotal += parseFloat(this.template.querySelector(`[data-id="${i}"]`).value);
    //         }
    //     }

    //     if (value > 9) {
    //         this.error = true;
    //         this.dispatchEvent(
    //             new ShowToastEvent({
    //                 title: 'Daily Working Hours limit exceeded',
    //                 message: 'Please review your working hours',
    //                 variant: 'error',
    //             }),
    //         );
    //     } else if(value) {
    //         this.error = false;
    //         let relatedDay = this.earning.hours.find(day => day.day.charAt(0) === id);

    //         if(relatedDay) {
    //             let dayId = relatedDay.id;
    //             this.dispatchEvent(new CustomEvent('changevalue', { detail: { earningsId: this.earning.id, dayId: dayId, value: value } }));
    //         } else {
    //             this.dispatchEvent(new CustomEvent('changevalue', { detail: { earningsId: this.earning.id, dayId: '', day: id, value: value } }));
    //         }
    //     }

    //     this.template.querySelector('[data-id="total-hours"]').value = newTotal;
    // }

    handleEarningChange(event) {
        const value = event.target.value;
        if(value !== null && value !== undefined) {
            this.dispatchEvent(new CustomEvent('changeearning', { detail: { earningType: value, id: this.earning.id }}));
        }
    }

    handleRemoveEarning() {
        const removeEarning = new CustomEvent('remove', { detail: { id: this.earning.id } });
        this.dispatchEvent(removeEarning);
    }
}