import { LightningElement, wire } from 'lwc';
import getInit from '@salesforce/apex/ContactUsRequest.getInit';

export default class ContactUsRequest extends LightningElement {
    error;
    categoryOptions = [];
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
