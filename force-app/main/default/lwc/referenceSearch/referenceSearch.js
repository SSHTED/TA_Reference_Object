import { LightningElement, api, track, wire } from 'lwc';
import getInit from '@salesforce/apex/ReferenceSearchController.getInit';
import getDataByFilter from '@salesforce/apex/ReferenceSearchController.getDataByFilter';

import { loadStyle } from 'lightning/platformResourceLoader';
import referenceSearchCmmn from '@salesforce/resourceUrl/ReferenceSearch';

export default class ReferenceSearch extends LightningElement {
    @api title = '기본제목';
    @track result = [];
    @track loading = true;
    isButtonDisabled = false;
    toggleInputCard = false;
    checkStyleLoad = false;
    searchCriteria = '';

    refAllData = [];
    supCallsList = [];
    supCallsItems = [];
    @track displayFields = {description: false, specialAccessRules: false,usage: false,memo: false,remove: false, SupportedCalls: false};
    displayHeaders = [];
    sortDirection = {};
    // toast
    isToastVisible = false;
    toastMessage = '';
    versionValue = 'before';
    @track inputValues ={name:'', description:'',apiversion:'',specialAccessRules:'',usage:'',memo:''};

    get versionOptions() {
        return [
            { label: '이전 버전', value: 'before' },
            { label: '이후 버전', value: 'after' },
        ];
    }
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
            console.time('setTable >>>>>>>>>>>>>> ');
            this.setTable();
            console.timeEnd('setTable >>>>>>>>>>>>>> ');
            this.updateSearchCriteria();
            console.log(':::::::::::::::: wiredInit end :::::::::::::::: ');

            
        } else if (error) {
            console.error('wiredInit 에러 :', error);
        }
    }

    // 화면 render가 끝나고 실행
    renderedCallback() {

        // static resource style 적용
        if(!this.checkStyleLoad){
            Promise.all([
                loadStyle( this, referenceSearchCmmn + "/referenceSearchCmmn.css" )
                ]).then(() => {
                    this.checkStyleLoad = true;
                    console.log( 'Files loaded' );
                })
                .catch(error => {
                    console.log( '못불러옴' + JSON.stringify(error) );
            });
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
                const selectedAorNameValue = aorNameOptions.length > 0 ? aorNameOptions[0].value : ''; 
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
        this.changeBooleanByKey('isButtonDisabled', false);
        console.log(":::::::::::::::: setTable end ::::::::::::::::");
    }

    handleAorNameValue(event) {
        this.value = event.detail.value;
    }

    btnSearch() {
        console.log(":::::::::::::::: btnSearch start ::::::::::::::::")

        const name = this.template.querySelector('[data-id="name"]').value;
        const objectNameLanguage = this.checkObjectNameLang(name);
        const description = this.template.querySelector('[data-id="description"]').value;
        const apiversion = this.template.querySelector('[data-id="apiversion"]').value;
        const apiversionType = this.template.querySelector('[data-id="apiversionType"]').value;
        const specialAccessRules = this.template.querySelector('[data-id="specialAccessRules"]').value;
        const usage = this.template.querySelector('[data-id="usage"]').value;
        const memo = this.template.querySelector('[data-id="memo"]').value;
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

        console.log("this.isToastVisible >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ", this.isToastVisible)
        if (description  && description.length < 2) {
            this.toastMessage = 'Description은 2글자 이상이어야 합니다.';
            this.isToastVisible = true; 

            return;
        }

        // filterGroup에 값을 저장하여 백엔드로 전달
        let filterGroup = {
            ApiVersion: apiversion,
            ApiVersionType: apiversionType,
            SupportedCalls: supportedCalls,
            Description: description,
            Remove: remove,
            SpecialAccessRules: specialAccessRules,
            Usage: usage,
            Memo: memo
        };

        console.log("filterGroup : " + JSON.stringify(filterGroup));

        // 한글이면 KorLabel, 영문이면 Name, space들어간 영문이면 EngLabel
        if (objectNameLanguage == 'kor') {
            filterGroup.KorLabel = name;
        } else if (objectNameLanguage == 'eng') {
            if (this.hasWhitespaceInMiddle()) {
                filterGroup.EngLabel = name;
            } else {
                filterGroup.Name = name;
            }
        }

        this.changeBooleanByKey('loading', true);
        this.changeBooleanByKey('isButtonDisabled', true);

        console.time('getDataByFilter>>>>>>>>>>>>>>');
        getDataByFilter({ filterGroup: JSON.stringify(filterGroup) })
            .then(result => {
                console.timeEnd('getDataByFilter >>>>>>>>>>>>>> ');
                this.changeBooleanByKey('loading', false);
                 console.log("loading state [[getDataByFilter]]>>>>>>>>>>>>>>>>> " + this.loading)
                if (result.success == true) {
                    console.log("result data : ", result.result);
                    console.time('getDataByFilter setTable >>>>>>>>>>>>>> ');
                    this.setTable(result.result);
                    console.timeEnd('getDataByFilter setTable >>>>>>>>>>>>>> ');
                } else {
                    console.error('result 에러 : ', error);
                }
            })
            .catch(error => {
                console.error('getDataByFilter 에러 : ', error);
            }).finally(() => {
                this.changeBooleanByKey('isButtonDisabled', false);
            });

        // 헤더 검색조건
        this.showFilteredCondition(filterGroup);
        // 동적 필드
        this.setSearchResultFields(filterGroup);
        console.log(":::::::::::::::: btnSearch end ::::::::::::::::")

    }

    // 초기화 버튼
    btnReset() {
        console.log(":::::::::::::::: btnReset start ::::::::::::::::");

        const checkboxes = this.template.querySelectorAll('.selectedCheckbox');
        checkboxes.forEach(checkbox => {
            checkbox.checked = false;
        });
        // inputValues 객체 초기화
        for (let key in this.inputValues) {
            this.inputValues[key] = '';
        }
        const inputboxes = this.template.querySelectorAll('.inputValue_filled');
        inputboxes.forEach(inputbox => {
            inputbox.value = '';
            this.handleInput({ target: inputbox });
        });
        this.toggleInputCard = false;
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

    // 검색 조건 영역에서 onkeydown check
    checkKeyboard(event) {
        if ((event.target.classList.contains('inputValue') || event.target.classList.contains('inputValue_filled') || event.target.classList.contains('selectedCheckbox')) && event.key === "Enter") {
            this.btnSearch();
            console.log(":::::::::::::::: enter ::::::::::::::::")
        }
    }

    // Object Name이 한글인지, 영문인지 체크
    checkObjectNameLang(text) {
        let language = '';
        
        if(/^[a-zA-Z\s]+$/.test(text)){
            language = 'eng';
        } else if(/[가-힣]/.test(text)){
            language = 'kor';
        } else {
            console.error('Object Name을 확인해주세요. ex) 계 or Account or case ...');
            
            this.toastMessage = '한글(ex. 계), 영문, 띄어쓰기만 입력 가능합니다.';
            this.isToastVisible = true; 

            return;
        }

        return language;
    }

    // 헤더 검색조건 추가
    showFilteredCondition(obj) {
        if(obj == '' || obj == undefined){
            obj = {};
        }

        this.searchCriteria = '';
        this.searchCriteria += obj.name != '' || obj.name != undefined ? `이름: ${obj.name} | ` : '';
        this.searchCriteria += obj.description || obj.name != undefined != '' ? `Description: ${obj.description} | ` : '';
        this.searchCriteria += obj.apiversion || obj.name != undefined != '' ? `Api Version: ${obj.apiversion} | ` : '';
        this.searchCriteria += obj.remove || obj.name != undefined != '' ? `API 삭제여부 : ${obj.remove ? 'Y' : 'N'} | ` : '';
        this.searchCriteria += obj.specialAccessRules || obj.name != undefined != '' ? `Special Access Rules: ${obj.specialAccessRules} | ` : '';
        this.searchCriteria += obj.memo || obj.name != undefined != '' ? `Memo: ${obj.memo} | ` : '';
    }

    // 동적으로 헤더,바디 추가
    setSearchResultFields(obj) {
        this.displayFields.description = obj.description ? true : false;
        this.displayFields.specialAccessRules = obj.specialAccessRules ? true : false;
        this.displayFields.usage = obj.usage ? true : false;
        this.displayFields.memo = obj.memo ? true : false;
        this.displayFields.remove = obj.remove ? true : false;
        this.displayFields.supportedCalls = obj.supportedCalls && obj.supportedCalls.length > 0 && obj.supportedCalls[0] !== '' ? true : false;
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

    // 검색결과 확장 토글
    toggleResultCard(event) {
        const clickedElement = event.target;
        this.isButtonDisabled = !this.isButtonDisabled;
        console.log("isButtonDisabled >>>>>>>>>>>>>>>>>>>>>", this.isButtonDisabled)
        console.log("clickedElement >>>>>>>>>>>>>>>>>>>>>", clickedElement)
        if (clickedElement.classList.contains('expand')) {
            console.log("if >> contains('.expand') >>>>>>>>>>>>>>>>>>>>> 진입")
            const cardElement = this.template.querySelector('.result_card');
            const pElement = this.template.querySelector('.totalData_p');
            const tableElement = this.template.querySelector('.loadedHolder table');
            cardElement.className = "result_card_folded";
            clickedElement.className = "expand_folded";
            pElement.className = "totalData_p_folded";
            tableElement.style = "top: 0";
            this.changeBooleanByKey('toggleInputCard', !this.toggleInputCard);
            console.log("toggleInputCard >>>>>>>>>>>>>>>>>>>>>", this.toggleInputCard)
        } else if(clickedElement.classList.contains('expand_folded')) {
            console.log("else if >> contains('expand') >>>>>>>>>>>>>>>>>>>>> 진입")
            const cardElement = this.template.querySelector('.result_card_folded');
            const pElement = this.template.querySelector('.totalData_p_folded');
            const tableElement = this.template.querySelector('.loadedHolder table');
            cardElement.className = "result_card";
            clickedElement.className = "expand";
            pElement.className = "totalData_p";
            tableElement.style = "top: -17px";
            this.changeBooleanByKey('toggleInputCard', !this.toggleInputCard);
            console.log("toggleInputCard >>>>>>>>>>>>>>>>>>>>>", this.toggleInputCard)
        }
    }

    // key value에 따라 true false change
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

    // 정렬( 검색 결과 table head 클릭 이벤트 )
    handleSort(event) {
        console.log(":::::::::::::::: handleSort start ::::::::::::::::")
        console.time('handleSort >>>>>>>>>>>>>> ');
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
        console.timeEnd('handleSort >>>>>>>>>>>>>> ');
        console.log(":::::::::::::::: handleSort end ::::::::::::::::")
    }

    handleToastClose() {
        this.isToastVisible = false;
    }

    // 입력 조건 유지 Input
    handleInput(event) {
        const inputElement = event.target;
        const inputId = inputElement.dataset.id; //  data-id 
        const inputValue = inputElement.value;
    
        if (inputValue.trim() !== "") {
            inputElement.className = "inputValue_filled";
        } else {
            inputElement.className = "inputValue";
        }
        // inputValues 상태를 업데이트합니다.
        this.inputValues = { ...this.inputValues, [inputId]: inputValue };
    }
    // 입력 조건 유지 Checkbox
    handleCheckboxChange(event) {
        const name = event.target.name; 
        const checked = event.target.checked; 
    
        // supCallsItems 배열에서 해당 항목을 찾아 checked 값을 업데이트합니다.
        this.supCallsItems = this.supCallsItems.map(item => 
            item.name === name ? { ...item, checked } : item
        );
    }
    
}