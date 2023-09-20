import { LightningElement, api, track, wire } from 'lwc';
import getInit from '@salesforce/apex/ReferenceSearchController.getInit';
import getDataByFilter from '@salesforce/apex/ReferenceSearchController.getDataByFilter';
import { resetValue } from './searchsh.js';


export default class ReferenceSearch extends LightningElement {
    @api title = '기본제목';
    @track isKorean = false;
    @track isEnglish = false;
    @track result = [];

    refAllData = []; 
    supCallsList = [];
    supCallsItems = []; // supported calls 항목들
    loaded = false;

    // 초기화면 세팅
    @wire(getInit)
    wiredInit({ error, data }) {
        if (data && data.result) {
            console.log('wiredInit >>>>>>>>>>>>>>> 데이터 받아옴');
            this.refAllData = data.result.refAllData;
            this.supCallsList = data.result.callList;
            this.supCallsItems = this.supCallsList.map(val => {
                val = val.replace('()', '');
                return { label: `${val}`, name: `${val}`, checked: false };
            });

            this.setTable();
            this.loaded = true;

        } else if (error) {
            console.error('Error:', error);
        }
    }

    setTable(refData){
        if(!refData) {
            refData = this.refAllData;
        }
        if (Array.isArray(refData)) {
            this.loaded = true; 
        } else {
            console.error('Data is not an array:', data);
        }
    }
    
    // this.name을 파라미터로 apex 클래스에 전달후, 응답을 받고 data를 테이블 형식으로 페이지에 렌더링
    btnSearch() {
        const name = this.template.querySelector('[data-id="name"]').value;
        const description = this.template.querySelector('[data-id="description"]').value;
        const apiversion = this.template.querySelector('[data-id="apiversion"]').value;
        
        const specialAccessRules = this.template.querySelector('[data-id="specialAccessRules"]').value;
        const usage = this.template.querySelector('[data-id="usage"]').value;
        const memo = this.template.querySelector('[data-id="memo"]').value;

        const isKorean = this.isKoreanText(name);
        const isEnglish = this.isEnglishText(name);

        let supportedCalls = '';
        // 체크박스 체크 여부 확인 후 supportedCalls 문자열에 추가
        const checkboxes = this.template.querySelectorAll('.selectedCheckbox');
        
        checkboxes.forEach((checkbox, idx) => {
            if(checkbox.checked) {
                if(idx == checkboxes.length-1){
                    supportedCalls += checkbox.name + '()';
                } else {
                    supportedCalls += checkbox.name + '();';
                }
            }
        });

        console.log('supportedCalls >>>>>>>>>>>>> ', supportedCalls);

        // 현재 삭제된 API 여부 확인 
        const removeChecked = this.template.querySelector('[data-id="remove"]');
        const remove = removeChecked.checked;
        
        // Description 필드의 입력값이 2글자 이상인지 확인
        if (description && description.length < 2) {
            // 입력값이 2글자 미만인 경우 경고 창 표시
            alert('Description은 2글자 이상이어야 합니다.');
            return; // 검색 중단
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

        // Name input 영역에 입력된 값이 한글인지 영어인지를 구분해서 서로 다른 필드로 전달
        if(isKorean) {
            filterGroup.KorLabel = name;  // 한글일 경우 KorLabel 키값에 텍스트 할당
        } else if(isEnglish) {
            if(this.hasWhitespaceInMiddle()) {
                filterGroup.EngLabel = name;  //  공백이 있는 영어일 경우 EngLabel 키값에 텍스트 할당
            } else {
                filterGroup.Name = name;  // 공백이 없는 영어인 경우 Name 키값에 텍스트 할당
            }
        }

        getDataByFilter({ filterGroup: JSON.stringify(filterGroup) })
            .then(result => {
                if(result.success == true){
                    this.setTable(result.result);
                } else {
                    console.error('result를 확인해주세요: ', error);
                }
            })
            .catch(error => {
                console.error('에러: ', error);
            });
    }
    
        
    isKoreanText(text) {
        const koreanRegex = /[가-힣]/;
        return koreanRegex.test(text);
    }

    isEnglishText(text) {
        const englishRegex = /^[a-zA-Z\s]+$/;
        return englishRegex.test(text);
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

    checkKey(event){
        const keyCode = event.keyCode;
        if(keyCode == 13){
            this.btnSearch();
        }
    }

    btnReset(){
        console.log("초기화 토글 : btnReset"); 
        resetValue.call(this);
        this.setTable();
    }
}