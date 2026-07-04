import { LightningElement } from "lwc";
import {
  subscribe,
  unsubscribe,
  onError,
  setDebugFlag,
  isEmpEnabled
} from "lightning/empApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const CHANNEL = "/event/Error_Log__e";
const COLUMNS = [
  {
    label: "Severity",
    fieldName: "severity",
    type: "text",
    cellAttributes: { class: { fieldName: "severityClass" } }
  },
  { label: "Source", fieldName: "source", type: "text" },
  { label: "Error Message", fieldName: "message", type: "text" },
  { label: "Record Id", fieldName: "recordId", type: "text" },
  { label: "Time", fieldName: "time", type: "text" }
];

export default class ErrorMonitor extends LightningElement {
  isSubscribed = false;
  errors = [];
  columns = COLUMNS;

  connectedCallback() {
    this.registerErrorListener();
    this.handleSubscribe();
  }

  registerErrorListener() {
    // Invoke onError empApi method
    onError((error) => {
      console.log("Received error from server: ", JSON.stringify(error));
      // Error contains the server-side error
      this.isSubscribed = false;
    });
  }

  handleSubscribe() {
    subscribe(CHANNEL, -1, (response) => {
      this.handleEvent(response);
    }).then(() => {
      this.isSubscribed = true;
    });
  }

  handleEvent(response) {
    const payload = response.data.payload;

    const error = {
      id: response.data.event.replayId,
      severity: payload.Severity__c,
      source: payload.Source__c,
      message: payload.Error_Message__c,
      recordId: payload.Record_Id__c || "",
      time: new Date().toLocaleTimeString(),
      severityClass:
        payload.Severity__c === "CRITICAL" ? "slds-text-color_error" : ""
    };

    this.errors = [error, ...this.errors];

    this.dispatchEvent(
      new ShowToastEvent({
        title: error.severity + ": " + error.source,
        message: error.message,
        variant:
          error.severity === "CRITICAL" || error.severity === "ERROR"
            ? "error"
            : "warning"
      })
    );
  }

  get hasErrors() {
    return this.errors.length > 0;
  }
}
