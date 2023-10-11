@isTest
public  class TestDataFactory {
    
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

    public static Account createAccount (String accountName, Boolean insertData){
        Account account = new Account (Name = accountName, Active__c = true);
        if (insertData){
            insert account;
        }
        return account;
    }

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

    public static List<Account> createManyAccountWithTask (String accountName, Integer NumberOfAccounts, Boolean withTask, Boolean insertData){
        List<Account> accounts = new List<Account>();
        List<Task> tasks = new List<Task>();
        for (Integer i = 0; i < NumberOfAccounts; i++) {
            accounts.add(createAccount((accountName + i), false));
            if(withTask){
                tasks.add(createTask((accountName + i), false));
            }
        }
        if (insertData){
            insert accounts;
            insert tasks;
        }
        return accounts;
    }
 }