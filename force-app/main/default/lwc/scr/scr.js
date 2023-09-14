import { LightningElement, api } from 'lwc';
import { toggleMoreFilter } from './searchsh.js'; 
import { resetValue } from './searchsh.js'; 



export default class Scr extends LightningElement {
    moreFilter = false;

    handleToggleMoreFilter() {
        console.log("필터 토글 : handleToggleMoreFilter");  
        toggleMoreFilter.call(this); 
    }

    btnReset(){
        console.log("버튼 토글 : btnReset");  
        resetValue.call(this);
    }
}