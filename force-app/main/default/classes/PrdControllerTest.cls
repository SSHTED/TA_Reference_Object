@isTest
public class PrdControllerTest {
    static Opportunity__c o; // 영업기회
    static OpportunityProduct__c op, op2, op3, op4; // 기회제품
    static Product__c p, p2, p3, p4; // 제품*
	static list<OpportunityProduct__c> oplist;
    static list<OpportunityProduct__c> oplist2;
    static Price_Book_Test__c pb;// PriceBook*
    static Price_Book_Entry__c pe, pe2, pe3, pe4; // PriceBookEntry*
    static list<Price_Book_Entry__c> plist;
    static set<Id> prdid;
    static Id Id;
   
    static{
        pb = new Price_Book_Test__c(Name='testPriceBook', IsActive__c=true); // Pricebook* 생성
        insert pb;
        
        /*
        p = new Product__c(depth_one__c='Salesforce License', Name='ServiceCloud AA');
        // 세부사항을 적은 제품 p 생성
        insert p;
        
        prdid = new set<Id>();
        prdid.add(p.id); // 제품 Id 추가
        system.debug('p------'+p);
        
        p2 = new Product__c(depth_one__c='Salesforce 컨설팅', Name='BB BB');
        insert p2;
        
        prdid.add(p2.id);
        system.debug('p2------'+p2);
        
        p3 = new Product__c(depth_one__c='Tableau License', Name='Desk.com CC');
        insert p3;
        prdid.add(p3.id);
        system.debug('p3------'+p3);
        
        p4 = new Product__c(depth_one__c='Tableau 컨설팅', Name='DD DD');
        insert p4;   
        prdid.add(p4.id);
        system.debug('p4------'+p4);
        */
        
        p = new Product__c(depth_one__c='License', Name='ServiceCloud AA');
        // 세부사항을 적은 제품 라이선스 p 생성
        insert p;
        
        p2 = new Product__c(depth_one__c='용역', Name='용역 AA');
        // 세부사항을 적은 제품 용역 p 생성
        insert p2;
        
        pe = new Price_Book_Entry__c(Price_Book_Test__c = pb.id, Product__c = p.id, UnitPrice__c = 100);// PriceBook Entry
        insert pe;
        system.debug('pe------'+pe);
        plist = new list<Price_Book_Entry__c>();
        plist.add(pe);
        
        pe2 = new Price_Book_Entry__c(Price_Book_Test__c = pb.id, Product__c = p2.id, UnitPrice__c = 200);
        insert pe2;        
        plist.add(pe2);
        /*
        pe3 = new Price_Book_Entry__c(Price_Book_Test__c = pb.id, Product__c = p3.id, UnitPrice__c = 300);
        insert pe3;
        plist.add(pe3);
        
        pe4 = new Price_Book_Entry__c(Price_Book_Test__c = pb.id, Product__c = p4.id, UnitPrice__c = 400);
        insert pe4;
        plist.add(pe4);
        system.debug('plist----'+plist);
        */
        o = new Opportunity__c(Name='test', Sales_Estimated_Date__c=System.today(), Field2__c='Salesforce', Price_Book__c = pb.id); // 이름이 test라는 기회 o 생성
        insert o;
		System.debug('oooooooooo111oooooooo-----------'+o);
        
        op = new OpportunityProduct__c(Opportunity__c=o.id, Product__c=p.id, SalePrice__c=100, number__c=10, Discount__c=10, Month__c=1, StartDate__c=System.today());
        // 기회가 o의 id와 제품이 p의 id(lookup)와 판매가격과 수량을 가진 기회제품 op 생성
        insert op;
        System.debug('op-----------'+op);
        
        op2 = new OpportunityProduct__c(Opportunity__c=o.id, Product__c=p2.id, SalePrice__c=2000, number__c=20, Discount__c=20, Remarks__c='aa');
        insert op2;
        System.debug('op2-----------'+op2);
        /*
        op3 = new OpportunityProduct__c(Opportunity__c=o.id, Product__c=p3.id, SalePrice__c=3000, number__c=30, Discount__c=30, Month__c=3, StartDate__c=System.today());
        insert op3;
        System.debug('op3-----------'+op3);
        
        op4 = new OpportunityProduct__c(Opportunity__c=o.id, Product__c=p4.id, SalePrice__c=4000, number__c=40, Discount__c=40, Remarks__c='bb');
        insert op4;
        System.debug('op4-----------'+op4);
		*/
    }
            
    @isTest
    static void myUnitTest01() { // saleforce 라이선스
        
        Test.startTest(); 
        System.debug('라이선스1 start-----------------------');
        PageReference pg = Page.PrdList;
        Test.setCurrentPage(pg);
        Apexpages.currentPage().getParameters().put('oppid', o.id); 
        Apexpages.currentPage().getParameters().put('opid', o.id); 
        Apexpages.currentPage().getParameters().put('prbid', pb.id); 
        PrdController PrdController  = new PrdController();
        PrdController.deletedid = op.Product__c;
        PrdController.selectedid = p.id;
        // PrdController.plist = plist;
        // insert new Price_Book_Entry__c(Price_Book_Test__c = pb.id, Product__c = p.id, UnitPrice__c = 200);
		PrdController.plist = [select name, depth_one__c, id from Product__c];
        // 위 plist에 Product__r.depth_one__c을 넣을 수 없기때문에 쿼리로 해줌
        
        PrdController.oprd.Product__c = p.id;
        PrdController.paramValue = p.id;
        
        // 기존 컨트롤러에서 test
         
        PrdController.selectProduct();
        PrdController.getProductList();
        PrdController.deleteProduct();
        PrdController.listSave();
        PrdController.cancel();
        PrdController.ClosePopup();
		PrdController.ShowPopup();
        PrdController.selectLeft();
        PrdController.selectRight();
        System.debug('라이선스1 stop-----------------------');
        Test.Stoptest();
    }
    
