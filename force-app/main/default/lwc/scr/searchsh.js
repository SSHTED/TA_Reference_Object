export function toggleMoreFilter() {
    this.moreFilter = !this.moreFilter; 
    console.log("toggleMoreFilter : ", this.moreFilter);

}

export function resetValue(){
    this.moreFilter = false;
    this.isChecked = false;
    console.log("resetValue : ", this.moreFilter);
    console.log("isChecked : ", this.isChecked);

    this.template.querySelectorAll('lightning-input[type="checkbox"]').forEach(checkbox => {
        checkbox.checked = false;
    });
    
}