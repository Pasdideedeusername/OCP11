public class OrderTriggerHandler {
    public static final String ERROR_NO_PRODUCT = 'Trigger P11: Vous ne pouvez pas activer cette Commande car il n\'a pas de produits associés.';
    public static void checkProductsBeforeActivation(List<Order> newOrders, Map<Id, Order> oldOrderMap) {
        List<Id> orderIdsToCheck = new List<Id>();
        
        // Identifie les Order qui passent de "Draft" à "Active"
        for (Order newOrder : newOrders) {
            Order oldOrder = oldOrderMap.get(newOrder.Id);
            if (newOrder.Status == 'Activated' && (oldOrder == null || oldOrder.Status != 'Activated')) {
                orderIdsToCheck.add(newOrder.Id);
            }
        }
        
        // Vérifie si les Order ont des produits associés
        List<Id> orderIdsWithProducts = new List<Id>();
        for (OrderItem item : [SELECT OrderId FROM OrderItem WHERE OrderId IN :orderIdsToCheck]) {
            orderIdsWithProducts.add(item.OrderId);
        }
        
        // Si des Order n'ont pas de produits associés, génère un message d'erreur
        for (Order newOrder : newOrders) {
            if (orderIdsToCheck.contains(newOrder.Id) && !orderIdsWithProducts.contains(newOrder.Id)) {
                newOrder.addError(ERROR_NO_PRODUCT);
            }
        }
    }

    public static void updateAccountActiveStatus(List<Order> deletedOrders) {
        Set<Id> accountIdsToUpdate = new Set<Id>();
        
        // Récupère les IDs de compte des Order supprimés
        for (Order deletedOrder : deletedOrders) {
            accountIdsToUpdate.add(deletedOrder.AccountId);
        }
        
        // Récupère les comptes associés aux Order supprimés
        List<Account> accountsToUpdate = [SELECT Id, (SELECT Id FROM Orders) FROM Account WHERE Id IN :accountIdsToUpdate];
        
        // désactive de champ du compte s'il n'a pas de commande
        List<Account> accountsToUpdateActiveStatus = new List<Account>();
        for (Account account : accountsToUpdate) {
            if (account.Orders.isEmpty()) {
                account.Active__c = false;
                accountsToUpdateActiveStatus.add(account);
            }
        }
        
        // Met à jour les comptes
        update accountsToUpdateActiveStatus;
        
    }
}