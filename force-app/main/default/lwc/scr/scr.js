import { LightningElement, api, track, wire } from 'lwc';
// import getInit from '@salesforce/apex/ReferenceSearchController.getInit';
import { toggleMoreFilter } from './searchsh.js'; 
import { resetValue } from './searchsh.js';


export default class ReferenceSearch extends LightningElement {
    @api title = '기본제목';
    @track isKorean = false;
    @track isEnglish = false;

    







    supCallsList = [];
    isChecked = false;

    inputList = [];
    setFilterCalls(){
        console.log('setFilterCalls >>>>>>>>>>>>>>>> 진입');
        const supCallsListLen = this.supCallsList.length;
        const loofCnt = supCallsListLen%3 == 0 ? supCallsListLen/3 : parseInt(supCallsListLen/3)+1;
        let cnt = 0;
        const supLen = this.supCallsList.length;

        for(const supCall of this.supCallsList) {
            if(cnt%3 == 0){
                this.inputList.push({
                    type: 'checkbox',
                    label: 'Label ' + (i + 1),
                    name: 'create',
                    checked: true
                });
            }

        }


        console.log('supEl.innerHTML >>>>>>>>>>>>>>>>>>>>>>> : ', supEl.innerHTML);
    }







}