export function toggleMoreFilter() {
    this.moreFilter = !this.moreFilter; 
    console.log("toggleMoreFilter : ", this.moreFilter);

}

export function resetValue(){
    //필터 더보기
    this.moreFilter = false;
    console.log("moreFilter : ", this.moreFilter);

    //체크박스
    const checkboxes = this.template.querySelectorAll('.selectedCheckbox');
    checkboxes.forEach(checkbox => {
        checkbox.checked = false;
        console.log("checkbox : ", checkbox.checked);
    });
    //인풋박스
    const inputboxes = this.template.querySelectorAll('.inputValue');
    inputboxes.forEach(inputbox => {
        inputbox.value = '';
        console.log("inputbox : ", inputbox.value);

    });


}