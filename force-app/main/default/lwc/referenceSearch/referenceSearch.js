import { LightningElement, api } from 'lwc';
import getInit from '@salesforce/apex/ReferenceSearch.getInit';
import { toggleMoreFilter } from './searchsh.js'; 

export default class ReferenceSearch extends LightningElement {
    @api title = '기본제목';
    moreFilter = false; 

    handleToggleMoreFilter() {
        toggleMoreFilter.call(this); 
    }
}