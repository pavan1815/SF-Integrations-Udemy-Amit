trigger AccountChangeEventTrigger on AccountChangeEvent(after insert) {
  AccountChangeEventHandler.handleChanges(Trigger.new);
}
