public class RetryableCalloutJob implements Queueable, Database.AllowsCallouts {
  private Id recordId;
  private Integer retryCount;
  private static final Integer MAX_RETRIES = 3;

  public RetryableCalloutJob(Id recordId, Integer retryCount) {
    this.recordId = recordId;
    this.retryCount = retryCount;
  }

  public void execute(QueueableContext context) {
    CalloutResult result = MyService.doCallout(recordId);

    if (result.isSuccess) {
      // Done — update record with result
      updateRecord(recordId, result);
    } else if (isRetryable(result) && retryCount < MAX_RETRIES) {
      // Retry — enqueue again
      System.enqueueJob(new RetryableCalloutJob(recordId, retryCount + 1));
    } else {
      // Give up — log the failure
      logFailure(recordId, result, retryCount);
    }
  }

  private Boolean isRetryable(CalloutResult result) {
    if (result.statusCode == null)
      return true; // Exception
    return result.statusCode == 429 || result.statusCode >= 500;
  }
}
