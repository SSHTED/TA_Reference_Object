import { LightningElement } from 'lwc';

export default class ContactUsRequest extends LightningElement {
    options = [
        { label: 'Option 1', value: 'option1' },
        { label: 'Option 2', value: 'option2' },
        // ... other options ...
    ];

    items = [
        {
            type: 'avatar',
            href: 'https://www.salesforce.com',
            label: 'Avatar Pill 1',
            src: 'https://www.lightningdesignsystem.com/assets/images/avatar1.jpg',
            fallbackIconName: 'standard:user',
            variant: 'circle',
            alternativeText: 'User avatar',
            isLink: true,
        },
        {
            type: 'avatar',
            href: '',
            label: 'Avatar Pill 2',
            src: 'https://www.lightningdesignsystem.com/assets/images/avatar2.jpg',
            fallbackIconName: 'standard:user',
            variant: 'circle',
            alternativeText: 'User avatar',
        },
        {
            type: 'avatar',
            href: 'https://www.google.com',
            label: 'Avatar Pill 3',
            src: 'https://www.lightningdesignsystem.com/assets/images/avatar3.jpg',
            fallbackIconName: 'standard:user',
            variant: 'circle',
            alternativeText: 'User avatar',
            isLink: true,
        },
    ];

    
}
