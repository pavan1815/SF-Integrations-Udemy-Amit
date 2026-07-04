public with sharing class AccountService {
  public static void insertAccounts(String inpAccountName) {
    Account acc = new Account(name = inpAccountName);
    try {
      insert acc;
    } catch (Exception ex) {
      ErrorLogPublisher.logError(
        'AccountService.insertAccounts',
        'ERROR',
        ex.getMessage(),
        null,
        ex.getStackTraceString()
      );
    }
  }
}
