import { LightningElement, api, track, wire } from 'lwc';
import getInit from '@salesforce/apex/ReferenceSearchController.getInit';
import getDataByFilter from '@salesforce/apex/ReferenceSearchController.getDataByFilter';

export default class ReferenceSearch extends LightningElement {
    @api title = '기본제목';
    @track result = [];
    @track loading = true;
    isButtonDisabled = false;
    toggleInputCard = false;
    searchCriteria = '';

    refAllData = [];
    supCallsList = [];
    supCallsItems = [];
    @track displayFields = {description: false, specialAccessRules: false,usage: false,memo: false,remove: false, SupportedCalls: false};
    displayHeaders = [];
    sortDirection = {};

    @wire(getInit)
    wiredInit({ error, data }) {
        if (data && data.result) {
            this.changeBooleanByKey('loading', false);
            console.log(':::::::::::::::: wiredInit start :::::::::::::::: ');
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
            console.log(':::::::::::::::: wiredInit end :::::::::::::::: ');
        } else if (error) {
            console.error('wiredInit 에러 :', error);
        }
    }

    handleInput(event) {
        const inputElement = event.target;
        const inputValue = inputElement.value;

        if (inputValue.trim() !== "") {
            inputElement.className = "inputValue_filled";
        } else {
            inputElement.className = "inputValue";
        }
    }

    setTable(refData) {
        console.log(":::::::::::::::: setTable start ::::::::::::::::");
        if (!refData) {
            refData = this.refAllData;
        }
        if (Array.isArray(refData)) {
            this.refAllData = refData.map((item, index) => {
                const aorNameOptions = item.aorName.map(name => ({ label: name, value: name }));
                const selectedAorNameValue = aorNameOptions.length > 0 ? aorNameOptions[0].value : ''; // AOR 존재 시 [0] 보이게
                return {
                    ...item,
                    displayedIndex: index + 1, 
                    aorNameOptions,
                    selectedAorNameValue,
                    objectReferenceDetailUrl: `https://dkbmc--pms.sandbox.lightning.force.com/lightning/r/ObjectReference__c/${item.id}/view`
                };
            });
            console.log("refAllData : ", this.refAllData);

        } else {
            console.error(' setTable 에러 : ', error);
            console.error(' setTable 에러 refData  : ', refData);
        }
        // this.changeBooleanByKey('loading', false);
        // console.log("loading state [[setTable]]>>>>>>>>>>>>>>>>> " + this.loading)
        this.changeBooleanByKey('isButtonDisabled', false);
        console.log(":::::::::::::::: setTable end ::::::::::::::::");
    }

    handleAorNameValue(event) {
        this.value = event.detail.value;
    }

