import { LightningElement, wire, api } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import getData from '@salesforce/apex/RelatedListCustomController.getData';
import deleteRecord from '@salesforce/apex/RelatedListCustomController.deleteRecord';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class relatedListCustom extends NavigationMixin( LightningElement ) { 
    MyData = [];// 데이터 저장
    columns = [];// 1차원 데이터의 열 정의
    level2Columns = [];// 2차원 데이터의 열 정의
    processedData = [];// 처리된 데이터 저장
    recordTypeOptions = [];
    error;         
    Lv2ObjectName; 
    selectedRecordTypeId;
    changedObjectApiName;
    navigationType = 'standard__objectPage';
    selectRecordName = '레코드 유형 선택'
    isTableVisible = true;
    isModalOpen = false;
    @api recordId; @api recordTypeId; @api relatedObjectApiName; 
    @api relationType; @api relationPosition; @api objectApiName;

    @api customIcon;
    @api customTitle;
    @api viewType;
    @api themeColor;
    @api activationCreateBtn;
    @api activationSelectedDeleteBtn;
    @api downloadBtn;
    @api changeOwnerBtn;
    @api setFieldCount;
    @api maxRow;
    @api sectionFirstOpen;
    @api activationCheckedFields; 
    @api activationNo;
    isDropdownVisible = false;
    selectedValue = '';
    isRelationPosition = false;
    customClass = '';
    viewAllUrl = '';

    connectedCallback() {
        this.isTableVisible = this.sectionFirstOpen;
        
        console.log("themeColor is >>>>>>>>>>>>>>>>>>", this.themeColor);

        switch (this.themeColor) {
            case 'red':
                this.customClass += 'themeColor_red';
                break;
            case 'orange':
                this.customClass += 'themeColor_orange';
                break;
            case 'yellow':
                this.customClass += 'themeColor_yellow';
                break;
            case 'green':
                this.customClass += 'themeColor_green';
                break;
            case 'blue':
                this.customClass += 'themeColor_blue';
                break;
            default:
        }

        console.log("viewAllUrl >>>>>>>>", this.viewAllUrl);
        // if(this.relationPosition == 'Myself'){
        //     this.setPropRelList('Myself');
        // } else if(this.relationPosition == 'Parent'){
        //     this.setPropRelList('Parent');
        // }
        /*
        console.log("relationPosition >>>>>", this.relationPosition);
        console.log("relatedObjectApiName >>>>>", this.relatedObjectApiName);
        console.log("activationCreateBtn >>>>>", this.activationCreateBtn);
        console.log("activationSelectedDeleteBtn >>>>>", this.activationSelectedDeleteBtn);
        console.log("downloadBtn >>>>>", this.downloadBtn);
        console.log("changeOwnerBtn >>>>>", this.changeOwnerBtn);
        console.log("setFieldCount >>>>>", this.setFieldCount);
        console.log("themeColor >>>>>", this.themeColor);
        console.log("customTitle >>>>>", this.customTitle);
        console.log("sectionFirstOpen >>>>>", this.sectionFirstOpen);
        console.log("activationCheckedFields >>>>>", this.activationCheckedFields);
        console.log("activationNo >>>>>", this.activationNo);
        */
        // this.isRelationPosition
        // this.relationType = this.relationPosition;
        // console.log("relationType >>>>>", this.relationType);
        // this.setPropRelList(this.relationPosition);
    }

    setPropRelList(relType) {
        console.log('setPropRelList >>>>>>>>>>> 진입');
        console.log('relType >>>>>>>>>>> ', relType);
    
        // getRelatedMap 함수에 전달하는 매개변수를 수정
        getRelatedMap({recordId: this.recordId, relationType: relType})
            .then(result => {
                // result가 유효한지 확인
                if (result) {
                    // 변경된 부분: result.Result가 아닌 바로 result를 사용
                    console.log('result >>> ', result);
                    this.relatedObjectApiName = result;
                    console.log('관련된 오브젝트 이름은 >>> ', this.relatedObjectApiName);
                    
                    // 변경된 부분: result의 구조에 따라 적절한 속성을 사용
                    if (result.length > 0) {
                        console.log('Object.keys >>> ', Object.keys(result[0]));
                        // 변경된 부분: result의 구조에 따라 적절한 속성을 사용
                        this.relatedObjectApiName = result[0].ObjectApiName;
                        console.log('this.relatedObjectApiName >>> ', this.relatedObjectApiName);
                        console.log('this.relationPosition >>> ', this.relationPosition);
    
                        this.relationType = this.relatedObjectApiName;
    
                        console.log("relationType은 >>>>>>>>>>", this.relationType);
                    } else {
                        console.error('Result array is empty');
                    }
                } else {
                    console.error('Result is undefined');
                }
            })
            .catch(error => {
                this.handleError(error);
            })
            .finally(() => {
                this.setLoadingState(false);
            });
    }

    // 레코드 타입 데이터 가져오기
    @wire(getObjectInfo, { objectApiName: '$relatedObjectApiName' })
    wiredObjectInfo({ error, data }) {
        if (data) {
            // 레코드 타입 옵션 설정
            this.recordTypeOptions = Object.values(data.recordTypeInfos)
                .filter(rt => rt.available && !rt.master)
                .map(rt => ({ label: rt.name, value: rt.recordTypeId }));
            // 기본 레코드 타입 설정
            if(this.recordTypeOptions.length>0){
                this.selectedRecordTypeId = this.recordTypeOptions[0].value;
            }
        } else if (error) {
            console.error('Error', error);
        }
    }

    // 전체 데이터 가져오기
    @wire(getData, { recordId: '$recordId', componentObjName: '$relatedObjectApiName', relationType: '$relationPosition'})
    wiredData({ error, data }) {
        console.log('wiredData relatedObjectApiName:', this.relatedObjectApiName);
        console.log('wiredData relationPosition:', this.relationPosition);
        console.log('recordId >>> ', this.recordId);
        console.log('relatedObjectApiName >>> ', this.relatedObjectApiName);
        console.log('objectApiName >>> ', this.objectApiName);

        if (data) {
            console.log(':::::::::::::::: wiredData start :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: ::::::::::::::::');
            console.log('data :::::::::::::::: ', data);
            this.updateChangedObjectApiName();
            this.processData(data.Result);
        } else if (error) {
            console.error('::: Error :::', error);
            this.handleError(error);
        }
    }
    
    processData(data) {
        if (data) {
            this.currentOrgType = window.location.href.includes('sandbox') ? 'dkbmc--pms.sandbox' : 'dkbmc'; //pms csr 구분
            this.Lv2ObjectName = data['2Lv'].Label; 
            this.customTitleUrl = this.getUrl(this.objectApiName, this.recordId, this.changedObjectApiName);
            console.log('customTitleUrl', this.customTitleUrl)

            this.columns = this.getColumns(data['1Lv'].ColumnList);
            this.level2Columns = this.getColumns(data['2Lv'].ColumnList); 
            this.MyData = this.getRows(data['1Lv'].Rows[0][this.changedObjectApiName], data['2Lv'].Rows, data['1Lv'].ColumnList, data['2Lv'].ReferencdObjApiName);
            this.level2DataCount = this.calculateLevel2DataCount(data['2Lv'].Rows, data['2Lv'].ReferencdObjApiName);

            console.log('MyData :' , this.Mydata)
        }
    }

    getColumns(colList) {
        return colList.map(col => ({ label: col.label, fieldName: col.fieldApiName }));
    }

    getRows(dynamicRows, level2DataRows, columnList1Lv, referencedObjApiName) {
        const level2DataMap = new Map();
        
        // 2차원 데이터를 ID별로 맵에 저장
        level2DataRows.forEach(l2Row => {
            level2DataMap.set(l2Row.Id, l2Row[referencedObjApiName] || []);
        });
        
        // 1차원 데이터를 화면에 표시할 형태로 가공
        return dynamicRows.map((row, index) => {
            // 각 열에 대한 값 매핑
            let displayValues = columnList1Lv.map(col => {
                let value = row[col.fieldApiName];
                let url = col.fieldApiName === 'Name' ? this.getUrl(this.relatedObjectApiName, row.Id) : '';
                return { key: col.fieldApiName, value: value, url: url };
            });
        
            // 2차원 데이터와 연결
            let level2Data = level2DataMap.get(row.Id) || [];
            return { 
                ...row, 
                displayValues: displayValues,
                level2Data: level2Data,
                index: index + 1
            };
        });
    }
    
    toggleLv2data(event) {
    // 체크박스, 버튼 메뉴, 또는 'name-link' 클래스를 가진 링크 클릭시 이벤트 처리를 하지 않음
    if (event.target.type === 'checkbox' || 
        event.target.tagName === 'LIGHTNING-BUTTON-MENU' ||
        event.target.classList.contains('name-link')) {
        return;
    }
        const rowId = event.currentTarget.dataset.id;
        const index = this.MyData.findIndex(row => row.Id === rowId);
    
        if (index !== -1) {
            this.MyData[index].showDetails = !this.MyData[index].showDetails;
    
            // 상세 정보를 표시하는 경우 Level 2 데이터 포맷
            if (this.MyData[index].showDetails) {
                this.MyData[index].formattedLevel2Data = this.formatLevel2Data(this.MyData[index].level2Data, this.level2Columns, rowId);
            }
            this.MyData = [...this.MyData];
        }
    
        console.log('MyData at index:', this.MyData[index]);
        console.log('Formatted Level 2 Data:', this.MyData[index].formattedLevel2Data);
    }
    
    
    formatLevel2Data(rows, level2Columns, parentId) {
        if (!rows || !level2Columns) return [];
    
        return rows.map((row, index) => {
            const rowKey = `${parentId}-detail-${index}`;
            const formattedRow = level2Columns.map(col => {
            const value = row[col['fieldName']] !== undefined ? row[col['fieldName']] : ''; 

            return {
                key: col['fieldName'],
                value: value
                };
            });
    
            return {
                rowKey: rowKey,
                data: formattedRow,
                index: index + 1 

            };
        });
    }
    
    // 2Lv 데이터의 총 개수를 계산
    calculateLevel2DataCount(level2Rows, referencedObjApiName) {
        let totalCount = 0;
    
        level2Rows.forEach(l2Row => {
            const relatedData = l2Row[referencedObjApiName];
            if (Array.isArray(relatedData)) {
                totalCount += relatedData.length;
            }
        });
        return totalCount;
    }
    
    handleProceed() {
        this.handleModal();
        this.navigateToCrudPage(this.navigationType, this.relatedObjectApiName, 'new', null, this.selectedRecordTypeId);
    }

    navigateToChangeOwner() {
        // '변경 소유자' 페이지로 네비게이션
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Account', //변경하고자 하는 객체의 API 이름
                actionName: 'changeOwner'
            }
        });
    }

    navigateToCrudPage(navigationType, relatedObjectApiName, actionName, recordId = null) {
        let navParams = {
            type: navigationType,
            attributes: {
                objectApiName: relatedObjectApiName,
                actionName: actionName
            },
            state: {}
        };
        // ('new') 액션일 경우 선택된 레코드 유형 ID 사용
        if (actionName === 'new' && this.selectedRecordTypeId) {
            navParams.state.recordTypeId = this.selectedRecordTypeId;
        } else if (recordId) {
            // 레코드 ID가 제공된 경우 ('edit')
            navParams.attributes.recordId = recordId;
        }
        this[NavigationMixin.Navigate](navParams);
    }

    // 테이블 Event 핸들러
    handleCellEvent(event) {
        event.stopPropagation();

        const actionName = event.detail.value || event.target.value || event.currentTarget.value;
        let rowId;

        console.log("actionName : " ,actionName)
        if (actionName !== 'new') {
            rowId = event.target.closest('lightning-button-menu')?.dataset.id;
        }

        switch (actionName) {
            case 'new':
                if (this.recordTypeOptions && this.recordTypeOptions.length > 0) {
                    this.handleModal();
                } else {
                    this.navigateToCrudPage(this.navigationType, this.relatedObjectApiName, 'new', null, this.selectedRecordTypeId);
                }
                break;
            case 'edit':
                this.navigateToCrudPage(this.navigationType, this.relatedObjectApiName, actionName, rowId);
                break;
            case 'delete':
                if (rowId) {
                    this.deleteSelectedRecord(rowId);
                } else {
                    this.deleteSelectedRecord();
                }
                break;
            case 'excel':
                this.downloadExcel();
                break;
           /* case 'changeOwner':
                this.handleOwnerChange();
                break;*/
            default:
        }

    }
    /*
    handleOwnerChange() {
        const selectedRowIds = this.MyData.filter(row => row.selected).map(row => row.Id);

        if (selectedRowIds.length === 1) {
            this.showChangeOwnerModal(selectedRowIds[0]);
        } else {
            console.log("error")
        }
    }*/

    deleteSelectedRecord(rowId) {
        let selectedIds;
        if (rowId) { selectedIds = [rowId];} 
            else {selectedIds = this.getSelectedIds();}

        console.log("selectedIds : ", selectedIds)
        console.log("deleteSelectedRecord MyData", this.MyData)

        if (selectedIds.length === 0) {
            this.showToast('실패', '삭제할 레코드를 선택해주세요.', 'error');
            return;
        }
    
        this.requestConfirmation(`선택한 ${selectedIds.length}개의 항목을 삭제하시겠습니까?`, () => {
    
            const recordIdListString = JSON.stringify(selectedIds);
            console.log('list>>', recordIdListString);

            deleteRecord({ recordIdList: recordIdListString })
                .then(result => {
                    if (result.Result) {
                        this.showToast('성공', `${result.Count}개의 레코드가 삭제되었습니다.`, 'success');
                        this.refreshDataAfterDelete(selectedIds); // 삭제 후 화면 새로고침
                    } else {
                        this.showToast('실패', '레코드 삭제 중 오류가 발생했습니다.', 'error');
                        console.error('오류 세부 정보:', result.ErrorMessage);
                    }
                })
                .catch(error => {
                    this.handleError(error);
                })
        });
    }

    downloadExcel() {
        // UTF-8의 BOM을 추가합니다.
        let BOM = "\uFEFF";
        let csvContent = "data:text/csv;charset=utf-8," + BOM;
        
        // CSV 데이터를 생성합니다.
        this.MyData.forEach((row, index) => {
            // Level 1 데이터의 컬럼 헤더 추가 (첫 번째 행에만 추가)
            if(index === 0) {
                let headerStringLv1 = this.columns.map(col => col.label).join(',');
                csvContent += headerStringLv1 + "\r\n";
            }
            
            // Level 1 데이터 행 추가
            let rowStringLv1 = row.displayValues.map(cell => `"${cell.value != null ? cell.value : ''}"`).join(',');
            csvContent += rowStringLv1 + "\r\n";
    
            // Level 2 데이터 행이 존재하는 경우에만 처리
            if(row.level2Data && row.level2Data.length > 0) {
                // Level 2 데이터의 컬럼 헤더 추가 (각 Level 1 행 아래에 추가)
                let headerStringLv2 = ',' + this.level2Columns.map(col => col.label).join(',');
                csvContent += headerStringLv2 + "\r\n";
    
                // Level 2 데이터 행 추가
                row.level2Data.forEach(l2Row => {
                    let rowStringLv2 = ',' + this.level2Columns.map(col => {
                        let value = l2Row[col.fieldName];
                        // 여기서 undefined를 체크하여 빈 문자열로 대체합니다.
                        return `"${value !== undefined ? value : ''}"`;
                    }).join(',');
                    csvContent += rowStringLv2 + "\r\n";
                });
            }
            //Level 1과 Level 2 사이에 구분선을 추가합니다
            //csvContent += "\r\n"; // 빈 줄 추가
        });
        
        // CSV 데이터를 URI로 인코딩합니다.
        let encodedUri = encodeURI(csvContent);
        
        // 임시 링크 요소를 생성하고 다운로드를 트리거합니다.
        let link = document.createElement("a");
        link.setAttribute("href", encodedUri);
        link.setAttribute("download", "relatedListCustom.csv"); // 다운로드할 파일 이름
        document.body.appendChild(link); // 필수: Firefox에서의 호환성을 위해
        
        link.click(); // 링크 클릭
        document.body.removeChild(link); // 클릭 후 링크 제거
    }
    
    



    
    refreshData(record) {
        console.log(':::::::::::::::: refreshData start ::::::::::::::::');

        const foundIndex = this.MyData.findIndex(item => item.d === record.id);
        if (foundIndex !== -1) {
            // 기존 레코드를 업데이트합니다.
            this.MyData[foundIndex] = record;
            this.MyData = [...this.MyData];
        } else {
            // 새 레코드를 추가합니다.
            this.MyData = [...this.MyData, record];
        }
    }

    refreshDataAfterDelete(idsToDelete) {
        console.log(':::::::::::::::: refreshDataAfterDelete start ::::::::::::::::');
    
        this.MyData = this.MyData.filter(item => !idsToDelete.includes(item.Id));
        // 남은 데이터에 대해 인덱스 재할당
        this.MyData.forEach((item, index) => {
            item.index = index + 1;
        });
    }    
