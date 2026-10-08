import { LightningElement, api, track } from 'lwc';

export default class Exercice3child extends LightningElement {
    @api componentLabel = 'Child Component';
    @track isSelected = false;

    @api
    resetChild() {
        this.isSelected = false;
    }

    get status() {
        return this.isSelected ? 'Selected' : 'Deselected';
    }

    get buttonLabel() {
        return this.isSelected ? 'Deselect' : 'Select';
    }

    get buttonVariant() {
        return this.isSelected ? 'destructive' : 'brand';
    }

    handleToggle() {
        this.isSelected = !this.isSelected;

        // Custom event that bubbles up to the parent component
        const toggleEvent = new CustomEvent('childtoggle', {
            bubbles: true,
            composed: true,
             detail: { 
            isSelected: this.isSelected,
            label: this.componentLabel 
        }
        });
        this.dispatchEvent(toggleEvent);
    }
}