    btnSearch() {
        console.log(":::::::::::::::: btnSearch start ::::::::::::::::")
        this.changeBooleanByKey('isButtonDisabled', true);

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

        if (description && description.length < 2) {

            //Alert lightning-toast 로 추후 변경 ********************************************************************

            alert('Description은 2글자 이상이어야 합니다. 추후 변경 필요 ');
            //alert 후 return 시 검색버튼 활성화 안됨 추후 수정
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

        this.changeBooleanByKey('loading', true);
        getDataByFilter({ filterGroup: JSON.stringify(filterGroup) })
            .then(result => {
                this.changeBooleanByKey('loading', false);
                 console.log("loading state [[getDataByFilter]]>>>>>>>>>>>>>>>>> " + this.loading)
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
                this.changeBooleanByKey('isButtonDisabled', false);
            });

        //헤더 검색조건
        this.updateSearchCriteria(name, description, apiversion, remove, specialAccessRules, memo, supportedCalls);
        //동적 필드
        this.updateDisplayFields(description, specialAccessRules, usage, memo, remove, supportedCalls);
        console.log(":::::::::::::::: btnSearch end ::::::::::::::::")

    }

    btnReset() {
        console.log(":::::::::::::::: btnReset start ::::::::::::::::");

        const checkboxes = this.template.querySelectorAll('.selectedCheckbox');
        checkboxes.forEach(checkbox => {
            checkbox.checked = false;
        });
        const inputboxes = this.template.querySelectorAll('.inputValue_filled');
        inputboxes.forEach(inputbox => {
            inputbox.value = '';
            this.handleInput({ target: inputbox });
        });
        this.setTable(this.initialData);
        this.updateSearchCriteria();
        this.toggleInputCard = false;
        //동적 필드
        this.updateDisplayFields(false, false, false, false, false, false);
        console.log(":::::::::::::::: btnReset end ::::::::::::::::")
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
    checkKeyboard(event) {
        if ((event.target.classList.contains('inputValue') || event.target.classList.contains('inputValue_filled') || event.target.classList.contains('selectedCheckbox')) && event.key === "Enter") {
            this.btnSearch();
            console.log(":::::::::::::::: enter ::::::::::::::::")
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

    // 헤더 검색조건 추가
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
        this.searchCriteria += name != '' ? `이름: ${name} | ` : '';
        this.searchCriteria += description != '' ? `Description: ${description} | ` : '';
        this.searchCriteria += apiversion != '' ? `Api Version: ${apiversion} | ` : '';
        this.searchCriteria += remove != '' ? `삭제된 API : ${remove ? 'Yes' : 'No'} | ` : '';
        this.searchCriteria += specialAccessRules != '' ? `Special Access Rules: ${specialAccessRules} | ` : '';
        this.searchCriteria += memo != '' ? `Memo: ${memo} | ` : '';
        this.searchCriteria += supportedCalls != '' ? `Supported Calls: ${supportedCalls} ` : '';
    }

    // 동적으로 헤더,바디 추가
    updateDisplayFields(description, specialAccessRules, usage, memo, remove, supportedCalls) {
        this.displayFields.description = description ? true : false;
        this.displayFields.specialAccessRules = specialAccessRules ? true : false;
        this.displayFields.usage = usage ? true : false;
        this.displayFields.memo = memo ? true : false;
        this.displayFields.remove = remove ? true : false;
        this.displayFields.supportedCalls = supportedCalls && supportedCalls.length > 0 && supportedCalls[0] !== '' ? true : false;
        console.log("this.displayFields.supportedCalls : " ,this.displayFields.supportedCalls);

        this.displayHeaders = [
            { key: 'description', isActive: this.displayFields.description },
            { key: 'specialAccessRules', isActive: this.displayFields.specialAccessRules },
            { key: 'usage', isActive: this.displayFields.usage },
            { key: 'memo', isActive: this.displayFields.memo },
            { key: 'remove', isActive: this.displayFields.remove },
            { key: 'supportedCalls', isActive: this.displayFields.supportedCalls },
        ].filter(header => header.isActive);
    
        console.log("update display Fields : ", this.displayFields);
        console.log("update display Headers : ", this.displayHeaders);
    }

    //검색결과 확장 토글
    toggleResultCard(event) {
        const clickedElement = event.target;
        if (clickedElement.classList.contains('result_card')) {
            const cardElement = this.template.querySelector('.result_card');
            cardElement.className = "result_card_folded";
            this.changeBooleanByKey('toggleInputCard', !this.toggleInputCard);
        } else if(clickedElement.classList.contains('result_card_folded')) {
            const cardElement = this.template.querySelector('.result_card_folded');
            cardElement.className = "result_card";
            this.changeBooleanByKey('toggleInputCard', !this.toggleInputCard);
        }
    }

    changeBooleanByKey(key, val) {
        switch (key) {
            case 'loading':
                this.loading = val;
                break;
            case 'isButtonDisabled':
                this.isButtonDisabled = val;
                break;
            case 'toggleInputCard':
                this.toggleInputCard = val;
                break;
            default:
                console.warn('key를 확인해주세요.');
                break;
        }
    }

    handleSort(event) {
        console.log(":::::::::::::::: handleSort start ::::::::::::::::")
        const key = event.currentTarget.dataset.key; 
        console.log("key : ", key)

        // this.sortDirection[key]가 정의되지 않았을 때 'asc'로 설정
        this.sortDirection[key] = this.sortDirection[key] || 'asc';
        this.sortDirection[key] = this.sortDirection[key] === 'asc' ? 'desc' : 'asc';
        console.log("sortDirection : ", this.sortDirection[key])

        this.refAllData = [...this.refAllData].sort((a, b) => {
            let valA = a[key] || '';
            let valB = b[key] || '';
            
            if(valA === '' && valB === '') return 0;
            if(valA === '') return this.sortDirection[key] === 'asc' ? -1 : 1;
            if(valB === '') return this.sortDirection[key] === 'asc' ? 1 : -1;
            
            if (!isNaN(valA) && typeof valA === 'string') valA = parseFloat(valA);
            if (!isNaN(valB) && typeof valB === 'string') valB = parseFloat(valB);
            
            if (typeof valA === 'string') valA = valA.toLowerCase();
            if (typeof valB === 'string') valB = valB.toLowerCase();
            
            if (this.sortDirection[key] === 'asc') return valA > valB ? 1 : (valA < valB ? -1 : 0);
            else return valA < valB ? 1 : (valA > valB ? -1 : 0);
        });
        console.log(":::::::::::::::: handleSort end ::::::::::::::::")
    }

}