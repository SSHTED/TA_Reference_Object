@isTest
public class BCEmailTemplate_TEST {
    static testmethod void Template() {
        BCEmailTemplate template = new BCEmailTemplate('BC Participation Airpot');
        Template.generate('test');
    }
}