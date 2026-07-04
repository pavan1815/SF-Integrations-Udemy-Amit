@RestResource(urlMapping='/accounts')
global with sharing class AccountRestService {

    @HttpPost
    global static String createAccount(String Name){

        if(String.isBlank(Name)){
            return 'Account name cannot be blank';
        }
        Account acc = new Account(Name = Name);
        try {
            insert acc;
            return 'Account created successfully with Id: ' + acc.Id;
        } catch (Exception e) {
            return 'Error creating account: ' + e.getMessage();
        }
    }
    
}