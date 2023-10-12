/**
 * Déclencheur Apex pour l'objet Order, qui se déclenche avant une mise à jour et après une suppression.
 * Ce déclencheur gère la logique métier des commandes et de la mise à jour du statut actif du compte associé.
 */
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