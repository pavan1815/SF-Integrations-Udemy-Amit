// creditCheck.js
import { LightningElement } from "lwc";
import startCreditCheck from "@salesforce/apexContinuation/CreditCheckController.startCreditCheck";
//                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
//                          NOT @salesforce/apex — this is the key difference!

export default class CreditCheck extends LightningElement {
  customerId = "";
  result = "";
  error = "";
  isLoading = false;

  handleInput(event) {
    this.customerId = event.target.value;
  }

  async runCheck() {
    this.isLoading = true;
    this.result = "";
    this.error = "";

    try {
      const response = await startCreditCheck({
        customerId: this.customerId
      });
      this.result = response;
    } catch (err) {
      this.error = err.body?.message || "Unknown error occurred";
    } finally {
      this.isLoading = false;
    }
  }
}
