public class ExamController{
    public string dumpId {get;set;}
    public Dump_Header__c dmpObj {get;set;}
    public map<Id,Dump_Header__c> hdMap {get;set;}
    public QuestionWithAnswer curQwA {get;set;}    
    public integer curIdx {get;set;}
    public list<QuestionWithAnswer> qwaLst {get;set;}
    public boolean isLast{get;set;}
    public boolean hasText{get;set;}
    public boolean isFinish{get;set;}
    public Exam__c exm{get;set;}
    public integer fromIdx{get;set;}
    public integer toIdx{get;set;}
    public boolean chkErrRange{get;set;}
    
    public  list<SelectOption>  dumpList{
        get{
            list<SelectOption> dl = new list<SelectOption>();
            List<Dump_Header__c> dmpLst = [Select Id, Name, Passing_Score__c, Questions__c, Time_Limit__c, cntExam__c from Dump_Header__c];
            hdMap = new map<Id,Dump_Header__c>(dmpLst);
            for(Dump_Header__c dmp : dmpLst){
                SelectOption so = new SelectOption(dmp.Id, dmp.Name);
                dl.add(so);
            }
            dmpObj = dmpLst[0];
            dumpId = dmpObj.Id;
            
            fromIdx = Integer.valueOf((hdMap.get(dumpId)).cntExam__c) != 0 ? 1 : 0;
            toIdx = Integer.valueOf((hdMap.get(dumpId)).cntExam__c) != 0 ? Integer.valueOf((hdMap.get(dumpId)).cntExam__c) : 0;
            return dl;
        }
        set;
    }
    
    public ExamController(){
        curIdx = -1;
        isLast = false;
        hasText = true;
        isFinish = false;
        chkErrRange = false;
    }
    public void changeDump(){
        dmpObj = hdMap.get(dumpId);
        fromIdx = Integer.valueOf((hdMap.get(dumpId)).cntExam__c) != 0 ? 1 : 0;
        toIdx = Integer.valueOf((hdMap.get(dumpId)).cntExam__c) != 0 ? Integer.valueOf((hdMap.get(dumpId)).cntExam__c) : 0;
    }
    
    public void genExam(){
        //다시 호출하지 않으면 처음지정한 값으로 출력된다.
        dmpObj = hdMap.get(dumpId);
        //출제범위 체크
        if((dmpObj.Questions__c != null) && (dmpObj.cntExam__c != null)){
            chkErrRange = (integer.valueOf(dmpObj.Questions__c) <= (toIdx - fromIdx)) ? 
                    (fromIdx > 0 && toIdx <= integer.valueOf(dmpObj.cntExam__c) ? true : false) : false;
        }
        	
        if(chkErrRange){
            integer qsts = integer.valueOf(dmpObj.Questions__c);
            exm = new Exam__c(
                                        Dump_Header__c = dumpId,
                                        Start__c = Datetime.now(),
                                        Elapsed_Time__c = 0,
                                        Is_finish__c = false
                                     );
            string q = 'SELECT  Name, Subject__c, Option_A__c, Option_B__c, Option_C__c, Option_D__c, ';
            q       += 'Option_E__c, Option_F__c, Option_G__c, Option_H__c, Option_I__c, ';
            q       += 'Option_J__c, Answer__c, Correct_Text__c, Dump_Header__c ';
            q       += 'FROM    Dump_Body__c ';
            q       += 'WHERE   Dump_Header__c = \'' + dumpId + '\' ';
            q       += 'AND Cnt__c >= '+ fromIdx +' AND Cnt__c <= '+ toIdx +'';
            if(!hasText)
                q   += 'AND     Correct_Text__c = null ';
            list<Dump_Body__c> bodyLst = Database.query(q);
            set<integer> idxSet = ranWithLimit(bodyLst.size(),qsts);
            qwaLst = new list<QuestionWithAnswer>();
            for(integer idx : idxSet){
                Dump_Body__c dmpBody = bodyLst[idx];
                Exam_Detail__c exDtl = new Exam_Detail__c(
                                                            Correct_Answer__c = dmpBody.Answer__c,
                                                            Dump_Body__c = dmpBody.Id,
                                                            Is_correct__c = false
                                                          );
                                                            
                QuestionWithAnswer qwa = new QuestionWithAnswer(dmpBody,exDtl);
                qwaLst.add(qwa);
            }        
            curQwA = qwaLst[0];
            curIdx = 0;
         }else{
            MessageUtility.showError('출제 문항수 보다 출제 범위가 작거나 출제 범위에 문제가 있습니다.');
        }   
    }
    
    public set<integer> ranWithLimit(integer upperLimit, integer numberOfRands){
        set<integer> idxSet = new set<integer>();
        for( ; idxSet.size() < numberOfRands ; ){
            idxSet.add(Math.floor(Math.random() * upperLimit).intValue());
        }
        return idxSet;
    }
    
    public void getNext(){
        if(curQwA != null){
            qwaLst[ curIdx++ ] = curQwA;
            curQwA = qwaLst[ curIdx ];
            
            if(curIdx + 1 == qwaLst.size())
            	isLast = true;
        }

    }
    public void getPrevious(){
        if(curQwA != null){
            qwaLst[ curIdx-- ] = curQwA;
            curQwA = qwaLst[ curIdx ];
        }
    }
    public void finish(){
        if(exm != null){
            exm.Finish__c = Datetime.now();
            integer elapsedTime = ((exm.Finish__c.hour() - exm.Start__c.hour() ) * 60 ) + exm.Finish__c.minute() - exm.Start__c.minute() ;
            exm.Elapsed_Time__c = elapsedTime;
            insert exm;
            string exmId = exm.Id;
            integer i = 1;
            string exmName = [SELECT NAME FROM Exam__c WHERE Id = :exm.Id].Name;
            list<Exam_Detail__c> edLst = new list<Exam_Detail__c>();
            for(QuestionWithAnswer qwa : qwaLst ){
                string dtlName = exmName + ' - ' + integer.valueOf(i++);
                if(String.isBlank(qwa.question.Correct_Text__c)){
                    string answers = '';
                    if(qwa.answerA)
                        answers += 'A;';
                    if(qwa.answerB)
                        answers += 'B;';
                    if(qwa.answerC)
                        answers += 'C;';
                    if(qwa.answerD)
                        answers += 'D;';
                    if(qwa.answerE)
                        answers += 'E;';
                    if(qwa.answerF)
                        answers += 'F;';
                    if(qwa.answerG)
                        answers += 'G;';
                    if(qwa.answerH)
                        answers += 'H;';
                    if(qwa.answerI)
                        answers += 'I;';
                    if(qwa.answerJ)
                        answers += 'J;';
                    qwa.exmDtl.Answer__c = answers;
                    string correctAnswer = qwa.question.Answer__c + ';';
                    if(answers == correctAnswer)
                        qwa.exmDtl.Is_correct__c = true;
                }
                else{
                    qwa.exmDtl.Is_correct__c = true;
                }
                qwa.exmDtl.Name = dtlName;
                qwa.exmDtl.Exam__c = exmId;
                edLst.add(qwa.exmDtl);
            }
            insert edLst;
            
            exm = [SELECT Id, Name, Dump_Header__c, Start__c, Finish__c, Elapsed_Time__c, PassCount__c, Dump_Header__r.Questions__c, Score__c, Dump_Header__r.Passing_Score__c,Is_Pass__c,Owner.Name
                   FROM   Exam__c
                   WHERE  Id = :exmId];
            isFinish = true;
        }
    }
}