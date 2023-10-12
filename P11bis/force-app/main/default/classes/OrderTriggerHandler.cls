/**
 * Classe Apex pour gérer les déclencheurs et les opérations associées aux objets Order.
 */
public class OrderTriggerHandler {
     /**
     * Message d'erreur affiché lorsque la commande n'a pas de produits associés.
     */
    public static final String ERROR_NO_PRODUCT = 'Trigger P11: Vous ne pouvez pas activer cette Commande car il n\'a pas de produits associés.';
     /**
     * Vérifie si les produits sont associés avant d'activer une commande.
     *
     * @param newOrders Liste des nouvelles commandes.
     * @param oldOrderMap Map des anciennes commandes.
     */
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
    /**
     * Met à jour le statut actif du compte en fonction des commandes supprimées.
     *
     * @param deletedOrders Liste des commandes supprimées.
     */
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