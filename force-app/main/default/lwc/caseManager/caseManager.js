import { LightningElement,wire,track } from 'lwc';
import getCases from '@salesforce/apex/CaseController.getCases';
import createCaseRecord from '@salesforce/apex/CaseController.createCaseRecord';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import CASE_OBJECT from '@salesforce/schema/Case';
import STATUS_FIELD from '@salesforce/schema/Case.Status';

// Define the datatable columns
const COLUMNS = [
    { label: 'Case Number', fieldName: 'CaseNumber', type: 'text' },
    { label: 'Subject', fieldName: 'Subject', type: 'text' },
    { label: 'Description', fieldName: 'Description', type: 'text' },
    { label: 'Status', fieldName: 'Status', type: 'text' }
];
export default class CaseManager extends LightningElement {
    searchKey='';
    statusFilter='ALL';
    dynamicStatusOptions=[];
    columns = COLUMNS;
    cases=[];
    wiredCasesResult;
    newSubject='';
    newDescription='';
    @wire(getObjectInfo, { objectApiName: CASE_OBJECT })
    caseObjectInfo;

    // ONLY ADDED: Wire to dynamically fetch live Case Status picklist values
    @wire(getPicklistValues, { 
        recordTypeId: '012000000000000AAA', 
        fieldApiName: STATUS_FIELD 
    })
    wiredPicklistValues({ error, data }) {
        if (data) {
            let options = [{ label: '-- All Statuses --', value: 'All' }];
            data.values.forEach(element => {
                options.push({ label: element.label, value: element.value });
            });
            this.dynamicStatusOptions = options;
        } else if (error) {
            this.showToast('Error', 'Failed to fetch picklist metadata', 'error');
        }
    }
   
    @wire(getCases,{searchNumber: '$searchKey',statusFilter:'$statusFilter'})
    wiredCases(result){
        this.wiredCasesResult=result;
        if(result.data){
            this.cases=result.data;
        }else if(result.error){
            this.showToast('Error','Failed to fetch cases','error');
        }
    }
handleSearchChange(event){
    this.searchKey=event.target.value;
     
 
}
handleStatusChange(event) {
    this.statusFilter = event.target.value;
}
handleFormChange(event){
    const field =event.target.dataset.id;
if (field==='subject'){
    this.newSubject = event.target.value;
}
else if ( field==='description'){
    this.newDescription = event.target.value;
}
}
 handleCreateCase() {
        if (!this.newSubject) {
            this.showToast('Warning', 'Subject is required', 'warning');
            return;
        }
createCaseRecord({ subject: this.newSubject, description: this.newDescription })
            .then(() => {
                this.showToast('Success', 'Case created successfully!', 'success');
                
                // Clear the form fields
                this.newSubject = '';
                this.newDescription = '';
                
                // Refresh the wire to display the new case in the datatable
                return refreshApex(this.wiredCasesResult);
            })
          .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    } 
     showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
} 
