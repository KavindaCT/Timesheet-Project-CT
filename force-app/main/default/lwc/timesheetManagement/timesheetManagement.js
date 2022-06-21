import { LightningElement } from 'lwc';

export default class TimesheetManagement extends LightningElement {
  isModalOpen = false;

  closeQuickAction() {
      this.isModalOpen = true;
  }

  hideModalBox(){
      this.isModalOpen = false;
  }


 viewTimeSheet(event){
    if(event){
        this.hideModalBox();
        this.dispatchEvent(new CustomEvent("setview",{detail:{view:"timesheet"}}));
    }
 }
}