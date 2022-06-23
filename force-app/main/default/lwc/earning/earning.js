import { LightningElement, api } from 'lwc';

export default class Earning extends LightningElement {
    @api earning;
    @api weekDays;
    earningType;
    
    renderedCallback() {
        var total = 0;
        if(this.earning) {
            this.template.querySelector(`[data-id="earning-type"]`).value = this.earning.earningType;
            for(let i = 0; i < 7; i++) {
                this.template.querySelector(`[data-id="${i}"]`).value = this.earning.hours[i];
                total += this.earning.hours[i];
            }
            // this.template.querySelector(`[data-id="earning-type"]`).value = this.earning.earningType;
            // for(let i = 0; i < 7; i++) {
            //     if(this.earning.hours) {
            //         for(let j = 0; j < this.earning.hours.length; j++) {
            //             if(this.earning.hours[j].day === i.toString()) {
            //                 this.template.querySelector(`[data-id="${i}"]`).value = this.earning.hours[j].hours;
            //                 total += this.earning.hours[i];
            //             } else {
            //                 this.template.querySelector(`[data-id="${i}"]`).value = 0;
            //             }
            //         }
            //     } else {
            //         this.template.querySelector(`[data-id="${i}"]`).value = 0;
            //     }
            // }
            
            this.template.querySelector(`[data-id="total-hours"]`).value = total;
        }
    }

    get earningTypes() {
        return [
            { label: 'Ordinary Hours', value: 'ordinary' },
            { label: 'Overtime Hours', value: 'ot' }
        ];
    }

    handleChange() {
        // const id = event.currentTarget.id;
        // const value = event.target.value;
        
        var newTotal = 0;
        for(let i = 0; i < 7; i++) {
            newTotal += parseFloat(this.template.querySelector(`[data-id="${i}"]`).value);
        }

        this.template.querySelector(`[data-id="total-hours"]`).value = newTotal;
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