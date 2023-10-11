@isTest
private class CreationTacheRappelBatchTest {

    @isTest
    static void testBatch() {
        // Crée des comptes sans tâches de rappel de type "Call"
        TestDataFactory.createManyAccountWithTask('AccountWithoutTask', 5, false, true);

        // Exécute le lot (batch)
        Test.startTest();
        CreationTacheRappelBatch batch = new CreationTacheRappelBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        // Vérifie que des tâches de rappel de type "Call" ont été créées pour les comptes
        List<Task> createdTasks = [SELECT Id, WhatId, Subject FROM Task]; // question pour William: pour sélectionner les taches de comptes spécifiques ?
        System.assertNotEquals(0, createdTasks.size(), 'Aucune tâche n\'a été créée.');

        for (Task task : createdTasks) {
            System.assertEquals('Call', task.Subject, 'Sujet de la tâche incorrect');
        }
    }
}