/*
    // 소유자 변경
    handleChangeOwner() {
        //매개 변수 확인
        changeOwner({ recordId: this.recordId, newOwnerId: this.newOwnerId })
            .then(result => {
                console.log('소유자 변경 성공 : ', result);
            })
            .catch(error => {
                this.handleError(error);
            });
    }
*/
    // (1Lv.Rows.오브젝트) 동적으로 가져오기
    updateChangedObjectApiName() {
        // 관련 객체 API 이름 변경
        if (this.relatedObjectApiName && this.relatedObjectApiName.endsWith('__c')) {
            this.changedObjectApiName = this.relatedObjectApiName.replace('__c', '__r');
        } else {
            this.changedObjectApiName = this.relatedObjectApiName;
        }
    }
    // 행 선택 로직
    handleRowSelection(event) {
        event.stopPropagation();

        if (event.target.name === "options") {
            const rowId = event.target.dataset.id;
    
            this.MyData = this.MyData.map(row => {
                if (row.Id === rowId) {
                    return { ...row, selected: !row.selected };
                }
                return row;
            });
        }
        console.log("handleRowSelection2", this.MyData)

    }

    // 전체 행 선택 로직
    handleSelectAllChange(event) {
        const selected = event.target.checked;
        this.MyData = this.MyData.map(row => ({ ...row, selected: selected }));
        console.log("handleSelectAllChange2", this.MyData)
    }

    requestConfirmation(message, callback) {
        if (confirm(message)) {
            callback();
        }
    }
    //테이블 항목 선택
    getSelectedIds() {
        return this.MyData.filter(row => row.selected).map(row => row.Id);
    }

    handleError(error) {
        let userMessage = '예기치 못한 문제가 발생했습니다. 관리자에게 문의하거나 다시 시도해 주세요.';
        console.error('Error:', error);
        this.showToast('오류', userMessage, 'error');
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable' // 사용자가 닫기 가능
        }));
    }

    handleTableAllData() {
        console.log("handleTableAllData click",this.isTableVisible )
        this.isTableVisible = !this.isTableVisible;
    }
    handleModal() {
        this.isModalOpen = !this.isModalOpen;
    }

    // getUrl(objectType, secondObApiName, id) {
    //     if (!objectType) { return ''; }
    //     if (id) {
    //         //name
    //         return `https://${this.currentOrgType}.lightning.force.com/lightning/r/${objectType}/${id}/view`;
    //     } else {
    //         return `https://${this.currentOrgType}.lightning.force.com/lightning/r/${objectType}/${id}/related/${secondObApiName}/view`;
    //     }
    // }

    getUrl(objectApiName, recordId, relatedObjectApiName) {
        if (relatedObjectApiName) {
            return `https://${this.currentOrgType}.lightning.force.com/lightning/r/${objectApiName}/${recordId}/related/${relatedObjectApiName}/view`;
        } else {
            return `https://${this.currentOrgType}.lightning.force.com/lightning/r/${objectApiName}/${recordId}/view`;
        }
    }
    

    // this.viewAllUrl = `https://${this.currentOrgType}.lightning.force.com/lightning/r/${this.objectApiName}/${this.recordId}/related/Employee__r/view`    
    get tableToggleIcon() {
        return this.isTableVisible ? 'utility:chevronup' : 'utility:chevrondown';
    }
    get isList() {
        return this.viewType === 'List';
    }
    get isTile() {
        return this.viewType === 'Tile';
    }
    get columnCount(){
        return this.columns.length - 1;
    }

    handleExpandTableData() {
        
    }
}