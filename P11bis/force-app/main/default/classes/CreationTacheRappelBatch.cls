global class CreationTacheRappelBatch implements Database.Batchable<sObject>, Schedulable {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        // Requête pour récupérer les comptes sans commande associée
        return Database.getQueryLocator('SELECT Id, Name FROM Account WHERE Id NOT IN (SELECT AccountId FROM Order)');
    }

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
                    Priority = 'Normal',
                    ActivityDate = Date.today().addDays(5),
                    WhatId = acc.Id
                );
                newTasks.add(newTask);
            }
        }
        // Insère toutes les nouvelles tâches en une seule opération DML
        insert newTasks;
    }

    global void finish(Database.BatchableContext BC) {
        // Aucune action à effectuer après l'exécution de la tâche de lot 
    }

    /* note: pour activer dans l'app le scheduler ci-dessous, il faut l'exécuter une fois dans la developper console:
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
