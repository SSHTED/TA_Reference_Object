import { LightningElement, wire, api } from 'lwc';
import getInit from '@salesforce/apex/ContactUsRequest.getInit';

export default class ContactUsRequest extends LightningElement {
    error;
    @api myRecordId;
    categoryOptions = [];
    fileItems = [];
    selectedCategoryOpt = '';

    @wire(getInit)
    wiredInit({error, data}){
        if(data){
            console.log(':::::::::::::::: wiredInit data start ::::::::::::::::');

            this.categoryOptions = data.result.categoryListVal.map(val => {
                return {label : val, value : val};
            });
            console.log('data ::::::::::: ', data);

            this.error = undefined;
        }else if(error){
            console.error('wiredInit 에러 :', error);

            this.error = error;
            this.categoryOptions = undefined;
        }
    }
    
    handleCategoryChange(event){
        console.log(':::::::::::::::: handleCategoryChange start ::::::::::::::::');
        this.selectedCategoryOpt = event.target.value;
        console.log("selectedCategoryOpt ::::::::::: ", this.selectedCategoryOpt)
    }

    // 파일 업로드
    get acceptedFormats() {
        return ['.png', '.xlsx', '.txt', '.pptx', '.7z', '.zip'];
    }

    getIconName(fileExtension) {
        console.log(':::::::::::::::: getIconName start ::::::::::::::::');

        const iconMap = {
            'png': 'doctype:image',
            'xlsx': 'doctype:excel',
            'txt': 'doctype:txt',
            'pptx': 'doctype:ppt',
            '7z': 'doctype:zip',
            'zip': 'doctype:zip'
        };
        return iconMap[fileExtension] || 'doctype:attachment';
    }

    handleUploadFinished(event) {
        console.log(':::::::::::::::: handleUploadFinished start ::::::::::::::::');

        const uploadedFiles = event.detail.files;
        uploadedFiles.forEach(uploadedFile =>{
            const fileExtension = uploadedFile.name.split('.').pop();

            this.fileItems = [...this.fileItems, { 
                name: uploadedFile.name, 
                Id: uploadedFile.Id,
                iconName: this.getIconName(fileExtension)
            }];
        });
        console.log('uploadedFiles ::::::::::: ', uploadedFiles);
        console.log('fileItems ::::::::::: ', JSON.stringify(this.fileItems));
        console.log('Icon Name:', this.fileItems[0].iconName);
    }

    handleUploadRemove(event) {
        console.log(':::::::::::::::: handleUploadRemove start ::::::::::::::::');
        const removedFileIndex = event.target.name;
        this.fileItems = this.fileItems.filter((file, index) => index !== parseInt(removedFileIndex, 10));

    }


    handleSaveClick(){
    }



    // items = [
    //     {
    //         type: 'avatar',
    //         href: 'https://www.salesforce.com',
    //         label: 'Avatar Pill 1',
    //         src: 'https://www.lightningdesignsystem.com/assets/images/avatar1.jpg',
    //         fallbackIconName: 'standard:user',
    //         variant: 'circle',
    //         alternativeText: 'User avatar',
    //         isLink: true,
    //     },
    //     {
    //         type: 'avatar',
    //         href: '',
    //         label: 'Avatar Pill 2',
    //         src: 'https://www.lightningdesignsystem.com/assets/images/avatar2.jpg',
    //         fallbackIconName: 'standard:user',
    //         variant: 'circle',
    //         alternativeText: 'User avatar',
    //     },
    //     {
    //         type: 'avatar',
    //         href: 'https://www.google.com',
    //         label: 'Avatar Pill 3',
    //         src: 'https://www.lightningdesignsystem.com/assets/images/avatar3.jpg',
    //         fallbackIconName: 'standard:user',
    //         variant: 'circle',
    //         alternativeText: 'User avatar',
    //         isLink: true,
    //     },
    // ];


}
