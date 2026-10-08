import { LightningElement, track } from 'lwc';

export default class Exercice3 extends LightningElement {
    @track totalSelections = 0;
  @track selectedChildren = [];
    // Triggered whenever a child component's button is clicked
    handleChildToggle(event) {
        const isChildSelected = event.detail.isSelected;
   const childLabel = event.detail.label;
        if (isChildSelected) {
            this.totalSelections += 1;
         if (!this.selectedChildren.includes(childLabel)) {
                this.selectedChildren.push(childLabel);
         }
        }
        
        else {
            this.totalSelections -= 1;
             this.selectedChildren = this.selectedChildren.filter(label => label !== childLabel);
        }
    }

    // Triggered by the "Reset All" button
    handleResetAll() {
        this.totalSelections = 0;
        this.selectedChildren=[];

        // Find all child components using querySelectorAll
        const children = this.template.querySelectorAll('c-exercice3child');
        
        if (children) {
            children.forEach(child => {
                child.resetChild();
            });
        }
   
 }
  get selectedChildrenList() {
        return this.selectedChildren.length > 0 
            ? this.selectedChildren.join(', ') 
            : 'None';
}
}
