export function toggleMoreFilter() {
    this.moreFilter = !this.moreFilter; 
    console.log("toggleMoreFilter : ", this.moreFilter);

}

export function resetValue(){
    //필터 더보기
    this.moreFilter = false;
    //체크박스
    const checkboxes = this.template.querySelectorAll('.selectedCheckbox');
    checkboxes.forEach(checkbox => {
        checkbox.checked = false;
    });

    console.log("moreFilter : ", this.moreFilter);
    console.log("checkboxes : ", this.checkboxes);


}