/**
 * Classe Apex pour la création de tâches de rappel pour les comptes sans tâches "Call" existantes.
 * Implémente les interfaces Database.Batchable et Schedulable pour permettre l'exécution en lot
 * planifié.
 */

global class CreationTacheRappelBatch implements Database.Batchable<sObject>, Schedulable {
    /**
     * Méthode start requise par l'interface Database.Batchable. Cette méthode définit la
     * requête pour récupérer les comptes sans commande associée.
     *
     * @param BC Le contexte du lot.
     * @return Database.QueryLocator contenant les enregistrements à traiter.
     */

     global Database.QueryLocator start(Database.BatchableContext BC) {
        // Requête pour récupérer les comptes sans commande associée
        return Database.getQueryLocator('SELECT Id, Name FROM Account WHERE Id NOT IN (SELECT AccountId FROM Order)');
    }

    /**
     * Méthode execute requise par l'interface Database.Batchable. Cette méthode est responsable
     * de la création de nouvelles tâches "Call" pour les comptes.
     *
     * @param BC Le contexte du lot.
     * @param scope La liste des comptes à traiter.
     */

     global void execute(Database.BatchableContext BC, List<Account> scope) {
        Set<Id> accountIdsWithCallTasks = new Set<Id>();
        // Récupére toutes les tâches de rappel de type "Call" pour les comptes
        for (Task task : [SELECT WhatId FROM Task WHERE Subject = 'Call' AND WhatId IN :scope]) {
            accountIdsWithCallTasks.add(task.WhatId);
        }

        List<Task> newTasks = new List<Task>();
        
        for (Account acc : scope) {
            // S'assure que le compte n'a pas de tâche de rappel de type "call"
            if (!accountIdsWithCallTasks.contains(acc.Id))  {
                // Crée une nouvelle tâche pour chaque compte
                Task newTask = new Task(
                    Subject = 'Call',
                    Status = 'New',
                    ReminderDateTime = Date.today().addDays(5),
                    IsReminderSet = true,
                    ActivityDate = Date.today().addDays(5),
                    WhatId = acc.Id
                );
                newTasks.add(newTask);
            }
        }
        // Insère toutes les nouvelles tâches en une seule opération DML
        insert newTasks;
    }

    /**
     * Méthode finish requise par l'interface Database.Batchable. Cette méthode est appelée
     * après l'exécution du lot, mais elle ne contient aucune action dans cette implémentation.
     *
     * @param BC Le contexte du lot.
     */

    global void finish(Database.BatchableContext BC) {
        // Aucune action à effectuer après l'exécution de la tâche de lot 
    }

    /**
     * Méthode execute requise par l'interface Schedulable. Cette méthode planifie l'exécution
     * périodique du lot.
     *
     * @param ctx Le contexte du planificateur.
     
    * note: pour activer dans l'app le scheduler ci-dessous, il faut l'exécuter une fois dans la developper console:
    CreationTacheRappelBatch scheduler = new CreationTacheRappelBatch();
    scheduler.execute(null);
    */
    
    public void execute (SchedulableContext ctx) {
        CreationTacheRappelBatch creationTacheDeRappelBatch = new CreationTacheRappelBatch();
        String cronExp = '0 0 0 ? * 2#1'; // Le 2#1 signifie le premier lundi de chaque mois
        String jobId = system.schedule('création tache de rappel', cronExp, creationTacheDeRappelBatch);
        // Affiche le JobId pour référence
        System.debug('Job Id : ' + jobId);
        
    }

}
