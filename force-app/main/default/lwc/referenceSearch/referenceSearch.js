import { LightningElement, api } from 'lwc';
import getInit from '@salesforce/apex/ReferenceSearch.getInit';

export default class ReferenceSearch extends LightningElement {
    @api title = '기본제목';
}