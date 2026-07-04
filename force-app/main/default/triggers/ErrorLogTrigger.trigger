trigger ErrorLogTrigger on Error_Log__e(after insert) {
  ErrorLogTriggerHandler.handle(Trigger.new);
}
