/**
 * Classe de test utilitaire pour la création de données de test dans les tests Apex.
 */
@isTest
public  class TestDataFactory {
    /**
     * Crée une commande avec des options pour l'insertion dans la base de données.
     *
     * @param accountId L'ID du compte associé à la commande.
     * @param insertData Indique si la commande doit être insérée dans la base de données.
     * @return Order La commande créée.
     */

    public static Order createOrder (Id accountId, Boolean insertData){ 
        Order order = new Order(
                        AccountId = accountId, 
                        EffectiveDate= date.today(), 
                        Status='Draft', 
                        Pricebook2Id=Test.getStandardPricebookId()); 

        if (insertData){
            insert order;
        }
        return order;
    }

    /**
     * Crée un compte avec des options pour l'insertion dans la base de données.
     *
     * @param accountName Le nom du compte.
     * @param insertData Indique si le compte doit être inséré dans la base de données.
     * @return Account Le compte créé.
     */

    public static Account createAccount (String accountName, Boolean insertData){
        Account account = new Account (Name = accountName, Active__c = true);
        if (insertData){
            insert account;
        }
        return account;
    }

    /**
     * Crée une tâche de rappel avec des options pour l'insertion dans la base de données.
     *
     * @param whatId L'ID de l'objet associé à la tâche de rappel.
     * @param insertData Indique si la tâche de rappel doit être insérée dans la base de données.
     * @return Task La tâche de rappel créée.
     */

    public static Task createTask (String whatId, Boolean insertData){
        Task newTask = new Task(
                    Subject = 'Call',
                    Status = 'New',
                    Priority = 'Normal',
                    ActivityDate = Date.today().addDays(5),
                    WhatId = whatId);
        if (insertData){
            insert newTask;
        }
        return newTask;
    }

    /**
     * Crée plusieurs comptes avec des options pour l'insertion dans la base de données.
     *
     * @param accountName Le nom de base pour les comptes.
     * @param NumberOfAccounts Le nombre de comptes à créer.
     * @param withTask Indique si une tâche de rappel "Call" doit être associée à chaque compte.
     * @param insertData Indique si les comptes et les tâches de rappel doivent être insérés dans la base de données.
     * @return List<Account> La liste des comptes créés.
     */
        
    public static List<Account> createManyAccountWithTask (String accountName, Integer NumberOfAccounts, Boolean withTask, Boolean insertData){
        List<Account> accounts = new List<Account>();
        List<Task> tasks = new List<Task>();
        for (Integer i = 0; i < NumberOfAccounts; i++) {
            Account account = createAccount((accountName + i), false);
            accounts.add(account);
            if(withTask){
                tasks.add(createTask(account.Id, false));
            }
        }
        if (insertData){
            insert accounts;
            insert tasks;
        }
        return accounts;
    }
 }