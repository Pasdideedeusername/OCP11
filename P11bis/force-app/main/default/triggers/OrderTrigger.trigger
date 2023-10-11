trigger OrderTrigger on Order (before update, after delete) {
    User currentUser= [SELECT Id, OrderTriggerBypass__c FROM User WHERE Id=: UserInfo.getUserId()];
    if (!currentUser.OrderTriggerBypass__c == true){
        if (Trigger.isBefore && Trigger.isUpdate){
            OrderTriggerHandler.checkProductsBeforeActivation(Trigger.new, Trigger.oldMap);
        }

        if (Trigger.isAfter && Trigger.isDelete){
        OrderTriggerHandler.updateAccountActiveStatus(Trigger.old);
        }
    }
}