import { LightningElement, api, track, wire } from 'lwc';
import getInit from '@salesforce/apex/ReferenceSearchController.getInit';
import getDataByFilter from '@salesforce/apex/ReferenceSearchController.getDataByFilter';
import { resetValue } from './searchsh.js';


export default class ReferenceSearch extends LightningElement {
    @api title = '기본제목';
    @track isKorean = false;
    @track isEnglish = false;
    @track result = [];

    supCallsList = [];
    isChecked = false;
    supCallsItems = [];

    refAllData = [];

    @wire(getInit)
    wiredInit({ error, data }) {
        if (data && data.result) {
            console.log('wiredInit >>>>>>>>>>>>>>> 데이터 받아옴');
            this.refAllData = data.result.refAllData;
            this.supCallsList = data.result.callList;

            this.supCallsItems = this.supCallsList.map(function(val){
                val = val.replace('()', '');
                return { label: `${val}`, name: `${val}`, checked: false };
            });
            
            this.setTable();
            
        } else if (error) {
            console.error('Error:', error);
        }
    }

    setTable(refData){
        if(refData == '' || refData == undefined || refData == null){
            refData = this.refAllData;
        } 

        if (Array.isArray(refData)) {
            const tableBody = this.template.querySelector('.refDataTbody');

            // 초기화
            tableBody.innerHTML = '';

            refData.forEach(item => {
                const row = document.createElement('tr');
                row.innerHTML = `
                <td>${item.Name}</td>
                <td>${item.Eng_Label__c}</td>
                <td>${item.Kor_Label__c}</td>
                <td>${item.Api_Version__c}</td>
                `;
                tableBody.appendChild(row);
            });
        } else {
            console.error('Data is not an array:', data);
        }
    }
    
    // this.name을 파라미터로 apex 클래스에 전달후, 응답을 받고 data를 테이블 형식으로 페이지에 렌더링
    btnSearch(event) {
        let name = this.template.querySelector('[data-id="name"]').value;
        let description = this.template.querySelector('[data-id="description"]').value;
        let apiversion = this.template.querySelector('[data-id="apiversion"]').value;
        let supportedCalls = '';
        
        let specialAccessRules = this.template.querySelector('[data-id="specialAccessRules"]').value;
        let usage = this.template.querySelector('[data-id="usage"]').value;
        let memo = this.template.querySelector('[data-id="memo"]').value;
        let docsLink = this.template.querySelector('[data-id="docsLink"]').value;

        this.isKorean = this.isKoreanText(name);
        this.isEnglish = this.isEnglishText(name);


        // 체크박스 체크 여부 확인 후 supportedCalls 문자열에 추가
        const checkboxes = this.template.querySelectorAll('.selectedCheckbox');
        
        checkboxes.forEach(checkbox => {
            if(checkbox.checked) {
                supportedCalls += checkbox.name + '();';
            }
        });

        // 문자열 맨 마지막 쉼표(,) 제거
        if(supportedCalls.endsWith(';')) {
            supportedCalls = supportedCalls.slice(0,-1);
        }

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
            Memo: memo,
            DocsLink: docsLink
        };

        // Name input 영역에 입력된 값이 한글인지 영어인지를 구분해서 서로 다른 필드로 전달
        if(this.isKorean) {
            filterGroup.KorLabel = name;  // 한글일 경우 KorLabel 키값에 텍스트 할당
        } else if(this.isEnglish) {
            if(this.hasWhitespaceInMiddle()) {
                filterGroup.EngLabel = name;  //  공백이 있는 영어일 경우 EngLabel 키값에 텍스트 할당
            } else {
                filterGroup.Name = name;  // 공백이 없는 영어인 경우 Name 키값에 텍스트 할당
            }
        }

        console.log("filterGroup >>>>>>>>>>>> " + JSON.stringify(filterGroup));



        getDataByFilter({ filterGroup: JSON.stringify(filterGroup) })
            .then(result => {
                const filteredDataList = result.result;
                console.log("this.results : " + JSON.stringify(filteredDataList));

                this.setTable(filteredDataList);
                
            })
            .catch(error => {
                console.error('에러: ' + JSON.stringify(error));
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

    btnReset(){
        console.log("초기화 토글 : btnReset"); 
        resetValue.call(this);
        this.setTable();
    }
}