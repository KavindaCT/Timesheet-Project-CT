import { LightningElement } from "lwc";

export default class PayrollDashboard extends LightningElement {
  setview(event) {
    this.dispatchEvent(
      new CustomEvent("setview", { detail: { view: event.detail.view } })
    );
  }
}
