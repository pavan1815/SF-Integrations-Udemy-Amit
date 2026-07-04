public with sharing class AccountChangeEventHandler {
  public static void handleChanges(List<AccountChangeEvent> events) {
    Set<String> accountIds = new Set<String>();

    for (AccountChangeEvent evt : events) {
      EventBus.ChangeEventHeader header = evt.ChangeEventHeader;
      String changeType = header.getChangeType();

      if (changeType != 'UPDATE') {
        continue;
      }

      List<String> changedFields = header.getChangedFields();
      if (!changedFields.contains('Active__c')) {
        continue;
      }

      String activeValue = (String) evt.get('Active__c');
      if (activeValue != 'No') {
        continue;
      }

      accountIds.addAll(header.getRecordIds());
    }

    if (accountIds.isEmpty()) {
      return;
    }

    List<Task> tasksToCreate = new List<Task>();

    Map<Id, Account> accounts = new Map<Id, Account>(
      [SELECT Id, OwnerId, Name FROM Account WHERE Id IN :accountIds]
    );

    for (Account acc : accounts.values()) {
      tasksToCreate.add(
        new Task(
          Subject = 'Follow Up - Account Deactivated: ' + acc.Name,
          WhatId = acc.Id,
          OwnerId = acc.OwnerId,
          Priority = 'High',
          Status = 'Not Started',
          ActivityDate = Date.today().addDays(3),
          Description = 'This account was marked inactive. Please follow up to understand the reason and attempt to re-engage.'
        )
      );
    }

    if (!tasksToCreate.isEmpty()) {
      Database.SaveResult[] results = Database.insert(tasksToCreate, false);
      for (Integer i = 0; i < results.size(); i++) {
        if (!results[i].isSuccess()) {
          System.debug(
            LoggingLevel.ERROR,
            'Failed to create task: ' + results[i].getErrors()[0].getMessage()
          );
        }
      }
    }
  }
}
