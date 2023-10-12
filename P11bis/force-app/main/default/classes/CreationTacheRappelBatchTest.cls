/**
 * Classe de test Apex pour le lot (batch) CreationTacheRappelBatch.
 */
@isTest
private class CreationTacheRappelBatchTest {
    /**
     * Méthode de configuration des données de test.
     */
    @TestSetup
    static void makeData(){
        // Crée des comptes sans tâches de rappel de type "Call"
        TestDataFactory.createManyAccountWithTask('AccountWithoutTask', 5, false, true);
    }
    /**
     * Méthode de test pour le lot (batch) CreationTacheRappelBatch.
     */
    @isTest
    static void testBatch() {
        // Exécute le lot (batch)
        Test.startTest();
        CreationTacheRappelBatch batch = new CreationTacheRappelBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        // Vérifie que des tâches de rappel de type "Call" ont été créées pour les comptes
        List<Task> createdTasks = [SELECT Id, WhatId, Subject FROM Task]; 
        System.assertNotEquals(0, createdTasks.size(), 'Aucune tâche n\'a été créée.');

        for (Task task : createdTasks) {
            System.assertEquals('Call', task.Subject, 'Sujet de la tâche incorrect');
        }
    }
}
