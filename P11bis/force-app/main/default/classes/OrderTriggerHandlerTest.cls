@isTest
public class OrderTriggerHandlerTest {
    @TestSetup
    static void makeData(){ 
        // Crée un compte avec Active__c à true
        Account account = TestDataFactory.createAccount('Test Account', true);
            
        // Crée 2 Order associés au compte en utilisant TestDataFactory
        Order order1 = TestDataFactory.createOrder(account.Id, true);
        Order order2 = TestDataFactory.createOrder(account.Id, true);
    }
    
    @isTest
    static void testOrderActivationWithoutProducts() {
        // Met à jour le statut de l'Order en "Activated"
        List<Order> testOrders = [SELECT Id, Status FROM Order];
        for (Order testOrder : testOrders) {
            testOrder.Status = 'Activated';
        }
        
        DmlException ex;
        Test.startTest();
        try {
            update testOrders;
        } catch (DmlException e) {
            ex = e;
        }
        Test.stopTest();
        
        // Vérifie si l'erreur contient le message attendu
        String expectedErrorMessage = OrderTriggerHandler.ERROR_NO_PRODUCT;
        System.assertEquals(true, ex.getMessage().contains(expectedErrorMessage), 'Le message d\'erreur est incorrect');
    }

    @isTest
    static void testUpdateAccountActiveStatus() {
        // Récupére le compte créé par votre TestDataFactory
        Account testAccount = [SELECT Id, Active__c FROM Account LIMIT 1];
        
        Test.startTest();
        // Vérifie si le compte est actif
        System.assertEquals(true, testAccount.Active__c, 'Le compte devrait être actif');
        
        // Supprime les Order
        List<Order> ordersToDelete = [SELECT Id FROM Order];
        delete ordersToDelete;
        Test.stopTest();
        
        // Vérifie si le compte est désactivé après la suppression des Order
        testAccount = [SELECT Id, Active__c FROM Account WHERE Id = :testAccount.Id];
        System.assertEquals(false, testAccount.Active__c, 'Le compte devrait être désactivé');
    }
}
