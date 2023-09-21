import { LightningElement, api, track, wire } from 'lwc';
import getInit from '@salesforce/apex/ReferenceSearchController.getInit';
import getDataByFilter from '@salesforce/apex/ReferenceSearchController.getDataByFilter';
// import { resetValue } from './searchsh.js';


export default class ReferenceSearch extends LightningElement {
    @api title = '기본제목';
    @track isKorean = false;
    @track isEnglish = false;
    @track result = [];
    loaded = false;
    isButtonDisabled = false;
    searchCriteria = '';

    refAllData = [];
    supCallsList = [];
    supCallsItems = []; 

    @wire(getInit)
    wiredInit({ error, data }) {
        if (data && data.result) {
            console.log(':::::::::::::::: wiredInit :::::::::::::::: ');
            this.refAllData = data.result.refAllData;
            this.initialData = [...this.refAllData];  //복사본
            this.supCallsList = data.result.callList;
            this.supCallsItems = this.supCallsList.map(val => {
                val = val.replace('()', '');
                return { label: `${val}`, name: `${val}`, checked: false };
            });

            console.log('data >>>>>>>>>>> ', data);

            
            this.setTable();
            this.updateSearchCriteria();
        } else if (error) {
            console.error('wiredInit 에러 :', error);
        }
    }

    setTable(refData) {
        this.loaded = false;
        console.log(":::::::::::::::: setTable start ::::::::::::::::");
        if (!refData) {
            refData = this.refAllData;
        }
        if (Array.isArray(refData)) {
            // this.refAllData = refData;
            this.refAllData = refData.map(item => {
                return {
                    ...item,
                    objectReferenceDetailUrl: `https://dkbmc--pms.sandbox.lightning.force.com/lightning/r/ObjectReference__c/${item.Id}/view`
                };
            });

            console.log("refAllData : ", this.refAllData)
            this.loaded = true;
            console.log(":::::::::::::::: setTable end :::::::::::::::: ")
        } else {
            console.error(' setTable 에러 : ', error);
            console.error(' setTable 에러 refData  : ', refData);
        }
        this.isButtonDisabled = false;
    }

    btnSearch() {
        console.log(":::::::::::::::: btnSearch 시작 ::::::::::::::::")
        this.isButtonDisabled = true;

        const name = this.template.querySelector('[data-id="name"]').value;
        const description = this.template.querySelector('[data-id="description"]').value;
        const apiversion = this.template.querySelector('[data-id="apiversion"]').value;
        const specialAccessRules = this.template.querySelector('[data-id="specialAccessRules"]').value;
        const usage = this.template.querySelector('[data-id="usage"]').value;
        const memo = this.template.querySelector('[data-id="memo"]').value;
        const isKorean = this.isKoreanText(name);
        const isEnglish = this.isEnglishText(name);
        let supportedCalls = '';

        // Supported Calls
        const callsCheckedboxes = this.template.querySelectorAll('[data-id="callsChecked"]');
        callsCheckedboxes.forEach((checkbox, idx) => {
            if (checkbox.checked) {
                if (idx == callsCheckedboxes.length - 1) {
                    supportedCalls += checkbox.name + '()';
                } else {
                    supportedCalls += checkbox.name + '();';
                }
            }
        });
        console.log('supportedCalls : ', supportedCalls);

        // 현재 삭제된 API 여부 확인 
        const removeChecked = this.template.querySelector('[data-id="remove"]');
        const remove = removeChecked.checked;
        console.log("remove : " + remove)

        if (description && description.length < 2) {

            //Alert lightning-toast 로 추후 변경 ********************************************************************

            alert('Description은 2글자 이상이어야 합니다. 추후 변경 필요 ');
            return;
        }

        // filterGroup에 값을 저장하여 백엔드로 전달
        let filterGroup = {
            ApiVersion: apiversion,
            SupportedCalls: supportedCalls,
            Description: description,
            Remove: remove,
            SpecialAccessRules: specialAccessRules,
            Usage: usage,
            Memo: memo
        };

        console.log("filterGroup : " + JSON.stringify(filterGroup));
        if (isKorean) {
            filterGroup.KorLabel = name;  
        } else if (isEnglish) {
            if (this.hasWhitespaceInMiddle()) {
                filterGroup.EngLabel = name;  
            } else {
                filterGroup.Name = name; 
            }
        }

        getDataByFilter({ filterGroup: JSON.stringify(filterGroup) })
            .then(result => {
                if (result.success == true) {
                    console.log("result data : ", result.result);
                    this.setTable(result.result);
                } else {
                    console.error('result 에러 : ', error);
                }
            })
            .catch(error => {
                console.error('getDataByFilter 에러 : ', error);
            }).finally(() => {
                this.isButtonDisabled = false;
            });

        //헤더 검색조건
        this.updateSearchCriteria(name, description, apiversion, remove, specialAccessRules, memo, supportedCalls);

    }

    btnReset() {
        console.log(":::::::::::::::: btnReset 시작 ::::::::::::::::");
        const checkboxes = this.template.querySelectorAll('.selectedCheckbox');
        checkboxes.forEach(checkbox => {
            checkbox.checked = false;
        });
        const inputboxes = this.template.querySelectorAll('.inputValue');
        inputboxes.forEach(inputbox => {
            inputbox.value = '';
        });

        this.setTable(this.initialData);
        this.updateSearchCriteria();
    }

    // 입력받은 텍스트가 영어일 때 공백여부를 확인하기 위한 함수
    hasWhitespaceInMiddle() {
        let name = this.template.querySelector('[data-id="name"]').value;
        const str = name;
        let result = false;
        // 문자열 중간에 있는 공백 여부 확인
        for (let i = 0; i < str.length; i++) {
            if (str[i] === ' ') {
                result = true; // 중간에 공백이 있으면 true 반환
            }
        }
        return result;
    }

    // Enter
    checkKey(event) {
        if ((event.target.classList.contains('inputValue') || event.target.classList.contains('selectedCheckbox')) && event.key === "Enter") {
            this.btnSearch();
            console.log("enter")
        }
    }
    isKoreanText(text) {
        const koreanRegex = /[가-힣]/;
        return koreanRegex.test(text);
    }
    isEnglishText(text) {
        const englishRegex = /^[a-zA-Z\s]+$/;
        return englishRegex.test(text);
    }

    // 헤더 검색조건 
    updateSearchCriteria(
        name = '',
        description = '',
        apiversion = '',
        remove = false,
        specialAccessRules = '',
        memo = '',
        supportedCalls = ''
    ) {
        this.searchCriteria = '';
        this.searchCriteria += `이름: ${name} | `;
        this.searchCriteria += `Description: ${description} | `;
        this.searchCriteria += `Api Version: ${apiversion} | `;
        this.searchCriteria += `삭제된 API : ${remove ? 'Yes' : 'No'} | `;
        this.searchCriteria += `Special Access Rules: ${specialAccessRules} | `;
        this.searchCriteria += `Memo: ${memo} | `;
        this.searchCriteria += `Supported Calls: ${supportedCalls} `;
    }

    toggleResultCard(event) {
        const clickedElement = event.target;

        if (clickedElement.classList.contains('result_card')) {
            console.log("되냐?")
        }
    }
    

    toggleInputCard = false;
    toggleResultCard(){
        this.toggleInputCard = !this.toggleInputCard;
    }
}