public with sharing class ErrorLogPublisher {
  public static void logError(
    String source,
    String severity,
    String message,
    Id recordId,
    String stackTrace
  ) {
    //Create the platform event
    Error_Log__e event = new Error_Log__e(
      Source__c = source,
      Severity__c = severity,
      Error_Message__c = message,
      Record_Id__c = recordId,
      Stack_Trace__c = stackTrace,
      User_Id__c = UserInfo.getUserId()
    );

    //to publish the platform event
    Database.SaveResult result = EventBus.publish(event);
    if (!result.isSuccess()) {
      System.debug(
        LoggingLevel.ERROR,
        'Failed to publish error log: ' + result.getErrors()[0].getMessage()
      );
    }
  }
}
