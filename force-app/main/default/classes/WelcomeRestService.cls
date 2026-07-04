@RestResource(urlMapping='/welcome')
global with sharing class WelcomeRestService {
    
    @HttpGet
    global static String getWelcomeMessage() {
        return 'Welcome to Apex REST Service! Your connection is successful.';
    }
}