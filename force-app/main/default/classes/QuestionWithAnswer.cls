public class QuestionWithAnswer {
	    public Dump_Body__c question {get;set;}
        public Exam_Detail__c exmDtl {get;set;}
        public boolean answerA{get;set;}
        public boolean answerB{get;set;}
        public boolean answerC{get;set;}
        public boolean answerD{get;set;}
        public boolean answerE{get;set;}
        public boolean answerF{get;set;}
        public boolean answerG{get;set;}
        public boolean answerH{get;set;}
        public boolean answerI{get;set;}
        public boolean answerJ{get;set;}
        
        public QuestionWithAnswer(Dump_Body__c pDmpBdy, Exam_Detail__c pExmDtl){
            question = pDmpBdy;
            exmDtl = pExmDtl;
            answerA = false;
            answerB = false;
            answerC = false;
            answerD = false;
            answerE = false;
            answerF = false;
            answerG = false;
            answerH = false;
            answerI = false;
            answerJ = false;
        
        }
}