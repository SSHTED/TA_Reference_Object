import { LightningElement, api} from 'lwc';
import getInit from '@salesforce/apex/ReferenceSearch.getInit';
import { toggleMoreFilter } from './searchsh.js'; 
import { resetValue } from './searchsh.js'; 

export default class ReferenceSearch extends LightningElement {
    @api title = '기본제목';

    handleToggleMoreFilter() {
        toggleMoreFilter.call(this); 
    }

    btnReset(){
        resetValue.call(this);
    }
}