import { LightningElement } from 'lwc';

export default class Exercice2 extends LightningElement {
    parentCounterValue = 0;

    handleParentClick() {
        // Increment the value right here in the parent
        this.parentCounterValue++;
    }
}