    @isTest
    static void myUnitTest02() { // salesforce 컨설팅
        // TO DO: implement unit test
        Test.startTest(); 
        System.debug('컨설팅1 start-----------------------');
        PageReference pg = Page.PrdList;
        Test.setCurrentPage(pg); 
        Apexpages.currentPage().getParameters().put('oppid', o.id);
        Apexpages.currentPage().getParameters().put('opid', o.id);
        Apexpages.currentPage().getParameters().put('prbid', pb.id); 
        PrdController PrdController  = new PrdController();
        PrdController.deletedid2 = op2.Product__c;
        PrdController.selectedid = p2.id;
        insert new Price_Book_Entry__c(Price_Book_Test__c = pb.id, Product__c = p2.id, UnitPrice__c = 200);
        PrdController.plist = [select name, depth_one__c, id from Product__c];
        system.debug('--------------------------------------------- plist : '+PrdController.plist);
        PrdController.oprd.Product__c = p2.id;
        PrdController.paramValue = p2.id;
        
        PrdController.selectProduct();
        PrdController.getProductList();
        PrdController.deleteProduct2();
        PrdController.cancel();
        PrdController.ClosePopup();
        PrdController.ShowPopup();
        PrdController.selectLeft2();
        PrdController.selectRight2();
        System.debug('컨설팅1 stop-----------------------');
        Test.Stoptest();
    }
    /*
    @isTest
    static void myUnitTest03() { // tableau 라이선스
        Test.startTest(); 
        System.debug('라이선스2 start-----------------------');
        PageReference pg = Page.PrdList;
        Test.setCurrentPage(pg);
        Apexpages.currentPage().getParameters().put('oppid', o.id); 
        Apexpages.currentPage().getParameters().put('opid', o.id); 
        Apexpages.currentPage().getParameters().put('prbid', pb.id); 
        PrdController PrdController  = new PrdController();
        PrdController.deletedid = op3.Product__c;
        PrdController.selectedid = p3.id;
		insert new Price_Book_Entry__c(Price_Book_Test__c = pb.id, Product__c = p3.id, UnitPrice__c = 200);
        PrdController.plist = [select Product__r.name, Product__r.depth_one__c, Product__r.id, UnitPrice__c from Price_Book_Entry__c];   
        PrdController.oprd.Product__c = p3.id;
        PrdController.paramValue = p3.id;
        
        // 기존 컨트롤러에서 test
        PrdController.selectProduct();
        PrdController.getProductList();
        PrdController.deleteProduct();
        PrdController.listSave();
        PrdController.cancel();
        PrdController.ClosePopup();
        PrdController.ShowPopup();
        PrdController.selectLeft();
        PrdController.selectRight();
        System.debug('라이선스2 stop-----------------------');
        Test.Stoptest();
    }     
    @isTest
    static void myUnitTest04() { // tableau 컨설팅
        // TO DO: implement unit test
        Test.startTest(); 
        System.debug('컨설팅2 start-----------------------');
        PageReference pg = Page.PrdList;
        Test.setCurrentPage(pg); 
        Apexpages.currentPage().getParameters().put('oppid', o.id);
        Apexpages.currentPage().getParameters().put('opid', o.id);
        Apexpages.currentPage().getParameters().put('prbid', pb.id); 
        PrdController PrdController  = new PrdController();
        PrdController.selectedid = p4.id;
        insert new Price_Book_Entry__c(Price_Book_Test__c = pb.id, Product__c = p4.id, UnitPrice__c = 200);
        PrdController.plist = [select Product__r.name, Product__r.depth_one__c, Product__r.id, UnitPrice__c from Price_Book_Entry__c]; 
        PrdController.deletedid2 = op4.Product__c;
        PrdController.paramValue = p4.id;
        /*
        PrdController prdc  = new PrdController();
        prdc.paramValue = op4.id;
        prdc.prd = p4;
        prdc.prd.depth_one__c = 'Tableau 컨설팅';
        prdc.prd.Name='DD DD';
        prdc.selectedid = p4.id;
        prdc.plist = plist;
        prdc.oprd.Product__c = p4.id;
        prdc.oprd.Opportunity__c = op4.id;
        System.debug('prdc.oprd.Opportunity__c 컨설팅 선택된 아이디 ---------'+prdc.oprd.Opportunity__c);
        
        prdc.oprd.SalePrice__c = 0;
        prdc.oprd.number__c = 0;
        prdc.oprd.Discount__c = 0;
        prdc.oprd.Remarks__c = null;
        prdc.oplist2.add(op4); // 필드 초기화 후 op의 정보를 oplist에 추가
        System.debug('prdc.oplist2 컨설팅 추가 ---------'+prdc.oplist2);
        
        prdc.deletedid2 = op2.Product__c;
        */
        /*
        PrdController.selectProduct();
        PrdController.getProductList();
        PrdController.deleteProduct2();
        PrdController.cancel();
        PrdController.ClosePopup();
        PrdController.ShowPopup();
        PrdController.selectLeft2();
        PrdController.selectRight2();
        System.debug('컨설팅2 stop-----------------------');
        Test.Stoptest();
    }
		*/
}