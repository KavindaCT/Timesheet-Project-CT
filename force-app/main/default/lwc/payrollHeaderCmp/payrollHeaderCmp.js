import { LightningElement } from 'lwc';

export default class PayrollHeaderCmp extends LightningElement {
    dueDate;
    paymentDate;

    connectedCallback(){
        const currentDate = new Date();
        this.paymentDate = (new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 5)).toDateString().substring(4);
        var lastDate = (new Date(currentDate.getFullYear(), currentDate.getMonth() + 1, 0));
        if(lastDate.getDay() <6 && lastDate.getDay() > 0){
            this.dueDate = lastDate.toDateString().substring(4);
        }else if(lastDate.getDay() == 6){
            let lastPaymentdate = new Date(currentDate).setDate(lastDate.getDate()-1);
            this.dueDate = new Date(lastPaymentdate).toDateString().substring(4);
        }else{
            let lastPaymentdate = new Date(currentDate).setDate(lastDate.getDate()-2);
           this.dueDate = new Date(lastPaymentdate).toDateString().substring(4);
        }
    }

    viewSalary(){}

    viewEarnings(){}
}