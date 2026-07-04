@RestResource(urlMapping='/contacts')
global with sharing class ContactRestService {

    @Httpput
    global static String upsertContact(String FirstName, String LastName, String Email, String Phone, String Title) {

        //validate required fields - lastname and email
        if (String.isBlank(LastName) || String.isBlank(Email)) {
            return 'Error: LastName and Email are required fields.';
        }

        //Check if contact with the same email already exists
        List<Contact> existingContact = [SELECT Id FROM Contact WHERE Email = :Email LIMIT 1];

        String operation = '';
        Contact contactRecord;

        if(existingContact.size() > 0){
          operation = 'updated';
          contactRecord = existingContact[0];
        }else{
            operation = 'created';
            contactRecord = new Contact();
        }

        //set the field values
        contactRecord.FirstName = FirstName;
        contactRecord.LastName = LastName;
        contactRecord.Email = Email;
        contactRecord.Phone = Phone;
        contactRecord.Title = Title;

        if(operation == 'created'){
            insert contactRecord;
        } else {
            update contactRecord;
        }   

        return 'Contact ' + operation + ' successfully with Id: ' + contactRecord.Id;

    }
    
}