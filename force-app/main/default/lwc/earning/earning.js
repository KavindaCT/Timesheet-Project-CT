import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Earning extends LightningElement {
    earning;
    @api weekDays;
    earningType;
    error = false;
    
    renderedCallback() {
        var total = 0;
        if(this.earning) {
            console.log('data: ' + JSON.stringify(this.earning));
            this.template.querySelector(`[data-id="earning-type"]`).value = this.earning.earningType;
            /*
            for(let i = 0; i < 7; i++) {
                this.template.querySelector(`[data-id="${i}"]`).value = this.earning.hours[i];
                total += this.earning.hours[i];
            }*/
            for(let i = 1; i < 6; i++) {
                if(this.earning.hours.length > 0) { // i = 5
                    let earningHours = this.earning.hours.find(earning => earning.day.charAt(0) === i.toString());
                    if(earningHours) {
                        this.template.querySelector(`[data-id="${i}"]`).value = earningHours.hours;
                        total += earningHours.hours;
                    } else if(!this.weekDays[i - 1].disabled) {
                        this.template.querySelector(`[data-id="${i}"]`).value = 0;
                    }
                } else if(!this.weekDays[i - 1].disabled) {
                    this.template.querySelector(`[data-id="${i}"]`).value = 0;
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
            { label: 'Ordinary Hours', value: 'Ordinary Hours' }
        ];
    }

    get getErrorClass() {
        return this.error? 'slds-box': '';
    }
    get getTotalHoursClass() {
        return this.error? 'slds-text-color_error' : 'slds-text-color_default';
    }

    handleChange(event) {
        // const id = event.currentTarget.dataset.id;
        const value = event.target.value;
        
        var newTotal = 0;
        for(let i = 1; i < 6; i++) {
            if(!this.weekDays[i - 1].disabled) {
                newTotal += parseFloat(this.template.querySelector(`[data-id="${i}"]`).value);
            }
        }

        if(value > 9) {
            this.error = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Daily Working Hours limit exceeded',
                    message: 'Please review your working hours',
                    variant: 'error',
                }),
            );
        } else {
            this.error = false;
        }

        this.template.querySelector('[data-id="total-hours"]').value = newTotal;
    }

    @api sendEarning() {
        let updatedEarning = { ...this.earning };
        updatedEarning.earningType = this.earningType;
        updatedEarning.hours = [
            this.day0,
            this.day1,
            this.day2,
            this.day3,
            this.day4,
            this.day5,
            this.day6
        ];
        const earningData = new CustomEvent('update', { detail: updatedEarning });
        this.dispatchEvent(earningData);
    }

    handleRemoveEarning() {
        const removeEarning = new CustomEvent('remove', { detail: { Id: this.earning.Id }} );
        this.dispatchEvent(removeEarning);
    }
}