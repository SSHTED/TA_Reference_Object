import { LightningElement, api} from 'lwc';
import getInit from '@salesforce/apex/ReferenceSearch.getInit';
import { toggleMoreFilter } from './searchsh.js'; 
import { resetValue } from './searchsh.js'; 

export default class ReferenceSearch extends LightningElement {
    @api title = '기본제목';
    moreFilter = false;

    handleToggleMoreFilter() {
        console.log("필터 토글 : handleToggleMoreFilter");  
        toggleMoreFilter.call(this); 
    }

    btnReset(){
        console.log("초기화 토글 : btnReset"); 
        resetValue.call(this);
    }

}