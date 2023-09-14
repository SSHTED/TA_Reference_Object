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
        console.log("초기화 토글 : btnReset"); 
        resetValue.call(this);
    }

    addFilter(){
        const self = this;
        const addFilterEl = this.template.querySelector(addFilter);
        addFilterEl.addEventListener('click', function(e){
            let html = '';
            html += '<tr>';
            html += '<th>';
            html += '<td>';
            html += '</td>';
            html += '</th>';
            html += '</tr>';

            const basicEl = self.template.querySelector('.basicFilterScope');
            basicEl.appendChild(html);
        });
    }

    closeFilter(){
        
    }
}