public with sharing class ErrorLogTriggerHandler {
  public static void handle(List<Error_Log__e> events) {
    List<Integration_Log__c> logs = new List<Integration_Log__c>();
    for (Error_Log__e evt : events) {
      Integration_Log__c log = new Integration_Log__c();
      log.Source__c = evt.Source__c;
      log.Serverity__c = evt.Severity__c;
      log.Error_Message__c = evt.Error_Message__c;
      log.Record_Id__c = evt.Record_Id__c;
      log.Stack_Trace__c = evt.Stack_Trace__c;
      log.User_Id__c = evt.User_Id__c;
      log.Logged_At__c = Datetime.now();
      logs.add(log);
    }
    if (!logs.isEmpty()) {
      try {
        insert logs;
      } catch (DmlException ex) {
        throw new EventBus.RetryableException(
          'Temporary Failure inserting topic ' + ex.getMessage()
        );
      }
    }
  }
}
