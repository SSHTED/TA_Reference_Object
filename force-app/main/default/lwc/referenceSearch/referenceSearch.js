import { LightningElement, api, wire ,track } from 'lwc';
import getInit from '@salesforce/apex/ReferenceSearch.getInit';
// import getFilterList from '@salesforce/apex/ReferenceSearch.getFilterList';
// import (이름가져오는함수) from '@salesforce/apex/ReferenceSearch.(이름가져오는함수)';
import { toggleMoreFilter, resetValue, fetchInitData  } from './searchsh.js'; 



export default class ReferenceSearch extends LightningElement {
    @api title = '기본제목';
    @track apiversion = '';

    @track isKorean = false;
    @track isEnglish = false;
    






    // 1. 사용자가 input에 입력한 값을 onchange함수를 통해 감지
 
    
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
        let name = this.template.querySelector('.inputValue').value;
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







    // this.name을 파라미터로 apex 클래스에 전달후, 응답을 받고 data를 테이블 형식으로 페이지에 렌더링
    btnSearch(event) {
        let name = this.template.querySelector('.inputValue').value;
        this.isKorean = this.isKoreanText(name);
        this.isEnglish = this.isEnglishText(name);
        
        let supportedCalls = '';
        const checkboxes = this.template.querySelectorAll('.selectedCheckbox');
        console.log(checkboxes.length)
        checkboxes.forEach(checkbox => {
            
            if(checkbox.checked) {
                supportedCalls += checkbox.name + ',';
            }
        });

        console.log("checkbox : ", supportedCalls);



        console.log(name);



        let filterGroup = {};

        if(this.isKorean) {
            filterGroup.KorLabel = name; // 한글인 경우 KorLabel 키값에 텍스트 할당
        } else if(this.isEnglish) {
            if(this.hasWhitespaceInMiddle()) {
                filterGroup.EngLabel = name;
            } else {
                filterGroup.Name = name;
            }
        }


        filterGroup.supportedCalls = supportedCalls;




        console.log(filterGroup);
    }
    
            
    
    //        getCaseList({
    //            recordId: this.selectedLocationType
    //            , filterGroup: JSON.stringify(filterGroup)
    //        })
    //        .then(result => {
    //            console.log(result);
    //            this.caseList = result;
    //            if(result.length > 0) {
    //                this.isExistData = true;
    //            } else {
    //                this.isExistData = false;
    //            }
    //        })
    //        .catch(error => {
    //            console.warn(error);
    //        });
    //    }




    // 입력값이 한글인지, 영어인지 판별하고 각각에 대한 처리를 구현해야함
    // if(입력값 한글) {}
    // else if(입력값 영어) {}
    // else {}
        
    //    let valid = 'kr';
    //    (이름가져오는함수)({ name: this.name })
    //    .then(result => {
    //        this.referenceList = result;
    //    })
    //        console.error('Error fetching persons:', error);
    //    });

    //    let result = { filterList: [],
    //                   success: true,

    //    };
    //    let data = { language: valid,
    //                 apiversion: this.apiversion,

    //            };

    //    getFilterList({ data: JSON.stringify(data) })
    //    .then(result => {
             
    //    })
    //    .catch(error => {

    //    });
    // 응답을 제대로 받아왔으면 this.referenceList html페이지에 뿌려주다
    // 받아온 this.referenceList를 JSON형식으로 전달하려면 JSON.stringify(this.referenceList);



    moreFilter = false;
    refAllData = [];

    handleToggleMoreFilter() {
        console.log("필터 토글 : handleToggleMoreFilter");  
        toggleMoreFilter.call(this); 
    }

    btnReset(){
        console.log("초기화 토글 : btnReset"); 
        resetValue.call(this);
    }

    connectedCallback() {
        console.log("fetchInitData 시작 : connectedCallback"); 

        fetchInitData.call(this);
    }

}

